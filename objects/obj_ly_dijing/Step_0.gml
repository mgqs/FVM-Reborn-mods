if (global.is_paused) exit;
var _saved_index = image_index;
var _saved_alpha = image_alpha;
state = ENEMY_STATE.ACTING;
event_inherited();
if (!instance_exists(id)) exit;
image_index = _saved_index;
image_alpha = _saved_alpha;
state = ly_mode == "dead" ? ENEMY_STATE.DEAD : ENEMY_STATE.ACTING;

if (hp <= 0 && ly_mode != "dead") {
    longyuan_begin_death();
    target_plant = noone;
}
if (ly_mode == "dead") {
    longyuan_animate();
    if (ly_done) {
        image_alpha -= 0.08;
        if (image_alpha <= 0) instance_destroy();
    }
    exit;
}
if (is_frozen || is_stun || is_scare) exit;

var _speed = move_speed * move_speed_modify / (is_slowdown ? 2 : 1);
if (ly_mode == "dig") {
    var _surface_card = longyuan_dijing_food_ahead();
    if (instance_exists(_surface_card)) {
        ly_food_surface = true;
        longyuan_damage_plant(_surface_card, 50);
        ly_mode = "appear";
        target_type = "normal";
        longyuan_play("出土", true);
        exit;
    }
    var _dig_speed = move_speed / (is_slowdown ? 2 : 1);
    x -= _dig_speed;
    longyuan_play("挖地");
    longyuan_animate();
    if (x <= global.grid_offset_x - 20) {
        ly_mode = "appear";
        target_type = "normal";
        longyuan_play("出土", true);
    }
    exit;
}
if (ly_mode == "appear") {
    longyuan_animate();
    if (ly_done) {
        ly_mode = "stunned";
        ly_cooldown = 180;
        longyuan_play("眩晕", true);
    }
    exit;
}
if (ly_mode == "stunned") {
    longyuan_animate();
    ly_cooldown = max(0, ly_cooldown - 1);
    if (ly_cooldown <= 0) {
        ly_mode = "walk";
        move_speed = ly_food_surface ? 0.15 : -0.15;
        attack_range = ly_food_surface ? 90 : -90;
        ly_action = "";
    }
    exit;
}

target_plant = longyuan_find_plant(false);
if (instance_exists(target_plant)) {
    ly_mode = "attack";
    longyuan_play(longyuan_attack_action());
    longyuan_animate();
    var _clip = ly_anims[$ ly_action];
    var _hit_frame = floor((_clip[2] - _clip[1] + 1) / 2);
    if (!ly_hit && ly_frame >= _hit_frame) {
        longyuan_damage_plant(target_plant, atk);
        ly_hit = true;
    }
    if (ly_done && ly_frame >= max(_clip[2] - _clip[1] + 1, atk_cycle * 10 / game_get_speed(gamespeed_fps))) {
        ly_frame = 0;
        ly_hit = false;
    }
    exit;
}
ly_mode = "walk";
longyuan_play(longyuan_move_action());
x -= _speed;
longyuan_animate();
