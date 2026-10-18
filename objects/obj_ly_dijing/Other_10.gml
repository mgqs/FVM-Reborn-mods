if (hp <= 0 || ly_mode == "dead") exit;
if (invincible) exit;

var _is_allowed_dig_hit = damage_source_object == obj_rotating_water_gun
	|| (damage_source_object == obj_hundun_god && damage_source_card_shape >= 3)
	|| damage_source_object == obj_nizhuanniu
	|| damage_source_object == obj_qingse_shishi_persimmon;
if (ly_mode == "dig" && !_is_allowed_dig_hit) {
	damage_source_object = noone;
	damage_source_card_shape = -1;
	exit;
}
damage_source_object = noone;
damage_source_card_shape = -1;

event_inherited();
