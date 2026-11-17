// 统一入口（2026-11-10）：火源 / 反弹源各自一个父对象，新卡只要 parent 指过去，子弹侧不用动
// 倍率 = atk × fire_mult_scale；倍率类卡（能量喵）atk 置 0、倍率放 custom["过火倍率"] → 走 fire_mult_override
var _mult = variable_instance_exists(other, "fire_mult_override") ? other.fire_mult_override : other.atk;
bullet_hazard_fire(id, other, _mult * other.fire_mult_scale);
