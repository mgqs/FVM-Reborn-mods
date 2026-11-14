// Generic archive installation jobs. No GameMaker API is called on a worker.
#ifdef _WIN32
#define NOMINMAX
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#else
#include <stdio.h>
#endif

#include "archive_extractor.h"
#include "Typedef.h"
#include "json.hpp"
#include <algorithm>
#include <array>
#include <atomic>
#include <condition_variable>
#include <chrono>
#include <unordered_set>
#include <cmath>
#include <cstring>
#include <fstream>
#include <memory>
#include <mutex>
#include <thread>
#include <unordered_map>

namespace {
namespace fs = std::filesystem;
using Json = nlohmann::json;
#ifdef _WIN32
std::wstring NativePath(const fs::path& path) {
  const auto value = path.native();
  if (value.rfind(L"\\\\?\\", 0) == 0) return value;
  if (value.rfind(L"\\\\", 0) == 0) return L"\\\\?\\UNC\\" + value.substr(2);
  return L"\\\\?\\" + value;
}
#endif
enum class Phase { Extracting, Ready, Publishing, Done, Cleaning, Cancelled, Failed };
enum class Action { Wait, Publish };
enum class Mode { Archive, State, Delete };

fs::path Path(const char* text) {
  std::string value = text ? text : "";
  std::replace(value.begin(), value.end(), '\\', '/');
  return fs::u8path(value);
}

std::string Utf8(const fs::path& path) {
  const auto value = path.generic_u8string();
  return std::string(value.begin(), value.end());
}

std::string Key(const fs::path& path) {
  auto value = Utf8(path.lexically_normal());
#ifdef _WIN32
  // Usual Windows paths compare case-insensitively. Unmatched Unicode aliases
  // still have a checked disk fallback below.
  for (auto& ch : value) if (ch >= 'A' && ch <= 'Z') ch += 'a' - 'A';
#endif
  return value;
}

struct PngHeader {
  std::array<unsigned char, 33> bytes{};
  std::uint64_t filled = 0;
  std::uint64_t size = 0;
  void Add(std::uint64_t offset, const void* data, std::size_t length) {
    size = std::max(size, offset + length);
    if (offset >= bytes.size()) return;
    auto count = std::min<std::size_t>(length, bytes.size() - static_cast<std::size_t>(offset));
    std::memcpy(bytes.data() + offset, data, count);
    for (std::size_t i = 0; i < count; ++i) filled |= std::uint64_t{1} << (offset + i);
  }
  bool Matches(std::uint32_t width, std::uint32_t height) const {
    static const unsigned char signature[] = {137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82};
    if (size < 33 || filled != ((std::uint64_t{1} << 33) - 1) ||
        std::memcmp(bytes.data(), signature, sizeof(signature)) != 0) return false;
    auto Read = [&](int start) {
      std::uint32_t result = 0;
      for (int i = 0; i < 4; ++i) result = result * 256 + bytes[start + i];
      return result;
    };
    return Read(16) == width && Read(20) == height;
  }
};

bool IsPng(const fs::path& path) {
  auto ext = Utf8(path.extension());
  for (auto& ch : ext) if (ch >= 'A' && ch <= 'Z') ch += 'a' - 'A';
  return ext == ".png";
}

bool Link(const fs::path& path) {
#ifdef _WIN32
  const auto attributes = GetFileAttributesW(NativePath(path).c_str());
  if (attributes != INVALID_FILE_ATTRIBUTES && (attributes & FILE_ATTRIBUTE_REPARSE_POINT)) return true;
#endif
  return fs::is_symlink(fs::symlink_status(path));
}

bool FolderName(const std::string& value) {
  return !value.empty() && value != "." && value != ".." && value.find_first_of("/\\:") == std::string::npos;
}

void CheckState(const Json& entries) {
  if (!entries.is_array()) throw std::runtime_error("Mod state must be an array");
  std::unordered_set<std::string> names;
  for (const auto& entry : entries) {
    if (!entry.is_object() || !entry.contains("folder") || !entry["folder"].is_string() ||
        !entry.contains("enabled") || !entry["enabled"].is_boolean()) throw std::runtime_error("Invalid Mod state entry");
    const auto name = entry["folder"].get<std::string>();
    if (!FolderName(name) || !names.insert(name).second) throw std::runtime_error("Invalid or duplicate Mod folder");
  }
}

std::string ReadText(const fs::path& path) {
  std::ifstream input(path, std::ios::binary);
  if (!input) throw std::runtime_error("Cannot read Mod state");
  return std::string(std::istreambuf_iterator<char>(input), {});
}

// Same temporary-file, good-backup and read-back contract as the GML writer.
// All reads, writes and renames below run on a worker.
void SaveState(const fs::path& path, const Json& entries) {
  CheckState(entries);
  const auto raw = entries.dump(-1, ' ', false, Json::error_handler_t::replace);
  const auto temporary = fs::path(path.native() + fs::path(".tmp").native());
  const auto backup = fs::path(path.native() + fs::path(".bak").native());
  try {
    {
      std::ofstream output(temporary, std::ios::binary | std::ios::trunc);
      if (!output) throw std::runtime_error("Cannot write Mod state");
      output.write(raw.data(), raw.size()); output.flush();
      if (!output) throw std::runtime_error("Incomplete Mod state write");
    }
    if (ReadText(temporary) != raw) throw std::runtime_error("Incomplete Mod state write");
    if (fs::exists(path)) {
      bool good = false;
      try { CheckState(Json::parse(ReadText(path))); good = true; } catch (...) {}
      if (good) { if (fs::exists(backup)) fs::remove(backup); fs::rename(path, backup); }
      else fs::remove(path);
    }
    fs::rename(temporary, path);
    if (ReadText(path) != raw) throw std::runtime_error("Cannot replace Mod state");
  } catch (...) {
    std::error_code ignored;
    fs::remove(temporary, ignored);
    if (!fs::exists(path, ignored) && fs::exists(backup, ignored))
      fs::copy_file(backup, path, fs::copy_options::overwrite_existing, ignored);
    throw;
  }
}

void MoveNew(const fs::path& source, const fs::path& target) {
#ifdef _WIN32
  if (!MoveFileW(NativePath(source).c_str(), NativePath(target).c_str()))
    throw fs::filesystem_error("Cannot move Mod folder", source, target,
                               std::error_code(GetLastError(), std::system_category()));
#elif defined(__APPLE__)
  if (renamex_np(source.c_str(), target.c_str(), RENAME_EXCL) != 0)
    throw fs::filesystem_error("Cannot move Mod folder", source, target,
                               std::error_code(errno, std::generic_category()));
#else
  if (fs::exists(target)) throw std::runtime_error("Mod destination already exists");
  fs::rename(source, target);
#endif
}

struct Job {
  Mode mode = Mode::Archive;
  fs::path root, target, state_path;
  Json entries;
  std::atomic<bool> committed{false};
  std::atomic<Phase> phase{Phase::Extracting};
  std::atomic<bool> cancel{false};
  std::atomic<std::uint64_t> files{0}, bytes{0}, total_files{0}, total_bytes{0};
  std::atomic<std::uint64_t> cache_hits{0}, disk_reads{0};
  std::mutex mutex;
  std::condition_variable wake;
  Action action = Action::Wait;
  int error = 0;
  std::string message;
  std::unordered_map<std::string, PngHeader> pngs;
  std::thread worker;
  ~Job() { if (worker.joinable()) worker.join(); }

