// obj_caihongshe_bullet（彩虹蛇的巧克力糖豆）Create
event_inherited();
sprite_index = spr_caihongshe_bullet;
image_speed = 0;
image_index = 0;
image_alpha = 1;
image_blend = c_white;
image_xscale = 1.5;
image_yscale = 1.5;

move_speed = 7;
vy = 0;
damage = 0;
damage_type = "normal";
target_type = "normal";
row = 0;
stun_chance = 10;
stun_frames = 120;
bounced = false;
life = 0;
hittable_types = get_hittable_enemy_types(target_type);

// ── 命中特效（2026-11-06 用户指正：素材后 5 帧就是攻击特效，之前直接销毁没播）──
//   spr_caihongshe_bullet 共 6 帧：0 = 糖豆本体（21×14）；1~4 = 命中炸开（51×46 → 66×64 → 58×54 → 60×54）；
//   5 = 空帧（不播，播到 4 就销毁）
hit_playing  = false;   // true = 已命中，正在原地播特效（不再移动 / 不再判定）
hit_t        = 0;
hit_fx_first = 1;       // 特效起始帧（image_index）
hit_fx_last  = 4;       // 特效末帧（image_index）
hit_fx_speed = 3;       // 每 3 帧推一帧 ≈ 0.05 秒，整段约 0.18 秒
