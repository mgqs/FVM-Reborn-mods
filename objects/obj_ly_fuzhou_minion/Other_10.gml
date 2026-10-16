if (hp <= 0 || ly_mode == "dead") exit;
if (invincible) exit;

if (is_soul) longyuan_apply_soul_damage_reduction();
event_inherited();
