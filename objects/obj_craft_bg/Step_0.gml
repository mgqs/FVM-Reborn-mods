// ── 融合确认弹窗（系统提示）：开着就吃掉本帧所有输入，只处理「确定 / 取消」──
// 放在最前面 + exit：底下的页签、档位、卡格、概率强化开关一概点不到（模态）
if (fusion_confirm){
	fusion_confirm_hover = -1;
	for (var _ci = 0; _ci < 2; _ci++){
		var _cr = fusion_confirm_rect(_ci);
		if (point_in_rectangle(mouse_x, mouse_y, _cr[0], _cr[1], _cr[2], _cr[3])) fusion_confirm_hover = _ci;
	}
	if (mouse_check_button_pressed(mb_left) && fusion_confirm_hover != -1){
		if (fusion_confirm_hover == 0){        // 确定 → 开演（融合剂在演出结束那帧真扣，见下）
			fusion_confirm = false;
			fusion_phase = 1;
			fusion_t = 0;
		}
		else{                                  // 取消 → 什么都不做
			fusion_confirm = false;
		}
		audio_play_sound(snd_button,0,0);
	}
	craft_tab_hover = -1;
	rate_toggle_hover = false;
	assure_toggle_hover = false;
	// 弹窗期间把合成屋的 X 藏起来（GM 的鼠标事件不派发给 visible=false 的实例 → 也点不到）
	with (obj_closecraft_btn) visible = !other.fusion_confirm;
	exit;
}

// ── 顶部页签切换：卡片宝石 / 食灵融合（2026-10-23）──
craft_tab_hover = -1
if point_in_rectangle(mouse_x, mouse_y, tab_cardgem_x, tab_cardgem_y, tab_cardgem_x + sprite_get_width(spr_craft_tab_cardgem)*craft_tab_scale, tab_cardgem_y + sprite_get_height(spr_craft_tab_cardgem)*craft_tab_scale)
	craft_tab_hover = 0
else if point_in_rectangle(mouse_x, mouse_y, tab_fusion_x, tab_fusion_y, tab_fusion_x + sprite_get_width(spr_craft_tab_fusion)*craft_tab_scale, tab_fusion_y + sprite_get_height(spr_craft_tab_fusion)*craft_tab_scale)
	craft_tab_hover = 1
if (mouse_check_button_pressed(mb_left) && craft_tab_hover != -1 && craft_tab_hover != craft_top_tab){
	craft_top_tab = craft_tab_hover
	current_uprade_target_id = ""
	// 切页签 = 融合页重开：装填状态和「刚融出来的临时结果卡」一起清掉
	fusion_stage = 0
	fusion_phase = 0
	fusion_t = 0
	fusion_loaded_id = ""
	fusion_fly_hold = 0
	fusion_fly_t = 0
	fusion_result_out = false
	audio_play_sound(snd_button,0,0)
}
// 页签切到融合时把「卡片强化 / 宝石强化」两个按钮和强化按钮藏起来，免得点到
// ⚠️ with 里要用 other. 取本实例的变量，直接写 craft_top_tab 会被解析成目标实例的变量 → 报 not set
with (obj_craft_select_btn) visible = (other.craft_top_tab == 0)
with (obj_craft_confirm_btn) visible = (other.craft_top_tab == 0)
with (obj_closecraft_btn) visible = true     // 弹窗关掉后恢复（弹窗分支里会被隐藏）

