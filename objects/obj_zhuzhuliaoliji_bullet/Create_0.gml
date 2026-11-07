// obj_zhuzhuliaoliji_bullet（猪猪料理机刀片）Create 事件
// 直线飞行、命中即消失；可过火（融合火盆 / 火盆），可被水神 / 樱桃布丁反弹。
event_inherited();

sprite_index = spr_zhuzhuliaoliji_bullet;
image_speed = 0;        // 帧由 Step 自己推（刀片 15 帧旋转），见 Step 里的注释
image_index = 0;
image_angle = 0;        // 出膛时由 Other_11 按弹道赋值，Step 每帧再按 vx/vy 校一次
image_alpha = 1;
image_blend = c_white;
image_xscale = 1.4;
image_yscale = 1.4;

vx = -8;
vy = 0;
// 命中判定节流：全工程通用口径是 2 帧（global.bullet_hit_interval）；
//   刀片 52x32 × 1.4 缩放沿飞行方向的半宽约 36px，老鼠半宽 20~30px，
//   3 帧 = 24px 仍远小于「子弹 + 鼠」的合体宽度 → 单卡放宽到 3 帧（2026-11-07 用户口径）
hit_tick = 0;
hit_interval = 3;
// 刀片不播动画（恒定第 0 帧）；只有过火后的火焰贴图还要帧数
_fire_frames = sprite_get_number(spr_fire_bullet);
damage = 0;
damage_type = "normal";
target_type = "normal";
row = 0;
slow_frames = 0;
bounced = false;
life = 0;

// 过火（ronghehuopen_pass_fire / 火盆碰撞按这几个字段判定）
// 🔴 2026-11-06 修：原来写 kind = "star"（照星星兔那颗抄的），
//   过火脚本对 star 走的是「看 move_y + center_row」那一支（只让水平那一发吃增幅），
//   而刀片用的是 vx / vy、没有这两个字段 → 一碰融合火盆就报
//   「Variable obj_zhuzhuliaoliji_bullet.move_y not set」，过火整个失效。
//   刀片没有「哪一发算水平」的说法（5 个方向都是正经弹道），所以不设 kind，
//   让过火脚本走通用的「同行 / 同列」判定；谁真碰上火盆谁被点燃。
burnt = 0;
// 过火门禁（2026-11-06 用户口径）：**只有正后那一发能过火**，其它 4 个方向一律不点燃。
//   默认 false，出弹时由 Other_11 按方向给 _is_back 那一发设 true。
can_burn = false;
brazier_list = ds_list_create();

hittable_types = get_hittable_enemy_types(target_type);
