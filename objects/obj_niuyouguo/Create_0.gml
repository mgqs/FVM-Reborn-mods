// obj_niuyouguo（邪恶牛油果）Create 事件
// 三形态：0 转 邪恶牛油果 / 1 转 沙沙牛油果 / 2 转 桑巴牛油果
// 机制：① 向前方 3 个方向（0°、±35.26° 扇形）各发射 1 发穿透飞镖，可穿透老鼠与障碍
//       ② 一转起命中附加减速 1.5 秒（ice_timer 90 帧）
//       ③ 二转每个方向 +1 发（共 6 发），同一轮攻击动画内错 4 帧补发第二组
// 数值取自「这组卡的推荐数值和情报岛.xlsx」新普卡-融合卡 第 8~13 行
// 素材按原始朝向导入（不做镜像）
event_inherited();
plant_id = "niuyouguo";
obj_type = object_index;
current_level = 1
event_user(0)
if shape == 0{
	sprite_index = spr_niuyouguo
}
else if shape == 1{
	sprite_index = spr_niuyouguo_1
}
else{
	sprite_index = spr_niuyouguo_2
}

// 18 帧素材：待机 1-12 帧（image_index 0-11）、攻击 13-19 帧（image_index 12-18）
idle_anim = 11
attack_anim = 7
flash_speed = 5
plant_type = "normal"
feature_type = "normal"
is_slowdown = false
attack_type = ATTACK_TYPE.SHOOTER
// 对空 + 穿透：pierce 打不到空军、air 会丢障碍/隐形/舞者，所以用组合类型 pierce_air
// （见 scripts/can_target_on：air 放行，其余按 pierce 走；get_hittable_enemy_types 给 normal+air+dance+obstacle+invisible）
target_type = "pierce_air"

// 每个方向几条飞镖：本体 / 一转 1 条，二转 2 条
shots_per_side = (shape >= 2) ? 2 : 1
// 一转起命中减速 1.5 秒（90 帧），本体为 0
slow_timer = (shape >= 1) ? 90 : 0
// 扇形单侧角度（度）：0° / ±35.26°
fan_angle = 35.26

// 本次攻击是否已开火；本次攻击已齐射次数（二转在同一轮动画内补发一次）
attack_timer = 0
fired_this_attack = false
salvo_index = 0
salvo_timer = 0
state = CARD_STATE.IDLE
