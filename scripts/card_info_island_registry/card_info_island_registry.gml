function info_island_register_init(){
	global.info_island     = ds_map_create();   // 成品（版式 + 折行后的最终文本）
	global.info_island_raw = ds_map_create();   // 原文（重排时每次都从它重新生成，幂等）
}


/// @function info_island_data_ready()
/// @description 卡表 / 分类表是否已经能查了。
///   🔴 原版 info_island_init() 在 obj_game_init 第 10 行就跑，而 global.plant_registry
///   第 30 行才创建、卡表在 obj_mod_manager 的 Create 里才注册 —— 那时取卡名会直接崩
///   「global variable name 'plant_registry' index not set」。所以注册时只存原文，
///   等卡表齐了再统一重排（info_island_compose_all）。
function info_island_data_ready() {
	if (!variable_global_exists("plant_registry")) return false;
	if (!ds_exists(global.plant_registry, ds_type_map)) return false;
	return (ds_map_size(global.plant_registry) > 0);
}


function register_card_info_island(card_id,info){
	// 兜底：任何一条注册早于 info_island_register_init() 时不崩
	if (!variable_global_exists("info_island_raw")) global.info_island_raw = ds_map_create();
	if (!variable_global_exists("info_island"))     global.info_island     = ds_map_create();

	global.info_island_raw[? card_id] = info;
	global.info_island[? card_id]     = info_island_build(card_id, info);
}


/// @function info_island_build(_id, _txt)
/// @description 单条从原文生成成品，两步都幂等：
///   1) info_island_compose()：来源一行 → 卡片分类 → 可用增幅 → 空一行 → 正文
///   2) info_island_unwrap()：合并手写软换行（原来按 35 字折出来的那些）
///   🔴 折行只在绘制端做（info_island_text_lines，按像素 + 标点规则），这里一个字符都不折。
function info_island_build(_id, _txt) {
	if (!is_string(_txt)) return _txt;
	return info_island_unwrap(info_island_compose(_id, _txt));
}


/// @function info_island_unwrap(_txt)
/// @description 合并手写软换行：原来文案是按 35 字硬折的，绘制端改成按像素折行以后，
///   这些手写断点会把行截短（行尾一片空白），所以先合并回整段。
///   **保留**换行的情况：空行 / 标题行（来源·卡片分类·可用增幅）/ 结构行（基础能力·
///   一~终转·`*`·`·`·`-`·`Tip`·`注`·`【`）/ 上一行以 `。！？…` 或 `：` 结尾。
function info_island_unwrap(_txt) {
	var _lines = string_split(_txt, "\n");
	var _out = [];
	for (var _i = 0; _i < array_length(_lines); _i++) {
		var _s = string_trim(_lines[_i]);
		if (array_length(_out) == 0) {
			array_push(_out, _s);
			continue;
		}
		var _prev = _out[array_length(_out) - 1];
		if (_prev == "" || _s == "" || info_island_starts_block(_s)
			|| info_island_is_title_line(_prev) || info_island_ends_sentence(_prev)) {
			array_push(_out, _s);
		} else {
			_out[array_length(_out) - 1] = _prev + _s;
		}
	}
	return info_island_join_lines(_out);
}


/// @function info_island_starts_block(_s)
/// @description 这一行是不是「自成一段」的起头（不能被上一行吞掉）。
function info_island_starts_block(_s) {
	var _c = string_char_at(_s, 1);
	if (_c == "*" || _c == "·" || _c == "-" || _c == "【" || _c == "⭐") return true;
	if (string_copy(_s, 1, 4) == "基础能力") return true;
	if (string_copy(_s, 1, 3) == "Tip") return true;
	if (string_copy(_s, 1, 1) == "注") return true;
	// 一转能力 / 二转能力 / 三转能力 / 四转能力 / 终转能力
	return (string_pos("转能力", string_copy(_s, 1, 5)) > 0);
}


/// @function info_island_is_title_line(_s)
/// @description 来源 / 卡片分类 / 可用增幅 这三行只说一件事，后面必须换行。
function info_island_is_title_line(_s) {
	if (string_copy(_s, 1, 2) == "来源") return true;
	if (string_copy(_s, 1, 4) == "卡片分类") return true;
	return (string_copy(_s, 1, 4) == "可用增幅");
}


