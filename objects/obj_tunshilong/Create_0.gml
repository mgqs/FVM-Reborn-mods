// obj_tunshilong（吞噬龙 / 幼年吞噬龙 / 成年吞噬龙）Create 事件
// 非远程类·吞噬类（照汉堡包）：吞掉范围内地面非防爆鼠（秒杀），防爆鼠扣 3000，BOSS 不响应；
//   消化期间一次只吞一只，消化时间到了再吞下一只。
// 吸取范围：以「自身右边第 1 格」为中心 3×3 / 3×3 / 5×5
// 素材 63 帧（下面是 image_index，括号里 = 编辑器显示的第几帧）：
//   待机   0~11  (1~12)     —— 用户 2026-11-06 给的分段
//   吞噬   26~52 (27~53)    —— 26 = 咬、27 起嘴里有老鼠，52 = 消化完毕
//   爆炸   53~62 (54~63)    —— 只有一转起死亡才播（由 obj_tunshilong_boom 接过去播）
// 数值：消化时间 → custom["消化时间"]（17 档）、冷却 cooldown（技能 9 档）
event_inherited();
plant_id = "tunshilong";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_tunshilong;
else if (shape == 1) sprite_index = spr_tunshilong_1;
else                 sprite_index = spr_tunshilong_2;

plant_type = "normal";
feature_type = "normal";
target_type = "normal";
is_slowdown = false;
image_speed = 0;

// ── 动画分段（用户 2026-11-06 口径；image_index 0 起算，括号里 = 编辑器第几帧）──
//   待机 0~11 (1~12) / 吞噬消化 26~52 (27~53) / 爆炸 53~62 (54~63)
TUN_IDLE_LAST  = 11;
TUN_EAT_FIRST  = 26;      // 26 = 咬（编辑器 27 帧）
TUN_EAT_LAST   = 52;      // 52 = 消化完毕（编辑器 53 帧）
TUN_EAT_LEN    = TUN_EAT_LAST - TUN_EAT_FIRST + 1;
TUN_BOOM_FIRST = 53;      // 爆炸段首帧（编辑器 54 帧）
TUN_BOOM_LAST  = 62;
eat_t = 0;                // 吞噬/消化动画计时（-1 = 不在该段）

// 🔴 父对象只会「IDLE 0~idle_anim / ATTACK idle_anim+1 ~ +attack_anim」两段，做不到
//    「待机 0~11 / 吞噬 26~52」这种带间隔的分段，所以帧由本对象自己推（见 Step 的帧机）。
//    idle_anim / attack_anim 只当父对象兜底：保证它自己推也永远进不到 26 帧以后。
idle_anim   = TUN_IDLE_LAST;
attack_anim = 0;
flash_speed = 5;

var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("tunshilong", shape, clamp(current_level, 0, 16), _sk);
ash_proof_damage = 3000;    // 对防爆鼠的伤害（custom["防爆伤害"]）
digest_time = 38 * 60;
if (_info != undefined && ds_map_exists(_info, "消化时间")) digest_time = _info[? "消化时间"] * 60;
if (_info != undefined && ds_map_exists(_info, "防爆伤害")) ash_proof_damage = _info[? "防爆伤害"];

digest_timer = 0;        // > 0 = 正在消化，吞不了下一只
swallow_t = 0;           // 吞咽动画进度
range_col = 1;
range_row = 1;
if (shape >= 2){ range_col = 2; range_row = 2; }

// 不可吞噬名单（按 mouse_id；对不上的走下面「防爆 / BOSS / 空中」三条通用规则兜底）
no_eat = [
    "kamikaze_glider_mouse",     // 神风幽灵鼠
    "kf_zr_nonmain",             // 僵尸非主流鼠
    "garbage_track_mouse",       // 垃圾车鼠
    "kf_zr_garbage",             // 变异垃圾车
    "magician_mouse",            // 魔术师鼠
    "kf_zr_magician",            // 变异魔术师
    "hazelnut_cannon_mouse",     // 榛子炮鼠
    "landmine_vehicle_mouse",    // 地雷车鼠
    "undersea_submarine",        // 水潜艇鼠
    "submarine_mouse",
    "kof_submarine_mouse",
    "thug_submarine_mouse",
    "infected_submarine_mouse",
    "infected_bingzha",          // 僵尸投冰车
    "suv_mouse",                 // 越野车鼠
    "fog_julie"                  // 迷雾鼠
];