  void Run(const fs::path& source) {
    try {
      ArchiveProgress progress;
      progress.cancelled = [&] { return cancel.load(); };
      progress.total = [&](std::uint64_t count, std::uint64_t length) {
        if (count) total_files = count;
        if (length) total_bytes = length;
      };
      progress.begin = [&](const fs::path& name, bool directory) {
        if (!directory && IsPng(name)) pngs[Key(name)] = PngHeader{};
      };
      progress.data = [&](const fs::path& name, std::uint64_t offset,
                          const void* buffer, std::size_t size) {
        bytes.fetch_add(size);
        if (IsPng(name)) pngs[Key(name)].Add(offset, buffer, size);
      };
      progress.end = [&](const fs::path&) { files.fetch_add(1); };
      ExtractArchiveWithProgress(source, root, &progress);
      if (!total_files.load()) total_files = files.load();
      if (!total_bytes.load()) total_bytes = bytes.load();
      std::unique_lock<std::mutex> lock(mutex);
      phase = Phase::Ready;
      wake.wait(lock, [&] { return cancel.load() || action != Action::Wait; });
      if (!cancel.load()) {
        phase = Phase::Publishing;
        const auto destination = target;
        lock.unlock();
        // Publication must not overwrite an installed package, even if another
        // process creates that directory after the UI picked its name.
#ifdef _WIN32
        if (!MoveFileW(NativePath(root).c_str(), NativePath(destination).c_str()))
          throw fs::filesystem_error("Cannot publish archive", root, destination,
                                     std::error_code(GetLastError(), std::system_category()));
#elif defined(__APPLE__)
        if (renamex_np(root.c_str(), destination.c_str(), RENAME_EXCL) != 0)
          throw fs::filesystem_error("Cannot publish archive", root, destination,
                                     std::error_code(errno, std::generic_category()));
#else
        if (fs::exists(destination)) throw std::runtime_error("Archive destination already exists");
        fs::rename(root, destination);
#endif
        phase = Phase::Done;
        return;
      }
    } catch (const ArchiveException& e) {
      error = e.code(); message = e.what();
    } catch (const std::exception& e) {
      error = NativeError::ExtractFailed; message = e.what();
    }
    phase = Phase::Cleaning;
    std::error_code ignored;
    fs::remove_all(root, ignored);
    if (ignored) {
      error = NativeError::ExtractFailed;
      message += " Cleanup failed: " + ignored.message();
      phase = Phase::Failed;
    } else phase = cancel.load() ? Phase::Cancelled : Phase::Failed;
  }

