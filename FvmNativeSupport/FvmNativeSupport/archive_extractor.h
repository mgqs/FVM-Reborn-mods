#pragma once

#include <filesystem>
#include <cstdint>
#include <functional>
#include <stdexcept>
#include <string>

namespace ArchiveErr {
constexpr int Ok = 0;
constexpr int DllLoadFailed = -10;
constexpr int InvalidArchive = -11;
constexpr int ExtractFailed = -12;
constexpr int PathTraversal = -13;
constexpr int PasswordRequired = -14;
constexpr int UnsupportedFormat = -15;
constexpr int OpenFailed = -16;
constexpr int FileCreateFailed = -17;
}  // namespace ArchiveErr

class ArchiveException : public std::runtime_error {
 public:
  ArchiveException(int code, const std::string& message)
      : std::runtime_error(message), code_(code) {}

  int code() const { return code_; }

 private:
  int code_;
};

struct ArchiveProgress;

class ArchiveExtractor {
 public:
  explicit ArchiveExtractor(std::filesystem::path seven_zip_dll);

  void extract(const std::filesystem::path& archive,
               const std::filesystem::path& output_directory,
               ArchiveProgress* progress = nullptr);

  static auto FindSevenZipDll() -> std::filesystem::path;

 private:
  std::filesystem::path dll_path_;
};

// Callbacks run on the extraction worker, never on the GameMaker thread.
struct ArchiveProgress {
  std::function<bool()> cancelled;
  std::function<void(std::uint64_t, std::uint64_t)> total;
  std::function<void(const std::filesystem::path&, bool)> begin;
  std::function<void(const std::filesystem::path&, std::uint64_t,
                     const void*, std::size_t)> data;
  std::function<void(const std::filesystem::path&)> end;
};

void ExtractArchiveWithProgress(const std::filesystem::path& archive,
                                const std::filesystem::path& output,
                                ArchiveProgress* progress);