// ── 食灵融合页：档位按钮 + 融合按钮 + 演出计时（纯演出，不判断任何前置、不消耗）──
if (craft_top_tab == 1){
	// 热区全部用 Create_0 算好的 fusion_* 几何（与 Draw_0 同一套，别再本地换算）
	var _lvs = fusion_ssy
	var _lvx = fusion_lx + 6 * fusion_ssx
	var _cfg = fusion_levels[fusion_level - 1]
	var _shape = _cfg.shape

	// 右侧列表的滚动上限（Draw 只读这两个值，滚轮在 Mouse_60/61 改 *_scroll_t）
	fusion_rows_recipe_max = max(0, ceil(array_length(fusion_recipe_list(_shape)) / fusion_gcols) - fusion_grows1)
	fusion_rows_card_max = max(0, ceil(array_length(fusion_card_list(fusion_level)) / fusion_gcols) - fusion_grows2)
	fusion_recipe_scroll_t = clamp(fusion_recipe_scroll_t, 0, fusion_rows_recipe_max)
	fusion_card_scroll_t = clamp(fusion_card_scroll_t, 0, fusion_rows_card_max)

	// 左侧四档：初级 / 深度 / 灵魂（演出中不让切）
	if fusion_phase != 1{
		for (var _li = 0; _li < 3; _li++){
			var _ly = fusion_ly + (100 + _li*55)*_lvs
			if point_in_rectangle(mouse_x, mouse_y, _lvx, _ly, _lvx + 55*_lvs, _ly + 59*_lvs){
				if mouse_check_button_pressed(mb_left) && fusion_level != _li + 1{
					fusion_level = _li + 1
					fusion_phase = 0
					fusion_t = 0
					fusion_stage = 0
					fusion_fly_hold = 0
					fusion_fly_t = 0
					fusion_result_out = false
					fusion_loaded_id = ""
					audio_play_sound(snd_button,0,0)
				}
			}
		}
	}

	// 卡片升阶 → 切回「卡片宝石」页
	var _uy = fusion_ly + 265*_lvs
	fusion_up_hover = point_in_rectangle(mouse_x, mouse_y, _lvx, _uy, _lvx + 55*_lvs, _uy + 59*_lvs)
	if fusion_up_hover && mouse_check_button_pressed(mb_left){
		craft_top_tab = 0
		audio_play_sound(snd_button,0,0)
	}

	// ── 融合菜谱格：点一下装填，再点一下（或点菜谱槽）卸下 ──
	if mouse_check_button_pressed(mb_left) && fusion_phase != 1{
		var _rcp_ids = fusion_recipe_list(_shape)
		var _r_off = floor(fusion_recipe_scroll)
		for (var _i1 = _r_off*fusion_gcols; _i1 < min(array_length(_rcp_ids), (_r_off + fusion_grows1)*fusion_gcols); _i1++){
			var _cid1 = _rcp_ids[_i1];
			if (fusion_stage >= 1 && _cid1 == fusion_loaded_id) continue;
			var _cx = fusion_g1x + (_i1 mod fusion_gcols)*fusion_gpx
			var _cy = fusion_g1y + (_i1 div fusion_gcols - _r_off)*fusion_gpy
			if point_in_rectangle(mouse_x, mouse_y, _cx - fusion_gpx*0.5, _cy - fusion_gpy*0.5, _cx + fusion_gpx*0.5, _cy + fusion_gpy*0.5){
				var _rid = _rcp_ids[_i1]
				if (fusion_loaded_id == _rid){
					fusion_stage = 0
					fusion_fly_hold = 0
					fusion_fly_t = 0
					fusion_result_out = false
					fusion_loaded_id = ""
				}
				else{
					fusion_loaded_id = _rid
					fusion_stage = 1
					fusion_phase = 0
					fusion_t = 0
				}
				audio_play_sound(snd_button,0,0)
				break
			}
		}
		// 点「融合菜谱」槽 = 卸下（跟强化页点卡槽取回一个手感）
		var _s0x = fusion_ppx + fusion_slot_x[0]*fusion_ssx
		var _s0y = fusion_ppy + fusion_slot_prop_y*fusion_ssy
		if ((fusion_stage >= 1) && point_in_rectangle(mouse_x, mouse_y, _s0x, _s0y, _s0x + 58*fusion_ssx, _s0y + 58*fusion_ssy)){
			fusion_stage = 0
			fusion_fly_hold = 0
			fusion_fly_t = 0
			fusion_result_out = false
			fusion_loaded_id = ""
			audio_play_sound(snd_button,0,0)
		}
	}

	// ── 融合按钮：装满了才能点 ──
	fusion_btn_hover = point_in_rectangle(mouse_x, mouse_y,
		fusion_ppx + fusion_btn_x*fusion_ssx, fusion_ppy + fusion_btn_y*fusion_ssy,
		fusion_ppx + (fusion_btn_x+161)*fusion_ssx, fusion_ppy + (fusion_btn_y+44)*fusion_ssy)
	if fusion_btn_hover && mouse_check_button_pressed(mb_left) && fusion_phase != 1{
		// 前置判定跟 Draw 的按钮共用 fusion_check()，提示词也由它给（缺什么说什么）
		var _chk = fusion_check();
		if (!_chk.ok){
			show_notice(_chk.reason, 80)
		}
		else{
			// 都满足了 → 弹「系统提示」确认，点确定才开演（扣金币 / 融合剂 / 食谱在演出结束那帧）
			fusion_confirm = true
			fusion_confirm_hover = -1
			audio_play_sound(snd_button,0,0)
		}
	}

	// ── 演出计时 → 出结果 ──
	if fusion_phase == 1{
		fusion_t += 1
		if fusion_t >= 62{
			fusion_phase = 0
			fusion_t = 0
			fusion_stage = 2
			fusion_fly_hold = 28
			fusion_fly_t = 0
			fusion_result_out = false
			// 金币真扣（弹窗文案就是「是否消耗金币继续」，不扣等于白嫖）
			if (global.save_data.player.gold >= _cfg.gold){
				global.save_data.player.gold -= _cfg.gold
			}
			// 融合剂真扣（卡不扣，只走动画）
			if (get_material_amount(_cfg.mat) >= _cfg.mat_n){
				add_material_amount(_cfg.mat, -_cfg.mat_n)
			}
			// 食谱（融合凭证）扣 1 本：诸神商店卖的是可持有道具，用掉就少一本
			var _recipe_item = fusion_recipe_item_id(fusion_loaded_id, _cfg.shape)
			if (get_material_amount(_recipe_item) > 0) add_material_amount(_recipe_item, -1)
			// 结果卡真进存档（原来只播动画，白扣材料拿不到卡）；unlock_card 内部取 max，不会把已练的形态降下来
			unlock_card(fusion_loaded_id, 0, _cfg.shape, 0)
			// 「融合XX成功」的飘字提示去掉（用户要求不要了），结果直接看结果槽
		}
	}

	// ── 融合完成后的飞卡计时：结果槽停一会 → 卡飞出去（离开结果槽）→ 24 帧后落地 ──
	if (fusion_stage == 2){
		if (!fusion_result_out){
			if (fusion_fly_hold > 0){
				fusion_fly_hold -= 1;
			}
			else{
				fusion_result_out = true;
				fusion_fly_t = 1;
			}
		}
		else if (fusion_fly_t > 0){
			if (fusion_fly_t < 24) fusion_fly_t += 1;   // 到 24 停住 = 已落地，卡留在那格里（列表刷新才清）
		}
	}
}
else{
	fusion_phase = 0
	fusion_t = 0
	fusion_btn_hover = false
	fusion_up_hover = false
}

