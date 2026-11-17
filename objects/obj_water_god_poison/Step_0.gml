// 水神 反弹毒伤 Step：跟着目标、每 1 秒一跳、跳满 ticks 次自毁（目标没了也自毁）
if (global.is_paused)
    exit;

if (!instance_exists(target))
{
    instance_destroy();
    exit;
}

t++;
if (t < tick_frames)
    exit;

t = 0;

if (target.hp > 0)
{
    with (target)
    {
        damage_amount = other.dmg;
        damage_type   = "normal";
        event_user(0);
    }

    // 鼠身紫雾：一跳一片，life 正好一跳的时长，不会叠出一堆
    if (instance_exists(target))
    {
        var _fx = instance_create_depth(target.x, target.y, target.depth - 1, obj_bbq_mouse_burn);
        _fx.fx_spr     = spr_fashishe_burn_mouse;
        _fx.target     = target;
        _fx.life       = tick_frames;
        _fx.life_total = tick_frames;
        _fx.x_off      = -6;
        _fx.y_off      = 50;
    }
}

done++;
if (done >= ticks)
    instance_destroy();
