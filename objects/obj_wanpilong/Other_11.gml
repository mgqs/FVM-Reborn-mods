/// @description 顽皮龙 - 用户事件1（受伤处理）
// 基础受伤逻辑
if (damage_amount > 0)
{
    hp -= damage_amount;
    hurt_time = flash_speed;

    if (hp <= 0)
    {
        hp = 0;
        state = CARD_STATE.DEAD;
        wanpilong_state = WANPILONG_STATE.FADING_OUT;

        // 从网格移除
        card_destroyed(id);
    }
}