// 概率强化 = 总开关：关掉时「保险金」一并关掉
// 「失败掉星」已内置进概率强化 —— 没有独立开关，开着就一定掉（5★ 及以下免疫）
// 热区要连右侧文字一起算（原来只到 +18，点「概率强化」四个字是点不到的）
// ⚠️ 只在「卡片宝石」页生效：融合页（craft_top_tab == 1）右边没有 exit，
//    这个热区正好压在融合场景的锅左侧 → 点场景会静默改开关 + 写 config.ini
rate_toggle_hover = (craft_top_tab == 0) && point_in_rectangle(mouse_x, mouse_y, rate_toggle_x-18, rate_toggle_y-18, rate_toggle_x+118, rate_toggle_y+18)
if mouse_check_button_pressed(mb_left) && rate_toggle_hover{
	var _s = craft_rate_settings()
	_s.enabled = !_s.enabled
	if !_s.enabled{
		_s.assure_enabled = false
	}
	audio_play_sound(snd_button,0,0)
	ini_open("config.ini")
	ini_write_bool("settings","craft_rate_enabled",_s.enabled)
	ini_write_bool("settings","craft_assure_enabled",_s.assure_enabled)
	ini_close()
	if _s.enabled show_notice("概率强化已开启",60)
	else show_notice("概率强化已关闭",60)
}

// 保险金开关点击（在徽章上：点徽章或下面那个勾选框都算；只在卡片强化页）
// 保险金是单独开关，但必须建立在「概率强化」开着的前提下（掉星内置在概率强化里，开概率强化才有星可保）
assure_toggle_hover = false
if (button_select == 0 && craft_top_tab == 0){
	assure_toggle_hover = point_in_rectangle(mouse_x, mouse_y, assure_badge_cx-33, assure_badge_cy-36, assure_badge_cx+33, assure_toggle_y+18)
	if mouse_check_button_pressed(mb_left) && assure_toggle_hover{
		var _a = craft_rate_settings()
		if !_a.enabled{
			show_notice("要先开启[概率强化]",80)
		}
		else{
			// 开启前先算清「本次强化总共要花多少金币」（强化金币 + 保险金），不够就不让勾上
			var _need_total = -1
			if current_uprade_target_id != ""{
				var _cd = get_card_info_simple(current_uprade_target_id)
				if _cd != false{
					var _ri = get_card_craft_rule(string(_cd.max_level+1))
					if !is_undefined(_ri) _need_total = _ri.gold_amount + craft_assure_gold(_cd.max_level)
				}
			}
			if !_a.assure_enabled && _need_total >= 0 && global.save_data.player.gold < _need_total{
				show_notice("金币不足，无法开启保险金",80)
			}
			else{
				_a.assure_enabled = !_a.assure_enabled
				audio_play_sound(snd_button,0,0)
				ini_open("config.ini")
				ini_write_bool("settings","craft_assure_enabled",_a.assure_enabled)
				ini_close()
				if _a.assure_enabled show_notice("保险金已开启",80)
				else show_notice("保险金已关闭",60)
			}
		}
	}
}

if close_timer > 0{
	close_timer --
}
if close_timer == 0{
	panel_anim_close(id)
	close_timer = -1
}
