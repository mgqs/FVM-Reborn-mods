// macOS implementation of the same C ABI exported by FvmNativeSupport.dll.
#import <AppKit/AppKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

#include "../third_party/libarchive-3.3.3/archive.h"
#include "../third_party/libarchive-3.3.3/archive_entry.h"
#include <algorithm>
#include <cerrno>
#include <filesystem>
#include <fstream>
#include <memory>
#include <sstream>
#include <string>

#include "../FvmNativeSupport/Typedef.h"
#include "../FvmNativeSupport/archive_extractor.h"
#include "../FvmNativeSupport/json.hpp"

namespace {
namespace fs = std::filesystem;
using Json = nlohmann::json;

fs::path Path(const char* value) {
    std::string text = value ? value : "";
    std::replace(text.begin(), text.end(), '\\', '/');
    return fs::u8path(text);
}

double Fail(int code, const char* message) {
    if (!NativeLogFilePath().empty()) {
        std::error_code ec;
        const auto path = Path(NativeLogFilePath().c_str());
        fs::create_directories(path.parent_path(), ec);
        std::ofstream out(path, std::ios::app);
        out << "[error_code=" << code << "] " << message << '\n';
    }
    return code;
}

template<class F> double Guard(F action) {
    try {
        return action();
    } catch (const ArchiveException& e) {
        return Fail(e.code(), e.what());
    } catch (const fs::filesystem_error& e) {
        return Fail(e.code().value(), e.what());
    } catch (const Json::exception& e) {
        return Fail(NativeError::JsonParseFailed, e.what());
    } catch (const std::exception& e) {
        return Fail(NativeError::UnknownFailure, e.what());
    }
}

// GameMaker normally invokes extensions on the main thread. Keep AppKit on that
// thread also when a caller invokes the ABI from another thread.
void OnMainThread(void (^action)(void)) {
    if ([NSThread isMainThread]) action();
    else dispatch_sync(dispatch_get_main_queue(), action);
}

std::string ChooseBackup(bool folder, const char* initial = nullptr) {
    __block std::string chosen;
    OnMainThread(^{
        @autoreleasepool {
            NSOpenPanel* panel = [NSOpenPanel openPanel];
            panel.canChooseDirectories = folder;
            panel.canChooseFiles = !folder;
            panel.canCreateDirectories = folder;
            panel.allowsMultipleSelection = NO;
            panel.title = folder ? @"选择备份目录" : @"选择存档备份";
            if (!folder) panel.allowedContentTypes = @[UTTypeJSON];
            if (initial && *initial) {
                panel.directoryURL = [NSURL fileURLWithPath:
                    [NSString stringWithUTF8String:initial] isDirectory:YES];
            }
            if ([panel runModal] == NSModalResponseOK) {
                chosen = panel.URL.path.UTF8String;
            }
        }
    });
    return chosen;
}

void ArchiveFailure(archive* reader, int fallback) {
    const char* message = archive_error_string(reader);
    const int code = archive_read_has_encrypted_entries(reader) > 0
        ? ArchiveErr::PasswordRequired : fallback;
    throw ArchiveException(code, message ? message : "Archive operation failed");
}

void Extract(const fs::path& source, const fs::path& output, ArchiveProgress* progress = nullptr) {
    std::unique_ptr<archive, decltype(&archive_read_free)>
        reader(archive_read_new(), archive_read_free);
    std::unique_ptr<archive, decltype(&archive_write_free)>
        writer(archive_write_disk_new(), archive_write_free);
    if (!reader || !writer) throw std::bad_alloc();
    archive_read_support_filter_all(reader.get());
    archive_read_support_format_all(reader.get());
    if (archive_read_open_filename(reader.get(), source.c_str(), 65536) != ARCHIVE_OK) {
        ArchiveFailure(reader.get(), ArchiveErr::InvalidArchive);
    }
    fs::create_directories(output);
    const auto root = fs::canonical(output);
    archive_write_disk_set_options(writer.get(),
        ARCHIVE_EXTRACT_SECURE_NODOTDOT | ARCHIVE_EXTRACT_SECURE_SYMLINKS |
        ARCHIVE_EXTRACT_UNLINK);

    archive_entry* entry = nullptr;
    int status;
    while ((status = archive_read_next_header(reader.get(), &entry)) != ARCHIVE_EOF) {
        if (progress && progress->cancelled()) throw ArchiveException(NativeError::OperationCancelled, "Cancelled");
        if (status != ARCHIVE_OK) ArchiveFailure(reader.get(), ArchiveErr::ExtractFailed);
        const char* name = archive_entry_pathname_utf8(entry);
        if (!name) name = archive_entry_pathname(entry);
        const auto relative = Path(name);
        if (relative.empty() || relative.is_absolute() ||
            relative.string().find(':') != std::string::npos ||
            archive_entry_symlink(entry) || archive_entry_hardlink(entry)) {
            throw ArchiveException(ArchiveErr::PathTraversal, "Unsafe archive entry");
        }
        for (const auto& component : relative) {
            if (component == "..") {
                throw ArchiveException(ArchiveErr::PathTraversal, "Archive entry escaped its directory");
            }
        }
        const auto type = archive_entry_filetype(entry);
        if (type != AE_IFREG && type != AE_IFDIR) {
            throw ArchiveException(ArchiveErr::UnsupportedFormat, "Unsupported archive entry type");
        }
        const auto target = root / relative.lexically_normal();
        // Do not traverse a symlink left by an earlier import, either.
        auto parent = root;
        for (const auto& component : relative) {
            parent /= component;
            std::error_code ec;
            if (fs::is_symlink(fs::symlink_status(parent, ec))) {
                throw ArchiveException(ArchiveErr::PathTraversal, "Archive output contains a symlink");
            }
        }
        archive_entry_set_pathname(entry, target.c_str());
        archive_entry_set_perm(entry, type == AE_IFDIR ? 0755 : 0644);
        if (progress) progress->begin(relative, type == AE_IFDIR);
        if (archive_write_header(writer.get(), entry) != ARCHIVE_OK) {
            throw ArchiveException(ArchiveErr::FileCreateFailed, "Cannot create archive output");
        }
        if (type == AE_IFREG) {
            const void* buffer;
            size_t size;
            la_int64_t offset;
            while ((status = archive_read_data_block(reader.get(), &buffer, &size, &offset)) != ARCHIVE_EOF) {
                if (progress && progress->cancelled()) throw ArchiveException(NativeError::OperationCancelled, "Cancelled");
                if (status != ARCHIVE_OK) ArchiveFailure(reader.get(), ArchiveErr::ExtractFailed);
                if (archive_write_data_block(writer.get(), buffer, size, offset) != ARCHIVE_OK) {
                    throw ArchiveException(ArchiveErr::ExtractFailed, "Cannot write archive output");
                }
                if (progress) progress->data(relative, static_cast<std::uint64_t>(offset), buffer, size);
            }
        }
        if (archive_write_finish_entry(writer.get()) != ARCHIVE_OK) {
            throw ArchiveException(ArchiveErr::ExtractFailed, "Cannot finish archive output");
        }
        if (progress) progress->end(relative);
    }
}
} // namespace

