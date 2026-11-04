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
