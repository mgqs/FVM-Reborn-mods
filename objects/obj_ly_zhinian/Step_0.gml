if (global.is_paused) exit;
// 死亡当帧强制重算夜晚（不靠 Create 初始化时可能的缓存，确保 level_file 就绪后拿到正确值）
if (!ly_soul && hp <= 0) {
    ly_night = longyuan_is_night();
    if (ly_night) ash_death = false;
}
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
        if (!ly_soul && longyuan_is_night()) longyuan_change_soul();
        else { image_alpha -= 0.08; if (image_alpha <= 0) instance_destroy(); }
    }
    exit;
}
if (hp <= 0) { longyuan_begin_death(); exit; }
if (is_frozen || is_stun || is_scare) exit;

ly_cooldown = max(0, ly_cooldown - 1);
ly_dodge_cooldown = max(0, ly_dodge_cooldown - 1);
var _speed = move_speed * move_speed_modify / (is_slowdown ? 2 : 1);

if (ly_mode == "spawn" || ly_mode == "appear" || ly_mode == "drop") {
    longyuan_animate();
    if (ly_done) {
        {

            ly_mode = "walk"; ly_action = "";
        }
    }
    exit;
}

// 魂体大招：三次普攻后向前移动 2 格，摧毁途径两格全部卡片（即使当前无目标也触发）。
if (ly_soul && ly_soul_special && ly_mode != "rush") {
    ly_mode = "rush";
    ly_rush_moved = false;
    for (var _roff = 1; _roff <= LY_ZHINIAN_RUSH_DIST; ++_roff) {
        var _rcol = grid_col - _roff;
        if (_rcol < 0 || _rcol >= global.grid_cols) continue;
        var _rlist = ds_grid_get(global.grid_plants, _rcol, grid_row);
        for (var _rli = ds_list_size(_rlist) - 1; _rli >= 0; --_rli) {
            var _rcard = _rlist[| _rli];
            if (instance_exists(_rcard) && _rcard.plant_id != "player" && _rcard.plant_type != "coffee") longyuan_destroy_card(_rcard);
        }
    }
    longyuan_play(longyuan_variant("正常冲刺", "破损冲刺"), true);
}
if (ly_mode == "rush") {
    longyuan_animate();
    var _rclip = ly_anims[$ ly_action];
    var _rhit = floor((_rclip[2] - _rclip[1] + 1) / 2);
    if (!ly_rush_moved && ly_frame >= _rhit) {
        x -= global.grid_cell_size_x * LY_ZHINIAN_RUSH_DIST;
        ly_rush_moved = true;
    }
    if (ly_done) {
        ly_soul_special = false;
        ly_soul_attack_count = 0;
        ly_mode = "walk"; ly_action = "";
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
        show_debug_message("zhinian soul dmg: atk=" + string(atk) + " plant_id=" + string(target_plant.plant_id) + " plant_hp=" + string(target_plant.hp));
        longyuan_damage_plant(target_plant, atk);
        ly_hit = true;
    }
    if (ly_done && ly_frame >= max(_clip[2] - _clip[1] + 1, atk_cycle * 10 / game_get_speed(gamespeed_fps))) {
        ly_frame = 0; ly_hit = false;
        if (ly_soul) {
            ly_soul_attack_count++;
            show_debug_message("zhinian soul atk_count=" + string(ly_soul_attack_count) + " special=" + string(ly_soul_special));
            if (ly_soul_attack_count >= LY_ZHINIAN_SOUL_ATK_COUNT) ly_soul_special = true;
        }
    }
    exit;
}
ly_mode = "walk";
longyuan_play(longyuan_move_action());
x -= _speed;
longyuan_animate();
