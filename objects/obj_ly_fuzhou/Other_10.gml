if (hp <= 0 || ly_mode == "dead") exit;
if (invincible) exit;

// 符咒鼠本体：对烤串机 / 护法神 / 灯影花糕 / 炎帝 之外的卡片一律减伤 90%（2026-10-27）。
// 这四张卡在各自子弹里已结算对魂系的额外倍率，这里不再额外处理。
if (!longyuan_hit_pierces_soul_reduction()) damage_amount *= 0.1;

event_inherited();
