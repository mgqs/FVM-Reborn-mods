if card_id == "magic_chicken"{
	var _blacklist = ["brahma","magic_chicken","ice_cream","kuileima","xingqiongma"]
	if global.last_placed_card_id != "" && array_get_index(_blacklist,global.last_placed_card_id) == -1{
		var card_save_data = get_card_info_simple(global.last_placed_card_id)
		if card_save_data != false{
			var prev_card_info = get_plant_data_with_skill(global.last_placed_card_id,card_save_data.shape,card_save_data.level,card_save_data.skill)
			if prev_card_info == undefined{
				exit
			}
			cost = prev_card_info[? "cost"]
			// 🔴 2026-11-12 修：只有「冷却走完 + 源卡换了」才重算，杜绝自动进冷却死循环。
			//   原来这段挂在 `cooldown_timer >= cooldown` 下面，而它自己又把 cooldown_timer 顶成 cooldown
			//   —— 顶满之后这个条件下一帧必然继续成立，于是这一段每帧都跑一次：
			//   ① 食谱加成（plus / multiply）被反复叠乘，cooldown 越滚越大；
			//   ② cooldown_timer 跟着一起顶满，冷却环永远停在满值。
			//   融合大炮（脆心死神大炮 1500 帧）冷却基数大，几十帧内就滚到几十万帧 → 看起来就是「永远卡在冷却」。
			//   现在：mc_src_id 记住上次处理的源卡 → 同一张源卡只算一次；换源仍然要等冷却走完（保持原口径，
			//   否则玩家随便塞张便宜卡就能白刷一次冷却）；重设用 0 而不是 cooldown。
			if (!variable_instance_exists(id, "mc_src_id")) mc_src_id = "";
			if (mc_src_id != global.last_placed_card_id && cooldown_timer >= cooldown){
				mc_src_id = global.last_placed_card_id
				raw_cooldown = prev_card_info[? "cooldown"]
				cooldown = prev_card_info[? "cooldown"]
				base_cooldown = cooldown
				//检查食谱
				var cookbook_list = global.save_data.equipped_cookbook
				for(var i = 0 ; i < array_length(cookbook_list) ; i++){
					for(var j = 0 ; j < array_length(cookbook_list[i]) ; j++){
						var cookbook_data = get_cookbook_data(cookbook_list[i][j])
						var modifs = cookbook_data.modif
						for(var k = 0 ; k < array_length(modifs) ; k++){
							if array_get_index(modifs[k].card_id,global.last_placed_card_id) != -1{
								if variable_instance_exists(self,modifs[k].modif_type){
									if modifs[k].modif_calc == "plus"{
										variable_instance_set(self,modifs[k].modif_type,variable_instance_get(self,modifs[k].modif_type)+modifs[k].amount)
									}
									else if modifs[k].modif_calc == "multiply"{
										variable_instance_set(self,modifs[k].modif_type,variable_instance_get(self,modifs[k].modif_type)*modifs[k].amount)
									}
								}
							}
						}
					}
				}
				if cooldown < 13.5 * 60{
					cooldown = 13.5 * 60
				}
				cooldown_timer = 0
				is_ready = false
			}
			var card_slot_data = deck_get_card_data(global.last_placed_card_id,card_save_data.shape)
			if card_slot_data != noone{
				card_spr = card_slot_data[? "sprite"]
			}
			//place_preview = card_slot_data[? "place_preview"]
			//card_obj = card_slot_data[? "obj"]
			
			current_cost = cost
			if ds_exists(global.plus_card_map, ds_type_map) && ds_map_find_value(global.plus_card_map,global.last_placed_card_id) != undefined{
				var plus_info = ds_map_find_value(global.plus_card_map,global.last_placed_card_id)
				with plus_info[0]{
					if card_save_data.shape < plus_info[1]{
						other.current_cost += 50
					}
				}
			}
			// 海克斯「卡片费用」（含第二批的均值 / 指定卡折扣）
			current_cost = round(hex_batch2_cost(card_id, current_cost));
		}
	}
}
