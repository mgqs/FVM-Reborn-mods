// obj_ronghesanxian（融合三线）Create 事件
// 三形态：0 转 子母三线酒架 / 1 转 仙人掌花酒架 / 2 转 烤灯笼鱼酒架
// 机制：① 同时攻击前方三行（本行 + 上下各一行，全程宽度）
//       ② 0 转每行 2 发(共 6) / 1 转 3 发(共 9) / 2 转 3 发(共 9) 且子弹可穿透
//       ③ 命中后 30% 概率附加燃烧 buff：每 1 秒结算 1 次、共 3 次[燃烧伤害]，可叠加
//       —— 燃烧的持续结算与挂身火焰交给独立控制器 obj_ronghesanxian_burn_ctrl /
//          obj_ronghesanxian_burn_fx（卡片被铲掉后，已在燃烧的老鼠继续结算）
// 数值取自「这组卡的推荐数值和情报岛.xlsx」新普卡-融合卡 65-77 行。
event_inherited();  // 继承父对象属性
plant_id = "ronghesanxian";
obj_type = object_index;
current_level = 1
event_user(0)
if shape == 0{
	sprite_index = spr_ronghesanxian
}
else if shape == 1{
	sprite_index = spr_ronghesanxian_1
}
else{
	sprite_index = spr_ronghesanxian_2
}

// 20 帧素材：待机 1-12 帧（image_index 0-11）、攻击 13-20 帧（image_index 12-19，花嘴后坐再伸出）
idle_anim = 11
attack_anim = 8
flash_speed = 5
plant_type = "normal"
feature_type = "normal"
is_slowdown = false
attack_type = ATTACK_TYPE.SHOOTER
target_type = "normal"

// 每行子弹数：0 转 2 发 / 1、2 转 3 发（2 转的子弹可穿透）
shots_per_row = (shape == 0) ? 2 : 3

// 燃烧伤害按星级查表（星 0 表里是"/"，沿用 1 星档 —— 与融合火盆的寒气表同一口径）
burn_dmg_table = [13, 13, 16, 19, 22, 25, 28, 31, 34, 42, 50, 70, 90, 110, 135, 160, 190];

// 本次攻击是否已开火；本次攻击已齐射次数（一次攻击动画内按 shots_per_row 分次齐射、错 5 帧）
fired_this_attack = false
salvo_index = 0
salvo_timer = 0
