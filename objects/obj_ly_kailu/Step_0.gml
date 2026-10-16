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
        if (!ly_soul && !ash_death && ly_night) longyuan_change_soul();
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

if (ly_mode == "dash") {
    var _dash_card = longyuan_card_in_cell(grid_col, grid_row);
    if (instance_exists(_dash_card)) {
        longyuan_destroy_card(_dash_card);
        instance_destroy();
        exit;
    }
    x -= max(1, _speed * 2);
    longyuan_animate();
    if (x <= ly_dash_target_x) { ly_mode = "walk"; ly_action = ""; }
    exit;
}

var _dash_col = array_get_index(ly_dash_cols, grid_col);
if (_dash_col != -1 && array_get_index(ly_dashed_cols, grid_col) == -1) {
    array_push(ly_dashed_cols, grid_col);
    ly_dash_target_x = x - global.grid_cell_size_x * 3;
    ly_mode = "dash";
    longyuan_play(ly_soul ? longyuan_variant("正常前进", "破损前进") : longyuan_variant("正常大火冲刺", "破损大火冲刺"), true);
    exit;
}

target_plant = longyuan_find_plant(false);
if (ly_soul) target_plant = noone;

if (instance_exists(target_plant)) {
    ly_mode = "attack";
    longyuan_play(longyuan_attack_action());
    longyuan_animate();
    var _clip = ly_anims[$ ly_action];
    var _hit_frame = floor((_clip[2] - _clip[1] + 1) / 2);
    if (!ly_hit && ly_frame >= _hit_frame) { longyuan_damage_plant(target_plant, atk); ly_hit = true; }
    if (ly_done && ly_frame >= max(_clip[2] - _clip[1] + 1, atk_cycle * 10 / game_get_speed(gamespeed_fps))) {
        ly_frame = 0; ly_hit = false;
        x = target_plant.x - global.grid_cell_size_x * 0.5;
        ly_mode = "walk"; ly_action = "";
    }
    exit;
}
ly_mode = "walk";
longyuan_play(longyuan_move_action());
x -= _speed;
longyuan_animate();