/// @function info_island_ends_sentence(_s)
/// @description 上一行是不是已经说完了（句末标点 / 冒号结尾）。
function info_island_ends_sentence(_s) {
	if (_s == "") return true;
	var _last = string_char_at(_s, string_length(_s));
	return (_last == "。" || _last == "！" || _last == "？" || _last == "…" || _last == "：");
}


/// @function info_island_compose_all()
/// @description 卡表齐了以后，把所有注册过的文案按原文重排一遍。
///   必须在 card_category_init() / mod_cards_init() 之后调用（obj_mod_manager/Create_0）：
///   原版那 83 条是在 Game Start 里注册的，那时既没有分类表也没有卡表。
function info_island_compose_all() {
	if (!variable_global_exists("info_island_raw")) return;
	var _keys = [];
	ds_map_keys_to_array(global.info_island_raw, _keys);
	for (var _i = 0; _i < array_length(_keys); _i++) {
		var _id = _keys[_i];
		global.info_island[? _id] = info_island_build(_id, global.info_island_raw[? _id]);
	}
}


/// @function info_island_category_line(_id)
/// @description 生成 `卡片分类：直射类-B型穿透类`（层数随分类数据 2~4 层；无分类返回空串）。
function info_island_category_line(_id) {
	var _lv = card_get_levels(_id);
	if (array_length(_lv) == 0) return "";

	var _s = "";
	for (var _i = 0; _i < array_length(_lv); _i++) {
		if (_i > 0) _s += "-";
		_s += _lv[_i];
	}
	return "卡片分类：" + _s;
}


/// @function info_island_is_tag_line(_s)
/// @description 判断一整行是不是「纯方括号标签行」（旧写法 `[直射类][B型穿透类]`）。
///   只认整行全由 `[...]` 组构成（组之间允许空格）的行，正文里的 `[攻击力]` 不会命中。
function info_island_is_tag_line(_s) {
	var _len = string_length(_s);
	if (_len < 2) return false;
	if (string_char_at(_s, 1) != "[") return false;
	if (string_char_at(_s, _len) != "]") return false;

	var _depth = 0;
	for (var _i = 1; _i <= _len; _i++) {
		var _c = string_char_at(_s, _i);
		if (_c == "[") {
			_depth++;
		} else if (_c == "]") {
			_depth--;
			if (_depth < 0) return false;
		} else if (_c != " " && _depth <= 0) {
			return false;   // 括号外面还有别的字 → 不是纯标签行
		}
	}
	return (_depth == 0);
}


/// @function info_island_join_lines(_arr)
/// @description 行数组拼回带 "\n" 的文本（等价 array_join，避免低版本兼容问题）。
function info_island_join_lines(_arr) {
	var _out = "";
	for (var _i = 0; _i < array_length(_arr); _i++) {
		if (_i > 0) _out += "\n";
		_out += _arr[_i];
	}
	return _out;
}


/// @function info_island_card_name(_id)
/// @description 取卡 0 形态的名字（注册表没有就退回 id），做增幅源显示用。
function info_island_card_name(_id) {
	if (!info_island_data_ready()) return _id;   // 卡表还没建：别去碰 get_plant_shape_data
	var _d = get_plant_shape_data(_id, 0);
	if (_d != undefined && ds_map_exists(_d, "name")) return _d[? "name"];
	return _id;
}


/// @function info_island_buff_groups()
/// @description 可用增幅的显示分组（数组顺序 = 显示顺序；段内用 `、`，段间用 `丨`）。
///   每段一个数组，元素是 `[源卡 id, 它覆盖的通道 ...]` —— 通道挂在**源卡**上，
///   所以「只吃多向不吃五向」的卡不会把五行蛇列进来（怪味鱿鱼），
///   「无轨迹追踪」的卡也不会列出莓果点心 / 香料虎（恶作剧神）。
///   过火 / 反弹不在这里（源卡太多，按体系名写），见 info_island_buff_line。
function info_island_buff_groups() {
	static _g = [
		[["aurora", "thrower"], ["blueberry_tower", "thrower"], ["fruit_tart", "thrower"],
		 ["nengliangmiao", "thrower"], ["zhuzhujiaqiang", "thrower"]],
		[["hspeed_juicer", "sprayer"], ["mozhang", "sprayer"], ["haiyang_god", "sprayer"]],
		[["mozhang", "sprayer_coffee"], ["haiyang_god", "sprayer_coffee"]],
		[["mozhang", "sprayer_attach"], ["haiyang_god", "sprayer_attach"]],
		[["wuxingshe", "five_dir"], ["fengrao_god", "five_dir", "multi_dir"]],
		[["berry_dessert", "track_berry"], ["xiangliaohu", "track_spice"],
		 ["xiangshui_god", "track_feast", "track_feast4"]],
		[["yinhema", "fixed_track"], ["fushengcha", "fixed_track"], ["xinggui_god", "fixed_track"]],
		[["yanyantu", "production"]],
	];
	return _g;
}


