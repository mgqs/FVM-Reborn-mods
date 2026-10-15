if (hp <= 0 || ly_mode == "dead") exit;
if (invincible || ly_mode == "retreat" || ly_mode == "dodge") exit;
if (!instance_exists(longyuan_find_plant(true))) exit;

event_inherited();
