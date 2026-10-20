// 概率强化 = 总开关：关掉时「失败掉星」「保险金」一并关掉
// 热区要连右侧文字一起算（原来只到 +18，点「概率强化」四个字是点不到的）
rate_toggle_hover = point_in_rectangle(mouse_x, mouse_y, rate_toggle_x-18, rate_toggle_y-18, rate_toggle_x+118, rate_toggle_y+18)
if mouse_check_button_pressed(mb_left) && rate_toggle_hover{
	var _s = craft_rate_settings()
	_s.enabled = !_s.enabled
	if !_s.enabled{
		_s.dropstar_enabled = false
		_s.assure_enabled = false
	}
	audio_play_sound(snd_button,0,0)
	ini_open("config.ini")
	ini_write_bool("settings","craft_rate_enabled",_s.enabled)
	ini_write_bool("settings","craft_dropstar_enabled",_s.dropstar_enabled)
	ini_write_bool("settings","craft_assure_enabled",_s.assure_enabled)
	ini_close()
	if _s.enabled show_notice("概率强化已开启",60)
	else show_notice("概率强化已关闭",60)
}

// 失败掉星开关点击（总开关关着时不给动）
// 联动：关掉失败掉星时「保险金」一并关掉（单向）；打开时不动保险金（保险金自己单独开关）
// 热区同样含文字
dropstar_toggle_hover = point_in_rectangle(mouse_x, mouse_y, dropstar_toggle_x-18, dropstar_toggle_y-18, dropstar_toggle_x+118, dropstar_toggle_y+18)
if mouse_check_button_pressed(mb_left) && dropstar_toggle_hover{
	var _d = craft_rate_settings()
	if !_d.enabled{
		show_notice("要先开启「概率强化」",80)
	}
	else{
		var _had_assure = _d.assure_enabled
		_d.dropstar_enabled = !_d.dropstar_enabled
		if !_d.dropstar_enabled _d.assure_enabled = false
		audio_play_sound(snd_button,0,0)
		ini_open("config.ini")
		ini_write_bool("settings","craft_dropstar_enabled",_d.dropstar_enabled)
		ini_write_bool("settings","craft_assure_enabled",_d.assure_enabled)
		ini_close()
		if _d.dropstar_enabled show_notice("失败掉星已开启",80)
		else if _had_assure show_notice("失败掉星已关闭，保险金一并关闭",80)
		else show_notice("失败掉星已关闭",60)
	}
}

// 保险金开关点击（在徽章上：点徽章或下面那个勾选框都算；只在卡片强化页）
// 保险金是**单独开关**（不再反向带动失败掉星），但必须建立在「概率强化」+「失败掉星」都开着的前提下
assure_toggle_hover = false
if button_select == 0{
	assure_toggle_hover = point_in_rectangle(mouse_x, mouse_y, assure_badge_cx-33, assure_badge_cy-36, assure_badge_cx+33, assure_toggle_y+18)
	if mouse_check_button_pressed(mb_left) && assure_toggle_hover{
		var _a = craft_rate_settings()
		if !_a.enabled{
			show_notice("要先开启「概率强化」",80)
		}
		else if !_a.dropstar_enabled{
			show_notice("要先开启「失败掉星」",80)
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
