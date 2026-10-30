// 高跷鼠：完全复用父类行走/啃咬/闪避/死亡状态机（同非主流鼠），仅覆写自己的精灵帧。
if (global.is_paused) exit;

// 目标类型：啃咬中为 normal（可被普通子弹命中），其余为 dance（对齐非主流鼠）
if (state == ENEMY_STATE.ATTACK) target_type = "normal";
else target_type = "dance";

if (hp <= 0 && state != ENEMY_STATE.DEAD) {
    state = ENEMY_STATE.DEAD;
    timer = 0;
    sprite_index = ly_anims[$ "死亡"][0];
}

// ----- 高架物后退（保留专属逻辑）：NORMAL 时前方 2 格内有高架物/连通米线桥，则转 IDLE 自管后撤 -----
ly_obstacle_near = false;
if (state == ENEMY_STATE.NORMAL && hp > 0 && ly_retreat_cooldown <= 0) {
    with (obj_card_parent) {
        if (hp > 0 && grid_row == other.grid_row && x < other.x && x > other.x - global.grid_cell_size_x * 2
            && (array_get_index(other.ly_high_obstacle_ids, plant_id) != -1
                || (variable_instance_exists(id, "longyuan_bridge_connected") && longyuan_bridge_connected))) {
            other.ly_obstacle_near = true;
        }
    }
    // 米线到龙柱的连接线本身不是卡片实例，单独按线段判定（同行、前方 2 格内被线段扫到即算）。
    if (!ly_obstacle_near) {
        var _line_owner = longyuan_bridge_contact(x - global.grid_cell_size_x * 2, y, x, y, grid_row);
        if (instance_exists(_line_owner)) ly_obstacle_near = true;
    }
}
if (ly_obstacle_near && state == ENEMY_STATE.NORMAL) {
    ly_retreat = true;
    ly_retreat_playing = false;
    ly_retreat_target_x = x + global.grid_cell_size_x * 2;   // 后退两个格子
    state = ENEMY_STATE.IDLE;
    timer = 0;
}

event_inherited();
if (!instance_exists(id)) exit;

if (global.is_paused || is_frozen || is_stun || is_scare) exit;

if (dance_cooldown > 0) dance_cooldown--;
if (ly_retreat_cooldown > 0) ly_retreat_cooldown--;

var _hurt = (hp <= maxhp * hurt_rate);

// ----- 后撤：向后（右）退两格，全程播 spr_gaoqiao_dance3，到位后恢复原有前进逻辑 -----
if (ly_retreat) {
    var _rr_hurt = (hp <= maxhp * hurt_rate);
    if (!ly_retreat_playing) {
        longyuan_play(_rr_hurt ? "破损闪避C" : "闪避C");
        ly_retreat_playing = true;
    }
    longyuan_animate();

    if (x < ly_retreat_target_x) {
        // 后退速度取前进的 3 倍，约 1 秒退完两格，避免「慢慢磨回去」的拖沓感。
        var _rs = move_speed * 3 * move_speed_modify / (is_slowdown ? 2 : 1);
        if (ly_air_speed_bonus) _rs *= longyuan_air_speed_multiplier();
        x = min(ly_retreat_target_x, x + _rs);
    }
    if (x >= ly_retreat_target_x || state == ENEMY_STATE.DEAD) {
        ly_retreat = false;
        ly_retreat_playing = false;
        ly_retreat_cooldown = 240;
        ly_action = "";
        sprite_index = ly_anims[$ "正常移动"][0];
        if (state == ENEMY_STATE.IDLE) { state = ENEMY_STATE.NORMAL; timer = 0; }
    }
    exit;
}

// ----- 按状态覆写高跷自己的动画帧（父类已完成移动/啃咬结算）-----
switch (state) {
    case ENEMY_STATE.NORMAL: {
        var _r = ly_clip_range(_hurt ? "破损移动" : "正常移动");
        image_index = _r[0] + floor(timer / flash_speed) mod _r[1];
        break;
    }
    case ENEMY_STATE.ATTACK: {
        var _r = ly_clip_range(_hurt ? "破损啃咬" : "正常啃咬");
        image_index = _r[0] + floor(timer / flash_speed) mod _r[1];
        break;
    }
    case ENEMY_STATE.ACTING: {
        // 舞步闪避：随机选 3 段闪避精灵（各独立文件，一次性播完后回 NORMAL）
        if (!ly_dodge_playing) {
            longyuan_play(choose("闪避A", "闪避B", "闪避C"), true);
            ly_dodge_playing = true;
        }
        longyuan_animate();
        if (ly_done || hp <= 0) {
            ly_dodge_playing = false; ly_action = "";
            sprite_index = ly_anims[$ "正常移动"][0];
            state = ENEMY_STATE.NORMAL;
            dance_cooldown = is_slowdown ? 240 : 120;
        }
        break;
    }
    case ENEMY_STATE.DEAD: {
        var _r = ly_clip_range("死亡");
        var _fi = min(floor(timer / flash_speed), _r[1] - 1);
        image_index = _r[0] + _fi;
        if (_fi >= _r[1] - 1) image_alpha -= 0.08;
        break;
    }
}
