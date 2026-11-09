/// =====================================================================
/// mod_info_island_search —— 情报岛搜索栏（2026-11-01 从 obj_info_island_bg 拆出来独立维护）
/// 职责：**只管情报岛**（卡片 / 敌人 / 关卡三个页签的名称搜索）。
///   - 通用输入框仍是公共的 obj SearchBox，公共部分一行没动
///   - 位置 / 尺寸 / 配色 / 回调 / 清空 / 过滤判定全部收在这里；
///     obj_info_island_bg 里只留「spawn 一句 + 切页签 clear 一句 + 过滤用 match」
///   - 与合成屋无关，所以放 mod 根目录，不放 mod/Craft
/// =====================================================================

/// @func info_island_search_spawn(px, py, depth)
/// @desc 在 (px,py) 建搜索框并绑到调用方（用 `with (bg)` 回写宿主的过滤词）
///   位置口径（2026-10-31 定，2026-11-05 宽度改 384）：面板左上 (130,118)、384×40 —— 左边对齐列表第 1 列格子的左沿，
///   宽度只占两列；调用方传的就是这两个数，改位置只改调用处一处
function info_island_search_spawn(_px, _py, _depth){
    var _sb = instance_create_depth(_px, _py, _depth, SearchBox);
    _sb.set_position(_px, _py)
       .set_size(384, 40)      // 宽 384 = 正好卡到列表第 3 格左沿（130 + 384 = 514），不会压卡片
       .set_placeholder("搜索名称/[分类名](支持拼音)")
       .set_theme({
            bg:           make_colour_rgb(3, 43, 80),
            bg_focus:     make_colour_rgb(8, 62, 112),
            border:       make_colour_rgb(120, 190, 240),
            border_focus: make_colour_rgb(200, 240, 255),
            text:         c_white,
            placeholder:  make_colour_rgb(150, 195, 230)
       })
       .set_on_change(method({ bg: id }, function(_t) {
            with (bg) {
                info_search_text = _t;
                select_card_index = -1;   // 结果变了，原来的选中项可能已不存在
                y_offset = 0;
                y_offset_target = 0;
            }
       }))
       .set_should_correspond(method({ bg: id }, function() {
            // 面板在动画 / 已销毁 / 有子弹窗时都不接受输入（instance_exists 兜底，避免关闭那帧读越界）
            return (instance_exists(bg) && bg.pnl_o > 0.5 && !bg.is_submenu_opened);
       }));
    return _sb;
}

/// @func info_island_search_clear(bg)
/// @desc 切页签清空：过滤词 + 搜索框文字 + **全局 keyboard_string**
///   ⚠️ 只 set_text("") 不够：SearchBox 每帧会从 keyboard_string 同步文字，不清它下一帧旧文字又回来
function info_island_search_clear(_bg){
    if (!instance_exists(_bg)) return;
    with (_bg){
        info_search_text = "";
        keyboard_string = "";
        if (variable_instance_exists(id, "info_search_box") && instance_exists(info_search_box)){
            info_search_box.set_text("");
        }
    }
}

/// @func info_island_search_match(query_lower, text)
/// @desc 过滤判定：不区分大小写的子串匹配；query 为空 = 全部通过
///   query 由调用方统一 `string_lower()` 一次，循环里别反复转
function info_island_search_match(_q, _text){
    if (_q == "") return true;
    if (!is_string(_text)) return false;
    return (string_pos(_q, string_lower(_text)) > 0);
}

// ─────────────────────────────────────────────────────────────────────────────
//  卡片分类检索（2026-11-03 用户批准「B 档：分类名 + 别名 + 空格分词」，**不做命中提示**）
//    只作用于「卡片」页签；敌人 / 关卡两个页签仍走 info_island_search_match（按名字）
//    分类数据源：card_buff_category 的 card_get_category()（12 大类 / 46 小分类 / 13 子分类）
// ─────────────────────────────────────────────────────────────────────────────

