// obj_caihongshe（彩虹蛇 / 溏心彩虹蛇 / 缤纷彩虹蛇）Create 事件
// 防御类·护罩类：plant_type = "shield_outer"（引擎把啃咬打到罩子上，铲子也铲不掉，同处女座 / 赫拉）
// 素材：蛇 64 帧循环（0~63）；护罩是同一份素材的第 65~71 帧，单独做 spr_caihongshe_shield
//   给 obj_caihongshe_shield（纯视觉，跟着本体画在罩子层）
// 数值走注册表：体力 hp、攻击力 atk、攻击间隔 cycle（技能 9 档）、死亡爆炸伤害 custom["死亡爆炸伤害"]
event_inherited();
plant_id = "caihongshe";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_caihongshe;
else if (shape == 1) sprite_index = spr_caihongshe_1;
else                 sprite_index = spr_caihongshe_2;

plant_type = "shield_outer";
feature_type = "normal";
target_type = "normal";
is_slowdown = false;
image_speed = 0;

// ── 动画分段（2026-11-06 用户给的分段；下面写的是 image_index，0 起算，括号里=编辑器显示的第几帧）──
//   健康待机  0~13  (1~14)
//   虚弱待机 14~27  (15~28)
//   健康开火 28~40  (29~41)   第 29 帧和待机第 1 帧**像素完全相同**，是美术给开火段起的头
//   虚弱开火 41~54  (42~55)
//   爆炸     55~63  (56~64)   只有死亡时用，待机和开火都不碰它
// 🔴 父对象只会「IDLE 0~idle_anim / ATTACK idle_anim+1 ~ +attack_anim」两段，
//    做不到健康/虚弱各一套，所以帧由本对象自己推（见 Step 的帧机，每帧覆盖 image_index）。
//    idle_anim / attack_anim 只当父对象的兜底用（保证它自己推也不会推到爆炸帧）。
idle_anim   = 13;      // 父对象 IDLE 兜底：只走健康待机前 14 帧
attack_anim = 13;      // 父对象 ATTACK 兜底：只走 14~26（虚弱待机段），不会碰爆炸帧
flash_speed = 5;

cai_idle_t = 0;        // 待机动画计时
cai_atk_t  = -1;       // -1 = 不在开火段；>=0 = 开火段已播了几帧
fired_this_attack = false;

// 🔴 2026-11-06 去掉「护罩泡泡」：原来拿素材 65~71 帧当护罩播，
//    但那 7 帧其实是**死亡炸开**的特效，结果种下就播一遍爆炸，看起来像刚放下就炸了。
//    蛇本身盘成环已经能表达「罩住」，不再叠一层假护罩。
//    （obj_caihongshe_shield 对象保留，留着以后有真正的泡泡素材再用）
shield_obj = noone;

current_hp = hp;
shoot_timer = 0;
// 2 转「子弹数量 +2」= **同一方向连射 3 发、中间错帧**（2026-11-06 用户口径），
//   不是 3 向散射（旧写法把 y 逐发上错 12px、vy 逐发 -0.4，看着像三向散射 —— 那是和别的卡混了）
shot_count = (shape >= 2) ? 3 : 1;
burst_left  = 0;      // 这一轮还差几发没出膛
burst_timer = 0;
burst_gap   = 8;      // 每两发之间隔几帧（8 帧 ≈ 0.13 秒）

// 发射一发糖豆（错帧连射靠 cai_fire_one 反复调，Other_11 只调第一次）
cai_fire_one = function()
{
    var _b = instance_create_depth(x + 10, y - 40, depth - 500, obj_caihongshe_bullet);
    _b.damage = atk;
    _b.row = grid_row;
    _b.stun_chance = stun_chance;
    _b.stun_frames = stun_frames;
    if (shape == 1)      _b.sprite_index = spr_caihongshe_bullet_1;
    else if (shape == 2) _b.sprite_index = spr_caihongshe_bullet_2;
};

// 数值全部走注册表 custom：改注册表就生效，文案里用 {定身概率} / {定身时间} 读同一份
//   死亡爆炸伤害 2026-11-06 用户定：**固定 900**，不进 custom（注册表里已删）
var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("caihongshe", shape, clamp(current_level, 0, 16), _sk);
boom_damage = 900;                                  // 一/二转死亡灰烬爆炸：固定 900
stun_chance = 10;
stun_time   = 2;
if (_info != undefined){
    if (ds_map_exists(_info, "定身概率"))     stun_chance = _info[? "定身概率"];
    if (ds_map_exists(_info, "定身时间"))     stun_time   = _info[? "定身时间"];
}
stun_frames = round(stun_time * 60);
