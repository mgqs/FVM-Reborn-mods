// obj_yuansushe_bullet（元素蛇子弹）Create 事件
// 直线穿透弹：沿本行往右飞，飞出地图右沿消散。
//   · 「可过障碍」= 本对象不做任何屏障碰撞，只按 global.enemy_by_type 的白名单逐只判包围盒；
//   · 「不可过火、不可反弹」= hazard_fire / hazard_rebound 都不声明（官方 11.直射 r19「A型穿透类」口径）。
event_inherited();

image_speed = 1;

row          = 0;
ys_color     = 0;
damage       = 0;
move_speed   = 9;
ys_end_col   = global.grid_cols + 1;
ys_delay     = 0;

ys_pin_chance    = 0;
ys_pin_ticks     = 90;
ys_poison_chance = 0;
ys_poison_damage = 300;
ys_freeze_chance = 0;
ys_freeze_ticks  = 120;
ys_slow_ticks    = 240;
ys_crit_chance   = 0;
ys_crit_mult     = 2;

// 穿透类命中白名单（同 can_target_on 的 pierce 分支：普通 / 非主流 / 障碍 / 未显形幽灵）
ys_hittable = ["normal", "dance", "obstacle", "invisible"];

// 命中即停标记：打到**老鼠**就置真（子弹当帧销毁，不穿透老鼠）；
// 打到**障碍物**（target_type == "obstacle"）不置 → 直接穿过去继续飞（用户 2026-11-13 口径）。
ys_stop = false;

// 名字必须叫 hitted：bullet_hazard_rebound 的 reset_hits 只清这几个约定名，
// 叫别的名字 → 弹回来的子弹打不到已经打过的老鼠
hitted = ds_list_create();

// 毒气对象用工程现成的 obj_ronghedan_god_poison_effect（自带「延迟 10 帧 → 一格范围一次性伤害」
//   的结算逻辑），这里只换精灵与参数，不另建一套。
ys_poison_obj = obj_ronghedan_god_poison_effect;

// 父对象 Draw_0 优先用 visual_scale_* 绘制（没有才退回 image_scale），
// 但 **bbox 只看 image_xscale / image_yscale**。
// 所以这里 image_scale 也要设成 1.3：画多大、判定就多大。
//   原来 image_scale = 1 而视觉 1.3 → 判定盒比画出来的小 30%，
//   子弹本体只有 60x28（垂直方向尤其窄），边缘命中会被静默漏掉，
//   玩家看到的就是「子弹明显穿过去了，但没伤害、也没出元素效果」。
visual_scale_x = 1.3;
visual_scale_y = 1.3;
image_xscale = 1.3;
image_yscale = 1.3;
