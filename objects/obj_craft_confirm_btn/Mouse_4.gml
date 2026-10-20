global.audio.play(snd_button,0,0)

var target_id = obj_craft_bg.current_uprade_target_id
if target_id != ""{
	if obj_craft_bg.button_select == 0{
		var spices_list = [0,0,0]
		var clover_list = [0,0,0,0]
		var card_data = get_card_info_simple(target_id)
		var current_level = card_data.max_level
		if array_get_index(cannot_upgrade_card_list,target_id) != -1{
			show_notice("该卡片无法被强化",60)
		}
		else if current_level < 16{
			var craft_rule_info = get_card_craft_rule(string(current_level+1))
			if (is_undefined(craft_rule_info)) { show_notice("该星级尚未配置强化配方", 60); exit; }
			var display_spices_amount = 0
			var display_clover_amount = 0
			var use_enhanced_spices = false
			var use_enhanced_clover = false
			if get_material_amount(craft_rule_info.spices_require) < craft_rule_info.spices_amount{
				for(var i = array_get_index(spices_use_order,craft_rule_info.spices_require);i < array_length(spices_use_order);i++){
					display_spices_amount += get_material_amount(spices_use_order[i])
					spices_list[i] = get_material_amount(spices_use_order[i])
					if display_spices_amount>= craft_rule_info.spices_amount{
						spices_list[i] -= (display_spices_amount - craft_rule_info.spices_amount)
						use_enhanced_spices = true
						break
					}
				}
			}
			else{
				display_spices_amount = get_material_amount(craft_rule_info.spices_require)
				var sp_index = array_get_index(spices_use_order,craft_rule_info.spices_require)
				spices_list[sp_index] =  craft_rule_info.spices_amount
			}
			if craft_rule_info.clover_require != "none"{
				
				
				if get_material_amount(craft_rule_info.clover_require) < craft_rule_info.clover_amount{
					for(var i = array_get_index(clover_use_order,craft_rule_info.clover_require);i < array_length(clover_use_order);i++){
						display_clover_amount += get_material_amount(clover_use_order[i])
						clover_list[i] = get_material_amount(clover_use_order[i])
						if display_clover_amount>= craft_rule_info.clover_amount{
							clover_list[i] -= (display_clover_amount - craft_rule_info.clover_amount)
							use_enhanced_clover = true
							break
						}
					}
				}
				else{
					display_clover_amount = get_material_amount(craft_rule_info.clover_require)
					var cl_index = array_get_index(clover_use_order,craft_rule_info.clover_require)
					clover_list[cl_index] =  craft_rule_info.clover_amount
				}
			}
			if display_spices_amount >= craft_rule_info.spices_amount &&
				(craft_rule_info.clover_require == "none" || display_clover_amount >= craft_rule_info.clover_amount) &&
				global.save_data.player.gold >= craft_rule_info.gold_amount
			{
				var fail_streak = get_card_fail_streak(target_id)
				var rate_bonus = get_card_craft_bonus(target_id)
				var success_rate = get_card_craft_rate(target_id, current_level+1, rate_bonus, fail_streak)
				var is_success = craft_roll(success_rate)
				var rate_settings = craft_rate_settings()
				var material_ratio = 1
				var gold_ratio = 1
				if !is_success{
					material_ratio = rate_settings.fail_material_ratio
					gold_ratio = rate_settings.fail_gold_ratio
				}
				// 保险金（雏形）：勾选且失败掉星开着时，每次强化多付一笔大额金币，失败时不掉星
				var assure_cost = 0
				if craft_assure_active() assure_cost = craft_assure_gold(current_level)
				if global.save_data.player.gold < ceil(craft_rule_info.gold_amount*gold_ratio) + assure_cost{
					show_notice("金币不足，无法强化（保险金 "+string(assure_cost)+"）",80)
					exit
				}
				for(var i = 0 ; i < array_length(spices_use_order) ; i++){
					if spices_list[i] > 0 add_material_amount(spices_use_order[i],-ceil(spices_list[i]*material_ratio))
				}
				if craft_rule_info.clover_require != "none"{
					for(var i = 0 ; i < array_length(clover_use_order) ; i++){
						if clover_list[i] > 0 add_material_amount(clover_use_order[i],-ceil(clover_list[i]*material_ratio))
					}
				}
				global.save_data.player.gold -= ceil(craft_rule_info.gold_amount*gold_ratio) + assure_cost
				if is_success{
					upgrade_card(target_id,current_level+1)
					set_card_fail_streak(target_id,0)
					set_card_craft_bonus(target_id,0)
					show_notice("强化成功！卡片升至 "+string(current_level+1)+" 星",60)
				}
				else{
					set_card_fail_streak(target_id,fail_streak+1)
					// 每次失败随机加 4~7 个点并累计（成功清零）；最多累计 pity_bonus_max_stack 次，之后失败不再加
					if fail_streak < rate_settings.pity_bonus_max_stack{
						set_card_craft_bonus(target_id,rate_bonus+random_range(rate_settings.pity_bonus_min, rate_settings.pity_bonus_max))
					}
					var _can_drop = craft_dropstar_can_drop(current_level)
					if _can_drop && assure_cost > 0{
						show_notice("不够好运，强化失败，保险金已生效",80)
					}
					else if _can_drop{
						upgrade_card(target_id,current_level-1)
						show_notice("不够好运，强化失败，星级 -1",80)
					}
					else{
						show_notice("不够好运，强化失败",80)
					}
				}
				// 强化后金币已不够下一次保险金 → 自动取消勾选
				if craft_rate_settings().assure_enabled{
					var _next_info = get_card_info_simple(target_id)
					var _next_cost = 0
					if _next_info != false _next_cost = craft_assure_gold(_next_info.max_level)
					if global.save_data.player.gold < _next_cost{
						craft_rate_settings().assure_enabled = false
						ini_open("config.ini")
						ini_write_bool("settings","craft_assure_enabled",false)
						ini_close()
						show_notice("金币不足，保险金已自动取消",80)
					}
				}
			}
			else{
				show_notice("金币或强化材料不足，升级失败！",60)
			}
		}
	
	}
	else if obj_craft_bg.button_select == 1{
		var crystal_list = [0,0,0]
		var gem_data = get_gem_info(target_id)
		var current_level = get_gem_max_level(target_id)
		if array_get_index(level_10_gems,target_id) != -1 && current_level >= 10{
			show_notice("该宝石强化上限为10星",60)
		}
		else if current_level <= 14{
			var craft_rule_info = get_gem_craft_rule(string(current_level+1))
			var display_crystal_amount = 0
			var use_enhanced_crystal = false
			if get_material_amount(craft_rule_info.crystal_require) < craft_rule_info.crystal_amount{
				for(var i = array_get_index(crystal_use_order,craft_rule_info.crystal_require);i < array_length(crystal_use_order);i++){
					display_crystal_amount += get_material_amount(crystal_use_order[i])
					crystal_list[i] = get_material_amount(crystal_use_order[i])
					if display_crystal_amount>= craft_rule_info.crystal_amount{
						crystal_list[i] -= (display_crystal_amount - craft_rule_info.crystal_amount)
						use_enhanced_crystal = true
						break
					}
				}
			}
			else{
				display_crystal_amount = get_material_amount(craft_rule_info.crystal_require)
				var cr_index = array_get_index(crystal_use_order,craft_rule_info.crystal_require)
				crystal_list[cr_index] =  craft_rule_info.crystal_amount
			}
			if display_crystal_amount >= craft_rule_info.crystal_amount &&
			global.save_data.player.gold >= craft_rule_info.gold_amount
			{
				var fail_streak = get_gem_fail_streak(target_id)
				var rate_bonus = get_gem_craft_bonus(target_id)
				var success_rate = get_gem_craft_rate(target_id, current_level+1, rate_bonus, fail_streak)
				var is_success = craft_roll(success_rate)
				var rate_settings = craft_rate_settings()
				var material_ratio = 1
				var gold_ratio = 1
				if !is_success{
					material_ratio = rate_settings.fail_material_ratio
					gold_ratio = rate_settings.fail_gold_ratio
				}
				for(var i = 0 ; i < array_length(crystal_use_order) ; i++){
					if crystal_list[i] > 0 add_material_amount(crystal_use_order[i],-ceil(crystal_list[i]*material_ratio))
				}
				global.save_data.player.gold -= ceil(craft_rule_info.gold_amount*gold_ratio)
				if is_success{
					edit_gem_max_level(target_id,current_level+1)
					edit_gem_level(target_id,get_gem_max_level(target_id))
					set_gem_fail_streak(target_id,0)
					set_gem_craft_bonus(target_id,0)
					show_notice("强化成功！宝石升至 "+string(current_level+1)+" 星",60)
				}
				else{
					set_gem_fail_streak(target_id,fail_streak+1)
					if fail_streak < rate_settings.pity_bonus_max_stack{
						set_gem_craft_bonus(target_id,rate_bonus+random_range(rate_settings.pity_bonus_min, rate_settings.pity_bonus_max))
					}
					show_notice("不够好运，强化失败",80)
				}
			}
			else{
				show_notice("金币或强化水晶不足，升级失败！",60)
			}
		}
	
	}
}
//show_notice("不够好运，升级失败！",60)
