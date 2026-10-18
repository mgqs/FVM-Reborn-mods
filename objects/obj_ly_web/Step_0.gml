if (global.is_paused) exit;

if (web_dying) {
    longyuan_animate();
    if (ly_done) {
        if (variable_global_exists("longyuan_web_cells") && web_col >= 0 && web_row >= 0
            && web_col < global.grid_cols && web_row < global.grid_rows)
            global.longyuan_web_cells[web_row * global.grid_cols + web_col] = false;
        instance_destroy();
    }
    exit;
}

longyuan_animate();
if (ly_action == "出生" && ly_done) longyuan_play("待机");

web_life++;
if (web_life >= LY_SPIDER_WEB_LIFE) {
    web_dying = true;
    longyuan_play("死亡", true);
}