/// @function info_island_buff_line(_id)
/// @description 生成 `可用增幅：A丨B丨C`；一段都不吃时返回 ""（整行不画）。
///   顺序：卡片增幅（子弹 / 喷壶 / 五向 / 多向 / 追踪 / 固定轨迹 / 产能）→ 火盆类 → 反弹类 → **战旗马固定最后**。
///   有特例的卡在「可用增幅」后加括号，文本来自 card_buff_note()。
function info_island_buff_line(_id) {
	var _segs = [];

	var _g = info_island_buff_groups();
	for (var _i = 0; _i < array_length(_g); _i++) {
		var _grp = _g[_i];
		var _names = "";
		for (var _j = 0; _j < array_length(_grp); _j++) {
			var _e = _grp[_j];
			var _hit = false;
			for (var _k = 1; _k < array_length(_e); _k++) {
				if (buff_channel_ok(_id, _e[_k])) { _hit = true; break; }
			}
			if (!_hit) continue;
			if (_names != "") _names += "、";
			_names += info_island_card_name(_e[0]);
		}
		if (_names != "") array_push(_segs, _names);
	}

	var _hz = card_hazard_flags(_id);
	if (_hz.burn)    array_push(_segs, "火盆类增幅");
	if (_hz.rebound) array_push(_segs, "反弹类增幅");

	// 战旗马固定最后。🔴 它不是网格通道、不在 buff_channel_order 里，
	//   buff_channels_has_any 永远查不到它，只能直接问 buff_channel_ok
	if (buff_channel_ok(_id, "zhanqima")) array_push(_segs, info_island_card_name("zhanqima"));

	if (array_length(_segs) == 0) return "";

	var _head = "可用增幅";
	var _note = card_buff_note(_id);
	if (_note != "") _head += "(" + _note + ")";

	var _body = "";
	for (var _j = 0; _j < array_length(_segs); _j++) {
		if (_j > 0) _body += "丨";
		_body += _segs[_j];
	}
	return _head + "：" + _body;
}


/// @function info_island_shape_name(_id, _shape)
/// @description 取这张卡指定形态的名字（形态不存在就退回 0 形态，再退回 id）。
function info_island_shape_name(_id, _shape) {
	if (!info_island_data_ready()) return _id;   // 同上
	var _d = get_plant_shape_data(_id, _shape);
	if (_d == undefined) _d = get_plant_shape_data(_id, 0);
	if (_d != undefined && ds_map_exists(_d, "name")) return _d[? "name"];
	return _id;
}


/// @function info_island_recipe_text(_id)
/// @description 金卡 / 融合卡的前置配方（**形态名**，`+` 连接）；两种都不是返回 ""。
///   金卡读 mod_evo_table（need 按卡自己的形态上限兜底 → 得到「梵音金刚马」这种二转名）；
///   融合读 mod_fusion_table 的三档，排除产物自己、同一张卡只出现一次。
///   两张表都只在这里 cache 一次（原始 API 每次调用都会重建整张表，145 条会白吃）。
function info_island_recipe_text(_id) {
	static _evo = undefined;
	static _fus = undefined;
	if (is_undefined(_evo)) _evo = mod_evo_table();
	if (is_undefined(_fus)) _fus = mod_fusion_table();

	var _out = [];

	if (variable_struct_exists(_evo, _id)) {
		var _cs = _evo[$ _id].cards;
		for (var _i = 0; _i < array_length(_cs); _i++) {
			var _c = _cs[_i];
			array_push(_out, info_island_shape_name(_c.id, mod_evo_need_of(_c.id, _c.need)));
		}
	} else if (variable_struct_exists(_fus, _id)) {
		var _cards = _fus[$ _id].cards;
		var _seen = [_id];                           // 产物自己在深度 / 灵魂档里当主卡，别列出来
		for (var _t = 0; _t < array_length(_cards); _t++) {
			var _pair = _cards[_t];
			for (var _k = 0; _k < 2; _k++) {
				var _cid  = (_k == 0) ? _pair.main.id : _pair.sub.id;
				var _need = (_k == 0) ? _pair.main.need : _pair.sub.need;
				if (_cid == "") continue;
				if (array_contains(_seen, _cid)) continue;
				array_push(_seen, _cid);
				array_push(_out, info_island_shape_name(_cid, mod_fusion_need_shape(_cid, _need)));
			}
		}
	}

	var _s = "";
	for (var _j = 0; _j < array_length(_out); _j++) {
		if (_j > 0) _s += "+";
		_s += _out[_j];
	}
	return _s;
}


