// obj_shiliu_bullet —— 石榴籽（碾压弹）
// 素材 spr_shiliu_bullet_0/1/2：12 帧、画布 63~74 x 294~298、原点在**底部中间**，
// 内容是「籽从画布顶部落到底部」——所以物体的 x/y 就是**落点**，籽靠自身帧往下掉，
// 不需要给 x/y 写速度（写速度反而会和帧动画的位移叠成双倍）。
//
// 帧序（以 0 转 63x296 为例，量自不透明 bbox）：
//   0 空 → 1 顶部 → 2 中部 → 3 到底(y203..294) → 4..10 落地碎裂 → 11 空
// 落地判定取 impact_frame = 3，伤害在那帧结算。
//
// 由 obj_shiliu_baobao_bing/Other_11 创建，参数全部由调用方写。
sprite_index     = spr_shiliu_bullet_0;

target_inst      = noone;      // 砸谁（会跟随目标的 x/y，目标死了就停在最后位置播完）
damage_value     = 0;          // 碾压伤害
caster_target_type = "all";    // 卡片 target_type，仅用于日志语义（伤害已由调用方筛过）
apply_freeze     = false;      // 爆炸范围内的目标才会附加冰冻 / 减速
freeze_ticks     = 0;
slow_ticks       = 0;

fall_offset_y    = -18;        // 落点比敌人原点再抬高一点，砸在背上而不是脚底
frame_speed      = 3;          // 每 3 tick 换一帧（总时长 ≈ 36 tick）
frame_timer      = 0;
impact_frame     = 3;          // 这一帧内容已经贴到底边 = 落地
landed           = false;

last_x = x;
last_y = y;

image_speed = 0;               // 帧全部自己推，避免受 is_slowdown / image_speed 影响
image_index = 0;

if (!sprite_exists(sprite_index)) instance_destroy();
