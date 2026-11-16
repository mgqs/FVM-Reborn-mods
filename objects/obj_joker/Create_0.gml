/// 恶作剧神 / 埃罗斯（joker）Create 事件
/// 直射类·连射溅射：本行连发 3 / 3 / 4 / 1 发带 3x3 溅射的子弹（终转 4 发压 1 发、atk ×4）
/// 索敌：四级优先 空 → 地下 → 潜水 → 陆地；终转穿透，不判优先
/// 可打：空中 / 陆地 / 潜水 / 钻地中的地鼠；子弹穿过岩浆与障碍；终转子弹穿透老鼠
/// 帧段：第 1~11 帧待机（index 0~10）、第 12 帧起攻击段（index 11~27）、第 16 帧出弹
/// 周期：技能表 joker/cycle（78→48 帧 = 1.3→0.8 秒）
event_inherited();
plant_id = "joker";
event_user(0);

if (shape == 1)
    sprite_index = spr_joker_1;
else if (shape == 2)
    sprite_index = spr_joker_2;
else if (shape == 3)
    sprite_index = spr_joker_3;
else
    sprite_index = spr_joker_0;

idle_anim   = 10;        // 第 1~11 帧（index 0~10）= 宝箱待机
attack_anim = 17;        // 第 12~28 帧（index 11~27，共 17 帧）= 攻击段
flash_speed = 5;

plant_type  = "normal";
is_slowdown = false;
target_type = "air";
cooldown    = cycle;
attacking   = false;

// ── 连发：首发绑动画帧，后续按 jk_burst_gap 逐帧补（不绑 image_index）──
jk_bullet_count = 3;     // custom 标量 3 / 3 / 4 / 1（终转 4 发压 1 发，atk ×4）
jk_splash_ratio = 0.4;   // custom 小数 0.4 / 0.4 / 0.8 / 1
jk_burst_left   = 0;
jk_burst_timer  = 0;
jk_burst_gap    = 6;     // 后几发比上一发晚几帧出膛
jk_fire_index   = 4;     // 攻击段第 5 张出弹（= 编辑器第 16 帧 = index 15；攻击段 index 11 起算）

var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("joker", shape, clamp(current_level, 0, 16), _sk);
if (_info != undefined && ds_map_exists(_info, "子弹数")) jk_bullet_count = _info[? "子弹数"];
if (_info != undefined && ds_map_exists(_info, "溅射比例")) jk_splash_ratio = _info[? "溅射比例"];
if (shape == 2) jk_bullet_count = max(jk_bullet_count, 4);   // 四转兜底 +1 发（终转已压缩成 1 发，不参与）
