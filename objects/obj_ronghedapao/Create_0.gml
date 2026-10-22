// obj_ronghedapao（融合巧克力炮）Create 事件
// 三形态：0转 脆心死神大炮 / 1转 霸王死神大炮 / 2转 乾坤死神大炮
// 前置：死神大炮（原版 chocolate_cannon 二转），见 gacha_random_card 的 fusion_get_prerequisites
// 机制：① 每次攻击朝本行第 8 列（target_col = 7）投下 2 枚巧克力炸弹，落地爆炸；
//       ② 0转爆炸 3*3（3 行 × 3 列），1转 / 2转扩大为 3*5（5 行 × 3 列）；
//       ③ 2转（灵魂融合）爆炸属性改为碾压：不防爆的鼠军直接消失、不出灰烬，BOSS 只吃伤害；
//       ④ 无需底座（初级融合）—— 三形态 target_card 都是 "none"，可直接放置。
//       数值取自「10.21群u要求追加的拐+融炮\数据信息.xlsx」融合巧克力炮 30-39 行。
event_inherited();  // 继承父对象属性
plant_id = "ronghedapao";
obj_type = object_index;
current_level = 1
event_user(0)
if shape == 0{
	sprite_index = spr_ronghedapao
}
else if shape == 1{
	sprite_index = spr_ronghedapao_1
}
else{
	sprite_index = spr_ronghedapao_2
}

// ========== 动画分段（20 帧素材，逐帧量过）==========
//   0~10  已装填：球坐在炮盘里轻晃（idx 10 与 idx 0 像素相同，循环无缝）
//   11    装填最后一帧（本轮划给发射段，作为起手）
//   12    球闭合（发射首帧）
//   13~18 球被顶出炮盘
//   19    空炮盘
// ⚠️ idx 11 / 12 属于发射段，绝不能算进待机（否则待机每转一圈会蹦一下那一帧）
// 帧交给父对象推，与原版 obj_chocolate_cannon 同构：待机循环 0~idle_anim(10)，攻击 11~19
idle_anim = 10
attack_anim = 8
flash_speed = 5
plant_type = "normal"
feature_type = "normal"
is_slowdown = false
target_type = "throw"
attack_timer = cycle - 60

// ========== 投弹 ==========
bombs_per_attack = 2;                      // 每轮 2 发（xlsx「子弹数2」）
bomb_interval = 7;                         // 两发错开 7 帧：子弹每帧升 15px、球约 102px，7 帧 ≈ 105px 头尾相接
fired_bombs = 0                            // 本轮已投弹数

// ========== 爆炸范围 ==========
blast_row_half = (shape >= 1) ? 2 : 1;     // 0转 3 行 / 1·2转 5 行
blast_col_half = 1;                        // 固定 3 列
crush_kill = (shape == 2)                  // 灵魂融合：碾压（直接消失、无灰烬）
