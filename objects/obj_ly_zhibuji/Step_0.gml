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

if (ly_mode == "shoot") {
    longyuan_animate();
    if (ly_done) {
        // 织布机丝：整行穿透，对经过的每张卡片造成 10 点伤害（火盆等可阻挡，见 obj_ly_shuttle）。
        instance_create_depth(x - 45, y - 45, depth - 1, obj_ly_shuttle, {lane: grid_row, damage: LY_SHUTTLE_DAMAGE});
        ly_mode = "walk"; ly_action = "";
    }
    exit;
}

// 有待发阈值：依次取出并播对应 6 帧发射动作（70/40/10% 档自动切减丝外观）。
if (array_length(ly_shot_queue) > 0) {
    ly_shoot_index = ly_shot_queue[0];
    array_delete(ly_shot_queue, 0, 1);
    ly_mode = "shoot";
    longyuan_play(ly_shot_actions[ly_shoot_index], true);
    exit;
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
