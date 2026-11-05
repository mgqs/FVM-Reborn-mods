// obj_caihongshe_shield（彩虹蛇的护罩表现层）Create
// 纯视觉：7 帧（展开）播完停在最后一帧；每帧跟着本体位置走，本体销毁时自己销毁
image_speed = 0;
image_index = 0;
image_alpha = 1;
image_blend = c_white;
image_xscale = 1.8;
image_yscale = 1.8;
parent_plant = noone;
shape = 0;
anim_t = 0;

// 2026-11-06：加「一次性爆炸」模式 —— 彩虹蛇死亡时用同一套 7 帧炸开当灰烬爆炸特效。
//   standalone = true 时：不跟本体、不按血量调透明度，自己从头播一遍再销毁（见 Step_0）。
standalone   = false;
burst_t      = 0;
burst_speed  = 4;     // 每 4 帧推一帧（7 帧 ≈ 0.47 秒）
