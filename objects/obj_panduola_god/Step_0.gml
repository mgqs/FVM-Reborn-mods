if (global.is_paused)
    exit;

event_inherited();

if (is_frozen)
    exit;

trigger_timer++;

// 放置后立即触发爆炸 + 毒气
if (!triggered && trigger_timer >= 2)
{
    triggered = true;
    event_user(1);
}

// 短帧展示后销毁自身
if (triggered && trigger_timer >= 10)
{
    instance_destroy();
}