/// @func info_island_search_alias_table()
/// @desc 口语别名 → 分类名（可多个）。搜「平射」时把「直射类」和「平射增幅」都带上
///   只收「玩家真的会这么打」的词；加词就加一行，别在匹配函数里写分支
///   2026-11-06：别名本身也能用拼音搜（`[toushou]` / `[toush]` → 投手 → 投掷类 / 单线投手…），不用另建表
function info_island_search_alias_table(){
    return [
        ["平射",   ["直射类", "平射增幅"]],
        ["投手",   ["投掷类", "灼烧投手", "单线投手", "多线投手"]],
        ["投掷",   ["投掷类"]],
        ["喷壶",   ["喷壶类"]],
        ["防空",   ["专业防空类", "纯对空类", "陆空兼备类"]],
        ["产火",   ["产能类", "主职产火"]],
        ["护罩",   ["防御类", "护罩类"]],
        ["面包",   ["防御类", "面包类"]],
        ["水管",   ["水管类"]],
        ["三线",   ["三线类"]],
        ["海星",   ["海星类", "类海星类"]],
        ["鱼刺",   ["鱼刺类"]],
        ["追踪",   ["追踪类"]],
        ["灰烬",   ["灰烬类"]],
        ["增幅",   ["增幅类"]],
        ["辅助",   ["辅助类"]],
        ["防御",   ["防御类"]],
        ["产能",   ["产能类"]],
        ["远程",   ["直射类", "投掷类", "多向类", "喷壶类", "追踪类", "专业防空类"]]
    ];
}

/// @func info_island_search_words(query)
/// @desc 过滤词 → 「词组」数组：**组内是「或」、组之间是「且」**
///   分组（且）：空格 / 全角空格 / Tab
///   组内或：`,`  `，`  `|`  `或`
///   每个替代词是一个 [关键词(小写), 是否分类检索] 的小数组：
///     - 词里出现过 `[ ]` `【 】` → **分类检索**（查大类 / 小分类 / 子分类 + 别名表）
///     - 没出现过括号 → **只查卡名**（含各转职形态名；拼音索引以后接在同一处）
///   例：`[喷壶类]`、`[喷壶类,防御类]`、`【面包】` 走分类；`喷壶` 只按名字找
///   2026-11-05 用户口径：分类必须打括号，和普通名字搜索区分开 —— 否则「面包」这种
///   既是卡名一部分、又是分类名的词会一起命中，容易看错结果
///   在过滤循环**外**调一次，循环里别反复切
function info_island_search_words(_q){
    var _groups = [];
    var _alts = [];
    var _cur = "";
    var _cur_cat = false;
    var _in_bracket = false;
    var _n = string_length(_q);

    for (var _i = 1; _i <= _n; _i++){
        var _ch = string_char_at(_q, _i);

        // 括号只是「这段是分类检索」的标记，本身不进关键词
        if (_ch == "[" || _ch == "【"){ _in_bracket = true; continue; }
        if (_ch == "]" || _ch == "】"){ _in_bracket = false; continue; }

        var _is_group_sep = (_ch == " " || _ch == "　" || _ch == "\t");
        var _is_alt_sep   = (_ch == "," || _ch == "，" || _ch == "|" || _ch == "或");

        if (_is_group_sep || _is_alt_sep){
            if (_cur != ""){
                var _kw = string_lower(_cur);
                var _dup = false;
                for (var _d = 0; _d < array_length(_alts); _d++){
                    if (_alts[_d][0] == _kw) _dup = true;
                }
                if (!_dup) array_push(_alts, [_kw, _cur_cat]);
                _cur = "";
                _cur_cat = false;
            }
            if (_is_group_sep && array_length(_alts) > 0){
                array_push(_groups, _alts);
                _alts = [];
            }
        }
        else{
            if (_cur == "") _cur_cat = _in_bracket;   // 词的属性由「起始位置在不在括号内」决定
            _cur += _ch;
        }
    }
    if (_cur != ""){
        var _kw2 = string_lower(_cur);
        var _dup2 = false;
        for (var _d2 = 0; _d2 < array_length(_alts); _d2++){
            if (_alts[_d2][0] == _kw2) _dup2 = true;
        }
        if (!_dup2) array_push(_alts, [_kw2, _cur_cat]);
    }
    if (array_length(_alts) > 0) array_push(_groups, _alts);

    return _groups;
}

