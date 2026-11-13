/// 

function NativeUtil() constructor {

    /// Portable form for parsing paths; use file_path before filesystem I/O.
    static normalize_path = function(_path) {
        return string_replace_all(string(_path), "\\", "/")
    }

    /// Windows GML sandbox checks require canonical backslashes in absolute paths.
    static file_path = function(_path) {
        if (os_type == os_windows) return string_replace_all(string(_path), "/", "\\")
        return self.normalize_path(_path)
    }

    /// Join trusted components and normalize the complete filesystem path.
    static join_path = function(_root, _child) {
        var _joined = self.normalize_path(_root)
        if (_joined != "" && !string_ends_with(_joined, "/")) _joined += "/"
        return self.file_path(_joined + string(_child))
    }

    /// @param {String} _path 
    /// @returns {String}
    static get_path_in_local_appdata = function(_path) {
        var _relative = self.normalize_path(_path)
        while (string_starts_with(_relative, "/")) {
            _relative = string_delete(_relative, 1, 1)
        }
        if (os_type == os_windows) {
            return self.join_path(environment_get_variable("LOCALAPPDATA"), _relative)
        }

        // Native operations must use the same location as relative GML save paths.
        var _root = "FVM_Reborn_makk"
        if (_relative == _root || string_starts_with(_relative, _root + "/")) {
            var _save_dir = self.normalize_path(game_save_id)
            if (!string_ends_with(_save_dir, "/")) _save_dir += "/"
            return _save_dir + string_delete(_relative, 1, string_length(_root) + 1)
        }
        // Legacy save migration still needs access to the old game's sibling directory.
        var _base = environment_get_variable("HOME") + "/Library/Application Support/"
        return _base + _relative
    }

    /// @param {String} _rel GML 沙盒相对路径
    /// @returns {String} native 可用的绝对路径
    static to_native_absolute = function(_rel) {
        _rel = self.normalize_path(_rel)
        if (string_starts_with(_rel, "/") || (string_length(_rel) >= 2 && string_char_at(_rel, 2) == ":")) {
            return self.file_path(_rel)
        }
        return self.get_path_in_local_appdata("FVM_Reborn_makk/" + _rel)
    }

    /// @param {String} _path 
    /// @returns {String}
    static transfer_path_to_windows = function(_path) {
        // Kept for existing callers; return a path valid on the current platform.
        return self.file_path(_path)
    }

    /// @param {Real} _code 
    /// @param {String} _msg 
    static show_error = function(_code, _msg) {
        show_message_async(_msg + "code: " + string(_code))
    }

}
