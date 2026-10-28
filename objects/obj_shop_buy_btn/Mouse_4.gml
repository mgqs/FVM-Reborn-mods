// 被锁住的凭证：点一下要说明原因（不满足购买条件 = 已持有 / 已转职；或魔塔层数不足），
// 否则点了完全没反应。credit_block 只有凭证按钮才有，「置灰」本身由 obj_shop_bg 判。
if not obj_shop_bg.is_submenu_opened and is_disabled
   and variable_instance_exists(id, "credit_block") and credit_block != ""{
	show_notice(credit_block, 80)
	exit
}

if not obj_shop_bg.is_submenu_opened and not is_disabled{
	
	global.audio.play(snd_button,0,0)
	if btn_type == "attire" && is_attire_owned{
		equip_attire(target_item)
		save_file(global.save_slot)
		if instance_exists(obj_player_character){
			with obj_player_character{
				sprite_index = get_attire_info(other.target_item).spr
				image_index = 0
			}
		}
		if instance_exists(obj_player_info_ui){
			with obj_player_info_ui{
				update_attire()
			}
		}
		with obj_shop_bg{
			shop_list_recharge()
		}
		exit
	}
	if btn_type == "card" || btn_type == "weapon" || btn_type == "gem" || btn_type == "attire"{
		// 抽卡模式：禁用卡片购买
		if (btn_type == "card" && (is_eternal_gacha_mode() || is_random_gift_mode())) {
			show_notice(is_random_gift_mode() ? "随机礼盒模式无法购买卡片" : "抽卡模式无法购买卡片", 60);
			exit;
		}
		// 抽卡模式：禁用MOD武器购买
		if (btn_type == "weapon" && is_eternal_gacha_mode() && gacha_is_mod_weapon(target_item)) {
			show_notice("抽卡模式通过随机奖励获取MOD武器", 60);
			exit;
		}
		// 抽卡模式：禁用MOD宝石购买
		if (btn_type == "gem" && is_eternal_gacha_mode() && gacha_is_mod_gem(target_item)) {
			show_notice("抽卡模式通过随机奖励获取MOD宝石", 60);
			exit;
		}
		if global.save_data.player.gold >= cost || global.debug{
			var inst = instance_create_depth(room_width/2,room_height/2,depth-3,obj_shop_buy_confirm)
			inst.banding_buy_btn = id
			obj_shop_bg.is_submenu_opened = true
			//show_debug_message(global.save_data.player.gold)
		}
		else{
			show_notice("金币不足",60)
		}
	}
	else if btn_type == "item"{
		if global.save_data.player.gold >= cost || global.debug{
			if target_item == "card_slot_21" && global.save_data.unlocked_items.max_slot != 20{
				show_notice("请先购买第20个卡槽",60)
			}
			else if target_item == "card_slot_20" && global.save_data.unlocked_items.max_slot != 19{
				show_notice("请先购买第19个卡槽",60)
			}
			else if target_item == "card_slot_19" && global.save_data.unlocked_items.max_slot != 18{
				show_notice("请先购买前18个卡槽",60)
			}
			else{
				var inst = instance_create_depth(room_width/2,room_height/2,depth-3,obj_shop_buy_confirm)
				inst.banding_buy_btn = id
				obj_shop_bg.is_submenu_opened = true
				//show_debug_message(global.save_data.player.gold)
			}
		}
		else{
			show_notice("金币不足",60)
		}
	}
	// 转职凭证页：威望 / 金币分别判断余额
	else if btn_type == "credit"{
		// 先拦「临时不满足」（爬塔层数不够 / 已持有 / 已转职等）——这些**不置灰**，点了才提示
		var _cp_buy = transfer_credit_parse(target_item)
		if (!is_undefined(_cp_buy)){
			var _blk_buy = transfer_credit_buyable(_cp_buy.card_id, _cp_buy.shape)
			if (_blk_buy != ""){
				show_notice(_blk_buy, 80)
				exit
			}
		}
		var _bal = (coin_type == "prestige") ? get_material_amount("prestige") : global.save_data.player.gold
		if (_bal >= cost || global.debug){
			// 凭证：**点价格右边的小箭头**才走「自定义购买数量」窗（2026-10-27 用户改）
			//   点按钮本体 = 买 1 个，仍走老确认框；箭头位置/热区由 transfer_credit 统一算
			if (variable_instance_exists(id, "credit_shape") && credit_shape > 0
				&& credit_price_arrow_hit(mouse_x, mouse_y, x, y - 62, credit_price_label(cost, coin_type))){
				credit_trade_open_buy(target_item,
					is_string(cost) ? real(cost) : cost,
					coin_type,
					(coin_type == "prestige") ? "威望" : "G",
					depth - 3)
			}
			else{
				var inst = instance_create_depth(room_width/2,room_height/2,depth-3,obj_shop_buy_confirm)
				inst.banding_buy_btn = id
			}
			obj_shop_bg.is_submenu_opened = true
		}
		else{
			show_notice(coin_type == "prestige" ? "威望不足" : "金币不足", 60)
		}
	}
}
