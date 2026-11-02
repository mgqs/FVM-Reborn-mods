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
///   位置口径（2026-10-31 定）：面板左上 (130,118)、250×40 —— 左边对齐列表第 1 列格子的左沿，
///   宽度只占两列；调用方传的就是这两个数，改位置只改调用处一处
function info_island_search_spawn(_px, _py, _depth){
    var _sb = instance_create_depth(_px, _py, _depth, SearchBox);
    _sb.set_position(_px, _py)
       .set_size(250, 40)
       .set_placeholder("搜索名称")
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
