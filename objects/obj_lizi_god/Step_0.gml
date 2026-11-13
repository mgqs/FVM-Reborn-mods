if (global.is_paused)
    exit;

event_inherited();

if (is_frozen || state == CARD_STATE.SLEEP)
    exit;

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

if (cooldown_timer > 0)
{
    cooldown_timer--;
    state = CARD_STATE.IDLE;
    exit;
}

var has_enemy = false;
var target_enemy = -4;

if (!attacking)
{
    var min_distance = 10000;

    with (obj_enemy_parent)
    {
        if (grid_row >= (other.grid_row - 1) && grid_row <= (other.grid_row + 1)
            && grid_col >= other.grid_col
            && can_target_on(other.target_type, target_type))
        {
            var distance = grid_col - other.grid_col;

            if (distance < min_distance)
            {
                min_distance = distance;
                target_enemy = id;
                has_enemy = true;
            }
        }
    }
}

if (has_enemy)
{
    target_instance = target_enemy;
    attacking = true;
}

if (attacking)
{
    state = CARD_STATE.ATTACK;
    attack_timer++;

    // 自己推攻击帧：idle 0~9，攻击 10~21
    var _fi = min(attack_timer div current_flash_speed, attack_anim - 1);
    var _frame = idle_anim + 1 + _fi;
    image_index = _frame;
    external_animation_sync_native(id, current_flash_speed, attack_timer, "attack_timer");

    // 🔴 脱手帧 = 第 19 帧（0 基，即第 20 帧）。原来按 (attack_anim-5)*flash 会卡到第 17 帧就投
    if (!lizi_fired && _frame >= 19)
    {
        lizi_fired = true;
        event_user(1);
        audio_play_sound(snd_throw, 0, 0);
    }

    if (attack_timer >= (attack_anim * current_flash_speed))
    {
        attacking = false;
        cooldown_timer = cycle - attack_timer;
        attack_timer = 0;
        target_instance = -4;
        lizi_fired = false;
    }
}
