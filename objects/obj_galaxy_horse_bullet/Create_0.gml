// obj_galaxy_horse_bullet（陨石）Create 事件
// 精灵 spr_galaxy_horse_bullet / _1 / _2：11 / 9 / 9 帧（末尾全空帧已在导入时截掉）
//   原点是「落地炸点」（导入脚本按最后一个非空帧的包围盒中心算），
//   所以实例直接摆到目标格中心，前面几帧自然表现为「从左上角砸下来」。
//
// 结算口径（官方 A116）：
//   索敌目标（本行离落点最近的可打目标）吃 100% 攻击力；
//   溅射范围内其余目标吃 50%；伤害类型 = ash（灰烬：无视护盾，击杀一律出灰烬）。
//   命中后若 gh_stun > 0（一转起）再给 2 秒眩晕，**防爆鼠同样吃**（不查 immune_to_ash）。
event_inherited();

image_speed   = 0;
visual_scale_x = 1;
visual_scale_y = 1;

gh_row          = 0;
gh_col          = 0;
gh_damage       = 0;
gh_splash_rows  = 1;
gh_splash_cols  = 1;
gh_splash_ratio = 0.5;
gh_stun         = 0;
gh_hittable     = ["normal", "diver", "air", "obstacle", "underground"];
gh_delay        = 0;

gh_timer      = 0;
gh_done       = false;
gh_frame_speed = 0.35;   // 8 帧 ≈ 23 tick ≈ 0.4 秒落地
gh_impact_idx  = 3;      // 第 4 帧（idx 3）开始炸

image_alpha = 0;         // 延迟期间不显形
image_index = 0;
