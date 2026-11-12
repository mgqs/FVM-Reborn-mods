/// 变异轰隆隆 技能3（坐压）冲击波特效
/// 由 obj_honglonglong Step_0.gml 在 SKILL3 落地那一 tick 创建，
/// 创建点 = 4x4 判定区的几何中点（网格线交点），不是 BOSS 脚底的 (x, y)
///
/// 放大倍数推导（spr_honglonglong_skill_3_effect，278x262，origin 139,131）：
///   逐帧 alpha 半径 r98：帧0 约 95px，帧1 约 110px，帧2/3/4 约 100px
///   4x4 判定区半宽 = 2 格 = 214px，半高 = 2 格 = 232px
///   1.8 倍只有 171~198px，铺不满判定区 → 取 2.1 倍 = 200~231px，正好压满
image_xscale = 2.1
image_yscale = 2.1
image_speed = 0
image_index = 0
image_alpha = 1

// 不写 depth：由 instance_create_depth 传入的 BOSS depth + 1 决定
// （数值更大 = 更远 = 先画，冲击波在 BOSS 背后，环心白核不会盖住本体）

timer = 0
