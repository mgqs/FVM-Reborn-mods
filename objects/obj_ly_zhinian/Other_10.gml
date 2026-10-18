if (hp <= 0 || ly_mode == "dead") exit;
if (invincible) exit;

if (ly_soul) damage_amount *= LY_ZHINIAN_SOUL_REDUCTION;
event_inherited();
