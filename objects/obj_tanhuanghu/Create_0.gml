/// 弹簧虎 / 飞行弹簧虎 / 机器弹簧虎（tanhuanghu）Create 事件
/// 直射类·连射溅射：连续发射 2/2/3 发带溅射的子弹攻击本行，优先空中；
///   子弹可穿过岩浆和障碍；溅射可同时命中空中 / 地面 / 地下的老鼠
/// 数值走注册表：子弹数 → custom 标量；溅射 25% / 40% 固定 → 写死
event_inherited();

plant_id = "tanhuanghu";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_tanhuanghu;
else if (shape == 1) sprite_index = spr_tanhuanghu_1;
else                 sprite_index = spr_tanhuanghu_2;

plant_type   = "normal";
feature_type = "normal";
target_type  = "pierce";        // 穿透：可打 dance / invisible / 障碍
is_slowdown  = false;
attack_type  = ATTACK_TYPE.SHOOTER;
image_speed  = 0;
flash_speed  = 5;

idle_anim   = 12;
attack_anim = 10;

attack_timer = 0;
state        = CARD_STATE.IDLE;
th_attacking = false;
th_target_t  = "normal";

// ── 可调参数 ──
th_burst_left  = 0;      // 本轮还没出膛的子弹数
th_burst_timer = 0;
th_burst_gap   = 7;      // 后几发比上一发晚几帧出膛
th_art_up      = -26;    // 出膛点 y 偏移
th_muzzle_x    = 46;     // 出膛点 x 偏移（卡片右侧）
th_lead        = 4;
th_fire_delay  = 1;

// ── 注册表 custom ──
var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("tanhuanghu", shape, clamp(current_level, 0, 16), _sk);

th_bullet_count = (shape >= 2) ? 3 : 2;                  // custom 标量 2 / 2 / 3
th_splash_ratio = (shape >= 2) ? 0.40 : 0.25;         // 攻击力 × 25% / 40%，写死
th_splash_cells = 1;                                  // 3*3 溅射
if (_info != undefined && ds_map_exists(_info, "子弹数")) th_bullet_count = _info[? "子弹数"];

// 优先空中：本行有空军时，子弹按目标身体中心的高度出膛（同多拿滋写法）
th_air_muzzle_dy = -60;       // 兜底：扫不到空军时用半个身位
