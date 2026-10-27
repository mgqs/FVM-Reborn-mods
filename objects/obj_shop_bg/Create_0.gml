image_xscale = 0.9
image_yscale = 0.9

is_submenu_opened = false
shop_button_select = 1
shop_screen_select = 1
current_page = 1
current_max_page = 1
// 转职凭证页的分类页签：0=全部 / 1=一转 / 2=二转
credit_tab = 0

goods_list = ds_list_create()

// These items are exclusive to the cross-server medal shop.
cross_server_exchange_ids = [
    // 白银商店卡片
    "baibianshe", "double_blade_snake", "laipishe", "spoon_rabbit", "magic_chicken", "xuanfengniu",
    // 黄金商店武器
    "master_shield", "hades_scythe", "zeus_bolt", "star_wand", "rose_shield", "aladdin_lamp",
    // 黄金商店宝石
    "divine_blessing_gem", "divine_protect_gem", "divine_holy_gem", "divine_shenji_gem",
    "ghost_strike_gem", "ghost_spark_gem", "ghost_pact_gem", "ghost_caijue_gem",
    "zeus_shadow_gem", "zeus_power_gem", "zeus_anger_gem", "zeus_ren_gem",
    "star_wand_gem_1", "star_wand_gem_2", "star_wand_gem_3", "star_wand_gem_4", "star_wand_gem_5",
    "rose_shield_gem_1", "rose_shield_gem_2", "rose_shield_gem_3", "rose_shield_gem_4", "rose_shield_gem_5",
    "aladdin_lamp_gem_1", "aladdin_lamp_gem_2", "aladdin_lamp_gem_3", "aladdin_lamp_gem_4", "aladdin_lamp_gem_5",
    // 红柳烤串机转职卡片（仅跨服黄金商店）
    "hongliukaochuan", "hongliukaochuan_1", "hongliukaochuan_2",
    "zhanqima", "zhanqima_1", "zhanqima_2",
    // 椰子果（0转银牌商店 / 1、2转金牌商店）
    "yeziguo", "yeziguo_1", "yeziguo_2"
]

instance_create_depth(x+800,y-430,depth-1,obj_closeshop_btn)

//创建商店栏位选择按钮
var btn1 = instance_create_depth(x-743,y-363,depth-1,obj_shop_select_btn)
btn1.button_index = 1
btn1.sprite_index = spr_shop_select_btn_1
var btn2 = instance_create_depth(x-560,y-363,depth-1,obj_shop_select_btn)
btn2.button_index = 2
btn2.sprite_index = spr_shop_select_btn_2
var btn3 = instance_create_depth(x-377,y-363,depth-1,obj_shop_select_btn)
btn3.button_index = 3
btn3.sprite_index = spr_shop_select_btn_3
var btn4 = instance_create_depth(x-194,y-363,depth-1,obj_shop_select_btn)
btn4.button_index = 4
btn4.sprite_index = spr_shop_select_btn_4
var btn5 = instance_create_depth(x-11,y-363,depth-1,obj_shop_select_btn)
btn5.button_index = 5
btn5.sprite_index = spr_shop_select_btn_5
// 第 6 页签：转职凭证（素材 159×37，比前 5 个宽，按高度对齐缩到 1.654；前面 5 个一律不动）
//   横向再收到 1.45（263 → 231 宽，2026-10-25 用户要求「不协调的大，适当横向缩小」）
//   位置 x+196：左边缘正好贴住第 5 个页签（美容）右边缘 x+81，不再留缝
var btn6 = instance_create_depth(x+196,y-363,depth-1,obj_shop_select_btn)
btn6.button_index = 6
btn6.sprite_index = spr_shop_select_btn_6
btn6.btn_scale = 1.654
btn6.btn_scale_x = 1.45

var prev_btn = instance_create_depth(x+285,y+435,depth-1,obj_shop_page_btn)
prev_btn.btn_type = "prev"
var next_btn = instance_create_depth(x+485,y+435,depth-1,obj_shop_page_btn)
next_btn.btn_type = "next"

shop_list_recharge()

