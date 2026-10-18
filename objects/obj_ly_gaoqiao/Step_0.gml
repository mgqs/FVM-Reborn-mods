// 高跷鼠：完全复用父类行走/啃咬/闪避/死亡状态机（同非主流鼠），仅覆写自己的精灵帧。
if (global.is_paused) exit;

// 目标类型：啃咬中为 normal（可被普通子弹命中），其余为 dance（对齐非主流鼠）
if (state == ENEMY_STATE.ATTACK) target_type = "normal";
else target_type = "dance";

if (hp <= 0 && state != ENEMY_STATE.DEAD) {
    state = ENEMY_STATE.DEAD;
    timer = 0;
    sprite_index = spr_gaoqiao;
}

// ----- 高架物后退（保留专属逻辑）：NORMAL 时前方 2 格内有高架物/连通米线桥，则转 IDLE 自管后撤 -----
ly_obstacle_near = false;
if (state == ENEMY_STATE.NORMAL && hp > 0) {
    with (obj_card_parent) {
        if (hp > 0 && grid_row == other.grid_row && x < other.x && x > other.x - global.grid_cell_size_x * 2
            && (array_get_index(other.ly_high_obstacle_ids, plant_id) != -1
                || (variable_instance_exists(id, "longyuan_bridge_connected") && longyuan_bridge_connected))) {
            other.ly_obstacle_near = true;
        }
    }
}
if (ly_obstacle_near && state == ENEMY_STATE.NORMAL) {
    ly_retreat = true;
    state = ENEMY_STATE.IDLE;
    timer = 0;
}

event_inherited();
if (!instance_exists(id)) exit;

if (global.is_paused || is_frozen || is_stun || is_scare) exit;

if (dance_cooldown > 0) dance_cooldown--;

var _hurt = (hp <= maxhp * hurt_rate);

// ----- 后撤位移与帧（IDLE 期间父类不移动，由此向右退；离开高架物范围后恢复前进）-----
if (ly_retreat) {
    if (!ly_obstacle_near || state == ENEMY_STATE.DEAD) {
        ly_retreat = false;
        if (state == ENEMY_STATE.IDLE) { state = ENEMY_STATE.NORMAL; timer = 0; }
    } else {
        var _rs = move_speed * move_speed_modify / (is_slowdown ? 2 : 1);
        if (ly_air_speed_bonus) _rs *= longyuan_air_speed_multiplier();
        x += _rs;
        var _rr = ly_clip_range(_hurt ? "破损后退" : "正常后退");
        image_index = _rr[0] + floor(timer / flash_speed) mod _rr[1];
        exit;
    }
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
        // 舞步闪避：精灵第11-30帧（0-based 10-29），共20帧，对齐非主流鼠 mod 20；结束回 NORMAL 并进冷却
        var _len = LY_GAOQIAO_DANCE_FRAMES;
        image_index = ly_dodge_start + floor(timer / flash_speed) mod _len;
        if (timer >= _len * flash_speed - 1 || hp <= 0) {
            timer = 0;
            sprite_index = spr_gaoqiao;
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
