// 受伤结算与非主流鼠一致：直接走父类（无盾/无头盔，hp -= damage_amount）。
// 舞步形态能否被命中由 target_type="dance" + can_target_on 决定，不在此额外免伤。
event_inherited();
