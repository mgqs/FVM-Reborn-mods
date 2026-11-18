// obj_jiejiema（结界马 / 一转 / 二转结界马）Create 事件
// 非远程类·连携类（2026-11-18 新卡，素材 = res1118\11月份做卡11.14\spr-jiejiema）
//   官方口径（数据信息.xlsx Sheet1 第 2~8 行）：
//     耗能 180 / 冷却 25 秒 / 体力 350 / 攻击间隔 2 秒 / 秒杀不防爆非精英鼠
//     1 只   → 本格 + 前方 1 格
//     2 只   → 非同行就连成一条线（同行就是一条横线）
//     多只   → 以最外圈的为顶点围成多边形，攻击内部 空 / 陆 / 地鼠军
//     持续时间到点消失；二转是悬浮状态（不占格）且可被铲除
//   一转起：同一只老鼠前 7 次受击 1 / 1.2 / 1.4 / 1.6 / 1.8 / 2 / 2.5 倍，第 8 次起 3 倍；
//     计数在「结界每次刷新（重新成形）」时清零（2026-11-18 用户口径）。
//
// ── 谁在算 ────────────────────────────────────────────────────────────────
//   这张卡**自己不打伤害**：格集 / 多边形 / 结算全在 obj_jiejiema_field。
//   场上 id 最小的那只当「领队」，由它创建并持有那块结界；领队死了结界跟着销毁，
//   下一帧剩下的马自己重新选一个领队 —— 所以铲掉任意一只都不会留下孤儿特效。
event_inherited();

plant_id = "jiejiema";
obj_type = object_index;
event_user(0);

if (shape == 0)
    sprite_index = spr_jiejiema;
else if (shape == 1)
    sprite_index = spr_jiejiema_1;
else
    sprite_index = spr_jiejiema_2;

// 素材帧结构（SWF 的 FrameLabelTag，三个形态各自不同）：
//   0 / 1 转 = 21 帧：frame 1「待机」…10，frame 11「技能」…21
//   2 转     = 24 帧：frame 1「待机」…12，frame 13「技能」…24
//   父对象 IDLE 段循环 0..idle_anim、ATTACK 段循环 idle_anim+1..idle_anim+attack_anim
//   （obj_card_parent/Step_0:281-289）→ idle_anim 填「待机段末下标」、attack_anim 填「技能段长」。
//   🔴 2026-11-18 修正：之前误判成「全帧都是待机」，待机动画里带着施法姿势、技能段永远不播。
if (shape >= 2)
{
    idle_anim   = 11;    // 24 帧：待机 12 帧（idx 0..11）
    attack_anim = 12;    //        技能 12 帧（idx 12..23）
}
else
{
    idle_anim   = 9;     // 21 帧：待机 10 帧（idx 0..9）
    attack_anim = 11;    //        技能 11 帧（idx 10..20）
}
state         = CARD_STATE.IDLE;
attack_timer  = 0;
jj_skill_timer = 0;      // 结界每次结算时点亮，让马播一遍「技能」动画
image_speed   = 0;       // 🔴 必须 0：帧由父对象 timer 推
flash_speed   = 6;
is_slowdown   = false;

// 二转悬浮：不占格子，可被铲子收走（与星轨神 / 仙笛马同口径）
if (shape >= 2) plant_type = "gridless";

// ── 持续时间（技能 0~8 级 = 25 / 26 / 27 / 28 / 30 / 33 / 36 / 40 / 45 秒）──
//   星级表里恒 0，真值只由 mod_skill_init 的 `duration` 写进升级数据；
//   父对象的 event_user(0) 只搬 hp/cost/atk/range/cooldown/cycle 六个字段，
//   自定义键要自己再取一次（与 obj_xingqiongma/Create_0:19-22 同写法）。
var _info = get_plant_data_with_skill(plant_id, shape, current_level, skill);
jj_duration = 1500;
if (_info != undefined && ds_map_exists(_info, "duration") && is_real(_info[? "duration"]))
    jj_duration = _info[? "duration"];
jj_life = jj_duration;

// ── 结算口径（结界对象照抄这几个字段，改口径只改这里）──────────────────
// 卡面「攻击内部空、陆、地鼠军」：**不含**潜水 / 非主流 / 未显形幽灵
jj_can_hit_types = ["normal", "air", "underground"];
// 一转起的逐次递增；0 转恒定 1 倍
jj_mult      = [1, 1.2, 1.4, 1.6, 1.8, 2, 2.5];
jj_mult_tail = 3;
jj_use_mult  = (shape >= 1);

// ── 领队 / 结界引用 ───────────────────────────────────────────────────────
jj_field = noone;
jj_blink = 0;
