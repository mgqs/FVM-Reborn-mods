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
// 2026-11-16 用户口径：**在地下（dig）时免疫灰烬**。
//   钻地本来就是「打不到」，但能命中 underground 的灰烬卡（target_type = all / rotate / d_fruit）
//   会在命中前把 ly_dig_hittable 置 true，从白名单漏进来扣血 —— 地火 / 三昧真火 / 灰烬爆炸
//   这类 damage_type == "ash" 的一律按 0 伤害处理。出土（walk / 啃咬）照旧正常吃灰烬。
if (ly_mode == "dig" && damage_type == "ash") {
	damage_source_object = noone;
	damage_source_card_shape = -1;
	exit;
}
if (ly_mode == "dig" && !_is_allowed_dig_hit) {
	damage_source_object = noone;
	damage_source_card_shape = -1;
	exit;
}
damage_source_object = noone;
damage_source_card_shape = -1;

event_inherited();
