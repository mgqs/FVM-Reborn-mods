///
self.state = {
    left: 0,
    top: 0,
    width: 420,
    height: 40,
    text: "",
    placeholder: "搜索名称或作者",
    focused: false,
    cursor_visible: true,
    cursor_timer: 0,
    /// 2026-11-05：光标插入位置（0 = 最前、string_length(text) = 末尾）+ 上一帧 keyboard_string 副本
    caret: 0,
    kb_prev: "",
    /// @type {function}
    on_change: undefined,
    /// 2026-11-09：附加绘制的回调（搜索导航器用它画「清空 / 下一个」）
    ///   画在搜索框这同一层 → 不会被面板里那些 depth 更低的按钮实例盖住
    on_draw_extra: undefined,
    /// @type {function ():Bool}
    should_correspond: function() { return true },
    /// @type {Struct|undefined} 可选配色；undefined = 原来的米色（实验室 / 联机地图两处不变）
    ///   { bg, bg_focus, border, border_focus, text, placeholder }
    theme: undefined,
}
self.mac_editor = new MacTextInput(id)

function layout_native_editor() {
    var _color = is_undefined(self.state.theme) ? c_black : self.state.theme.text
    self.mac_editor.layout(self.state.left + 12, self.state.top + 2,
        max(1, self.state.width - 24), self.state.height - 4, 21, _color)
}

/// Cocoa reports only Return/Escape that were not used by an IME candidate.
function accept_pressed() {
    if (!self.mac_editor.enabled) return keyboard_check_pressed(vk_enter)
    var _pressed = self.mac_editor.submitted
    self.mac_editor.submitted = false
    return _pressed
}

function cancel_pressed() {
    if (!self.mac_editor.enabled) return keyboard_check_pressed(vk_escape)
    var _pressed = self.mac_editor.cancelled
    self.mac_editor.cancelled = false
    return _pressed
}

/// @func set_theme(theme) 换配色（不调它 = 原来的米色 + 描边字）
function set_theme(_theme) {
    self.state.theme = _theme
    return self
}

function set_position(_left, _top) {
    self.state.left = _left
    self.state.top = _top
    return self
}

function set_size(_width, _height) {
    self.state.width = _width
    self.state.height = _height
    return self
}

function set_placeholder(_text) {
    self.state.placeholder = _text
    return self
}

function set_on_change(_on_change) {
    self.state.on_change = _on_change
    return self
}

/// @func set_on_draw_extra(func) 搜索框画完之后再画点什么（同一层，最上层）
function set_on_draw_extra(_f) {
    self.state.on_draw_extra = _f
    return self
}

function set_should_correspond(_should_correspond) {
    if (is_undefined(_should_correspond)) {
        throw("SearchBox: should_correspond must be a function")
    }
    self.state.should_correspond = _should_correspond
    return self
}

function get_text() {
    return self.state.text
}

function set_text(_text) {
    self.state.text = string(_text)
    self.mac_editor.set_text(self.state.text)
    // 2026-11-05：外部改文字时光标跟到末尾，并把 keyboard_string 对齐 —— 否则下一帧的
    //   「新旧串比对」会拿旧串当输入，把刚设进去的文字覆盖回去
    self.state.caret = string_length(self.state.text)
    keyboard_string = self.state.text
    self.state.kb_prev = keyboard_string
    return self
}

function emit_change() {
    if (!is_undefined(self.state.on_change)) {
        self.state.on_change(self.state.text)
    }
}

function focus() {
    if (self.state.focused) {
        return
    }
    self.state.focused = true
    // 2026-10-31：点进去立刻显示光标（不重置的话可能正好落在「灭」的相位，最多 0.5s 看不到竖线）
    self.state.cursor_timer = 0
    self.state.cursor_visible = true
    keyboard_string = self.state.text
    self.state.kb_prev = keyboard_string
    self.state.caret = string_length(self.state.text)
    if (self.mac_editor.enabled) {
        layout_native_editor()
        self.mac_editor.begin(self.state.text, 64, self.state.placeholder)
    }
    if (os_type == os_windows && variable_global_exists("ime_block") && native_enable_ime != undefined) {
        native_enable_ime(window_handle())
    }
}

function blur() {
    if (!self.state.focused) {
        return
    }
    if (self.mac_editor.enabled) {
        var _before = self.state.text
        self.mac_editor.finish()
        self.state.text = self.mac_editor.text
        self.state.caret = self.mac_editor.caret
        if (self.state.text != _before) emit_change()
    }
    self.state.focused = false
    if (variable_global_exists("ime_block") && global.ime_block && native_disable_ime != undefined) {
        native_disable_ime(window_handle())
    }
}

