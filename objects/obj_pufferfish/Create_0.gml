event_inherited();

plant_id = "pufferfish";
obj_type = object_index;
event_user(0);

// 0/1/2 转分别对应 spr_pufferfish / _1 / _2（各 48 帧）
if (shape == 0)
    sprite_index = spr_pufferfish;
else if (shape == 1)
    sprite_index = spr_pufferfish_1;
else if (shape == 2)
    sprite_index = spr_pufferfish_2;

// ===== 素材 48 帧分段（0-based 索引）=====
//   0 .. 22   待机 + 膨胀 + 转场（共用前段）
//   23 .. 34  蓝色爆炸（到 3/3/2 倍数、炸老鼠时）
//   37 .. 45  红色爆炸（未到倍数、清植物卡时）
// 注：idle_anim / attack_anim 仅作登记，实际帧推进由本对象 Step 手动控制（image_speed 已由父卡设为 0）
idle_anim = 22;
attack_anim = 12;
flash_speed = 5;

puffer_pre_end    = 22;   // 前段最后一帧
puffer_blue_start = 23;   // 蓝色爆炸起始帧
puffer_blue_end   = 34;   // 蓝色爆炸结束帧
puffer_red_start  = 37;   // 红色爆炸起始帧
puffer_red_end    = 45;   // 红色爆炸结束帧
puffer_phase      = 0;    // 0=前段 1=蓝色爆炸(炸老鼠) 2=红色爆炸(清卡)
puffer_is_blast   = false;
plant_type = "normal";
feature_type = "normal";
is_slowdown = false;
invincible = true;          // 与可乐炸弹一致：放下期间不被啃食

// ===== 爆辣河豚：全局放置次数计数 =====
if (!variable_global_exists("pufferfish_place_count")) global.pufferfish_place_count = 0;
global.pufferfish_place_count++;
// 本次是第几次放置（用于结算判定）
puffer_place_index = global.pufferfish_place_count;
