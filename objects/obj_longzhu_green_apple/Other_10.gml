/// 青苹果被卡片 / 子弹命中（User Event 0）
/// 卡片侧统一走「写 damage_amount / damage_type → event_user(0)」，
/// 所以这里只需要扣血，血量归零后由 Step 的「消失」分支收尾。
if (!variable_instance_exists(id, "damage_amount")) exit;
if (hp <= 0) exit;

var _dmg = damage_amount;
damage_amount = 0;
if (!is_real(_dmg) || _dmg <= 0) exit;

hp = max(0, hp - _dmg);
longzhu_hit_flash = 6;
