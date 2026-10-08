event_inherited();  // 继承父对象属性
plant_id = "yeziguo";
obj_type = object_index;
current_level = 1
event_user(0)       // 从注册表取 hp / cost / atk / range / cooldown（并可能覆盖 shape）

// 贴图：0/1/2 转 → spr_yeziguo / spr_yeziguo_1 / spr_yeziguo_2（各 27 帧）
if shape == 0{
	sprite_index = spr_yeziguo;
}
else if shape == 1{
	sprite_index = spr_yeziguo_1;
}
else if shape == 2{
	sprite_index = spr_yeziguo_2;
}

// ========== 素材 27 帧分段（0-based 索引）==========
//   0 .. 13   待机摇摆（14 帧）
//   14 .. 19  原地起跳
//   20        落地撞击（结算帧）
//   21 .. 26  冲击水花 → 回到待机姿态（13 帧 = 攻击段总长）
idle_anim = 13;
attack_anim = 13;
flash_speed = 6;

// ========== 椰子果机制 ==========
yyz_impact_frame   = 20;                        // 落地撞击帧（第 21 帧）结算
yyz_crush_total    = (shape == 2) ? 3 : 1;      // 0/1 转砸 1 次；2 转连砸 3 次
yyz_crush_left     = 0;                         // 本轮剩余碾压次数
yyz_crush_interval = 90;                        // 2 转两次碾压间隔 1.5 秒（90 帧）
yyz_phase          = 0;                         // 0=待机索敌 1=攻击中 2=碾压间隔等待
yyz_wait_timer     = 0;
yyz_has_impact     = false;
yyz_last_index     = 0;
yyz_hit_col        = -1;                        // 本次落点格（= 目标所在格）
yyz_hit_row        = -1;
yyz_stun_time      = 180;                       // 眩晕 3 秒
yyz_cell_col       = -1;                        // 当前「所在格」（占格登记用）；每次落地搬到落点格
yyz_cell_row       = -1;
yyz_start_x        = 0;                         // 起跳起点
yyz_start_y        = 0;
yyz_target_x       = 0;                         // 落点格中心
yyz_target_y       = 0;

// ========== 技能：每级 +125 攻击力 ==========
// 注册在 scripts/mod_skill_init：register_card_skill("yeziguo", "atk", [1000,1125,...,2000])
// 走工程标准 "atk" 键 —— 上面的 event_user(0) 已经通过 get_plant_data_with_skill 把
// 技能对应的攻击力写进 atk（图鉴面板读同一个键，数值也会一致），此处无需再处理。

plant_type = "normal"
feature_type = "normal"
invincible = true;      // 与面粉袋一致：免疫敌人的啃咬和砸击伤害