//刷新商品列表的函数
function shop_list_recharge(){
	ds_list_clear(goods_list)
	
	var map_array = []

	ds_map_keys_to_array(global.goods_map,map_array)
	// 跨服商品不进入普通金币商店的任何分类。
	var _normal_goods = []
	for (var _g = 0; _g < array_length(map_array); _g++) {
		if (!variable_struct_exists(global.goods_map[? map_array[_g]], "cross_server_shop")) {
			array_push(_normal_goods, map_array[_g])
		}
	}
	map_array = _normal_goods

	var goods_array_size = array_length(map_array)

	//武器和宝石分类：先显示武器，再显示宝石，同一个武器的宝石排在一起
	if shop_button_select == 2{
		//先添加所有武器，并记录武器顺序
		var weapon_id_list = ds_list_create()
		for(var i = 0; i < goods_array_size;i++){
			if global.goods_map[? map_array[i]].type == "weapon" && array_get_index(cross_server_exchange_ids, global.goods_map[? map_array[i]].unlock_item_id) == -1{
				ds_list_add(goods_list,map_array[i])
				ds_list_add(weapon_id_list, global.goods_map[? map_array[i]].unlock_item_id)
			}
		}
		//按武器分组添加宝石：同一个武器的宝石排在一起
		var added_gems = ds_list_create()
		//遍历武器列表，按顺序添加每个武器的专属宝石
		for(var w = 0; w < ds_list_size(weapon_id_list); w++){
			var weapon_id = ds_list_find_value(weapon_id_list, w)
			for(var i = 0; i < goods_array_size;i++){
				if global.goods_map[? map_array[i]].type == "gem" && array_get_index(cross_server_exchange_ids, global.goods_map[? map_array[i]].unlock_item_id) == -1{
					var gem_id = global.goods_map[? map_array[i]].unlock_item_id
					//检查是否已添加
					var already_added = false
					for(var a = 0; a < ds_list_size(added_gems); a++){
						if ds_list_find_value(added_gems, a) == map_array[i]{
							already_added = true
							break
						}
					}
					if !already_added{
						var gem_info = get_gem_info(gem_id)
						if (gem_info != noone) && variable_struct_exists(gem_info, "allowed_weapons"){
							//检查宝石是否属于当前武器
							for(var aw = 0; aw < array_length(gem_info.allowed_weapons); aw++){
								if gem_info.allowed_weapons[aw] == weapon_id{
									ds_list_add(goods_list,map_array[i])
									ds_list_add(added_gems,map_array[i])
									break
								}
							}
						}
					}
				}
			}
		}
		//最后添加通用宝石（没有专属武器的宝石）
		for(var i = 0; i < goods_array_size;i++){
			if global.goods_map[? map_array[i]].type == "gem" && array_get_index(cross_server_exchange_ids, global.goods_map[? map_array[i]].unlock_item_id) == -1{
				var already_added = false
				for(var a = 0; a < ds_list_size(added_gems); a++){
					if ds_list_find_value(added_gems, a) == map_array[i]{
						already_added = true
						break
					}
				}
				if !already_added{
					ds_list_add(goods_list,map_array[i])
				}
			}
		}
		ds_list_destroy(weapon_id_list)
		ds_list_destroy(added_gems)
	}
	else{
		for(var i = 0; i < goods_array_size;i++){
			//获取卡片类型商品
			if shop_button_select == 1{
                if global.goods_map[? map_array[i]].type == "card" && array_get_index(cross_server_exchange_ids, global.goods_map[? map_array[i]].unlock_item_id) == -1{
					//将商品id添加到商品列表中
					//var card_data = deck_get_card_data(global.goods_map[? map_array[i]].unlock_item_id,0)
					ds_list_add(goods_list,map_array[i])
				}
			}
			//获取道具类型商品
			else if shop_button_select == 3{
				if global.goods_map[? map_array[i]].type == "item"{
					// 神秘礼盒仅在抽卡模式下显示
					var _item_id = global.goods_map[? map_array[i]].unlock_item_id
					if (_item_id == "gacha_box" && !is_eternal_gacha_mode()){
						// 跳过，不添加到列表
					}
					else{
						//将商品id添加到商品列表中
						//var card_data = deck_get_card_data(global.goods_map[? map_array[i]].unlock_item_id,0)
						ds_list_add(goods_list,map_array[i])
					}
				}
			}
			//获取卡片皮肤
			else if shop_button_select == 4{
				if global.goods_map[? map_array[i]].type == "card_attire"{
					//将商品id添加到商品列表中
					ds_list_add(goods_list,map_array[i])
				}
			}
			//获取角色皮肤
			else if shop_button_select == 5{
				if global.goods_map[? map_array[i]].type == "player_attire"{
					//将商品id添加到商品列表中
					ds_list_add(goods_list,map_array[i])
				}
			}
			//获取转职凭证（type = "credit"；按分类页签过滤，兑换项永远显示）
			else if shop_button_select == 6{
				var _cgoods = global.goods_map[? map_array[i]]
				if (_cgoods.type == "credit"){
					if (credit_tab == 0 || _cgoods.credit_shape == 0 || _cgoods.credit_shape == credit_tab){
						ds_list_add(goods_list,map_array[i])
					}
				}
			}
		}
	}

	// 凭证页排序（2026-10-26 用户口径，第二版）
	//   取消的是「全局先一转、后二转」；现在要求：**同一张卡的凭证挨在一起，卡内先一转后二转**
	//   —— goods_map 是散列遍历序，不排会出现「小火炉二转 / 冰煮蛋器二转 / 机枪一转…」这种乱序
	//   排序键见 credit_shop_sort_key() = 「卡id|档位」，兑换项（威望 x1000）垫底；插入排序，量小无所谓
	if (shop_button_select == 6){
		var _sn = ds_list_size(goods_list);
		for (var _sa = 1; _sa < _sn; _sa++){
			var _cur = ds_list_find_value(goods_list, _sa);
			var _ck  = credit_shop_sort_key(_cur);
			var _sb  = _sa - 1;
			while (_sb >= 0){
				var _prev = ds_list_find_value(goods_list, _sb);
				if (credit_shop_sort_key(_prev) <= _ck) break;
				ds_list_replace(goods_list, _sb + 1, _prev);
				_sb -= 1;
			}
			ds_list_replace(goods_list, _sb + 1, _cur);
		}
	}

	//每页显示 16 个商品，页数随当前分类动态计算
	current_max_page = max(1, ceil(ds_list_size(goods_list) / 16))
	current_page = clamp(current_page, 1, current_max_page)
	//按类型创建购买按钮
	instance_destroy(obj_shop_buy_btn)
	for(var i = 0 ; i< 4; i++){
		for(var j = 0; j < 4; j++){
			//绘制卡片类型商品
			if shop_button_select == 1{
				if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
					// 检查卡片是否已解锁
		            var is_unlocked = false;
		            for(var k = 0; k < array_length(global.save_data.unlocked_cards); k++) {
		                if (global.save_data.unlocked_cards[k].id == global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id) {
		                    is_unlocked = true;
		                    break;
		                }
		            }
					//根据商品id获取卡片信息
					var inst = instance_create_depth(x-618+411*j+77, y-190+165*i+60,depth-1,obj_shop_buy_btn)
					inst.target_item = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id
					inst.cost = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].cost
					inst.goods_name = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].display_name
					inst.tooltip_text = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].description
					inst.btn_type = "card"
					if is_unlocked{
						inst.is_disabled = true
					}
				}
			}
			else if shop_button_select == 2{
				if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
					// 检查商品类型
		            var is_unlocked = false
					var goods_type = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].type
					if goods_type == "weapon"{
						is_unlocked = is_weapon_unlocked(global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id)
					}
					else if goods_type == "gem"{
						is_unlocked = is_gem_unlocked(global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id)
					}
					//根据商品id获取宝石或武器信息
					var inst = instance_create_depth(x-618+411*j+77, y-190+165*i+60,depth-1,obj_shop_buy_btn)
					inst.target_item = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id
					inst.cost = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].cost
					inst.goods_name = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].display_name
					inst.tooltip_text = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].description
					inst.btn_type = goods_type
					if is_unlocked{
						inst.is_disabled = true
					}
				}
			}
			else if shop_button_select == 3{
				if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
					
					//根据商品id获取商品信息
					var inst = instance_create_depth(x-618+411*j+77, y-190+165*i+60,depth-1,obj_shop_buy_btn)
					var _item_id = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id
					inst.target_item = _item_id
					// 神秘礼盒价格动态计算：50000 + 购买次数 * 50000
					if (_item_id == "gacha_box"){
						var _buy_count = 0;
						if (variable_struct_exists(global.save_data, "gacha_box_buy_count")) {
							_buy_count = global.save_data.gacha_box_buy_count;
						}
						inst.cost = 50000 + _buy_count * 50000
					}
					else{
						inst.cost = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].cost
					}
					inst.goods_name = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].display_name
					inst.tooltip_text = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].description
					inst.btn_type = "item"
					
				}
			}
			else if shop_button_select == 4 || shop_button_select == 5{
				if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
					
					//根据商品id获取商品信息
					var inst = instance_create_depth(x-618+411*j+77, y-190+165*i+60,depth-1,obj_shop_buy_btn)
					inst.target_item = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id
					inst.cost = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].cost
					inst.goods_name = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].display_name
					inst.tooltip_text = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].description
					inst.btn_type = "attire"
					var _attire_id = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id
					inst.is_attire_owned = shop_button_select == 5 && is_attire_unlocked(_attire_id)
					inst.is_attire_equipped = inst.is_attire_owned && get_attire_state(_attire_id) == "equipped"
					inst.is_disabled = inst.is_attire_equipped || (shop_button_select == 4 && is_attire_unlocked(_attire_id))
					
				}
			}
			//转职凭证页
			else if shop_button_select == 6{
				if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
					var _ci = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)]
					var inst = instance_create_depth(x-618+411*j+77, y-190+165*i+60,depth-1,obj_shop_buy_btn)
					inst.target_item = _ci.unlock_item_id
					inst.cost = _ci.cost
					inst.coin_type = variable_struct_exists(_ci, "coin_type") ? _ci.coin_type : "gold"
					inst.reward_prestige = variable_struct_exists(_ci, "reward_prestige") ? _ci.reward_prestige : 0
					inst.btn_type = "credit"
					// 凭证名按卡名表实时算（注册时机早于卡名表也不会退化成卡 id）
					inst.goods_name = (_ci.credit_shape > 0) ? transfer_credit_name_from_id(_ci.unlock_item_id) : _ci.display_name
					inst.tooltip_text = _ci.description
					// 已购 / 已转上去 / 形态不存在 → 置灰＋点不动（兑换项 credit_shape = 0 永远可买）
					// 爬塔门槛 / 余额不足不在这里置灰：它们是「临时不满足」，点购买时再弹提示（2026-10-26 用户定）
					inst.credit_block = ""
					// 爬塔门槛 key：凭证和兑换项都算好（Draw 用它画「通过X-X层可买」，
					//   规则见 transfer_credit 的 credit_shop_tower_defaults()：一转 1-1 / 二转 13-1 / 兑换项 35-1）
					inst.credit_floor_key = credit_shop_floor_key(_ci)
					if (_ci.credit_shape > 0) {
						var _cp = transfer_credit_parse(_ci.unlock_item_id)
						if (!is_undefined(_cp)) {
							inst.credit_block = transfer_credit_buyable(_cp.card_id, _cp.shape)
							if (transfer_credit_buyable_locked(_cp.card_id, _cp.shape)) inst.is_disabled = true
						}
					}
					else {
						// 兑换项（威望）：默认要通魔塔最大层才可买；不置灰，点购买时弹提示
						inst.credit_block = credit_shop_floor_reason(_ci)
					}
				}
			}
		}
	}
}

panel_anim_init(id, 0.28, 0.18, 260);
panel_anim_kids(id, [obj_closeshop_btn, obj_shop_select_btn, obj_shop_page_btn,
	obj_shop_buy_btn, obj_shop_buy_confirm]);

pg_t = -1;
pg_frames = 17;
pg_dir = 1;
pg_surf = -1;
pg_old_surf = -1;
pg_switch = false;
pg_alpha = 1;
