// 抽卡奖励弹窗 - Draw GUI 事件（确保显示在最顶层）
var gw = display_get_gui_width();
var gh = display_get_gui_height();
var cx = gw / 2;
var cy = gh / 2;

// 半透明背景遮罩
draw_set_color(c_black);
draw_set_alpha(0.7);
draw_rectangle(0, 0, gw, gh, false);
draw_set_alpha(1);

draw_set_font(font_yuan);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (reward != noone) {
    var reward_id = reward.id;
    var reward_shape = reward.shape;
    var reward_type = "card";
    if (variable_struct_exists(reward, "reward_type")) {
        reward_type = reward.reward_type;
    }

    // 标题文字
    var title_text = "随机获得卡片";
    if (reward_type == "weapon") {
        title_text = "随机获得武器";
    } else if (reward_type == "gem") {
        title_text = "随机获得宝石";
    }
    draw_set_color(c_black);
    draw_text(cx, cy - 180, title_text);

    // 卡槽外框（保持原大小）
    draw_sprite_ext(spr_slot, 0, cx, cy - 20, 1.2, 1.2, 0, c_white, 1);

    if (reward_type == "card") {
        // === 卡片奖励 ===
        var card_shape_data = get_plant_shape_data(reward_id, reward_shape);
        var card_deck_data = deck_get_card_data(reward_id, reward_shape);

        // 卡片贴图（放大约一倍）
        if (card_deck_data != noone) {
            var card_spr = card_deck_data[? "sprite"];
            if (card_spr != undefined) {
                draw_sprite_ext(card_spr, 0, cx, cy - 20, 1.8, 1.8, 0, c_white, 1);
            }
        }

        // 卡片名称颜色
        var name_color = c_blue;
        if (gacha_is_gold_card(reward_id)) {
            name_color = c_yellow;
        } else if (gacha_is_zodiac_card(reward_id)) {
            name_color = c_purple;
        }
        draw_set_color(name_color);
        var card_name = "未知卡片";
        if (card_shape_data != undefined) {
            card_name = card_shape_data[? "name"];
        }
        draw_text(cx, cy + 120, card_name);

        // 形态
        draw_set_color(c_lime);
        draw_text(cx, cy + 150, "形态：" + string(reward_shape));
    } else if (reward_type == "weapon") {
        // === 武器奖励 ===
        var weapon_icon = gacha_get_weapon_icon(reward_id);
        var weapon_name = gacha_get_weapon_name(reward_id);

        // 武器图标（放大约一倍）
        if (weapon_icon != -1) {
            draw_sprite_ext(weapon_icon, 0, cx, cy - 20, 2.0, 2.0, 0, c_white, 1);
        }

        // 武器名称（金色）
        draw_set_color(c_yellow);
        draw_text(cx, cy + 120, weapon_name);

        // 类型标签
        draw_set_color(c_lime);
        draw_text(cx, cy + 150, "MOD武器");
    } else if (reward_type == "gem") {
        // === 宝石奖励 ===
        var gem_icon = gacha_get_gem_icon(reward_id);
        var gem_name = gacha_get_gem_name(reward_id);

        // 宝石图标（放大约一倍）
        if (gem_icon != -1) {
            draw_sprite_ext(gem_icon, 0, cx, cy - 20, 2.5, 2.5, 0, c_white, 1);
        }

        // 宝石名称（紫色）
        draw_set_color(c_purple);
        draw_text(cx, cy + 120, gem_name);

        // 类型标签
        draw_set_color(c_lime);
        draw_text(cx, cy + 150, "MOD宝石");
    }

    // 确定按钮
    var btn_x = cx;
    var btn_y = cy + 220;
    var btn_w = 160;
    var btn_h = 50;

    // 按钮背景
    draw_set_color(c_white);
    draw_rectangle(btn_x - btn_w/2, btn_y - btn_h/2, btn_x + btn_w/2, btn_y + btn_h/2, false);

    // 按钮边框（灰色）
    draw_set_color(c_gray);
    draw_rectangle(btn_x - btn_w/2, btn_y - btn_h/2, btn_x + btn_w/2, btn_y + btn_h/2, true);

    // 按钮文字
    draw_set_color(c_black);
    draw_text(btn_x, btn_y, "确定");
} else {
    // reward 为 noone 时显示调试信息（确保弹窗确实出现了）
    draw_set_color(c_red);
    draw_text(cx, cy, "奖励加载中...");
}

draw_set_halign(fa_left);
draw_set_valign(fa_middle);