/// @function info_island_compose(_id, _txt)
/// @description 情报岛版式统一：来源 → 卡片分类（自动生成）→ 可用增幅 → 空行 → 正文。
///   先删文案里手写的分类行 / 增幅行再按上面结构插回；幂等（重复调用结果不变）。
function info_island_compose(_id, _txt) {
	if (!is_string(_txt)) return _txt;

	// 分类表里有这张卡才删旧标签行；没有的（原版少数几张没进分类表）保留，那是它唯一的分类信息
	var _cat = info_island_category_line(_id);
	var _drop_tags = (_cat != "");

	var _lines = string_split(_txt, "\n");
	var _kept = [];
	var _src_at = -1;
	var _tag_at = -1;

	for (var _i = 0; _i < array_length(_lines); _i++) {
		var _l = _lines[_i];
		var _s = string_trim(_l);
		// 手写分类行 / 手写增幅行一律丢弃（这两行只认数据）
		if (_s != "" && ((info_island_is_tag_line(_s) && _drop_tags)
			|| string_copy(_s, 1, 4) == "卡片分类"
			|| string_copy(_s, 1, 4) == "可用增幅"))
			continue;

		array_push(_kept, _l);
		if (_src_at < 0 && _s != "" && string_copy(_s, 1, 2) == "来源")
			_src_at = array_length(_kept) - 1;
		if (_tag_at < 0 && _s != "" && info_island_is_tag_line(_s))
			_tag_at = array_length(_kept) - 1;
	}

	// 卡表还没建（原版 info_island_init 在 Game Start 里跑）→ 不做任何数据相关的排版，
	//   等 info_island_compose_all() 统一重排
	if (!info_island_data_ready()) return info_island_join_lines(_kept);

	// 来源行末尾追加前置配方（金卡 / 融合卡）：`来源：…丨星火红柳烤串机+梵音金刚马`
	// 幂等：已经有 丨 的先截掉再拼，重复 compose 不会叠加
	var _recipe = info_island_recipe_text(_id);
	if (_src_at >= 0 && _recipe != "") {
		var _sl = _kept[_src_at];
		var _bar = string_pos("丨", _sl);
		if (_bar > 0) _sl = string_copy(_sl, 1, _bar - 1);
		_kept[_src_at] = _sl + "丨" + _recipe;
	}

	var _buff = info_island_buff_line(_id);

	var _head = [];
	if (_cat  != "") array_push(_head, _cat);
	if (_buff != "") array_push(_head, _buff);
	if (array_length(_head) == 0) return info_island_join_lines(_kept);

	var _ins;
	if (_src_at >= 0) {
		_ins = _src_at + 1;
		// 没有自动分类、但保留了旧标签行 → 增幅行插在标签行之后，别顶到标签上面
		if (_cat == "" && _tag_at == _src_at + 1) _ins = _tag_at + 1;
	} else {
		_ins = 0;
		while (_ins < array_length(_kept) && string_trim(_kept[_ins]) == "") _ins++;
	}
	// 原来「分类行」后面本来就跟着一个空行（`分类\n\n正文`），删掉它，
	// 否则插完会变成两个连续空行。幂等：上一次插的空行也在这里被吃掉再补回。
	if (_ins < array_length(_kept) && string_trim(_kept[_ins]) == "")
		array_delete(_kept, _ins, 1);

	// 先插空行、再倒序插头部各行 → 得到「来源 / 分类 / 可用增幅 / 空行 / 正文」
	array_insert(_kept, _ins, "");
	for (var _h = array_length(_head) - 1; _h >= 0; _h--)
		array_insert(_kept, _ins, _head[_h]);

	return info_island_join_lines(_kept);
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
	var _tail_punct = "，。、；：！？）】》」』…%丨+";
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
