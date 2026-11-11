/// macOS-only native editing session. Windows keeps its existing input path.
/// Positions are in GUI coordinates; Cocoa receives fractions of the window,
/// so Retina, resizing and application-surface letterboxing share one mapping.
function MacTextInput(_owner) constructor {
    enabled = os_type == os_macosx;
    owner = string(_owner);
    active = false;
    opened = false;
    text = "";
    caret = 0;
    composing = false;
    submitted = false;
    cancelled = false;
    bounds = {};

    static request = function(_op, _args) {
        if (!self.enabled) return;
        if (!variable_global_exists("mac_text_input_abi")) {
            global.mac_text_input_abi = external_define("libFvmNativeSupport.dylib",
                "MacTextInput", dll_cdecl, ty_string, 1, ty_string);
        }
        _args.op = _op;
        _args.owner = self.owner;
        var _result = json_parse(external_call(global.mac_text_input_abi, json_stringify(_args)));
        if (!_result.ok) {
            self.active = false;
            return;
        }
        self.active = _result.active;
        self.text = _result.text;
        self.caret = _result.caret;
        self.composing = _result.composing;
        self.submitted = _result.submitted;
        self.cancelled = _result.cancelled;
    }

    static layout = function(_x, _y, _width, _height, _font_pixels, _color) {
        if (!self.enabled) return;
        var _surface = application_get_position();
        var _ww = max(1, window_get_width());
        var _wh = max(1, window_get_height());
        var _sx = (_surface[2] - _surface[0]) / max(1, display_get_gui_width());
        var _sy = (_surface[3] - _surface[1]) / max(1, display_get_gui_height());
        self.bounds = {
            x: (_surface[0] + _x * _sx) / _ww,
            y: (_surface[1] + _y * _sy) / _wh,
            width: _width * _sx / _ww,
            height: _height * _sy / _wh,
            font_size: _font_pixels * _sy / _wh,
            color: _color,
        };
    }

    static begin = function(_text, _limit, _label, _digits = false) {
        self.text = string(_text);
        self.bounds.text = string(_text);
        self.bounds.limit = _limit;
        self.bounds.label = _label;
        self.bounds.digits = _digits;
        self.request("begin", self.bounds);
        self.opened = self.active;
    }

    static poll = function() {
        self.submitted = false;
        self.cancelled = false;
        self.request("poll", self.bounds);
    }

    static set_text = function(_text) {
        self.text = string(_text);
        if (self.active) {
            var _submit = self.submitted;
            var _cancel = self.cancelled;
            self.request("set", {text: self.text});
            self.submitted = self.submitted || _submit;
            self.cancelled = self.cancelled || _cancel;
        }
    }

    static finish = function() {
        if (self.opened) {
            var _submit = self.submitted;
            var _cancel = self.cancelled;
            self.request("end", {});
            self.submitted = self.submitted || _submit;
            self.cancelled = self.cancelled || _cancel;
        }
        self.active = false;
        self.opened = false;
        self.composing = false;
        // Native editing must not leave Return/Escape down in the Runner when
        // focus returns to gameplay or another dialog.
        if (self.enabled) {
            keyboard_clear(vk_enter);
            keyboard_clear(vk_escape);
        }
    }
}
