// obj_yuansushe_bullet（元素蛇子弹）Create 事件
// 直线穿透弹：沿本行往右飞，飞出地图右沿消散。
//   · 「可过障碍」= 本对象不做任何屏障碰撞，只按 global.enemy_by_type 的白名单逐只判包围盒；
//   · 「不可过火、不可反弹」= hazard_fire / hazard_rebound 都不声明（官方 11.直射 r19「A型穿透类」口径）。
event_inherited();

image_speed = 1;

row          = 0;
ys_color     = 0;
damage       = 0;
// 命中口径：穿透（父对象 BeginStep 的 hex_b3_bullet_tag 与各类记账都会读这两个字段）
target_type  = "pierce";
damage_type  = "pierce";
move_speed   = 9;
ys_end_col   = global.grid_cols + 1;
ys_delay     = 0;
// 当前所在列（Step 每帧按 x 反算）：命中判定用「同行 + 同列」，
// 与精灵尺寸 / 缩放 / 原点全部解耦，不再依赖像素包围盒（见 Step_0 的注释）
ys_col_now   = 0;

ys_pin_chance    = 0;
ys_pin_ticks     = 90;
ys_poison_chance = 0;
ys_poison_damage = 300;
ys_freeze_chance = 0;
ys_freeze_ticks  = 120;
ys_slow_ticks    = 240;
ys_crit_chance   = 0;
ys_crit_mult     = 2;

// 命中白名单不再在子弹里维护：Step 改为 `with (obj_enemy_parent)` 全量扫描，
// 每只敌人用 can_hit(target_type, 敌人 target_type) 现场过滤（等价于 can_target_on）。
//   早期版本用 get_hittable_enemy_types("pierce") 得到 ["normal","dance","obstacle","invisible"]
//   再按 global.enemy_by_type 逐类遍历 —— 那张表由敌人自己在 Step 里注册，
//   而工程里有 57 个敌人对象重写 Step 却没有 event_inherited()、其中一部分没写注册代码，
//   它们永远不在表里，子弹就「从身上飞过去毫无反应」。改成全量扫描后这条链路彻底不依赖注册表。

// 命中口径（2026-11-14 用户定稿）：**穿透障碍，不穿透老鼠**。
//   命中障碍物 → 继续飞；命中任何非障碍目标 → 当帧结算完就自毁（ys_stop）。
//   所以这里要有一个 ys_stop 标记位（Step 里置 true，循环结束后据它销毁）。
ys_stop = false;

// 名字必须叫 hitted：bullet_hazard_rebound 的 reset_hits 只清这几个约定名，
// 叫别的名字 → 弹回来的子弹打不到已经打过的老鼠
hitted = ds_list_create();

// 毒气对象用工程现成的 obj_ronghedan_god_poison_effect（自带「延迟 10 帧 → 一格范围一次性伤害」
//   的结算逻辑），这里只换精灵与参数，不另建一套。
ys_poison_obj = obj_ronghedan_god_poison_effect;

// 父对象 Draw_0 优先用 visual_scale_* 绘制（没有才退回 image_scale），
// bbox 只认 image_xscale / image_yscale —— 画多大、判定就该多大。
//   注意：obj_bullet_parent/BeginStep_0 每帧把 image_scale 夹回 1（只把原值拷进 visual_scale），
//   所以这里的赋值只对「创建当帧」有效；真正让判定盒一直保持 1.3 的是 Step_0.gml 里每帧的重设。
visual_scale_x = 1.3;
visual_scale_y = 1.3;
image_xscale = 1.3;
image_yscale = 1.3;
