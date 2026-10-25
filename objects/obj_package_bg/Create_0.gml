image_xscale = 1.8
image_yscale = 1.8
instance_create_depth(x+380,y+403,depth-1,obj_closepackage_btn)
package_cols = 9 //背包格子行列数
package_rows = 16
info_button_select = 1
package_button_select = 1
is_submenu_opened = false
gem_start_line = 0
y_offset = 0
package_surface = -1
y_offset_target = 0
sb_dragging = false
sb_drag_y = 0
sb_drag_offset = 0
pg_t_l = -1
pg_t_r = -1
pg_frames = 13
//创建背包栏位选择按钮
var btn1 = instance_create_depth(x-300,y-455,depth-1,obj_packageselect_btn)
btn1.type = "Package"
btn1.button_index = 1
btn1.sprite_index = spr_packageselect_btn_1
var btn2 = instance_create_depth(x-70,y-455,depth-1,obj_packageselect_btn)
btn2.type = "Package"
btn2.button_index = 2
btn2.sprite_index = spr_packageselect_btn_2
var btn5 = instance_create_depth(x+160,y-455,depth-1,obj_packageselect_btn)
btn5.type = "Package"
btn5.button_index = 3
btn5.sprite_index = spr_packageselect_btn_5
// 第 4 页签「凭证」：sprite 为 81×31 窄版（左右边框不压扁），1.8 缩放 = 146×56，高度与前三个一致
var btn7 = instance_create_depth(x+347,y-455,depth-1,obj_packageselect_btn)
btn7.type = "Package"
btn7.button_index = 4
btn7.sprite_index = spr_packageselect_btn_7
btn7.image_xscale = 1.8
btn7.image_yscale = 1.8
var btn3 = instance_create_depth(x-1170,y-454,depth-1,obj_packageselect_btn)
btn3.type = "Player Info"
btn3.button_index = 1
btn3.sprite_index = spr_packageselect_btn_3
var btn4 = instance_create_depth(x-1020,y-454,depth-1,obj_packageselect_btn)
btn4.type = "Player Info"
btn4.button_index = 2
btn4.sprite_index = spr_packageselect_btn_4
var btn6 = instance_create_depth(x-870,y-454,depth-1,obj_packageselect_btn)
btn6.type = "Player Info"
btn6.button_index = 3
btn6.sprite_index = spr_packageselect_btn_6

hover_card_index = -1; // 当前悬停的卡片索引
deck_sort_order = [] // 卡片排序映射（普通卡在前 → 融合卡居中 → 金卡在后）
hover_weapon_index = -1
hover_gem_index = -1
hover_material_index = -1
hover_transfer_index = -1
view_max_shapes = 0

panel_anim_init(id, 0.28, 0.18, 260, 1);
panel_anim_kids(id, [obj_closepackage_btn, obj_packageselect_btn,
    obj_card_edit_menu, obj_card_edit_select_btn, obj_card_edit_btn,
    obj_card_attire_menu, obj_card_attire_select_btn,
    obj_gem_edit_menu, obj_gem_edit_select_btn, obj_gem_edit_btn]);
