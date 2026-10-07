// 柿子攻击效果对象 - Create 事件
// 从上方落下，到达目标后造成 3×3 范围伤害

// 目标位置
target_x = 0
target_y = 0
// 伤害值
damage = 0
// 命中半径（格数）
hit_radius = 1
// 目标类型
target_type = "normal"
// 施法批次ID（用于去重）
cast_id = 0
// 分身索引
clone_index = 0
// 所有者卡牌
owner = noone

// 下落速度
fall_speed = 12
// 是否已造成伤害
has_dealt_damage = false
// 落地后存活时间（用于播放效果）
land_timer = 0
land_max_time = 15

// 初始位置在目标上方
image_speed = 0.2
