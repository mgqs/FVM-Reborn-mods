// obj_quit_confirm - Step Event
if (variable_instance_exists(id, "pnl_closing") && pnl_closing) exit
selected_button = -1;

// 检测鼠标交互
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

for (var i = 0; i < array_length(buttons); i++) {
    var btn = buttons[i];
    var btn_x = x + btn[0] * pop_s;
    var btn_y = y + 70 * pop_s;
    var btn_width = btn[2];
    var btn_height = btn[3];
    
    if (point_in_rectangle(mx, my, 
        btn_x - btn_width/2, btn_y - btn_height/2,
        btn_x + btn_width/2, btn_y + btn_height/2)) 
    {
        selected_button = i;
        
        if (mouse_check_button_released(mb_left)) {
            switch (i) {
                case 1: // 取消
					obj_shop_bg.is_submenu_opened = false
                    instance_destroy();
                    break;
                    
                case 0: // 确定
                    // 购买逻辑
					obj_shop_bg.is_submenu_opened = false

					// 兜底：转职凭证可能已经不可买（连点 / 界面状态过期）→ 提示并关窗，不扣钱
					if (banding_buy_btn != noone && instance_exists(banding_buy_btn) && banding_buy_btn.btn_type == "credit") {
						var _bp = transfer_credit_parse(banding_buy_btn.target_item)
						if (!is_undefined(_bp)) {
							var _blk = transfer_credit_buyable(_bp.card_id, _bp.shape)
							if (_blk != "") {
								show_notice(_blk, 60)
								instance_destroy()
								exit
							}
						}
					}
					
					// 先判断是否是神秘礼盒（特殊处理，避免with作用域问题）
					var _is_gacha_box = false;
					var _gacha_cost = 0;
					if (banding_buy_btn != noone) {
					    if (banding_buy_btn.btn_type == "item" && banding_buy_btn.target_item == "gacha_box") {
							_is_gacha_box = true;
							_gacha_cost = banding_buy_btn.cost;
						}
					}
					
					if (_is_gacha_box) {
						// 神秘礼盒：扣钱、增加次数、弹出奖励界面
						if (global.save_data.player.gold >= _gacha_cost || global.debug) {
							global.save_data.player.gold -= _gacha_cost;
							if (!variable_struct_exists(global.save_data, "gacha_box_buy_count")) {
								global.save_data.gacha_box_buy_count = 0;
							}
							global.save_data.gacha_box_buy_count += 1;
							save_file(global.save_slot);
							
							// 创建奖励弹窗
							var reward = gacha_pick_random_reward();
							var inst = instance_create_depth(0, 0, -99999, obj_gacha_reward_popup);
							inst.reward = reward;
							
							// 刷新商店列表
							with obj_shop_bg {
								shop_list_recharge();
							}
							
							instance_destroy();
						}
					}
					else {
						// 普通商品购买
						with banding_buy_btn{
							if btn_type == "card"{
								global.save_data.player.gold -= cost
								unlock_card(target_item,0,0,global.save_data.unlocked_items.max_skill_level)
							}
							else if btn_type == "weapon"{
								global.save_data.player.gold -= cost
								unlock_weapon(target_item)
							}
							else if btn_type == "gem"{
								global.save_data.player.gold -= cost
								unlock_gem(target_item)
							}
							else if btn_type == "attire"{
								global.save_data.player.gold -= cost
								unlock_attire(target_item)
								save_file(global.save_slot)
							}
							else if btn_type == "item"{
								global.save_data.player.gold -= cost
								if target_item == "card_slot" && global.save_data.unlocked_items.max_slot < 18{
									global.save_data.unlocked_items.max_slot += 1
								}
								else if target_item == "card_slot_19" && global.save_data.unlocked_items.max_slot == 18{
									global.save_data.unlocked_items.max_slot += 1
								}
								else if target_item == "card_slot_20" && global.save_data.unlocked_items.max_slot == 19{
									global.save_data.unlocked_items.max_slot += 1
								}
								else if target_item == "card_slot_21" && global.save_data.unlocked_items.max_slot == 20{
									global.save_data.unlocked_items.max_slot += 1
								}
								save_file(global.save_slot)
							}
							// 转职凭证页：威望结算 / 凭证或兑换奖励
							else if btn_type == "credit"{
								if (coin_type == "prestige") add_material_amount("prestige", -cost)
								else global.save_data.player.gold -= cost
								if (reward_prestige > 0) add_material_amount("prestige", reward_prestige)
								else add_material_amount(target_item, 1)
								save_file(global.save_slot)
							}
						}
						with obj_shop_bg{
							shop_list_recharge()
						}
						instance_destroy()
					}
                    break;
            }
			global.audio.play(snd_button,0,0)
        }
        break;
    }
}

// ESC键关闭确认窗口
if (keyboard_check_pressed(vk_escape)) {
    panel_anim_close(id);
}
if (!instance_exists(id)) exit
pop_anim_step(id)