  void Remove(const fs::path& path) {
    std::vector<std::pair<fs::path, bool>> pending{{path, false}};
    while (!pending.empty()) {
      auto item = pending.back(); pending.pop_back();
      if (!item.second && !Link(item.first) && fs::is_directory(item.first)) {
        pending.push_back({item.first, true});
        for (const auto& child : fs::directory_iterator(item.first)) pending.push_back({child.path(), false});
      } else { fs::remove(item.first); files.fetch_add(1); }
    }
    total_files = files.load();
  }

  void RunManagement() {
    try {
      if (mode == Mode::State) {
        SaveState(state_path, entries); committed = true;
      } else {
        // Only a direct installed folder may be retired; never follow a link
        // into another save or package. The trash directory is outside enumeration.
        if (!fs::is_directory(root) || Link(root) ||
            fs::canonical(root).parent_path() != fs::canonical(state_path.parent_path()))
          throw std::runtime_error("Invalid installed Mod directory");
        auto trash = state_path.parent_path().parent_path() / ".mod-trash";
        fs::create_directories(trash);
        if (Link(trash)) throw std::runtime_error("Mod trash directory is a link");
        fs::path retired;
        for (unsigned int attempt = 0;; ++attempt) {
          retired = trash / ("job_" + std::to_string(std::chrono::steady_clock::now().time_since_epoch().count()) + "_" + std::to_string(attempt));
          if (fs::create_directory(retired)) break;
        }
        auto payload = retired / "payload";
        Json previous = entries;
        if (fs::exists(state_path)) {
          try { auto candidate = Json::parse(ReadText(state_path)); CheckState(candidate); previous = candidate; } catch (...) {}
        }
        // The removed folder stays explicitly disabled in the durable state.
        // A crash before the rename must not make an absent state entry enable it.
        try {
          SaveState(state_path, entries);
          MoveNew(root, payload);
        } catch (...) {
          auto failure = std::current_exception();
          SaveState(state_path, previous);
          std::error_code ignored; fs::remove(retired, ignored);
          std::rethrow_exception(failure);
        }
        committed = true;
        Remove(retired);
      }
      phase = Phase::Done;
    } catch (const ArchiveException& e) {
      error = e.code(); message = e.what();
      phase = cancel.load() ? Phase::Cancelled : Phase::Failed;
    } catch (const std::exception& e) {
      error = NativeError::UnknownFailure; message = e.what();
      phase = cancel.load() ? Phase::Cancelled : Phase::Failed;
    }
    // State jobs never own the installed directory: no failure or
    // cancellation path may call remove_all(root).
  }

};

struct Registry {
  std::mutex mutex;
  std::unordered_map<int, std::shared_ptr<Job>> jobs;
  int next = 1;
};

// Explicit shutdown occurs in Game End before the extension is unloaded. Avoid
// joining workers from the Windows DLL loader-lock destructor.
Registry& Jobs() { static auto* registry = new Registry; return *registry; }

std::shared_ptr<Job> Find(double handle) {
  if (!std::isfinite(handle) || handle < 1 || handle > 2147483647 || handle != static_cast<int>(handle)) return {};
  auto& registry = Jobs();
  std::lock_guard<std::mutex> lock(registry.mutex);
  const auto found = registry.jobs.find(static_cast<int>(handle));
  return found == registry.jobs.end() ? nullptr : found->second;
}

const char* Reply(const Json& data) {
  thread_local std::string text;
  text = data.dump(-1, ' ', false, Json::error_handler_t::replace);
  return text.c_str();
}

const char* Name(Phase phase) {
  switch (phase) {
    case Phase::Extracting: return "extracting";
    case Phase::Ready: return "ready";
    case Phase::Publishing: return "publishing";
    case Phase::Done: return "done";
    case Phase::Cleaning: return "cleaning";
    case Phase::Cancelled: return "cancelled";
    default: return "failed";
  }
}

bool Terminal(Phase phase) {
  return phase == Phase::Done || phase == Phase::Cancelled || phase == Phase::Failed;
}
} // namespace

