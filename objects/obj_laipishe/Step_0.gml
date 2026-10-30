// 赖皮蛇 - 步事件
// 无论场上是否有敌人，都按攻击间隔发射海胆子弹
if global.is_paused{
	exit
}

event_inherited();

// 冰冻则不行动（父类已设置is_frozen，这里再次确认）
if is_frozen{
    exit
}

// 赖皮蛇：无论是否有敌人都按间隔发射子弹
// 帧布局（2026-10-28 用户）：1-14 待机 / 15-26 攻击，第 22 帧发射
if (state != CARD_STATE.ATTACK)
{
    attack_timer++;

    // cycle 不足以播完整套攻击动画时按 cycle 压缩每帧时钟（总周期仍是 cycle）
    var _cs = is_slowdown ? flash_speed_base * 2 : flash_speed_base;
    var _spd = min(_cs, max(1, floor(cycle / max(1, attack_anim))));
    var _window = attack_anim * _spd;

    if (attack_timer >= cycle - _window)
    {
        attack_timer = 0;
        state = CARD_STATE.ATTACK;
        image_index = idle_anim + 1;
        laipishe_fired = false;
        flash_speed = is_slowdown ? max(1, _spd * 0.5) : _spd;
    }
}
else
{
    // 攻击动画播到第 22 帧 → 发射海胆子弹
    if (!laipishe_fired && image_index >= laipishe_shoot_frame)
    {
        event_user(1);
        laipishe_fired = true;
    }

    if (image_index >= idle_anim + attack_anim)
    {
        state = CARD_STATE.IDLE;
        image_index = 0;
        attack_timer = 0;
        flash_speed = flash_speed_base;
    }
}

// 清理已失效的子弹引用
if (ds_exists(laipishe_bullets, ds_type_list))
{
    for (var i = ds_list_size(laipishe_bullets) - 1; i >= 0; i--)
    {
        var _b = ds_list_find_value(laipishe_bullets, i);
        if (!instance_exists(_b))
            ds_list_delete(laipishe_bullets, i);
    }
}
