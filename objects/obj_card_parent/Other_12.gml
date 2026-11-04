flash_value = 150
// 海克斯二期：孤狼的高傲（卡片致死免一次并回满）/ 悬丝的傀儡（人物致死免疫 + 30 秒无敌）。
// 放在最前面：再往下的星穹马减伤只处理“被打到但没死”的情况，救不回已经 0 血的卡
if (hex_enabled()) hex_b3_card_lethal(id);
// 星穹马减伤：减伤时间内抵挡指定次数老鼠攻击（含致命伤）
if (variable_instance_exists(id,"zodiac_guard_time") && zodiac_guard_time > 0 && zodiac_guard_hits > 0 && hp < zodiac_guard_hp) {
    hp = zodiac_guard_hp;
    zodiac_guard_hits--;
    if (zodiac_guard_hits <= 0) zodiac_guard_time = 0;
}
