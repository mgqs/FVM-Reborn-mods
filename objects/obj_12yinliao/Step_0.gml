if (global.is_paused)
    exit;

event_inherited();

if (is_frozen || hp <= 0)
    exit;

var current_flash_speed = flash_speed;
if (is_slowdown)
    current_flash_speed *= 2;

attack_timer++;

if (attack_timer <= first_produce_delay) {
    // 阶段1：闲置动画
    state = CARD_STATE.IDLE;
} else {
    // 阶段2：攻击动画，播放到第16帧时触发加血+爆炸
    state = CARD_STATE.ATTACK;
    // 用 attack_timer 换算动画帧（image_index 会被引擎 wrap，不可靠）
    var frame = idle_anim + 1 + ((attack_timer - first_produce_delay - 1) div current_flash_speed);
    if (frame >= 16) {
        event_user(1);
        instance_destroy();
    }
}