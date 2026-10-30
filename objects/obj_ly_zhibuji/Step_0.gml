if (global.is_paused) exit;
// 保留父对象注册、状态效果、深度及胜负处理；ACTING禁止旧动画偏移算法。
var _saved_index = image_index;
var _saved_alpha = image_alpha;
// 免疫减速控制：清空冰冻减速计时，父对象据此不会置 is_slowdown。
ice_timer = 0;
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
        show_debug_message("zhibuji shooting idx=" + string(ly_shoot_index) + " act=" + string(ly_action));
        var _shuttle = instance_create_depth(x - 45, y - 45, depth - 1, obj_ly_shuttle);
        if (instance_exists(_shuttle)) show_debug_message("zhibuji shuttle created at x=" + string(_shuttle.x) + " y=" + string(_shuttle.y));
        _shuttle.lane = grid_row;
        ly_mode = "walk"; ly_action = "";
    }
    exit;
}

// 有待发阈值：依次取出并播对应 6 帧发射动作（70/40/10% 档自动切减丝外观）。
if (array_length(ly_shot_queue) > 0) {
    ly_shoot_index = ly_shot_queue[0];
    array_delete(ly_shot_queue, 0, 1);
    show_debug_message("zhibuji dequeue idx=" + string(ly_shoot_index));
    ly_mode = "shoot";
    longyuan_play(ly_shot_actions[ly_shoot_index], true);
    exit;
}

target_plant = longyuan_find_plant(false);

if (instance_exists(target_plant)) {
    // 织布机鼠不再做啃咬动作，遇到卡片直接将其摧毁后继续前进。
    longyuan_destroy_card(target_plant, true);
    target_plant = noone;
}
ly_mode = "walk";
longyuan_play(longyuan_move_action());
x -= _speed;
longyuan_animate();
