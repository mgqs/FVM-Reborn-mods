damage = 0
move_speed = 0
y_move_speed = 0
row = 0
col = 0
damage_type = "normal"
target_type = "normal"
b_type = 0
bounced = false
shape = 0
target_id = noone
has_bounced_wall = false
bullet_speed = 8
image_xscale = 1.5;
image_yscale = 1.5;
image_speed = 0;
image_index = 0;
has_hit_anim = false;
hit_anim_timer = 0;
hittable_types = get_hittable_enemy_types(target_type);
// 命中判定隔帧计数（口径与 obj_youyu_god_bullet / obj_corn_shooter_bullet 一致）
// 间隔：2026-11-07 用户口径 —— 与炭烧海星 / 料理机刀片对齐，单卡取 3 帧（不用全局 2 帧）
//   安全性：融海子弹 71×75 精灵、1.5 缩放，包围盒约 45×50，沿飞行方向半宽 ≈ 22~25px；
//   斜向两发速度 √(5²+3²) ≈ 5.83px/帧，3 帧 ≈ 17.5px，仍远小于「子弹 + 鼠」的合体宽度
hit_tick = 0;
hit_interval = 3;
// 错帧连发延时：初级融合「向后的子弹数量+1」的第二发用它滞后飞出
delay = 0;
// 发射方向索引（0=后 1=下 2=上 3=右上 4=右下）—— 边界规则 / 追踪资格用它
dir_index = -1;
// 深度融合（1 转起）单格溅射比例，0 = 不溅射
splash_ratio = 0;

// ── 环境交互（2026-11-10）：吃火 / 可反弹 + 需要的参数都在这里声明，碰撞事件由父类 obj_bullet_parent 统一处理
hazard_rebound = { flip_y:true, judge:"none" };   // 融合海星：斜弹翻 y
fire_mult = 1;           // 对象池会复用实例：不重置就会带着上一发的过火倍率出生，导致这一发点不着
