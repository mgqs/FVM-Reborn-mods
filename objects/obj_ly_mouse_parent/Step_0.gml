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
        if (!ly_soul && ly_night && (ly_kind == "kailu" || ly_kind == "zhinian")) longyuan_change_soul();
        else { image_alpha -= 0.08; if (image_alpha <= 0) instance_destroy(); }
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
if (ly_kind == "dongfeng" && ly_fan) {
    var _fan_near = false;
    with (obj_card_parent) {
        if (hp > 0 && grid_row == other.grid_row && plant_id == "ventilation_fan" && abs(x - other.x) < global.grid_cell_size_x * 4) _fan_near = true;
    }
    if (_fan_near && ly_mode != "drop") { ly_mode = "drop"; longyuan_play("下落", true); }
}
if (ly_kind == "longmu" && ly_egg && shield_hp <= 0 && ly_mode != "drop") {
    ly_mode = "drop"; longyuan_play(longyuan_variant("正常原地发火", "破损原地发火"), true);
}
if (ly_mode == "spawn" || ly_mode == "appear" || ly_mode == "drop") {
    longyuan_animate();
    if (ly_done) {
        if (ly_mode == "appear") { ly_mode = "stunned"; ly_cooldown = 180; longyuan_play("眩晕"); }
        else {
            if (ly_mode == "drop" && ly_kind == "longmu") { ly_egg = false; move_speed = 0.9; atk_cycle = 18; }
            if (ly_mode == "drop" && ly_kind == "dongfeng") { ly_fan = false; move_speed = 0.3; target_type = "normal"; }
            ly_mode = "walk"; ly_action = "";
        }
    }
    exit;
}
if (ly_mode == "dig") {
    x -= _speed;
    longyuan_play("挖地"); longyuan_animate();
    if (x <= global.grid_offset_x - 20) { ly_mode = "appear"; target_type = "normal"; longyuan_play("出土", true); }
    exit;
}
if (ly_mode == "stunned") {
    longyuan_animate();
    if (ly_cooldown <= 0) { ly_mode = "walk"; move_speed = -0.15; ly_action = ""; }
    exit;
}
if (ly_mode == "retreat" || ly_mode == "dodge") {
    if (ly_mode == "retreat") x += 5;
    longyuan_animate();
    if (ly_done) { ly_mode = "walk"; ly_dodge_cooldown = 30; ly_action = ""; }
    exit;
}
if (ly_mode == "heal" || ly_mode == "cast" || ly_mode == "shoot") {
    longyuan_animate();
    if (ly_done) {
        switch (ly_mode) {
            case "heal":
                ly_fire = max(0, ly_fire - 1);
                var _ratio = ly_heal_ratio;
                with (obj_enemy_parent) {
                    if (hp > 0 && state != ENEMY_STATE.DEAD && variable_instance_exists(id, "is_soul") && is_soul) hp = min(maxhp, hp + maxhp * _ratio);
                }
                move_speed = 0.3; break;
            case "cast":
                ly_fire = max(0, ly_fire - 1);
                ly_amulet = instance_create_depth(x - 35, y - 65, depth - 1, obj_ly_amulet, {owner: id, lane: grid_row});
                ly_cooldown = ly_summon_cooldown; break;
            case "shoot":
                instance_create_depth(x - 45, y - 45, depth - 1, obj_ly_shuttle, {lane: grid_row});
                ly_pending_shots = max(0, ly_pending_shots - 1); break;
        }
        ly_mode = "walk"; ly_action = "";
    }
    exit;
}
invincible = ly_kind == "fuzhou" && instance_exists(ly_amulet);
if (ly_kind == "yaoguan" && ly_fire > 0 && hp <= maxhp * 0.3) {
    ly_mode = "heal"; longyuan_play(longyuan_variant("正常回血", "破损回血"), true); exit;
}
if (ly_kind == "fuzhou" && ly_fire > 0 && ly_cooldown <= 0 && !instance_exists(ly_amulet)) {
    ly_mode = "cast"; longyuan_play(longyuan_variant("正常施法", "破损施法"), true); exit;
}
if (ly_kind == "zhibuji" && ly_pending_shots > 0) {
    ly_mode = "shoot";
    // SWF的23/37/59帧虽然仍标“移动”，均为对应剩余丝线的6帧段，保留原区间。
    var _action = "全丝线发射子弹";
    if (hp <= maxhp * 0.75) { ly_anims[$ "发射"] = [spr_zhibuji, 23, 28]; _action = "发射"; }
    if (hp <= maxhp * 0.5) ly_anims[$ "发射"] = [spr_zhibuji, 37, 42];
    if (hp <= maxhp * 0.3) ly_anims[$ "发射"] = [spr_zhibuji, 59, 64];
    if (hp <= maxhp * 0.15) { ly_pending_shots = 0; ly_mode = "walk"; }
    else { ly_action = ""; longyuan_play(_action, true); exit; }
}
if (ly_kind == "zhizhujing") {
    // 仅SWF可证明待机/缠绕/死亡；技能目标和时序需说明，不擅自销毁或封锁卡片。
    longyuan_play("正常待机"); longyuan_animate(); exit;
}
if (ly_kind == "gaoqiao") {
    var _bridge = longyuan_bridge_contact(x, y, x - _speed, y, grid_row);
    if (_bridge != noone) { ly_mode = "retreat"; longyuan_play(longyuan_variant("正常后退", "破损后退"), true); exit; }
    var _bullet = instance_nearest(x, y - 55, obj_bullet_parent);
    if (ly_dodge_cooldown <= 0 && instance_exists(_bullet) && point_distance(x, y - 55, _bullet.x, _bullet.y) < 80) {
        ly_mode = "dodge"; longyuan_play(longyuan_variant("正常闪避1", "破损闪避1"), true); exit;
    }
}
target_plant = longyuan_find_plant(ly_kind == "gaoqiao");
if (ly_kind == "zhibuji" || ly_kind == "kailu_soul") target_plant = noone;
if (ly_kind == "dongfeng" && ly_fan && ly_cooldown <= 0) {
    ly_mode = "wind"; longyuan_play("持扇攻击", true);
}
if (ly_mode == "wind") {
    longyuan_animate();
    if (ly_done) { ly_mode = "walk"; ly_cooldown = 180; ly_action = ""; }
    exit;
}
if (instance_exists(target_plant)) {
    ly_mode = "attack";
    longyuan_play(ly_kind == "zhinian_soul" ? longyuan_variant("正常攻击卡片", "破损攻击卡片") : longyuan_attack_action());
    longyuan_animate();
    var _clip = ly_anims[$ ly_action];
    var _hit_frame = ly_kind == "langyabang" ? 9 : floor((_clip[2] - _clip[1] + 1) / 2);
    if (!ly_hit && ly_frame >= _hit_frame) { longyuan_damage_plant(target_plant, atk); ly_hit = true; }
    if (ly_done && ly_frame >= max(_clip[2] - _clip[1] + 1, atk_cycle * 10 / game_get_speed(gamespeed_fps))) {
        ly_frame = 0; ly_hit = false;
        if (ly_kind == "kailu") { x = target_plant.x - global.grid_cell_size_x * 0.5; ly_mode = "walk"; ly_action = ""; }
    }
    exit;
}
ly_mode = "walk";
longyuan_play(longyuan_move_action());
x -= _speed;
longyuan_animate();
