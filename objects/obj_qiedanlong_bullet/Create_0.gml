/// 窃蛋龙 弹体 Create（投掷弹：抛物线飞行，命中或落地都会爆炸）
event_inherited();

damage     = 0;
base_atk   = 0;
move_speed = 0;
cvspeed    = 0;
cgravity   = 0;
row        = 0;
shape      = 0;

target_type    = "throw";
damage_type    = "throw";
hittable_types = get_hittable_enemy_types(target_type);

hit_enemy    = false;
hitted_enemy = noone;
has_splashed = false;
hit_tick     = 0;

// 2026-11-13：落点爆炸改成「飞满 N 帧就在落点爆」，不再靠 bbox 判半路命中
flight_t  = 0;
flight_ft = 45;      // 由 Other_11 按距离覆写

splash_ratio = 0.35;
splash_cells = 1;

thrower_y = 0;
land_y    = 0;
land_target = noone;      // 发射时锁定的那只（半路没撞到时，落点也按它的身体中心炸）

// 爆炸图自己的中心在原点上方多少（实测 0 转 18 / 1 转 20 / 2 转 23 px，×1.4 缩放 = 25 / 28 / 32）
//   ⚠ shape 是建完实例之后由 Other_11 赋的，所以这个值在 Step 里按 shape 现算，不在这里定。

image_speed = 0;
image_index = 0;
image_angle = 0;          // 2026-11-13：不再斜 45° + 翻滚，蛋头朝上飞

if (shape == 1)      sprite_index = spr_qiedanlong_bullet_1;
else if (shape == 2) sprite_index = spr_qiedanlong_bullet_2;
else                 sprite_index = spr_qiedanlong_bullet;

image_xscale = 1.4;
image_yscale = 1.4;

// 2026-11-13：判定框改成**直接读精灵的碰撞遮罩**（sprite_get_bbox_*），并按缩放换算成相对原点的偏移。
//   在精灵编辑器里改遮罩（bboxMode 手动 / 自动都行）→ 运行时立刻生效，不用再改代码。
//   注意：这里只用 bbox 矩形，`collisionKind`（矩形/椭圆/精确像素）不参与 —— 工程里的子弹都是 AABB 判定。
var _bsx = abs(image_xscale);
var _bsy = abs(image_yscale);
egg_bl = (sprite_get_bbox_left(sprite_index)   - sprite_get_xoffset(sprite_index)) * _bsx;
egg_br = (sprite_get_bbox_right(sprite_index)  - sprite_get_xoffset(sprite_index)) * _bsx;
egg_bt = (sprite_get_bbox_top(sprite_index)    - sprite_get_yoffset(sprite_index)) * _bsy;
egg_bb = (sprite_get_bbox_bottom(sprite_index) - sprite_get_yoffset(sprite_index)) * _bsy;
