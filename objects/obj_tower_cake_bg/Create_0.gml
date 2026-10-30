image_xscale = 0.9
image_yscale = 0.9
image_speed = 0

texture_prefetch("enemy_tower")
texture_prefetch("enemy_delicious")
texture_prefetch("enemy_volcanic")

instance_create_depth(x+810,y-472,depth-1,obj_closetowercake_btn)

is_submenu_opened = false
current_page = global.tower_cake_page
total_page = 5
level_select = -1
real_level_index = -1
menu_music = mus_menu

reward_button_list = []
level_button_list = []

map_surface = -1

var page_btn1 = instance_create_depth(x-695,y+495,depth-1,obj_tower_cake_page_btn)
page_btn1.sprite_index = spr_tower_cake_page_btn
page_btn1.btn_type = "prev"
var page_btn2 = instance_create_depth(x-605,y+495,depth-1,obj_tower_cake_page_btn)
page_btn2.sprite_index = spr_tower_cake_page_btn
page_btn2.btn_type = "next"
var page_btn3 = instance_create_depth(x-750,y+495,depth-1,obj_tower_cake_page_btn)
page_btn3.sprite_index = spr_tower_cake_page_set_btn
page_btn3.btn_type = "min"
var page_btn4 = instance_create_depth(x-550,y+495,depth-1,obj_tower_cake_page_btn)
page_btn4.sprite_index = spr_tower_cake_page_set_btn
page_btn4.btn_type = "max"

instance_create_depth(x+608,y+470,depth-1,obj_tower_cake_start_btn)
refresh_level_button()
//for(var i = 0 ; i < 15 ; i ++){
//	instance_create_depth(x-648,y+438-56*i,depth-1,obj_tower_cake_level_btn)
//}

//var inst = instance_create_depth(x+608,y-280,depth-2,obj_tower_cake_card_reward)
//inst.target_card_id = "small_fire"
//inst.target_shape = 1
//inst.unlocked = true
//var inst2 = instance_create_depth(x+744,y-280,depth-3,obj_tower_cake_card_reward)
//inst2.target_card_id = "gatlin_long_bao"
//inst2.target_shape = 1
//inst2.unlocked = true
//var inst3 = instance_create_depth(x+472,y-280,depth-1,obj_tower_cake_card_reward)
//inst3.target_card_id = "goblet_lamp"
//inst3.target_shape = 1
//inst3.unlocked = true

function refresh_level_button(){
	instance_destroy(obj_tower_cake_level_btn)
	var level_list = global.maps_map[? "tower_cake"].levels_data
	for(var i = 0 ;i < 15;i++){
		var level_index = i + 15 * (current_page - 1)
		if level_index < array_length(level_list){
			var c_level_data = level_list[level_index]
			var inst = instance_create_depth(x-648,y+438-56*i,depth-1,obj_tower_cake_level_btn)
			inst.btn_index = i
			var _wf_n = min(15, array_length(level_list) - 15 * (current_page - 1))
			inst.wf_y0 = inst.y
			inst.wf_dur = 18
			inst.wf_t = ui_anim_on(2) ? -(max(0, _wf_n - 1 - i) * 2) : 18
			inst.image_alpha = (inst.wf_t < 0) ? 0 : 1
			inst.level_index = level_index
			inst.btn_text = string((level_index div 2) + 1) + "-" + string((level_index mod 2) + 1)
		
			if (array_get_index(global.save_data.completed_levels,c_level_data.pre_level) != -1) || c_level_data.pre_level == "none"{
				inst.is_unlocked = true
			}
		}
		else{
			break
		}
	}
}

function refresh_reward_button(){
	instance_destroy(obj_tower_cake_card_reward)
	var level_list = global.maps_map[? "tower_cake"].levels_data
	var c_level_data = level_list[real_level_index]
	// 2026-10-27：奖励格改画「威望」——每条 rewards 一格（0 = 首通 / 1 = 次通），布局一行没动
	var _cleared = (array_get_index(global.save_data.completed_levels, c_level_data.id) != -1)
	for(var i = 0 ; i < array_length(c_level_data.rewards);i++){
		var _r = c_level_data.rewards[i]
		if (!variable_struct_exists(_r, "prestige")) continue
		var inst = instance_create_depth(x+472+136*i,y-280,depth-i-1,obj_tower_cake_card_reward)
		inst.prestige_amount = _r.prestige
		inst.reward_kind = ((i == 0) ? "first" : "repeat")
		inst.btn_index = i + 1
		// 已通关 → 首通那格盖灰（首通只发一次）；次通格一直亮（能反复刷）
		inst.dimmed = (_cleared && i == 0)
	}
}

// 2026-10-27：原来这里会把「已通关关卡 + 卡已拥有 + 形态没到」的卡片奖励**自动补形态**，
//   并弹「未领取的转职奖励已自动领取」。魔塔奖励改成威望后这段整块删掉：
//   ① 塔关 rewards 里已经没有 card_id ② 威望在通关结算里直接发（obj_battle_pause_manager/Step_2），
//   不需要也不允许在进界面时补发。
