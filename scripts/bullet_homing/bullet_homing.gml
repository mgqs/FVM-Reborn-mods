/// @function homing_target_ok(_t)
/// @desc 追踪弹「目标还值不值得追」的统一判定（2026-10-24）
///       原来的写法只判 `instance_exists(target_id) && target_id.hp > 0`，于是：
///         ① 目标进无敌（护盾 / 剧情无敌 / 复活无敌）—— hp 还在，子弹一直贴着它转；
///         ② 目标隐身 / 潜行；
///         ③ 目标被隐藏或传走（实例还在、位置已经没用）——
///       子弹都会一直纠缠在目标原地，直到对方恢复才继续飞。
///       现在这些情况一律判为「无效目标」，子弹保持当前 move_x / move_y 直线飞，
///       直到飞出地图或 timer 到期自然销毁。
/// @param {id} _t 目标实例 id
/// @return {bool} true = 可以继续朝它转向
function homing_target_ok(_t) {
    if (!instance_exists(_t)) return false;
    if (!variable_instance_exists(_t, "hp") || _t.hp <= 0) return false;
    // 无敌：护盾 / 剧情无敌 / 复活无敌
    if (variable_instance_exists(_t, "invincible") && _t.invincible) return false;
    if (variable_instance_exists(_t, "is_invincible") && _t.is_invincible) return false;
    // 隐身 / 潜行（魂系敌人分类叫 invisible，实例上也可能挂同名标记）
    if (variable_instance_exists(_t, "invisible") && _t.invisible) return false;
    if (variable_instance_exists(_t, "is_invisible") && _t.is_invisible) return false;
    // 被隐藏 / 离开战场（传送、出场前等）
    if (!_t.visible) return false;
    return true;
}
