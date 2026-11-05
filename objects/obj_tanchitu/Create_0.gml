// obj_tanchitu（贪吃兔 / 肥肥贪吃兔 / 暴走贪吃兔）Create 事件
// 灰烬类·瞬发类·冲撞类（照白羊座）：前摇 1.3 秒后召唤兔子沿**列**竖向冲撞整列，随后本体消失
// 列数：0 转第 8 列；1 转第 7、8 列；2 转第 7、8、9 列
// 素材 12 帧纯待机（0~11）；兔子用 spr_tanchitu_bullet（8 帧）
// 数值：atk（秒杀类固定 900，走注册表）、冷却 cooldown（17 档）
event_inherited();
plant_id = "tanchitu";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_tanchitu;
else if (shape == 1) sprite_index = spr_tanchitu_1;
else                 sprite_index = spr_tanchitu_2;

plant_type = "normal";
feature_type = "normal";
target_type = "normal";
is_slowdown = false;
image_speed = 0;

idle_anim   = 11;
attack_anim = 0;
flash_speed = 5;

windup_frames = 78;      // 前摇 1.3 秒
windup_t = 0;
spawned = false;
