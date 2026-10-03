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
if (attack_timer <= cycle - attack_anim * flash_speed) {
    attack_timer++;
} else if (attack_timer <= cycle) {
    attack_timer++;
    state = CARD_STATE.ATTACK;
} else {
    event_user(1); // 发射海胆子弹
    attack_timer = 0;
    state = CARD_STATE.IDLE;
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