void ExtractArchiveWithProgress(const std::filesystem::path& source,
                                const std::filesystem::path& output,
                                ArchiveProgress* progress) {
    Extract(source, output, progress);
}

GmlCallable double SetNativeLogFilePath(const char* path) {
    if (!path || !*path) return NativeError::InvalidArgument;
    return Guard([&]() -> double {
        NativeLogFilePath() = path;
        fs::create_directories(Path(path).parent_path());
        return NativeError::Ok;
    });
}

GmlCallable double OpenFolder(const char* path) {
    if (!path || !*path) return NativeError::InvalidArgument;
    return Guard([&]() -> double {
        if (!fs::is_directory(Path(path))) return Fail(ENOENT, "Folder does not exist");
        __block bool opened = false;
        OnMainThread(^{
            @autoreleasepool {
                opened = [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:
                    [NSString stringWithUTF8String:Path(path).c_str()] isDirectory:YES]];
            }
        });
        return opened ? 0 : Fail(NativeError::UnknownFailure, "Cannot open folder");
    });
}

GmlCallable double FolderExists(const char* path) {
    std::error_code ec;
    return path && *path && fs::is_directory(Path(path), ec) ? 1 : 0;
}

GmlCallable double FileExists(const char* path) {
    std::error_code ec;
    return path && *path && fs::is_regular_file(Path(path), ec) ? 1 : 0;
}

GmlCallable double CopyFolder(const char* source, const char* destination) {
    if (!source || !*source || !destination || !*destination) return NativeError::InvalidArgument;
    return Guard([&]() -> double {
        auto from = Path(source).lexically_normal();
        if (from.filename().empty()) from = from.parent_path();
        if (!fs::is_directory(from)) return Fail(ENOENT, "Copy source does not exist");
        const auto parent = Path(destination);
        fs::create_directories(parent);
        fs::copy(from, parent / from.filename(),
            fs::copy_options::recursive | fs::copy_options::overwrite_existing);
        return NativeError::Ok;
    });
}

