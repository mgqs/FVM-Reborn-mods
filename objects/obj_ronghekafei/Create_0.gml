// obj_ronghekafei（融合咖啡杯）Create 事件
// 三形态：0转 机枪咖啡杯 / 1转 喷壶咖啡杯 / 2转 三叠咖啡杯
// 前置：骨瓷咖啡杯（coffee_cup），见 gacha_random_card 的 fusion_get_prerequisites
// 机制：① 耗能 0，不需要火苗，全天可用（白天不睡觉）；
//       ② 索敌本行前方，0转 每轮连发 3 发 / 1转 浓缩成 1 发 / 2转 三个杯子各吐 1 发（合计 3 发）；
//       ③ 1转起子弹穿透老鼠与障碍；2转 单发取 1 转表值，3 发合计 = 2 转表值（xlsx「伤害 3 倍」口径）；
//       ④ 子弹 7 帧素材：0~3 出膛喷溅（快速播 8 帧）、4~6 飞行，三形态共用同一张图。
//       数值取自「这组卡的推荐数值和情报岛.xlsx」融合咖啡杯 51-61 行。
event_inherited();  // 继承父对象属性
plant_id = "ronghekafei";
obj_type = object_index;
current_level = 1
event_user(0)
if shape == 0{
	sprite_index = spr_ronghekafei
}
else if shape == 1{
	sprite_index = spr_ronghekafei_1
}
else{
	sprite_index = spr_ronghekafei_2
}

// ========== 动画分段（23 帧素材，逐帧量过）==========
//   0~11  待机：杯子轻轻晃动（素材第 1~12 帧）
//   12~22 发射：枪口张开 → 后坐抖动（16=18=20=22、17=19=21 两帧交替）
// 帧交给父对象推：待机循环 0~idle_anim(11)，发射 12~22（attack_anim=10，窗口 55 帧正好播完）
// 1转 浓缩成 1 发，attack_anim 收成 4：只播 12~16（素材第 13~17 帧，起手 + 一次后坐），窗口 25 帧
idle_anim = 11
attack_anim = (shape == 1) ? 4 : 10
flash_speed = 5
plant_type = "normal"
feature_type = "normal"
is_slowdown = false
attack_timer = cycle - 60

// ========== 连发 ==========
shots_per_attack = (shape == 1) ? 1 : 3              // 1转 浓缩成 1 发，0转 / 2转 各 3 发
shot_frames = (shape == 1) ? [16] : [16, 18, 20]     // 按后坐帧开火：16 / 18 / 20 是「枪身最靠后」的那张 A 帧
fired_shots = 0                                      // 本轮已发数
shot_pierce = (shape >= 1)                           // 1转起穿透老鼠与障碍
