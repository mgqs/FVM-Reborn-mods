// 清理巫蛊蛇残留的蛊毒特效，避免卡片死亡/铲除后继续造成伤害
for (var i = instance_number(obj_zodiac_effect) - 1; i >= 0; i--) {
    var eff = instance_find(obj_zodiac_effect, i);
    if (instance_exists(eff) && variable_instance_exists(eff, "poison_source") && eff.poison_source == id) {
        instance_destroy(eff);
    }
}
if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
event_inherited();
