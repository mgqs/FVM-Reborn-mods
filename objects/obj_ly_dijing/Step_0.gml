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

// 朝向：地精有两套朝向相反的美术，不能统一翻转。
//   spr_dijing（走路 / 吃东西 / 眩晕 / 倒地）原图朝右；
//   spr_dijing_dig（挖地）/ spr_dijing_apper（出土）是专门朝左画的贴图。
// 只有「美术朝向 ≠ 实际前进方向」时才翻转，否则会把本来就朝左的挖地 /
// 出土贴图翻成朝右（表现为出土瞬间脸朝右）。
// 前进方向看 move_speed：Step 里一律 x -= speed，所以 speed > 0 就是向左。
// 翻转时乘以基类基准缩放（1.8），不能直接写 ±1，否则贴图会缩回原尺寸。
var _flip     = ((move_speed > 0) != (ly_action == "挖地" || ly_action == "出土")) ? -1 : 1;
image_xscale = _flip * ly_base_xscale;

var _speed = move_speed * move_speed_modify / (is_slowdown ? 2 : 1);
if (ly_mode == "dig") {
    var _surface_card = longyuan_dijing_food_ahead();
    if (instance_exists(_surface_card)) {
        ly_food_surface = true;
        ly_food_target = _surface_card;
        longyuan_damage_plant(_surface_card, 50);
        ly_mode = "appear";
        target_type = "normal";
        // 提前出土后下一步是向左走：立刻把攻击朝向切成向左。
        // 出土贴图本身朝左，不要在这里翻转 xscale（上面每帧会按需处理）。
        attack_range = 90;
        longyuan_play("出土", true);
        exit;
    }
    var _dig_speed = move_speed / (is_slowdown ? 2 : 1);
    x -= _dig_speed;
    longyuan_play("挖地");
    image_xscale = ly_base_xscale;   // 挖地贴图本身朝左，钻地也是向左，不需要翻转
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
        // 出土后只做极短的愣神（原 180 帧 = 3 秒，表现为「出土后僵在原地卡顿」）。
        ly_cooldown = 40;
        // 出土动画一结束就把前进方向定下来：眩晕贴图朝右，只有提前出土（向左走）
        // 才需要翻转，否则会出现「眩晕朝左、下一步走路朝右」的抽一下。
        move_speed = ly_food_surface ? 0.3 : -0.3;
        longyuan_play("眩晕", true);
    }
    exit;
}
if (ly_mode == "stunned") {
    longyuan_animate();
    ly_cooldown = max(0, ly_cooldown - 1);
    if (ly_cooldown <= 0) {
        ly_mode = "walk";
        // 出土后使用正常可见的慢速前进（原 0.15 近乎原地不动，表现为“发呆”）。
        move_speed = ly_food_surface ? 0.3 : -0.3;
        attack_range = ly_food_surface ? 90 : -90;
        ly_action = "";
    }
    exit;
}

if (instance_exists(ly_food_target) && ly_food_target.hp > 0) {
    target_plant = ly_food_target;
}
else {
    target_plant = longyuan_find_plant(false);
}
// 外层优先：目标被瓜皮护罩 / 赫拉 / 处女座罩住时，先啃保护卡本体，破罩后下一帧才轮到内层。
// 已经是护罩本身时跳过，避免每帧白遍历一遍全部卡片。
if (instance_exists(target_plant) && target_plant.plant_type != "shield_outer") {
    var _outer = longyuan_outer_card_of(target_plant);
    if (instance_exists(_outer)) target_plant = _outer;
}
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
