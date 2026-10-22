if (hp <= 0 || ly_mode == "dead") exit;
if (invincible) exit;

// 魂体免疫灰烬伤害（damage_type == "ash"）
if (ly_soul && damage_type == "ash") { hp += damage_amount; exit; }
if (ly_soul) damage_amount *= LY_ZHINIAN_SOUL_REDUCTION;
event_inherited();
