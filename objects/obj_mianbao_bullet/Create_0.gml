// obj_mianbao_bullet（融合菠萝面包 2 转 · 灵魂子弹）Create 事件
// 独立对象（不是复用机枪小笼包那颗）：平射、不穿透，伤害完全取本卡 atk（xlsx「灵魂子弹攻击力」）
// 素材 spr_mianbao_bullet 21×16（素材只有 1 张静态图）
damage = 0
move_speed = 0
row = 0
damage_type = "normal"
target_type = "normal"
burnt = 0
bounced = false
brazier_list = ds_list_create()
// 与融合火盆过火脚本里写的 1.8 保持一致，免得「过火一瞬间变小」
image_xscale = 1.8
image_yscale = 1.8
hittable_types = get_hittable_enemy_types(target_type)
hit_tick = 0
// 对象池复用必须复位内置显示变量（铁律）
image_angle = 0
image_index = 0
image_alpha = 1
image_blend = c_white

// ── 环境交互（2026-11-10）：吃火 / 可反弹 + 需要的参数都在这里声明，碰撞事件由父类 obj_bullet_parent 统一处理
hazard_fire = true;      // 可被火盆 / 火神 / 金牛 / 能量喵 / 融合火盆 点燃
hazard_rebound = true;   // 可被樱桃布丁 / 布丁汪 / 水神 反弹
