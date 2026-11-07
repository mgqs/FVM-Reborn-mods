// 醉酒（drunk）：本对象**覆写了父类受伤事件**，父类那段 ×1.5 不会执行 → 必须在这里补一遍，
//   否则测试关（全用测试鼠）/ 木桶鼠 / 牡蛎鼠 对上桂花酒会「醉了却不加伤」。
if (variable_instance_exists(id, "drunk_timer") && drunk_timer > 0 && !is_boss)
{
    damage_amount = damage_amount * (variable_instance_exists(id, "drunk_mult") ? drunk_mult : 1.5);
}
flash_value = 150
if state == ENEMY_STATE.ACTING{
	hp -= 0.1 * damage_amount
}
else{
	hp -= damage_amount
}