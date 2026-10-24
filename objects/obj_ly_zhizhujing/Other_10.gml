if (hp <= 0 || ly_mode == "dead") exit;
if (invincible) exit;

// 蜘蛛精夜魂体用户未给减伤，按受伤 100% 处理。
event_inherited();