/// @func info_island_search_cat_hit(keyword_lower, cat_names)
/// @desc 分类词命中（2026-11-06 加拼音）：
///   ① 分类名（大类 / 小分类 / 子分类）中文子串
///   ② 分类名拼音 —— `[toush` / `[toushou` / `[ts` 都能出「投掷类」「单线投手」这类
///   ③ 别名表：中文精确匹配 **或** 别名拼音（`[mianbao` → 面包 → 防御类 / 面包类）
///   拼音走 scripts/mod_info_island_pinyin 的通用 `py_hit_text`，末字允许只打一半
function info_island_search_cat_hit(_kw, _cat){
    static _alias_tbl = undefined;          // 别名表只建一次（每帧每卡都重建太浪费）
    if (_alias_tbl == undefined) _alias_tbl = info_island_search_alias_table();

    // ① 分类名中文子串
    for (var _i = 0; _i < array_length(_cat); _i++){
        if (_cat[_i] != "" && string_pos(_kw, _cat[_i]) > 0) return true;
    }
    // ② 分类名拼音（只对三种分类名做，不碰卡名）
    for (var _p = 0; _p < array_length(_cat); _p++){
        if (_cat[_p] != "" && py_hit_text(_cat[_p], _kw)) return true;
    }
    // ③ 别名 → 分类：中文精确匹配，或别名拼音命中
    for (var _a = 0; _a < array_length(_alias_tbl); _a++){
        if (_alias_tbl[_a][0] != _kw && !py_hit_text(_alias_tbl[_a][0], _kw)) continue;
        var _targets = _alias_tbl[_a][1];
        for (var _t = 0; _t < array_length(_targets); _t++){
            var _tg = string_lower(_targets[_t]);
            for (var _c = 0; _c < array_length(_cat); _c++){
                if (_cat[_c] != "" && string_pos(_tg, _cat[_c]) > 0) return true;
            }
        }
    }
    return false;
}

/// @func info_island_search_match_card(groups, card_id)
/// @desc 卡片页签的过滤判定
///   **每个词组至少命中一个替代词**（组间「且」、组内「或」）；全部命中才留下这张卡
///   命中来源按词的类型分：
///     - 分类词（带括号）：大类 / 小分类 / 子分类 + 别名表（[喷壶] → 喷壶类），**支持拼音与半截拼音**
///     - 普通词：**只看卡名**，且任意形态名都能命中（麻辣香锅 → 酱香鱿鱼锅 也能搜到）
///   拼音（全拼 / 首字母 / 末字半截）两类词都支持（2026-11-05 普通词、2026-11-06 分类词）
function info_island_search_match_card(_groups, _cid){
    if (array_length(_groups) == 0) return true;

    // ① 所有形态的名字（0~3 形态，取不到就跳）
    var _names = [];
    for (var _sh = 0; _sh < 4; _sh++){
        var _sd = get_plant_shape_data(_cid, _sh);
        if (_sd == undefined) continue;
        if (!ds_map_exists(_sd, "name")) continue;
        array_push(_names, string_lower(string(_sd[? "name"])));
    }
    if (array_length(_names) == 0) array_push(_names, string_lower(string(_cid)));

    // ② 分类（只有分类词才用；普通词不查分类）
    var _cat = [];
    var _c = card_get_category(_cid);
    if (_c != undefined){
        array_push(_cat, string_lower(_c.major), string_lower(_c.minor), string_lower(_c.sub));
    }

    for (var _g = 0; _g < array_length(_groups); _g++){
        var _alts = _groups[_g];
        var _group_hit = false;

        for (var _a = 0; _a < array_length(_alts); _a++){
            var _kw = _alts[_a][0];
            var _is_cat = _alts[_a][1];

            if (_is_cat){
                // ── 分类词：中文子串 → 拼音 → 别名（中文 / 拼音）──
                _group_hit = info_island_search_cat_hit(_kw, _cat);
            }
            else{
                // ── 普通词：先查卡名（任一形态名命中即可）──
                for (var _ni = 0; _ni < array_length(_names); _ni++){
                    if (_names[_ni] != "" && string_pos(_kw, _names[_ni]) > 0){ _group_hit = true; break; }
                }
                // 名字没命中 → 再查拼音（全拼 / 首字母 / 末字半截，2026-11-05 实装）
                //   表与索引都在 scripts/mod_info_island_pinyin
                if (!_group_hit) _group_hit = info_island_pinyin_hit(_cid, _kw);
            }

            if (_group_hit) break;
        }

        if (!_group_hit) return false;   // 组间「且」：任一组没命中就整卡排除
    }
    return true;
}
