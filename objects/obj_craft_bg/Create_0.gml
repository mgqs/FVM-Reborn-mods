image_xscale = 0.9
image_yscale = 0.9

is_submenu_opened = false
button_select = 0

instance_create_depth(x+785,y-466,depth-1,obj_closecraft_btn)
instance_create_depth(x-305,y+220,depth-1,obj_craft_confirm_btn)

var btn1 = instance_create_depth(x-661,y-50,depth-1,obj_craft_select_btn)
btn1.button_index = 0
btn1.text_spr = spr_craft_card_text
var btn2 = instance_create_depth(x-661,y+100,depth-1,obj_craft_select_btn)
btn2.button_index = 1
btn2.text_spr = spr_craft_gem_text

card_material_id_list = ["natural_spices","secret_spices","royal_spices","clover_1","clover_2","clover_3","clover_4"]
gem_material_id_list = ["less_crystal","middle_crystal","advanced_crystal"]


hover_card_index = -1
hover_gem_index = -1
craft_sort_order = []
close_timer = -1

y_offset = 0
card_surface = -1

current_uprade_target_id = ""

spices_use_order = ["natural_spices","secret_spices","royal_spices"]
clover_use_order = ["clover_1","clover_2","clover_3","clover_4"]
crystal_use_order = ["less_crystal","middle_crystal","advanced_crystal"]

// 概率强化 / 失败掉星 / 保险金 三个开关：同一排放在纸卷顶部空白带（再往下会被香料槽挡住）
rate_toggle_x = x - 600
rate_toggle_y = y - 105
rate_toggle_hover = false

dropstar_toggle_x = x - 420
dropstar_toggle_y = y - 105
dropstar_toggle_hover = false

assure_badge_cx = x - 90
assure_badge_cy = y + 140
assure_toggle_x = x - 90
assure_toggle_y = y + 202
assure_toggle_hover = false