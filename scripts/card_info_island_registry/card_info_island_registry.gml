function info_island_register_init(){
	global.info_island = ds_map_create()
}


function register_card_info_island(card_id,info){
	// 注册即折行：情报岛正文区（obj_info_island_bg/Draw_0 的 draw_text_ext(x-390,y-100,text,30,300)）
	// 不认中文断句，一段连续字符太长就会冲出面板。统一在入口把每段压到 35 字以内，
	// 文案作者不用自己数格子；对手写换行安全（幂等）。
	global.info_island[? card_id] = info_island_wrap(info)
}


/// @function info_island_wrap(_text, _max_chars)
/// @description 情报岛正文按字数硬折行。
///   先切行（"\n"），逐段检查：连续字符超过 _max_chars 个就在第 _max_chars 个字后插入换行。
///   原有换行原样保留，且每行结果不超过 _max_chars，因此重复调用结果不变（幂等）。
///   排版保护区：
///     0) 作者手数格子时把 "[攻击间隔]" 劈成 "[攻" + "击间隔]" 的，先拼回去再折行；
///     1) 不劈开 "[攻击力]"/"[间隔]" 这类占位符，切点落在方括号内时整体留到下一行；
///     2) 优先在收尾标点（，。、；：！？）】》」』…%）后断开，找不到才硬切；
///     3) 下一行首字是标点时断点回退，标点不顶行首；
///     4) 行尾不留起头符号（（【《「『[）。
/// @param {string} _text 原文
/// @param {real} _max_chars 单行最多字符数，默认 35（与现有手写排版的最长行同宽）
/// @returns {string}
function info_island_wrap(_text, _max_chars = 35) {
	if (!is_string(_text)) return _text;
	_max_chars = max(1, floor(_max_chars));
	var _lines = info_island_join_split_tokens(string_split(_text, "\n"));
	var _out = "";
	for (var _li = 0; _li < array_length(_lines); _li++) {
		if (_li > 0) _out += "\n";
		_out += info_island_wrap_line(_lines[_li], _max_chars);
	}
	return _out;
}


/// @function info_island_wrap_line(_line, _max_chars)
/// @description 单行折行（info_island_wrap 内部使用），规则见上。
function info_island_wrap_line(_line, _max_chars) {
	var _len = string_length(_line);
	var _tail_punct = "，。、；：！？）】》」』…%";
	var _head_punct = "（【《「『[";
	var _min_len = max(1, floor(_max_chars * 0.5)); // 优先断点最多回退到这里，避免切出过短的行
	var _out = "";
	var _start = 1;
	while (_len - _start + 1 > _max_chars) {
		var _cut = _start + _max_chars - 1;
		// 1) 切点落在占位符内部 → 整体退到 "[" 之前
		if (info_island_in_bracket(_line, _cut)) _cut = info_island_open_bracket_before(_line, _cut, _start);
		// 2) 优先在收尾标点后断开
		for (var _p = _cut; _p >= _start + _min_len; _p--) {
			var _ch = string_char_at(_line, _p);
			if (_ch != "" && string_pos(_ch, _tail_punct) > 0 && !info_island_in_bracket(_line, _p)) {
				_cut = _p;
				break;
			}
		}
		// 3) 下一行首字是标点 → 断点回退一格
		var _next = string_char_at(_line, _cut + 1);
		if (_next != "" && string_pos(_next, _tail_punct) > 0) {
			_cut--;
			if (_cut >= _start && info_island_in_bracket(_line, _cut)) _cut = info_island_open_bracket_before(_line, _cut, _start);
		}
		// 4) 行尾不留起头符号
		var _g = 0;
		while (_g < 3 && _cut > _start) {
			var _last = string_char_at(_line, _cut);
			if (_last == "" || string_pos(_last, _head_punct) == 0) break;
			_cut--;
			_g++;
		}
		// 5) 🔴 兜底（2026-11-06）：切完前缀里不能留着没闭合的 `{` / `[`
		//    否则变量被劈成两半（如 `每把造成{` + `攻击力}点`），
		//    换行被 render 当表达式空白吞掉，整段又拼回一行、冲出面板
		_cut = info_island_cut_outside_tokens(_line, _start, _cut);
		if (_cut < _start) _cut = _start;
		_out += string_copy(_line, _start, _cut - _start + 1) + "\n";
		_start = _cut + 1;
	}
	return _out + string_copy(_line, _start, _len - _start + 1);
}


