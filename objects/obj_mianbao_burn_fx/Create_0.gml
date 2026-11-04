// obj_mianbao_burn_fx（融合菠萝面包 · 5*5 灼烧的单格火格）Create 事件
// 一个实例锁一格；视觉照火龙果的 obj_burn_effect：
//   帧 1~4 淡入（每帧停 5 帧）→ 帧 5~12 循环（每帧停 5 帧）→ 帧 13~16 淡出（每帧停 4 帧）
//   放大 1.8 倍、贴图居中 → 相邻格互相压住，看不到方块接缝（和火龙果同一个口径）
// 伤害：每 tick_interval（24 帧 = 0.4 秒）一跳，2 秒共 5 跳，每跳 = damage（= 本卡注册表 cycle ÷60）
// 只烧「就是这一格」的敌人（grid_col / grid_row 严格相等，不做 bbox 兜底）；击杀一律出灰烬
image_speed = 0;
image_index = 0;
image_angle = 0;
image_alpha = 1;
image_blend = c_white;

SCALE = 1.8;                 // 贴图放大倍数（越大越盖住接缝；1.28 = 正好一格会露方块）

// 想整体挪位置就改这两个（单位：像素，乘过缩放后的画面像素）
FX_OFF_X = 8;                // 往右为正、往左为负
FX_OFF_Y = -22;              // 往上为负、往下为正

image_xscale = SCALE;
image_yscale = SCALE;

// 调用方给的 x / y 是「格子中心」。摆法：**内容底边贴格子底边、水平居中**（同 bbq 的铺法）
//   素材 origin 正好落在内容底边（41,81），所以 y 直接给格子底边即可让火苗往上长；
//   x 按 origin 与画布中心的差值补一点，让贴图左右居中。
x += FX_OFF_X + (sprite_get_xoffset(sprite_index) - sprite_get_width(sprite_index) / 2) * SCALE;
y += global.grid_cell_size_y * 0.5 + FX_OFF_Y;

// 帧段（0 基索引，素材 16 帧）
FADE_IN_LAST   = 3;          // 帧 1~4 淡入
LOOP_FIRST     = 4;          // 帧 5 起循环
LOOP_LEN       = 8;          // 帧 5~12 共 8 帧
FADE_OUT_FIRST = 12;         // 帧 13 起淡出
FADE_OUT_LEN   = 4;          // 帧 13~16
FADE_IN_STEP   = 5;          // 淡入每帧停 5 帧 → 20 帧
LOOP_STEP      = 5;          // 循环每帧停 5 帧 → 一圈 40 帧（0.67 秒）
FADE_OUT_STEP  = 4;          // 淡出每帧停 4 帧 → 16 帧
FADE_IN_FRAMES = (FADE_IN_LAST + 1) * FADE_IN_STEP;   // 20
TAIL_FRAMES    = FADE_OUT_LEN * FADE_OUT_STEP;        // 16

t = 0;
life = 120;                  // 伤害阶段 2 秒
damage = 0;
damage_type = "normal";
hittable_types = ["normal", "dance", "underground", "invisible"];
tick_interval = 24;          // 0.4 秒一跳 → 5 跳

grid_col = -1;
grid_row = -1;
