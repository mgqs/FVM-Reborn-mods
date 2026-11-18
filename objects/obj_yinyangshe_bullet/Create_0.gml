// obj_yinyangshe_bullet（阴阳蛇子弹）Create 事件
// 一行直线弹：向本行右方飞，出界消散。
//   · 可过火 / 可被反弹 —— 由父对象 obj_bullet_parent 的两个 Collision 事件统一处理，
//     这里只声明 hazard_fire / hazard_rebound 与 fire_mult；
//   · 阴蛇弹 target_type = "pierce"（含未显形幽灵），阳蛇弹 = "normal"；
//   · 2 转阳蛇是穿透弹（yy_pierce = true）：命中后继续飞，靠 hitted 保证同一只只吃一次。
event_inherited();

image_speed = 1;

row          = 0;
yy_kind      = 0;        // 0 = 阴蛇、1 = 阳蛇
yy_pierce    = false;    // 命中老鼠后是否继续飞（2 转阳蛇）
yy_poison    = false;    // 这一发是否附毒
yy_poison_mult = 3;
damage       = 0;
damage_type  = "normal";
target_type  = "pierce";
move_speed   = 10;
end_col      = global.grid_cols + 1;
yy_col_now   = 0;        // 当前列（按 x 反算，判定与精灵尺寸/缩放解耦）
yy_stop      = false;
yy_life      = 0;        // 存活帧数：推火苗帧用

// 环境交互三件套（与 obj_corn_shooter_bullet 同口径）
burnt        = 0;
bounced      = false;
brazier_list = ds_list_create();
// scale:0 = 尺寸由本对象 Step 自己管。父对象的普通火源分支会写
//   `image_xscale = 1.8`（**无符号**），被布丁弹回的子弹正朝左飞，
//   那一帧会被掰成正向、闪一下；自己管就不会打架。
hazard_fire    = { scale: 0 };   // 可被火盆 / 火神 / 金牛 / 能量喵 / 融合火盆 点燃
hazard_rebound = true;           // 可被樱桃布丁 / 布丁汪 / 水神 反弹
fire_mult      = 1;              // 对象池复用会带上一发的过火倍率，必须重置

// 名字必须叫 hitted：bullet_hazard_rebound 的 reset_hits 只清这个约定名
hitted = ds_list_create();

can_dandantu_store = true;

// 父对象 Draw_0 优先用 visual_scale_*；bbox 只认 image_xscale / image_yscale
image_xscale  = 1.6;
image_yscale  = 1.6;
visual_scale_x = 1.6;
visual_scale_y = 1.6;

yy_poison_obj = obj_yinyangshe_poison;
