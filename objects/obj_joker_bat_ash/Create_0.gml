/// 恶作剧神三转起 击杀特效：死亡蝙蝠灰烬（精灵 13 帧）
/// 只播一遍：不循环、不淡出跳帧，播完直接销毁
image_speed  = 0;
image_index  = 0;
image_angle  = 0;
image_alpha  = 1;
image_blend  = c_white;
image_xscale = 1.6;
image_yscale = 1.6;

bat_timer = 0;
bat_step  = 4;      // 4 步 / 帧 ≈ 15fps，13 帧 ≈ 0.87 秒
