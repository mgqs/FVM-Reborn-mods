/// 主动宝石「冷却就绪」闪光提示（2026-11-13）
///
/// 需求：任何需要玩家手动点击触发的宝石，冷却读完后在人物处闪一次光。
/// 生效范围（全工程仅这 6 个宝石对象带 Mouse_4 = 左键按下触发）：
///   激光宝石 obj_laser_gem / 轰炸宝石 obj_bomb_gem / 冰冻宝石 obj_freeze_gem
///   神圣宝石 obj_holy_gem / 星光宝石 obj_starlight_gem / 猫眼宝石 obj_cateye_gem
/// 尺寸：3 格 × 3 格（网格 107×116 → 321×348）；时长 3 秒 = 180 帧（贴图 12 帧）
///
/// 触发点写在每个宝石对象的 Step_0，写法统一：
///   if cooldown_timer > 0 {
///       cooldown_timer--;
///       if cooldown_timer <= 0 gem_cooldown_flash_create();
///   }
/// 只有「从 >0 递减到 <=0」的那一帧会闪一次，冷却期间不会重复触发。

#macro GEM_FLASH_CELLS 3
#macro GEM_FLASH_DURATION 180

/// @func gem_cooldown_flash_create()
/// @desc 在人物处生成冷却就绪闪光
/// @return 闪光实例 id；人物不存在或还没落地时返回 noone
function gem_cooldown_flash_create() {
    var _pl = instance_find(obj_player_character, 0);
    if (!instance_exists(_pl)) return noone;
    // 人物还没放到格子上（跟随鼠标阶段）不闪，否则会在屏幕乱闪
    if (variable_instance_exists(_pl, "is_placed") && !_pl.is_placed) return noone;

    var _fx = instance_create_depth(_pl.x, _pl.y + 20, _pl.depth - 2, obj_gem_cooldown_flash);
    return _fx;
}