GmlCallable double ArchiveJobStart(const char* archive, const char* staging) {
  if (!archive || !*archive || !staging || !*staging) return NativeError::InvalidArgument;
  try {
    const auto source = fs::absolute(Path(archive));
    if (!fs::is_regular_file(source)) return NativeError::OpenFailed;
    auto root = fs::absolute(Path(staging)).lexically_normal();
    if (root.filename().empty() || root.filename() == "." || root.filename() == "..") return NativeError::InvalidArgument;
    auto& registry = Jobs();
    std::lock_guard<std::mutex> lock(registry.mutex);
    if (registry.jobs.size() >= 4 || registry.next == 2147483647) return NativeError::UnknownFailure;
    fs::create_directories(root.parent_path());
    if (!fs::create_directory(root)) return NativeError::FileCreateFailed;
    auto job = std::make_shared<Job>();
    job->root = fs::canonical(root);
    const int handle = registry.next++;
    registry.jobs.emplace(handle, job);
    try { job->worker = std::thread([job, source] { job->Run(source); }); }
    catch (...) { registry.jobs.erase(handle); fs::remove_all(job->root); throw; }
    return handle;
  } catch (...) { return NativeError::FileCreateFailed; }
}

GmlCallable const char* ArchiveJobPoll(double handle) {
  auto job = Find(handle);
  if (!job) return Reply({{"state", "missing"}, {"error", NativeError::InvalidArgument}});
  const auto phase = job->phase.load();
  Json result = {{"state", Name(phase)}, {"root", Utf8(job->root)},
    {"files", job->files.load()}, {"bytes", job->bytes.load()},
    {"total_files", job->total_files.load()}, {"total_bytes", job->total_bytes.load()},
    {"cache_hits", job->cache_hits.load()}, {"disk_reads", job->disk_reads.load()},
    {"committed", job->committed.load()}};
  // Error text is immutable once the release/acquire terminal state is visible.
  if (Terminal(phase)) { result["error"] = job->error; result["message"] = job->message; }
  return Reply(result);
}

GmlCallable const char* ArchiveJobCheckPng(double handle, const char* payload) {
  auto job = Find(handle);
  if (!job || job->phase.load() != Phase::Ready || job->cancel.load())
    return Reply({{"ok", false}, {"error", "Archive is not ready for validation"}});
  try {
    const auto request = Json::parse(payload ? payload : "");
    const auto& paths = request.at("paths");
    if (!paths.is_array() || paths.size() > 128) throw std::runtime_error("Invalid PNG batch");
    const auto width = request.at("width").get<std::uint32_t>();
    const auto height = request.at("height").get<std::uint32_t>();
    for (const auto& name : paths) {
      auto absolute = Path(name.get_ref<const std::string&>().c_str());
      if (!absolute.is_absolute()) absolute = job->root / absolute;
      const auto relative = absolute.lexically_normal().lexically_relative(job->root);
      if (relative.empty() || relative.is_absolute()) throw std::runtime_error("PNG path escaped archive");
      for (const auto& part : relative) if (part == "..") throw std::runtime_error("PNG path escaped archive");
      if (!IsPng(relative)) throw std::runtime_error("PNG extension required");
      auto found = job->pngs.find(Key(relative));
      PngHeader disk;
      const PngHeader* header = nullptr;
      if (found != job->pngs.end()) { header = &found->second; job->cache_hits.fetch_add(1); }
      else {
        // Preserve OS filename alias compatibility without weakening path checks.
        auto parent = job->root;
        for (const auto& part : relative) {
          parent /= part;
          std::error_code ec;
          if (!ec && Link(parent)) throw std::runtime_error("PNG path contains a symlink");
        }
        std::ifstream input(job->root / relative, std::ios::binary);
        std::array<char, 33> prefix{};
        input.read(prefix.data(), prefix.size());
        disk.Add(0, prefix.data(), static_cast<std::size_t>(input.gcount()));
        job->disk_reads.fetch_add(1); header = &disk;
      }
      if (!header->Matches(width, height))
        return Reply({{"ok", false}, {"path", name}, {"error", "PNG header or dimensions mismatch"}});
    }
    return Reply({{"ok", true}, {"checked", paths.size()}});
  } catch (const std::exception& e) { return Reply({{"ok", false}, {"error", e.what()}}); }
}

