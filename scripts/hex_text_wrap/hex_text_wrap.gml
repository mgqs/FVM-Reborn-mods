/// hex_text_wrap —— UI 文本换行 / 截断工具
/// 只做排版，不碰任何玩法数值。给海克斯的三个界面共用：
///   obj_hex_panel（三/四选一卡面）、obj_hex_list（词条列表）、obj_hex_effect（效果两栏）
///
/// 用法约定：调用前先把 draw_set_font / color / halign 设好，valign 用 fa_middle，
///          传入的 _y 是「这一块文本的顶部」，行中心由函数自己算。

/// @function hex_wrap_text(_text, _max_w)
/// @desc 按像素宽度贪心断行，返回行数组（至少 1 行）。
///       - 支持文本里已有的 \n 强制换行
///       - 中文逐字断行；英文/数字尽量不拆单词（断点两侧都是字母时回退到最近空格）
///       - 行首标点悬挂：标点允许超出 ≤12px，避免下一行以「，。」开头
function hex_wrap_text(_text, _max_w) {
    var _lines = [];
    if (!is_string(_text)) _text = string(_text);
    if (_max_w < 8) _max_w = 8;

    var _n = string_length(_text);
    if (_n == 0) {
        array_push(_lines, "");
        return _lines;
    }

    var _punct = "，。；：、！？）】》”’,.!?)]}%";

    var _cur = "";
    var _i = 0;
    while (_i < _n) {
        var _ch = string_char_at(_text, _i + 1);

        if (_ch == "\n" || _ch == "\r") {
            array_push(_lines, _cur);
            _cur = "";
            _i += 1;
            continue;
        }

        var _trial = _cur + _ch;
        var _w = string_width(_trial);

        if (_w <= _max_w) {
            _cur = _trial;
            _i += 1;
            continue;
        }

        // 行首标点悬挂
        if (_cur != "" && string_pos(_ch, _punct) > 0 && _w <= _max_w + 12) {
            _cur = _trial;
            _i += 1;
            continue;
        }

        // 单个字符就超宽（容器太窄），硬放一行，不然会死循环
        if (_cur == "") {
            array_push(_lines, _ch);
            _cur = "";
            _i += 1;
            continue;
        }

        // 英文单词尽量不拆：断点前后都是字母/数字时，回退到当前行最后一个空格
        var _bc = string_byte_at(_ch, 1);
        var _ch_alpha = (_bc >= 65 && _bc <= 90) || (_bc >= 97 && _bc <= 122) || (_bc >= 48 && _bc <= 57);
        if (_ch_alpha) {
            var _last_sp = 0;
            for (var k = string_length(_cur); k >= 1; k--) {
                if (string_char_at(_cur, k) == " ") {
                    _last_sp = k;
                    break;
                }
            }
            if (_last_sp > 1) {
                var _keep = string_copy(_cur, 1, _last_sp - 1);
                var _move = string_copy(_cur, _last_sp + 1, string_length(_cur) - _last_sp);
                array_push(_lines, _keep);
                _cur = _move;
                continue;   // 不推进 _i，让 _ch 接到新行后面重试
            }
        }

        array_push(_lines, _cur);
        _cur = "";
        // 不推进 _i：该字符重新尝试放进新行
    }

    if (_cur != "") array_push(_lines, _cur);
    if (array_length(_lines) == 0) array_push(_lines, "");
    return _lines;
}

/// @function hex_ellipsis(_text, _max_w)
/// @desc 单行截断加省略号（仅用于「行数超上限」的末行）
function hex_ellipsis(_text, _max_w) {
    if (string_width(_text) <= _max_w) return _text;
    while (string_length(_text) > 0) {
        _text = string_copy(_text, 1, string_length(_text) - 1);
        if (string_width(_text + "…") <= _max_w) break;
    }
    return _text + "…";
}

/// @function hex_draw_lines(_lines, _x, _y, _lh, _max_lines, _max_w)
/// @desc 逐行绘制，_y 是块顶部，每行以 fa_middle 对齐到行中心。
///       超出行数上限时末行自动加省略号。返回实际占用高度。
///       调用方负责 font / color / halign，valign 必须是 fa_middle。
function hex_draw_lines(_lines, _x, _y, _lh, _max_lines, _max_w) {
    var _n = array_length(_lines);
    if (_n <= 0) return 0;

    var _show = _n;
    var _cut  = false;
    if (_max_lines > 0 && _n > _max_lines) {
        _show = _max_lines;
        _cut  = true;
    }

    for (var i = 0; i < _show; i++) {
        var _t = _lines[i];
        if (_cut && i == _show - 1) _t = hex_ellipsis(_t, _max_w);
        draw_text(_x, _y + i * _lh + _lh / 2, _t);
    }
    return _show * _lh;
}
