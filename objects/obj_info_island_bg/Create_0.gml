image_xscale = 1.8
image_yscale = 1.8
var btn_close = instance_create_depth(x+380,y-400,depth-1,obj_closeinfo_btn)
info_cols = 4 //防御卡信息行列数
info_rows = 40
info_button_select = 1
//package_button_select = 1
is_submenu_opened = false
//创建信息栏位选择按钮
var btn1 = instance_create_depth(x-1130,y-455,depth-1,obj_info_island_select_btn)
btn1.button_index = 1
btn1.sprite_index = spr_info_island_select_btn_1
var btn2 = instance_create_depth(x-870,y-455,depth-1,obj_info_island_select_btn)
btn2.button_index = 2
btn2.sprite_index = spr_info_island_select_btn_2
var btn3 = instance_create_depth(x-610,y-455,depth-1,obj_info_island_select_btn)
btn3.button_index = 3
btn3.sprite_index = spr_info_island_select_btn_3

var btn_edit = instance_create_depth(x+320,y-320,depth-1,obj_info_island_edit_btn)

hover_card_index = -1; // 当前悬停的卡片索引
hover_weapon_index = -1
select_card_index = -1
deck_sort_order = [] // 卡片排序映射（普通卡在前 → 融合卡居中 → 金卡在后）

view_card_level = 0
view_card_shape = 0
view_card_skill = 0

info_surface = -1
surface_width = 900
surface_height = 780

y_offset = 0

// 滚动条状态
scrollbar_dragging = false
scrollbar_drag_start_y = 0
scrollbar_drag_start_offset = 0
scrollbar_x = 0
scrollbar_y = 0
scrollbar_w = 17
scrollbar_h = 0
y_offset_target = 0
anim_slide = 360
panel_anim_init(id, 0.28, 0.18, anim_slide)
anim_surf = -1

// ── 搜索栏（2026-10-31）：用工程通用 SearchBox，左上角、三个页签共用 ──
//   位置 / 尺寸：(130,118) 250×40 —— 左边对齐列表第 1 列格子的左沿（列表格左沿 = x-1154-96 = 130），
//   宽度只占两列（130~380），不再捅出面板、也不压到第 3 列
//   口径：卡片页搜卡名 / 敌人页搜敌人名 / 关卡页搜关卡名；**切页签清空**（见 Draw_0 的 tab_shown 段）
info_search_text = "";        // 当前过滤词（小写比较在 Draw 里做）
info_view = [];               // 当前页签的可见条目：tab1 = player_deck 下标 / tab2·3 = id
var _sb = instance_create_depth(130, 118, depth - 1, SearchBox);
_sb.set_position(130, 118)
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
info_search_box = _sb;

anim_kids = [[btn1,-1],[btn2,-1],[btn3,-1],[btn_close,1],[btn_edit,1]]
for (var _i = 0; _i < array_length(anim_kids); _i++){
    var _c = anim_kids[_i][0]
    _c.anim_base_x = _c.x
    _c.anim_base_y = _c.y
}
