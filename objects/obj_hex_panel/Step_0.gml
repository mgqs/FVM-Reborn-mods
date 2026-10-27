// 战斗已经结束 / 已经换关：面板不该继续存在。
// 它每帧会把 is_paused 按回 true，残留到下一关就是"开局直接暂停、什么都干不了"
if (!instance_exists(obj_battle)) {
    global.hex_pick_open = false;
    instance_destroy();
    exit;
}

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
// 面板存在期间强制暂停：暂停菜单、拾取面板等外部逻辑都可能把 is_paused 改回 false，
// 那样玩家在还没选牌时就能操作卡槽 —— 而 hex_place_locked() 仍然为真，
// 表现就是「卡槽能选中、鼠标跟出虚影，但点地面怎么都放不下去」。
if (!global.is_paused) global.is_paused = true;

hover_idx = -1;
for (var i = 0; i < array_length(offer); i++) {
    var _r = hex_panel_card_rect(i);
    if (point_in_rectangle(mouse_x, mouse_y, _r.x1, _r.y1, _r.x2, _r.y2)) hover_idx = i;
}
select_hover = point_in_rectangle(mouse_x, mouse_y, select_x - btn_w / 2, btn_y - btn_h / 2,
                                  select_x + btn_w / 2, btn_y + btn_h / 2);
reroll_hover = point_in_rectangle(mouse_x, mouse_y, reroll_x - btn_w / 2, btn_y - btn_h / 2,
                                  reroll_x + btn_w / 2, btn_y + btn_h / 2);
giveup_hover = point_in_rectangle(mouse_x, mouse_y, giveup_x - btn_w / 2, btn_y - btn_h / 2,
                                  giveup_x + btn_w / 2, btn_y + btn_h / 2);

// ── 鼠标 ──
// 点牌只算「选中」，不会生效；确认只有「选择」按钮（或回车/空格）
if (mouse_check_button_pressed(mb_left)) {
    if (hover_idx >= 0) {
        hex_panel_select(hover_idx);
    } else if (select_hover) {
        hex_panel_confirm();
    } else if (reroll_hover) {
        hex_panel_reroll();
    } else if (giveup_hover) {
        hex_panel_giveup();
    }
}

// ── 键盘：1/2/3 选中，回车/空格确认，R 重随，Esc 放弃 ──
if (keyboard_check_pressed(ord("1"))) hex_panel_select(0);
if (keyboard_check_pressed(ord("2"))) hex_panel_select(1);
if (keyboard_check_pressed(ord("3"))) hex_panel_select(2);
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) hex_panel_confirm();
if (keyboard_check_pressed(ord("R"))) hex_panel_reroll();
if (keyboard_check_pressed(vk_escape)) hex_panel_giveup();
