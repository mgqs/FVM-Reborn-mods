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

if (ly_mode == "retreat" || ly_mode == "dodge") {
    if (ly_mode == "retreat") x += 5;
    longyuan_animate();
    if (ly_done) { ly_mode = "walk"; ly_dodge_cooldown = 30; ly_action = ""; }
    exit;
}

{
    var _bridge = longyuan_bridge_contact(x, y, x - _speed, y, grid_row);
    if (_bridge != noone) { ly_mode = "retreat"; longyuan_play(longyuan_variant("正常后退", "破损后退"), true); exit; }
    var _bullet = instance_nearest(x, y - 55, obj_bullet_parent);
    if (ly_dodge_cooldown <= 0 && instance_exists(_bullet) && point_distance(x, y - 55, _bullet.x, _bullet.y) < 80) {
        ly_mode = "dodge"; longyuan_play(longyuan_variant("正常闪避1", "破损闪避1"), true); exit;
    }
}
target_plant = longyuan_find_plant(true);

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
