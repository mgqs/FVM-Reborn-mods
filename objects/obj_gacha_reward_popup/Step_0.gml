// 抽卡奖励弹窗 - Step 事件（处理鼠标点击）
if (reward == noone) exit;

// 使用 GUI 坐标检测点击（与 Draw GUI 一致）
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var gw = display_get_gui_width();
var gh = display_get_gui_height();
var cx = gw / 2;
var cy = gh / 2;

// 确定按钮位置
var btn_x = cx;
var btn_y = cy + 220;
var btn_w = 160;
var btn_h = 50;

if (mouse_check_button_pressed(mb_left)) {
    if (point_in_rectangle(mx, my, btn_x - btn_w/2, btn_y - btn_h/2, btn_x + btn_w/2, btn_y + btn_h/2)) {
        if (!received) {
            // 发放奖励
            var reward_type = "card";
            if (variable_struct_exists(reward, "reward_type")) {
                reward_type = reward.reward_type;
            }
            var reward_id = reward.id;
            var target_shape = reward.shape;

            if (reward_type == "card") {
                if (!is_card_unlocked(reward_id)) {
                    unlock_card(reward_id, 0, target_shape, global.save_data.unlocked_items.max_skill_level);
                } else {
                    var info = get_card_info_simple(reward_id);
                    var new_level = info.level;
                    var new_shape = max(info.shape, target_shape);
                    var new_max_shape = max(info.max_shape, target_shape);

                    var is_fallback = false;
                    if (variable_struct_exists(reward, "fallback")) {
                        is_fallback = reward.fallback;
                    }
                    if (is_fallback) {
                        new_level = min(info.level + 1, info.max_level);
                    }

                    for (var ci = 0; ci < array_length(global.save_data.unlocked_cards); ci++) {
                        if (global.save_data.unlocked_cards[ci].id == reward_id) {
                            global.save_data.unlocked_cards[ci].level = max(global.save_data.unlocked_cards[ci].level, new_level);
                            global.save_data.unlocked_cards[ci].shape = new_shape;
                            global.save_data.unlocked_cards[ci].max_shape = new_max_shape;
                            global.save_data.unlocked_cards[ci].max_level = max(global.save_data.unlocked_cards[ci].max_level, new_level);
                            break;
                        }
                    }
                }
            } else if (reward_type == "weapon") {
                unlock_weapon(reward_id);
            } else if (reward_type == "gem") {
                unlock_gem(reward_id);
            }

            received = true;
            save_file(global.save_slot);
        }

        audio_play_sound(snd_button, 0, 0);
        instance_destroy();
    }
}
