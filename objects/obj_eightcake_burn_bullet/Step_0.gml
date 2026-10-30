// obj_eightcake_burn_bullet Step 事件
if (global.is_paused) exit;
if (landed) exit;

t++;

// 飞行段只在 0~fly_end 之间循环：自己推帧（image_speed 恒 0），
//   否则按 image_speed 递增会越过 fly_end，飞行途中闪出「地上的火」（2026-10-31 用户反馈）
image_index = floor(t * fly_anim_speed) mod (fly_end + 1);

var _p = min(1, t / T);
x = lerp(sx, tx, _p);
y = lerp(sy, ty, _p) - arc * 4 * _p * (1 - _p);

if (t < T) exit;

// ===== 落地：本格 0.5s 灼烧 =====
landed = true;

var _b = instance_create_depth(tx, ty, depth, obj_burn_cell);
_b.sprite_index = sprite_index;   // 跟着形态走（本体 32 帧 / 一、二转 36 帧），别写死本体那张
_b.frame_start = burn_start;      // 本体 15（14 是落地过渡）；一、二转 19（18 是落地过渡）
_b.frame_end = sprite_get_number(sprite_index) - 2;   // 本体 30 / 一、二转 34（末尾是空帧）
_b.damage = damage;
_b.life = 30;
// 🔴 火格是按「格子底边」摆的，让它自己按坐标反算会算成下一行（用户报「直接投到下一行」），所以锁死格子
_b.lock_grid = true;
_b.grid_col = col;
_b.grid_row = row;

instance_destroy();
