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

        instance_create_depth(x - 45, y - 45, depth - 1, obj_ly_shuttle, {lane: grid_row});
        ly_pending_shots = max(0, ly_pending_shots - 1);
        ly_mode = "walk"; ly_action = "";
    }
    exit;
}

if (ly_pending_shots > 0) {
    ly_mode = "shoot";
    // SWF的23/37/59帧虽然仍标“移动”，均为对应剩余丝线的6帧段，保留原区间。
    var _action = "全丝线发射子弹";
    if (hp <= maxhp * 0.75) { ly_anims[$ "发射"] = [spr_zhibuji, 23, 28]; _action = "发射"; }
    if (hp <= maxhp * 0.5) ly_anims[$ "发射"] = [spr_zhibuji, 37, 42];
    if (hp <= maxhp * 0.3) ly_anims[$ "发射"] = [spr_zhibuji, 59, 64];
    if (hp <= maxhp * 0.15) { ly_pending_shots = 0; ly_mode = "walk"; }
    else { ly_action = ""; longyuan_play(_action, true); exit; }
}

target_plant = longyuan_find_plant(false);
target_plant = noone;

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
