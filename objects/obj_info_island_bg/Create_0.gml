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
anim_kids = [[btn1,-1],[btn2,-1],[btn3,-1],[btn_close,1],[btn_edit,1]]
for (var _i = 0; _i < array_length(anim_kids); _i++){
    var _c = anim_kids[_i][0]
    _c.anim_base_x = _c.x
    _c.anim_base_y = _c.y
}
