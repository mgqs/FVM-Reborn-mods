if (global.is_paused) exit;

if (flash_value > 0) flash_value -= 10;

// 被卡片摧毁
if (hp <= 0) {
    image_alpha -= 0.12;
    if (image_alpha <= 0) instance_destroy();
    exit;
}

// 出生 → 待机动画
longyuan_clip_frame(timer, 5, fx_loop);
if (!fx_loop && longyuan_clip_done(timer, 5)) {
    if (fx_next_action != "") {
        var _na = fx_next_action;
        fx_next_action = "";
        longyuan_clip_set(_na);
        timer = 0;
        fx_loop = fx_loop_after;
    }
}
timer++;

// 深度按格子更新
var _g = get_grid_position_from_world(x, y);
grid_col = _g.col;
grid_row = _g.row;
depth = -10 - (_g.row * 45) - (_g.col * 5) - 4.5;
