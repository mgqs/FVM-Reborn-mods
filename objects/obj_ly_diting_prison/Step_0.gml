if (global.is_paused) exit;

// 钟不移动：始终固定在生成格，由父类负责注册与受伤状态。
var _saved_index = image_index;
var _saved_alpha = image_alpha;
state = ENEMY_STATE.ACTING;
event_inherited();
if (!instance_exists(id)) exit;
image_index = _saved_index;
image_alpha = _saved_alpha;
depth = -600; // 盖在美食上方

if (prison_col < 0) { prison_col = grid_col; prison_row = grid_row; }

// 被卡片打碎：直接播死亡消失，不产生魂体开路鼠。
if (hp <= 0 && ly_mode != "dead") {
    ly_mode = "dead";
    longyuan_play("死亡", true);
}

switch (ly_mode) {
    case "birth":
        longyuan_animate();
        if (ly_done) longyuan_play("待机");
        break;

    case "idle":
        longyuan_animate();
        break;

    case "fuse":
        // 激活段播完后循环激活待机，LY_DITING_PRISON_FUSE（3 秒）后自毁生魂体开路鼠。
        longyuan_animate();
        if (ly_action == "激活" && ly_done) longyuan_play("激活待机");
        ly_timer++;
        if (ly_timer >= LY_DITING_PRISON_FUSE) {
            var _soul = instance_create_depth(x, y, depth, obj_ly_kailu);
            if (instance_exists(_soul)) _soul.longyuan_change_soul();
            instance_destroy();
            exit;
        }
        break;

    case "dead":
        longyuan_animate();
        if (ly_done) instance_destroy();
        break;
}
