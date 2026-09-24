if (global.is_paused)
    exit;

event_inherited();

if (is_frozen || hp <= 0)
    exit;

var current_flash_speed = flash_speed;
if (is_slowdown)
    current_flash_speed *= 2;

attack_timer++;

// 施法闪光倒计时
if (zhiyumiao_cast_flash > 0)
    zhiyumiao_cast_flash--;

// 周期治疗：将cycle(ms)转换为帧数(60fps)
var _heal_interval = max(60, round(cycle * 60 / 1000));

if (attack_timer < first_produce_delay) {
    // 初始延迟阶段
    state = CARD_STATE.IDLE;
    image_index = (attack_timer div current_flash_speed) mod (idle_anim + 1);
} else if (attack_timer < first_produce_delay + _heal_interval) {
    // 等待周期阶段
    state = CARD_STATE.IDLE;
    var _pos = attack_timer - first_produce_delay;
    image_index = (_pos div current_flash_speed) mod (idle_anim + 1);
} else {
    // 施法动画阶段
    state = CARD_STATE.ATTACK;
    var _attack_pos = attack_timer - first_produce_delay - _heal_interval;
    var _attack_frame = _attack_pos div current_flash_speed;

    if (_attack_frame >= attack_anim) {
        // 触发治疗
        if (shape < 2)
            event_user(1);
        else
            event_user(11);

        zhiyumiao_cast_flash = 20;
        attack_timer = first_produce_delay;
        state = CARD_STATE.IDLE;
    } else {
        image_index = idle_anim + 1 + _attack_frame;
    }
}
