if (hp <= 0 || ly_mode == "dead") exit;
if (invincible || ly_mode == "retreat" || ly_mode == "dodge") exit;

target_type = ly_mode == "attack" ? "normal" : "dance";

event_inherited();
