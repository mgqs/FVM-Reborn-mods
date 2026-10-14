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

ly_cooldown = max(0, ly_cooldown - 1);
ly_dodge_cooldown = max(0, ly_dodge_cooldown - 1);
var _speed = move_speed * move_speed_modify / (is_slowdown ? 2 : 1);
if (target_type == "air") {
    var _wind = false;
    with (obj_ly_dongfeng) {
        if (hp > 0 && ly_fan && ly_action == "持扇攻击" && !is_frozen && !is_stun && !is_scare) _wind = true;
    }
    if (_wind) _speed *= ly_wind_multiplier;
}
if (ly_fan) {
    var _fan_near = false;
    with (obj_card_parent) {
        if (hp > 0 && grid_row == other.grid_row && plant_id == "ventilation_fan" && abs(x - other.x) < global.grid_cell_size_x * 4) _fan_near = true;
    }
    if (_fan_near && ly_mode != "drop") { ly_mode = "drop"; longyuan_play("下落", true); }
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

if (ly_fan && ly_cooldown <= 0) {
    ly_mode = "wind"; longyuan_play("持扇攻击", true);
}
if (ly_mode == "wind") {
    longyuan_animate();
    if (ly_done) { ly_mode = "walk"; ly_cooldown = 180; ly_action = ""; }
    exit;
}
if (instance_exists(target_plant)) {
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