/// @function info_island_cut_outside_tokens(_line, _start, _cut)
/// @description 把断点往前挪，直到 [start, cut] 这段里没有没闭合的 `{` 或 `[`。
///   挪不动（开括号就在 _start）时原样返回，避免死循环。
function info_island_cut_outside_tokens(_line, _start, _cut) {
	var _guard = 0;
	while (_guard < 8) {
		var _d_brace = 0;
		var _d_sq = 0;
		var _last_brace = 0;
		var _last_sq = 0;
		for (var _i = _start; _i <= _cut; _i++) {
			var _c = string_char_at(_line, _i);
			if (_c == "{") { _d_brace++; _last_brace = _i; }
			else if (_c == "}") { _d_brace--; if (_d_brace <= 0) { _d_brace = 0; _last_brace = 0; } }
			else if (_c == "[") { _d_sq++; _last_sq = _i; }
			else if (_c == "]") { _d_sq--; if (_d_sq <= 0) { _d_sq = 0; _last_sq = 0; } }
		}
		var _open_at = 0;
		if (_d_brace > 0) _open_at = _last_brace;
		if (_d_sq > 0 && _last_sq > _open_at) _open_at = _last_sq;
		if (_open_at == 0) break;
		var _nc = _open_at - 1;
		if (_nc < _start) break;
		_cut = _nc;
		_guard++;
	}
	return _cut;
}


/// @function info_island_join_split_tokens(_lines)
/// @description 把作者手工换行劈开的占位符拼回去："…每隔[攻" + "击间隔]秒…" → "…每隔[攻击间隔]秒…"。
///   只在方括号确实没闭合、且下一行前 6 个字内出现 "]" 时才拼接，
///   因此像 "[辅助类][地形类" 这种真的漏了 "]" 的文案不会被吞掉下一行。
function info_island_join_split_tokens(_lines) {
	var _n = array_length(_lines);
	var _out = [];
	var _i = 0;
	while (_i < _n) {
		var _line = _lines[_i];
		while (_i + 1 < _n && info_island_count_char(_line, "[") > info_island_count_char(_line, "]")) {
			var _close_pos = string_pos("]", _lines[_i + 1]);
			if (_close_pos == 0 || _close_pos > 6) break;
			_line += _lines[_i + 1];
			_i++;
		}
		array_push(_out, _line);
		_i++;
	}
	return _out;
}


/// @function info_island_in_bracket(_line, _pos)
/// @description 判断 _pos（1 起算）是否严格位于一对占位符内部：`[ ]` 或 `{ }`。
///   🔴 2026-11-06 修：原来只保护方括号，切点会落进 `{每跳间隔}` 这种变量里；
///      换行符一旦插进大括号内，`info_island_text_render` 会把整段当表达式解析、
///      解析时跳过所有空白（含 `\n`），换行被吞掉 → 那段又拼回一整行、冲出面板。
function info_island_in_bracket(_line, _pos) {
	var _len = string_length(_line);
	if (_pos < 1 || _pos > _len) return false;
	if (info_island_in_pair(_line, _pos, "[", "]")) return true;
	return info_island_in_pair(_line, _pos, "{", "}");
}


/// @function info_island_in_pair(_line, _pos, _open_ch, _close_ch)
/// @description 判断 _pos 是否严格位于指定的一对括号内部（供 info_island_in_bracket 调用）。
function info_island_in_pair(_line, _pos, _open_ch, _close_ch) {
	var _len = string_length(_line);
	var _open = 0;
	var _i = 0;
	for (_i = _pos - 1; _i >= 1; _i--) {
		var _c = string_char_at(_line, _i);
		if (_c == _close_ch) return false;
		if (_c == _open_ch) { _open = _i; break; }
	}
	if (_open == 0) return false;
	for (_i = _open + 1; _i <= _len; _i++) {
		if (string_char_at(_line, _i) == _close_ch) return (_pos > _open && _pos < _i);
	}
	return false;
}


/// @function info_island_open_bracket_before(_line, _pos, _min_pos)
/// @description 从 _pos 往前找最近的 "[" 或 "{"，返回它前一个字符的位置（找不到返回 _pos）。
function info_island_open_bracket_before(_line, _pos, _min_pos) {
	for (var _i = _pos; _i >= _min_pos; _i--) {
		var _c = string_char_at(_line, _i);
		if (_c == "[" || _c == "{") return _i - 1;
	}
	return _pos;
}


/// @function info_island_count_char(_s, _ch)
/// @description 统计单字符出现次数。
function info_island_count_char(_s, _ch) {
	var _n = 0;
	for (var _i = 1; _i <= string_length(_s); _i++) {
		if (string_char_at(_s, _i) == _ch) _n++;
	}
	return _n;
}
