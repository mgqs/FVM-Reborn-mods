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

if (ly_mode == "heal") {
    longyuan_animate();
    if (ly_done) {

        ly_fire = max(0, ly_fire - 1);
        var _ratio = LY_YAOGUAN_HEAL_RATIO;
        with (obj_enemy_parent) {
            if (hp > 0 && state != ENEMY_STATE.DEAD && variable_instance_exists(id, "is_soul") && is_soul) hp = min(maxhp, hp + maxhp * _ratio);
        }
        move_speed = LY_YAOGUAN_HEAL_DONE_SPEED;
        ly_mode = "walk"; ly_action = "";
    }
    exit;
}

// 生命值低于最大生命 30% 且仍有魂火时进入回血；魂火耗尽后条件永不成立，不再触发。
if (ly_fire > 0 && hp <= maxhp * LY_YAOGUAN_HEAL_TRIGGER) {
    ly_mode = "heal"; longyuan_play(longyuan_variant("正常回血", "破损回血"), true); exit;
}

target_plant = longyuan_find_plant(false);

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
