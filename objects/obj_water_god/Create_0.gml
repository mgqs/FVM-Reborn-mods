/// 水神 / 忒提丝（water_god）Create 事件
/// 辅助·反弹类：不发射子弹，靠子弹碰撞它反弹；反弹时给子弹加附伤（= 本卡 atk）
/// 帧段：第 1~13 帧待机（index 0~12）/ 第 14 帧起反弹动作（index 13~17，5 帧）
/// 毒伤：被反弹的子弹命中时按概率挂毒（每 1 秒 1 跳、共 3 跳、只刷新不叠加），
///   数值走 custom["毒伤"] + 技能表 water_god/毒伤（100→300），0 转 5% 概率、一转起必定
/// 终转：反弹子弹伤害翻倍（含附伤），在 mod_bullet_hazard 的反弹处按 wg_final_double 乘
event_inherited();
plant_id = "water_god";
event_user(0);

sprite_index = spr_water_god;
if (shape == 1)
    sprite_index = spr_water_god_1;
else if (shape == 2)
    sprite_index = spr_water_god_2;
else if (shape == 3)
    sprite_index = spr_water_god_3;

idle_anim   = 12;        // 第 1~13 帧
attack_anim = 5;         // 第 14~18 帧（index 13~17）
flash_speed = 6;
flash_speed_base = 6;
plant_type  = "normal";
is_slowdown = false;

// ── 反弹带毒 / 终转翻倍（rebound 处读这几个字段）──
var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("water_god", shape, clamp(current_level, 0, 16), _sk);

wg_poison_dmg    = 100;                 // custom["毒伤"]，技能表会覆盖成 100→300
wg_poison_ticks  = 3;                   // 每 1 秒 1 跳，共 3 跳
wg_poison_chance = (shape >= 1) ? 100 : 5;   // custom["毒伤概率"]，缺省 0 转 5% / 一转起 100%
wg_final_double  = (shape >= 3);              // 终转：反弹子弹伤害翻倍（含附伤）

// ── 反弹动作：被反弹时播一遍第 14~18 帧（见 Step），播完回待机 ──
wg_reflect_t    = 0;     // 0 = 没在播；>0 = 已播放的帧数
wg_anim_step    = 3;     // 每张停几帧（5 张 × 3 = 15 帧 ≈ 0.25 秒）

if (_info != undefined && ds_map_exists(_info, "毒伤")) wg_poison_dmg = _info[? "毒伤"];
if (_info != undefined && ds_map_exists(_info, "毒伤概率")) wg_poison_chance = _info[? "毒伤概率"];
