// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "coal_starfish"; 
// 设置对象类型和精灵
obj_type = object_index;
sprite_index = spr_coal_starfish;
current_level = 1
event_user(0)
if shape == 1{
	sprite_index = spr_coal_starfish_1
}
if shape == 2{
	sprite_index = spr_coal_starfish_2
}

// ========== 特定属性默认值 ==========

attack_anim = 21;
idle_anim = 10
flash_speed = 5
plant_type = "normal"
is_slowdown = false
drown_timer = 0

if shape >= 2{
	// 🔴 2026-11-06 用户口径：二转素材 26 帧，**第 26 帧（index 25）和第 18 帧（index 17）是同一张**
	//   → 动画截断到 18 帧：待机 0~11（12 帧）、攻击 12~17（6 帧），只演一次
	//   那一次攻击里**错帧连发 2 发**（两轮 5 方向，第二轮延后 burst_gap 帧出膛）
	idle_anim   = 11
	attack_anim = 6
}

// 本次攻击是否已经出弹（出弹绑在动画帧上，见 Step_0）
fired_this_attack = false;
// 本轮已经开火几次（0·1 转只一次；2 转一次攻击里连发 2 发）
shots_fired = 0;
// 二转「错帧连发」剩余轮数与计时
burst_left  = 0
burst_timer = 0
burst_gap   = 8        // 2026-11-13 用户口径：6 → 8 帧（64px），两批之间拉开一点，不再首尾搭接
