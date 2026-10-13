// User事件0（受伤）：覆盖父类扣血逻辑。
// 代理自身无敌，只累加伤害，由EndStep转发给绑定老鼠。
decoy_pending += max(0, damage_amount);

// 伤害类型按 true(真伤) > pierce(穿透) > normal 取最强
if (damage_type == "true"
    || (damage_type == "pierce" && decoy_type == "normal")) {
    decoy_type = damage_type;
}
flash_value = 0;
