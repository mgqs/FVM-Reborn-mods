flash_value = 150
// 星穹马减伤：减伤时间内抵挡指定次数老鼠攻击（含致命伤）
if (variable_instance_exists(id,"zodiac_guard_time") && zodiac_guard_time > 0 && zodiac_guard_hits > 0 && hp < zodiac_guard_hp) {
    hp = zodiac_guard_hp;
    zodiac_guard_hits--;
    if (zodiac_guard_hits <= 0) zodiac_guard_time = 0;
}
