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

if (ly_mode == "cast") {
    longyuan_animate();
    if (ly_done) {

        ly_fire = max(0, ly_fire - 1);
        // GameMaker instance_create_depth 只有 4 参数，owner/lane 必须创建后手动赋值
        var _amu = instance_create_depth(x - 35, y - 65, depth - 1, obj_ly_amulet);
        if (instance_exists(_amu)) {
            _amu.owner = id;
            _amu.lane = grid_row;
            ly_amulet = _amu;
        }
        // 本次阈值已完成，出队：下一档为第6列(5)、再下一档为第4列(3)
        if (array_length(ly_summon_cols) > 0) array_delete(ly_summon_cols, 0, 1);
        ly_cooldown = 0;
        invincible = true;
        ly_mode = "walk"; ly_action = "";
    }
    exit;
}
// 符咒/符咒魂鼠存活期间本体持续无敌；二者皆无才解除。
invincible = ly_has_servant(id);

// 推进到当前阈值列即施法（参考东风鼠 <= 判定：啃卡停在卡右侧一格时也能触发）
if (ly_fire > 0 && array_length(ly_summon_cols) > 0 && grid_col <= ly_summon_cols[0]
    && !instance_exists(ly_amulet)) {
    show_debug_message("fuzhou cast triggered at col=" + string(grid_col) + " threshold=" + string(ly_summon_cols[0]));
    invincible = true;
    ly_mode = "cast"; longyuan_play(longyuan_variant("正常施法", "破损施法"), true); exit;
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
