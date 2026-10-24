if (global.is_paused) exit;
// 保留父对象注册、状态效果、深度及胜负处理；ACTING禁止旧动画偏移算法。
var _saved_index = image_index;
var _saved_alpha = image_alpha;
state = ENEMY_STATE.ACTING;
event_inherited();
if (!instance_exists(id)) exit;
image_index = _saved_index;
image_alpha = _saved_alpha;
state = ly_mode == "dead" ? ENEMY_STATE.DEAD : ENEMY_STATE.ACTING;
if (ly_mode == "dead") {
    longyuan_animate();
    if (ly_done) {
        image_alpha -= 0.08;
        if (image_alpha <= 0) instance_destroy();
    }
    exit;
}
if (hp <= 0) { longyuan_begin_death(); exit; }
if (is_frozen || is_stun || is_scare) exit;

// 东风鼠一生只施法一次：到达第8列时触发全屏加速。
// wind 必须在 drop 之前检查——否则 ly_fan 掉了就永远触发不了。
if (!ly_wind_active && grid_col <= LY_DONGFENG_TRIGGER_COL) {
    ly_wind_active = true;
    ly_mode = "wind";
    longyuan_play(ly_fan ? "持扇攻击" : longyuan_variant("正常啃咬", "破损啃咬"), true);
}

// 到达第2列强制落地（飞行终点）；或被打掉 helmet；或被电风扇吹落——三者任一触发。
if (ly_fan && (grid_col <= LY_DONGFENG_DROP_COL || hp <= maxhp - helmet_hp)) {
    ly_mode = "drop";
    longyuan_play("下落", true);
}

ly_cooldown = max(0, ly_cooldown - 1);
ly_dodge_cooldown = max(0, ly_dodge_cooldown - 1);
var _speed = move_speed * move_speed_modify / (is_slowdown ? 2 : 1);
if (target_type == "air") {
    _speed *= longyuan_air_speed_multiplier();
}
if (ly_fan) {
    var _fan_near = false;
    with (obj_card_parent) {
        if (hp > 0 && grid_row == other.grid_row && plant_id == "ventilation_fan" && abs(x - other.x) < global.grid_cell_size_x * 4) _fan_near = true;
    }
    // 换气扇对东风鼠直接秒杀（不再只是吹落）
    if (_fan_near) {
        var _blow = instance_create_depth(x, y, depth - 10, obj_mouse_blow_effect);
        _blow.sprite_index = sprite_index;
        _blow.image_index = image_index;
        is_blown_away = true;
        hp = 0;
        shield_hp = 0;
        helmet_hp = 0;
        state = ENEMY_STATE.DEAD;
        instance_destroy();
        exit;
    }
}

if (ly_mode == "spawn" || ly_mode == "appear" || ly_mode == "drop") {
    longyuan_animate();
    if (ly_done) {
        {

            if (ly_mode == "drop") { ly_fan = false; move_speed = 0.3; target_type = "normal"; }
            ly_mode = "walk"; ly_action = "";
        }
    }
    exit;
}

target_plant = longyuan_find_plant(false);

if (ly_mode == "wind") {
    longyuan_animate();
    if (ly_done) { ly_mode = "walk"; ly_action = ""; }
    exit;
}
// 东风鼠在空中态（持扇飞行）只在第8列触发一次全屏加速，其余帧完全不攻击卡片；落地后才正常啃咬。
if (target_type != "air" && instance_exists(target_plant)) {
    ly_mode = "attack";
    longyuan_play(longyuan_attack_action());
    longyuan_animate();
    var _clip = ly_anims[$ ly_action];
    var _hit_frame = floor((_clip[2] - _clip[1] + 1) / 2);
    if (!ly_hit && ly_frame >= _hit_frame) { longyuan_damage_plant(target_plant, atk); ly_hit = true; }
    if (ly_done && ly_frame >= max(_clip[2] - _clip[1] + 1, atk_cycle * 10 / game_get_speed(gamespeed_fps))) {
        ly_frame = 0; ly_hit = false;

    }
    exit;
}
ly_mode = "walk";
longyuan_play(longyuan_move_action());
x -= _speed;
longyuan_animate();