GmlCallable double DeleteFolder(const char* path) {
    if (!path || !*path) return NativeError::InvalidArgument;
    return Guard([&]() -> double {
        const auto target = fs::absolute(Path(path)).lexically_normal();
        if (target == target.root_path()) return NativeError::InvalidArgument;
        fs::remove_all(target);
        return NativeError::Ok;
    });
}

GmlCallable double StartBackupWithTargetFile(const char* saves, const char* target) {
    if (!saves || !*saves || !target || !*target) return NativeError::InvalidArgument;
    return Guard([&]() -> double {
        fs::create_directories(Path(saves));
        Json backup = {{"files", Json::array()}};
        for (const auto& entry : fs::directory_iterator(Path(saves))) {
            if (entry.is_regular_file() && entry.path().extension() == ".json") {
                std::ifstream input(entry.path(), std::ios::binary);
                if (!input) return Fail(EIO, "Cannot read save file");
                std::ostringstream content;
                content << input.rdbuf();
                backup["files"].push_back({{"name", entry.path().filename().string()}, {"content", content.str()}});
            }
        }
        std::ofstream output(Path(target), std::ios::binary);
        output << backup.dump(4);
        output.close();
        return output ? 0 : Fail(EIO, "Cannot write backup file");
    });
}

GmlCallable double RestoreBackupWithTargetFile(const char* saves, const char* target) {
    if (!saves || !*saves || !target || !*target) return NativeError::InvalidArgument;
    return Guard([&]() -> double {
        std::ifstream input(Path(target), std::ios::binary);
        if (!input) return Fail(ENOENT, "Backup file does not exist");
        const auto backup = Json::parse(input);
        if (!backup.is_object() || !backup.contains("files") || !backup["files"].is_array()) {
            return Fail(NativeError::JsonParseFailed, "Backup has no files array");
        }
        // Validate the entire backup before creating any restored files.
        for (const auto& file : backup["files"]) {
            if (!file.is_object() || !file.contains("name") || !file.contains("content") ||
                !file["name"].is_string() || !file["content"].is_string()) {
                return Fail(NativeError::JsonParseFailed, "Invalid backup file entry");
            }
            const auto name = Path(file["name"].get_ref<const std::string&>().c_str());
            if (name.empty() || name.has_parent_path() || name == "." || name == "..") {
                return Fail(NativeError::PathTraversal, "Backup filename is not a basename");
            }
        }
        fs::create_directories(Path(saves));
        for (const auto& file : backup["files"]) {
            const auto path = Path(saves) / Path(file["name"].get_ref<const std::string&>().c_str());
            if (fs::is_symlink(fs::symlink_status(path))) {
                return Fail(NativeError::PathTraversal, "Save file is a symlink");
            }
            std::ofstream output(path, std::ios::binary);
            output << file["content"].get_ref<const std::string&>();
            output.close();
            if (!output) return Fail(EIO, "Cannot restore save file");
        }
        return NativeError::Ok;
    });
}

GmlCallable double StartBackup(const char* saves) {
    if (!saves || !*saves) return NativeError::InvalidArgument;
    return Guard([&]() -> double {
        const auto folder = ChooseBackup(true);
        if (folder.empty()) return NativeError::OperationCancelled;
        return StartBackupWithTargetFile(saves, (Path(folder.c_str()) / "backup.json").c_str());
    });
}

GmlCallable double RestoreBackup(const char* saves, const char* initial) {
    if (!saves || !*saves) return NativeError::InvalidArgument;
    return Guard([&]() -> double {
        const auto file = ChooseBackup(false, initial);
        return file.empty() ? NativeError::OperationCancelled : RestoreBackupWithTargetFile(saves, file.c_str());
    });
}

GmlCallable double UnzipMapFile(const char* archive_path, const char* output) {
    if (!archive_path || !*archive_path || !output || !*output) return NativeError::InvalidArgument;
    return Guard([&]() -> double {
        if (!fs::is_regular_file(Path(archive_path))) return ArchiveErr::OpenFailed;
        Extract(Path(archive_path), Path(output));
        return NativeError::Ok;
    });
}

// Win32-specific hooks are deliberately inactive on macOS. The GML layer keeps
// normal Cocoa keyboard/IME handling and does not request global event access.
GmlCallable double DisableIme(double) { return 0; }
GmlCallable double EnableIme(double) { return 0; }
GmlCallable double StartMouseLimit(double, double) { return 0; }
GmlCallable double StopMouseLimit() { return 0; }
GmlCallable double MouseLimitStats(double) { return 0; }
