// obj_tangchaolizi_bullet（滚烫栗子）Step 事件
if (global.is_paused) exit;

t++;

// 飞行段只循环 0~7（爆开 / 火焰帧留给落地特效）
image_index = (t div 3) mod (fly_end + 1);

var _p = min(1, t / T);
x = lerp(sx, tx, _p);
y = lerp(sy, ty, _p) - arc * 4 * _p * (1 - _p);

if (t < T) exit;

// ===== 落地：生成灼烧特效（同一张精灵，从爆开帧开始播）=====
x = tx;
y = ty;

// 火焰贴地：depth = -10 - row*45（比老鼠靠后一层，不会挡住老鼠 —— 同 8周年蛋糕的火格）
// 纵向位置直接落在 ty 上（ty 在 Other_11 里已经按「地图贴图格线」抬过 36，别在这里再抬）
var _e = instance_create_depth(tx, ty, -10 - row * 45, obj_tangchaolizi_bullet_effect);
_e.sprite_index = sprite_index;
_e.shape = shape;
_e.damage = damage;
_e.damage_corner = damage_corner;
_e.grid_row = row;
_e.grid_col = col;

instance_destroy();