function contains_point(_mx, _my) {
    return point_in_rectangle(
        _mx, _my,
        self.state.left, self.state.top,
        self.state.left + self.state.width,
        self.state.top + self.state.height)
}

/// @func insert_at_caret(text) 在光标处插入文字（2026-11-05）
function insert_at_caret(_t) {
    _t = string(_t)
    if (_t == "") return
    var _c = clamp(self.state.caret, 0, string_length(self.state.text))
    self.state.text = string_copy(self.state.text, 1, _c) + _t + string_delete(self.state.text, 1, _c)
    self.state.caret = _c + string_length(_t)
}

/// @func set_caret_from_mouse(mx) 点击时按字符宽度找最近的字缝（2026-11-05）
function set_caret_from_mouse(_mx) {
    var _t = self.state.text
    var _n = string_length(_t)
    var _rel = _mx - (self.state.left + 12)
    if (_rel <= 0 || _n == 0) {
        self.state.caret = 0
        return
    }
    draw_set_font(font_yuan)
    var _i = 0
    var _w0 = 0
    while (_i < _n) {
        var _w1 = string_width(string_copy(_t, 1, _i + 1))
        if (_rel < (_w0 + _w1) * 0.5) break
        _w0 = _w1
        _i += 1
    }
    self.state.caret = _i
}

function on_create() {
}

function on_step() {
    if (!visible) {
        if (self.state.focused) blur()
        exit
    }
    if (!self.state.should_correspond()) {
        if (self.state.focused) {
            blur()
        }
        exit
    }

    if (mouse_check_button_pressed(mb_left)) {
        var _mx = device_mouse_x_to_gui(0)
        var _my = device_mouse_y_to_gui(0)
        if (contains_point(_mx, _my)) {
            focus()
            if (!self.mac_editor.enabled) set_caret_from_mouse(_mx)
        } else if (self.state.focused) {
            blur()
        }
    }

    if (!self.state.focused) {
        exit
    }

    if (self.mac_editor.enabled) {
        layout_native_editor()
        var _before_native = self.state.text
        self.mac_editor.poll()
        self.state.text = self.mac_editor.text
        self.state.caret = self.mac_editor.caret
        if (self.state.text != _before_native) emit_change()
        if (self.mac_editor.cancelled || !self.mac_editor.active) blur()
        exit
    }

    if (keyboard_check_pressed(vk_escape)) {
        blur()
        exit
    }

    var _prev = self.state.text

    // ── 2026-11-05：支持「光标插在中间」（原来整串取 keyboard_string，只能在末尾加、末尾删）──
    //   自己维护 text + caret：每帧把 keyboard_string 和上一帧副本比对，只把「新增的那一段」
    //   插到光标处；随后回写 keyboard_string = text，让下一帧的比对基准永远是本框的文字。
    if (keyboard_check(vk_control) && keyboard_check_pressed(ord("V"))) {
        insert_at_caret(clipboard_get_text())
    } else {
        var _kb = keyboard_string
        var _pk = self.state.kb_prev
        if (_kb != _pk) {
            if (string_length(_kb) > string_length(_pk) && string_pos(_pk, _kb) == 1) {
                // 正常打字 / 中文输入法上屏：多出来的那段插到光标处
                insert_at_caret(string_delete(_kb, 1, string_length(_pk)))
            } else if (string_length(_kb) < string_length(_pk) && string_pos(_kb, _pk) == 1) {
                // 原生退格：GM 已把键盘串末尾删掉 → 改成「删光标前一个字」
                if (self.state.caret > 0) {
                    self.state.text = string_delete(self.state.text, self.state.caret, 1)
                    self.state.caret -= 1
                }
            } else {
                // 兜底（输入法组合态等判定不了的变化）：整串接管，光标跟到末尾
                self.state.text = _kb
                self.state.caret = string_length(_kb)
            }
        }
    }

    // 方向键 / Home / End / Delete（移动后立刻显示光标，别正好落在「灭」的相位）
    var _prev_caret = self.state.caret
    if (keyboard_check_pressed(vk_left))  self.state.caret = max(0, self.state.caret - 1)
    if (keyboard_check_pressed(vk_right)) self.state.caret = min(string_length(self.state.text), self.state.caret + 1)
    if (keyboard_check_pressed(vk_home))  self.state.caret = 0
    if (keyboard_check_pressed(vk_end))   self.state.caret = string_length(self.state.text)
    if (keyboard_check_pressed(vk_delete) && self.state.caret < string_length(self.state.text)) {
        self.state.text = string_delete(self.state.text, self.state.caret + 1, 1)
    }

    if (string_length(self.state.text) > 64) {
        self.state.text = string_copy(self.state.text, 1, 64)
    }
    self.state.caret = clamp(self.state.caret, 0, string_length(self.state.text))
    keyboard_string = self.state.text
    self.state.kb_prev = keyboard_string

    if (self.state.text != _prev || self.state.caret != _prev_caret) {
        self.state.cursor_timer = 0
        self.state.cursor_visible = true
    }

    if (self.state.text != _prev) {
        emit_change()
    }

    self.state.cursor_timer += 1
    if (self.state.cursor_timer >= 30) {
        self.state.cursor_timer = 0
        self.state.cursor_visible = !self.state.cursor_visible
    }
}

