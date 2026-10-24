if (hp <= 0 || ly_mode == "dead") exit;
if (invincible) exit;

// 钻地期间参照 obj_mole：能命中 underground 目标的攻击（rotate / d_fruit / all）
// 以及喷壶类（直线/旋转）卡片与子弹会在命中前把 ly_dig_hittable 置为 true，允许造成伤害；
// 白名单内不经过类型判定的特殊来源同样放行。
var _is_allowed_dig_hit = ly_dig_hittable
	|| (damage_source_object == obj_hundun_god && damage_source_card_shape >= 3)
	|| damage_source_object == obj_nizhuanniu
	|| damage_source_object == obj_qingse_shishi_persimmon;
ly_dig_hittable = false;
if (ly_mode == "dig" && !_is_allowed_dig_hit) {
	damage_source_object = noone;
	damage_source_card_shape = -1;
	exit;
}
damage_source_object = noone;
damage_source_card_shape = -1;

event_inherited();
