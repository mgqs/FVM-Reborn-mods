// 蜘蛛精夜魂体吐出的蛛网：占据格子使其无法放卡，存活 LY_SPIDER_WEB_LIFE 后自动消失。无父对象。
web_col = -1;
web_row = -1;
ly_kind = "web";
ly_anims = longyuan_animation_table("web");
ly_action = "";
ly_frame = 0;
ly_done = false;
ly_once = false;
ly_hit = false;
is_slowdown = false; // 蛛网不吃减速，仅为 longyuan_animate() 提供变量
image_speed = 0;
image_xscale = 1.8;
image_yscale = 1.8;
web_life = 0;
web_dying = false;

// 全局占格表（懒初始化，供 can_place_at_position 查询）
if (!variable_global_exists("longyuan_web_cells"))
    global.longyuan_web_cells = array_create(global.grid_rows * global.grid_cols, false);
if (web_col >= 0 && web_row >= 0 && web_col < global.grid_cols && web_row < global.grid_rows)
    global.longyuan_web_cells[web_row * global.grid_cols + web_col] = true;

longyuan_play("出生", true);