function on_draw() {
    if (!visible) {
        exit
    }
    var _s = self.state

    // ── 可选配色（商店凭证页那种深蓝底）：没设 theme 就走下面的原版米色 ──
    if (!is_undefined(_s.theme)) {
        var _th = _s.theme
        draw_set_alpha(1)
        draw_set_color(_s.focused ? _th.bg_focus : _th.bg)
        draw_roundrect(_s.left, _s.top, _s.left + _s.width, _s.top + _s.height, false)
        draw_set_color(_s.focused ? _th.border_focus : _th.border)
        draw_roundrect(_s.left, _s.top, _s.left + _s.width, _s.top + _s.height, true)

        if (self.mac_editor.active) {
            if (!is_undefined(_s.on_draw_extra)) _s.on_draw_extra()
            exit
        }

        draw_set_font(font_yuan)
        draw_set_halign(fa_left)
        draw_set_valign(fa_middle)
        // 光标位置：文字末端（空文本时 string_width("") = 0，正好落在左内边距 left+14）
        //   2026-11-05：改成「光标之前那段文字的宽度」，支持插在中间
        var _caret_x = _s.left + 14 + string_width(string_copy(_s.text, 1, _s.caret))
        if (_s.text == "") {
            // 空且已聚焦时只留光标，别让占位字和竖线叠在一起
            if (!_s.focused) {
                draw_set_color(_th.placeholder)
                draw_text(_s.left + 12, _s.top + _s.height * 0.5, _s.placeholder)
            }
        } else {
            draw_set_color(_th.text)
            draw_text(_s.left + 12, _s.top + _s.height * 0.5, _s.text)
        }
        // 2026-10-31：光标移到 if/else 外面 —— 空输入框聚焦时也要有闪烁竖线（原来只写在 else 里，空框一根线都没有）
        if (_s.focused && _s.cursor_visible) {
            draw_set_color(_th.text)
            draw_line(_caret_x, _s.top + 8, _caret_x, _s.top + _s.height - 8)
        }
        draw_set_halign(fa_left)
        draw_set_valign(fa_top)
        draw_set_color(c_white)
        // 附加绘制（清空 / 下一个）：跟搜索框同层，永远在面板之上
        if (!is_undefined(_s.on_draw_extra)) _s.on_draw_extra()
        exit
    }

    draw_set_alpha(0.72)
    draw_set_color(_s.focused ? make_color_rgb(250, 246, 230) : make_color_rgb(236, 228, 208))
    draw_roundrect(_s.left, _s.top, _s.left + _s.width, _s.top + _s.height, false)
    draw_set_alpha(1)
    draw_set_color(_s.focused ? make_color_rgb(120, 82, 40) : make_color_rgb(90, 72, 48))
    draw_roundrect(_s.left, _s.top, _s.left + _s.width, _s.top + _s.height, true)

    if (self.mac_editor.active) {
        if (!is_undefined(_s.on_draw_extra)) _s.on_draw_extra()
        exit
    }

    var _label = _s.text
    var _color_name = "font_hei_outline_4dir_black"
    var _caret_x2 = _s.left + 14 + string_width(string_copy(_label, 1, _s.caret))   // 空文本时 = 左内边距
    if (_label == "") {
        // 空且已聚焦时只留光标，占位字不画（否则竖线会压在第 1 个字上）
        if (!_s.focused) {
            scribble(_s.placeholder)
                .align(fa_left, fa_middle)
                .starting_format(_color_name)
                .blend(c_gray, 1)
                .draw(_s.left + 12, _s.top + _s.height * 0.5)
        }
    } else {
        scribble(_label)
            .align(fa_left, fa_middle)
            .starting_format(_color_name)
            .draw(_s.left + 12, _s.top + _s.height * 0.5)
    }
    // 2026-10-31：同深色分支，光标提到 if/else 外面，空输入框也闪
    if (_s.focused && _s.cursor_visible) {
        draw_set_color(c_black)
        draw_line(_caret_x2, _s.top + 8, _caret_x2, _s.top + _s.height - 8)
    }
    // 附加绘制（清空 / 下一个）：米色分支同样支持
    if (!is_undefined(_s.on_draw_extra)) _s.on_draw_extra()
}

on_create()
