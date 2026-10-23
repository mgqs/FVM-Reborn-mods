// obj_ronghedapao_bullet（融合巧克力炮的巧克力炸弹）Create 事件
// 运动抄原版 obj_chocolatecannon_bullet：先升空离场 → 换到落点列上方 → 下落 → 落地建爆炸
image_speed = 0

// 🔴 对象池复用（instance_change）不会重置显示变量，必须在这里清零
sprite_index = spr_ronghedapao_bullet   // 默认 0 转那颗球；1/2 转由 obj_ronghedapao 的 Other_11 覆盖
image_angle = 0
image_index = 0
image_alpha = 1
image_blend = c_white
// 飞行时的大小对齐「卡片上那颗球」（卡片 1.8 倍绘制、球径约 100px；本精灵球径约 60px → 1.65）
image_xscale = 1.65
image_yscale = 1.65

state = "start"
target_col = -1
target_row = -1

can_mouse_list = ["can_mouse"]

damage = 900
timer = 0

// 爆炸参数（由 obj_ronghedapao 的 Other_11 覆盖）
blast_shape = 0
blast_row_half = 1
blast_col_half = 1
crush_kill = false
