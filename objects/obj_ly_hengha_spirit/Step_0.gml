if (global.is_paused) exit;

var _saved_index = image_index;
var _saved_alpha = image_alpha;
state = ENEMY_STATE.ACTING;
event_inherited();
if (!instance_exists(id)) exit;
image_index = _saved_index;
image_alpha = _saved_alpha;

// 进第 9 列前被打死：正常死亡，不返还血量。
if (hp <= 0 && ly_mode != "dead") {
    ly_mode = "dead";
    longyuan_play("死亡", true);
}

if (ly_mode == "birth") {
    longyuan_animate();
    if (ly_done) {
        // 出生动画播完，该格子的卡片直接销毁
        if (ly_kill_col >= 0) {
            longyuan_damage_cell(ly_kill_col, ly_kill_row, 0, true);
            ly_kill_col = -1; ly_kill_row = -1;
        }
        ly_mode = "idle";
        longyuan_play("待机");
    }
    exit;
}

if (ly_mode == "dead") {
    longyuan_animate();
    if (ly_done) instance_destroy();
    exit;
}

// 待机/被吸收：原地待机；吸收后向右（第 9 列）移动。
if (ly_melted) {
    longyuan_play("死亡", true);
    longyuan_animate();
    if (ly_done) instance_destroy();
    exit;
}

longyuan_play("待机");
longyuan_animate();
if (ly_absorbing) {
    x += move_speed;
    if (grid_col >= global.grid_cols - 1) {
        // 进入第 9 列后自己消散，剩余血量返还给牛头（并同步共享血的马面）。
        if (instance_exists(ly_absorb_boss)) {
            var _boss = ly_absorb_boss;
            _boss.hp = min(_boss.maxhp, _boss.hp + max(0, hp));
            if (instance_exists(_boss.ly_shared_boss_peer))
                _boss.ly_shared_boss_peer.hp = max(_boss.ly_shared_boss_peer.hp, _boss.hp);
        }
        ly_melted = true;
        longyuan_play("死亡", true);
        longyuan_animate();
    }
}
