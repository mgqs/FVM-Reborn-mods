if (global.is_paused) exit;
zodiac_card_before_step();
event_inherited();
if (hp <= 0) exit;
zodiac_card_step();
