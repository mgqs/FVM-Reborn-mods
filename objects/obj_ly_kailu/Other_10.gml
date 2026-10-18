if (hp <= 0 || ly_mode == "dead") exit;
if (invincible) exit;

if (ly_soul) longyuan_apply_soul_damage_reduction(LY_KAILU_SOUL_REDUCTION);
event_inherited();
