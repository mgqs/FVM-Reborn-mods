if (hp <= 0 || ly_mode == "dead") exit;
if (invincible) exit;

// 符咒魂鼠免疫灰烬伤害（damage_type == "ash"）
if (is_soul && damage_type == "ash") { hp += damage_amount; exit; }
if (is_soul) longyuan_apply_soul_damage_reduction();
event_inherited();
