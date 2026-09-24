if (global.is_paused)
    exit;

event_inherited();

if (is_frozen)
    exit;

// 初始化死亡卡片记录列表
if (!variable_global_exists("dead_cards"))
{
    global.dead_cards = ds_list_create();
}

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

// 放下后立即进入攻击状态播放动画
state = CARD_STATE.ATTACK;

// 到第20帧时执行复活
if (image_index >= 20 && !revive_triggered)
{
    event_user(1);
    revive_triggered = true;
}
// 复活完成后消失
else if (revive_triggered)
{
    instance_destroy();
}
