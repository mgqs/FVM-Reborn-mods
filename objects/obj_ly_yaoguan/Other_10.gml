if (hp <= 0 || ly_mode == "dead") exit;
if (invincible) exit;

// 魂火减伤：每团魂火提供 20% 减伤，三团封顶 60%。
if (ly_fire > 0) damage_amount *= 1 - min(LY_YAOGUAN_FIRE_RED_MAX, ly_fire * LY_YAOGUAN_FIRE_RED_PER);

var _hp_before = hp;
event_inherited();

// 烤串机 / 俱吠罗神使 / 炎凰马 / 神农氏神使 每次攻击命中，额外打掉一团魂火（需当次确实造成伤害）。
if (ly_fire > 0 && damage_amount > 0 && _hp_before > 0) {
    var _from_obj = (damage_source_object == obj_hongliukaochuan || damage_source_object == obj_hufa_god
                 || damage_source_object == obj_yanhuangma       || damage_source_object == obj_shennong_god);
    var _from_id = false;
    if (variable_instance_exists(id, "damage_source_card_id") && is_string(damage_source_card_id)) {
        _from_id = (damage_source_card_id == "hongliukaochuan" || damage_source_card_id == "hufa_god"
                 || damage_source_card_id == "yanhuangma"       || damage_source_card_id == "shennong_god");
    }
    if (_from_obj || _from_id) ly_fire = max(0, ly_fire - 1);
}
