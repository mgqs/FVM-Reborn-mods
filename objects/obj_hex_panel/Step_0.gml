t += 1;
if (msg_timer > 0) msg_timer -= 1;

// ── 关闭：先让选中/放弃动画走完，再恢复对局 ──
if (closing > 0) {
    closing -= 1;
    if (closing <= 0) {
        global.is_paused = false;
        global.hex_pick_open = false;
        if (instance_exists(obj_hex_hud)) obj_hex_hud.force_pi_refresh = true;
        instance_destroy();
    }
    exit;
}

// ── 悬停 ──
hover_idx = -1;
for (var i = 0; i < array_length(offer); i++) {
    var _r = hex_panel_card_rect(i);
    if (point_in_rectangle(mouse_x, mouse_y, _r.x1, _r.y1, _r.x2, _r.y2)) hover_idx = i;
}
reroll_hover = point_in_rectangle(mouse_x, mouse_y, reroll_x - btn_w / 2, btn_y - btn_h / 2,
                                  reroll_x + btn_w / 2, btn_y + btn_h / 2);
giveup_hover = point_in_rectangle(mouse_x, mouse_y, giveup_x - btn_w / 2, btn_y - btn_h / 2,
                                  giveup_x + btn_w / 2, btn_y + btn_h / 2);

// ── 鼠标 ──
if (mouse_check_button_pressed(mb_left)) {
    if (hover_idx >= 0) {
        hex_panel_pick(hover_idx);
    } else if (reroll_hover) {
        hex_panel_reroll();
    } else if (giveup_hover) {
        hex_panel_giveup();
    }
}

// ── 键盘：1/2/3 选卡，R 重随，Esc 放弃 ──
if (keyboard_check_pressed(ord("1"))) hex_panel_pick(0);
if (keyboard_check_pressed(ord("2"))) hex_panel_pick(1);
if (keyboard_check_pressed(ord("3"))) hex_panel_pick(2);
if (keyboard_check_pressed(ord("R"))) hex_panel_reroll();
if (keyboard_check_pressed(vk_escape)) hex_panel_giveup();
