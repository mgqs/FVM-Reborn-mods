if (hp <= 0 || ly_mode == "dead") exit;
if (invincible || ly_mode == "retreat" || ly_mode == "dodge") exit;
if (ly_kind == "gaoqiao" && !instance_exists(longyuan_find_plant(true))) exit;
if (ly_kind == "yaoguan" && ly_fire > 0) damage_amount *= 1 - ly_soul_damage_reduction;
var _before = hp;
event_inherited();
var _loss = max(0, _before - hp);
if (ly_kind == "zhibuji") {
    ly_damage_accum += _loss;
    var _threshold = max(1, maxhp * ly_shot_loss);
    while (ly_damage_accum >= _threshold) { ly_damage_accum -= _threshold; ly_pending_shots++; }
}
if (variable_instance_exists(id, "damage_source_card_id")) longyuan_fire_hit(id, damage_source_card_id);