GmlCallable double ArchiveJobPublish(double handle, const char* target) {
  auto job = Find(handle);
  if (!job || job->mode != Mode::Archive || !target || !*target) return NativeError::InvalidArgument;
  std::lock_guard<std::mutex> lock(job->mutex);
  if (job->phase.load() != Phase::Ready || job->cancel.load() || job->action != Action::Wait)
    return NativeError::InvalidArgument;
  try { job->target = fs::absolute(Path(target)).lexically_normal(); }
  catch (...) { return NativeError::InvalidArgument; }
  job->action = Action::Publish;
  job->wake.notify_all();
  return 0;
}

GmlCallable double ArchiveJobCancel(double handle) {
  auto job = Find(handle);
  if (!job) return NativeError::InvalidArgument;
  std::lock_guard<std::mutex> lock(job->mutex);
  if (!Terminal(job->phase.load()) && job->phase.load() != Phase::Publishing) {
    job->cancel = true; job->wake.notify_all();
  }
  return 0;
}

GmlCallable double ArchiveJobRelease(double handle) {
  if (!Find(handle)) return NativeError::InvalidArgument;
  auto& registry = Jobs();
  std::shared_ptr<Job> job;
  {
    std::lock_guard<std::mutex> lock(registry.mutex);
    auto found = registry.jobs.find(static_cast<int>(handle));
    if (found == registry.jobs.end() || !Terminal(found->second->phase.load())) return NativeError::InvalidArgument;
    job = found->second; registry.jobs.erase(found);
  }
  if (job->worker.joinable()) job->worker.join();
  return 0;
}

GmlCallable double ArchiveJobShutdown() {
  auto& registry = Jobs();
  std::vector<std::shared_ptr<Job>> active;
  {
    std::lock_guard<std::mutex> lock(registry.mutex);
    for (const auto& entry : registry.jobs) active.push_back(entry.second);
  }
  for (auto& job : active) {
    std::lock_guard<std::mutex> lock(job->mutex);
    if (!Terminal(job->phase.load()) && job->phase.load() != Phase::Publishing) job->cancel = true;
    job->wake.notify_all();
  }
  for (auto& job : active) if (job->worker.joinable()) job->worker.join();
  return 0;
}


GmlCallable double ModJobStart(const char* payload) {
  try {
    auto request = Json::parse(payload ? payload : "");
    auto job = std::make_shared<Job>();
    const auto operation = request.at("operation").get<std::string>();
    if (operation == "state") job->mode = Mode::State;
    else if (operation == "delete") job->mode = Mode::Delete;
    else return NativeError::InvalidArgument;
    {
      job->state_path = fs::absolute(Path(request.at("state_path").get_ref<const std::string&>().c_str())).lexically_normal();
      job->entries = request.at("entries"); CheckState(job->entries);
      job->phase = Phase::Publishing;
    }
    if (job->mode == Mode::State) job->root = job->state_path.parent_path();
    else {
      job->root = fs::absolute(Path(request.at("root").get_ref<const std::string&>().c_str())).lexically_normal();
      bool disabled = false;
      for (const auto& entry : job->entries)
        if (entry["folder"] == Utf8(job->root.filename()) && !entry["enabled"].get<bool>()) disabled = true;
      if (!disabled) return NativeError::InvalidArgument;
    }
    auto& registry = Jobs();
    std::lock_guard<std::mutex> lock(registry.mutex);
    if (registry.jobs.size() >= 4 || registry.next == 2147483647) return NativeError::UnknownFailure;
    const int handle = registry.next++;
    registry.jobs.emplace(handle, job);
    try { job->worker = std::thread([job] { job->RunManagement(); }); }
    catch (...) { registry.jobs.erase(handle); throw; }
    return handle;
  } catch (...) { return NativeError::InvalidArgument; }
}
