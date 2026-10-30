// obj_ronghedapao_bullet_effect（融合巧克力炮爆炸）Create 事件
// 名字里带 bullet_effect → 走对象池，复用 instance_change 不会恢复默认精灵，
// 所以 sprite_index / 显示变量必须在这里显式复位（手册 §3.2.2 / §3.7）。
sprite_index = spr_ronghedapao_effect

image_speed = 0
image_angle = 0
image_index = 0
image_alpha = 1
image_blend = c_white

// 178×324 放大 1.8 倍 ≈ 3 列 × 5 行；216×177 放大 1.8 倍 ≈ 3 列 × 3 行
image_xscale = 1.8
image_yscale = 1.8

timer = 0
blast_shape = 0
