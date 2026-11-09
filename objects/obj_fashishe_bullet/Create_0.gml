// obj_fashishe_bullet（法师蛇 · 蛇形穿透弹）Create 事件
// 弹道：沿本行向右匀速，y 上做正弦摆动；全程穿透（同一只老鼠只吃一次）。
// 过火 / 反弹：与 bbq 子弹同一套（火盆 / 融盆 / 火神 / 金牛 / 能量喵 + 布丁 / 水神）。
event_inherited();

can_dandantu_store = true;

sprite_index = spr_fashishe_bullet;
image_speed  = 0;
image_index  = 0;
image_angle  = 0;
image_alpha  = 1;
image_blend  = c_white;
// 2026-11-10 用户口径：原来 1.5 倍太大（0/1 转精灵 169×69，×1.5 后 2.4 格宽；2 转 3.2 格宽），
//   改回素材原大（1.58 格宽）。想再大/再小就改这两个数。
image_xscale = 1.0;
image_yscale = 1.0;

damage    = 0;
move_speed = 6.5;
// 过火加速（2026-11-08 用户口径：同 bbq 一样的效果）：被火盆 / 融盆 / 火神 / 金牛 / 能量喵点燃后提速 1.5 倍。
//   bbq 是 5.35 → 8.02（×1.499），这里按同一比例 6.5 → 9.75，见 Step 里 _spd 的取法。
burnt_speed = 9.75;
move_dir   = 1;          // 1 = 向右；被布丁 / 水神反弹后 -1

row    = 0;
base_y = y;              // 飞行中线（改平射后就是恒定的 y）
phase  = 0;              // 已停用：原来给正弦用
wave_amp   = 0;          // 已停用（2026-11-10 取消蛇形摆动，改直线平射）
wave_speed = 0;

end_x      = 2200;
end_x_left = -200;
bounced    = false;
fading     = false;   // 出图后播「飞行到极限」的消散帧（第 5 帧起）
fade_t     = 0;

damage_type = "pierce";     // 穿透（2026-11-10 用户口径：改回 pierce —— 毒针是全程穿透弹，必须能穿地形障碍，
                            //   障碍物 Step 的放行条件只认 damage_type=="pierce" / pierce_all / pierce_obstacle。
                            //   ⚠️ 连带效果（已知并接受）：打带护盾的老鼠会「破盾 + 直接掉血」；
                            //   蛋蛋兔不再储存这颗子弹的伤害。target_type 仍是 normal，可攻击类型不变。）
target_type = "normal";

// 过火字段（Collision_obj_* 与 ronghehuopen_pass_fire 都按这几个判定）
kind        = "fire";
burnt       = 0;
can_burn    = true;
brazier_list = ds_list_create();

hitted = ds_list_create();
hittable_types = get_hittable_enemy_types(target_type);
max_life = 400;
life = 0;
