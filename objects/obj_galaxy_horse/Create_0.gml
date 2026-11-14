// obj_galaxy_horse（银河马 / 星渊银河马 / 创世银河马）Create 事件
// 灰烬类·轰炸类（2026-11-13 新卡，素材 = 桌面\皮特\11月份做卡11.12\spr-galaxyhorse）
//   官方口径（米苏.jpeg + 数据信息.xlsx 第 105~116 行）：
//     召唤 1 颗陨石，对本行老鼠进行海陆空全方位打击；耗能 380 / 范围 1 行 / 全天。
//     有目标才会攻击 | 索敌 3/3/5 行 | 子弹仅落在本行
//     | 仅对本行索敌目标造成[攻击力]伤害，其余造成 50% 溅射
//     | 均秒杀不防爆，击杀灰烬 | 无法攻击非主流 & 幽灵鼠。
//   一转：攻击力 +25%，眩晕防爆鼠 2 秒（表内 A110 / 米苏图）。
//   二转：子弹数 +2（1 → 3），溅射范围扩到 3*5。
//
// ── 数值口径 ─────────────────────────────────────────────────────────────
//   攻击力：xlsx 第 113~114 行两行直接抄表 —— 本体 600~1100、一转 750~1375（= ×1.25）。
//           **二转没有独立行**（表内只有「银河马 / 一转攻击力」两行，二转靠 3 发子弹提升），
//           所以 shape 2 沿用一转数值，见 mod_cards_init 的注释。
//   攻击间隔：xlsx 第 115 行 19 / 18.5 / … / 11 秒 —— 官方「技能强化 = 攻击速度」，
//           17 档同一个 19 秒，递减写在 mod_skill_init 的 9 档技能表里。
//   耗能 380 / hp 100 / cooldown 2700（45 秒）/ 范围 1 行。
event_inherited();

plant_id = "galaxy_horse";
obj_type = object_index;
event_user(0);

if (shape == 0)
    sprite_index = spr_galaxy_horse;
else if (shape == 1)
    sprite_index = spr_galaxy_horse_1;
else
    sprite_index = spr_galaxy_horse_2;

plant_type   = "normal";
feature_type = "normal";
// 🔴 target_type 只用来让引擎的通用判定「不当场拦掉」；真正能不能打到谁由 gh_hittable 决定
//    （"all" 会把 dance / invisible 也放进来，而本卡官方口径是「无法攻击非主流 & 幽灵鼠」）
target_type  = "all";
is_slowdown  = false;
image_speed  = 0;      // 帧由父对象 timer 推
flash_speed  = 5;

// 素材 25 帧 = 待机 1~13（idx 0..12）+ 攻击 14~25（idx 13..24）
idle_anim   = 12;
attack_anim = 12;
state       = CARD_STATE.IDLE;
attack_timer = 0;

// ── 可调参数（要改能力只动这几行）──────────────────────────────────
//   海陆空 = 普通 / 潜水 / 空军 / 障碍 / 钻地；**不含** dance（非主流走行）与 invisible（未显形幽灵）
gh_hittable     = ["normal", "diver", "air", "obstacle", "underground"];
gh_bullet_count = (shape >= 2) ? 3 : 1;   // 子弹数 1 / 1 / 3
gh_search_rows  = (shape >= 2) ? 2 : 1;   // 索敌 3 / 3 / 5 行（本行 ±1 / ±2）
gh_splash_rows  = (shape >= 2) ? 2 : 1;   // 溅射 3*3 / 3*3 / 3*5（列恒 ±1）
gh_splash_cols  = 1;
gh_splash_ratio = 0.5;                    // 非索敌目标只吃 50%
gh_stun_ticks   = (shape >= 1) ? 120 : 0; // 一转起：命中眩晕 2 秒
gh_shot_gap     = 8;                      // 一轮内后几发晚几帧起落

gh_bullet_spr = spr_galaxy_horse_bullet;
if (shape == 1) gh_bullet_spr = spr_galaxy_horse_bullet_1;
else if (shape >= 2) gh_bullet_spr = spr_galaxy_horse_bullet_2;

gh_target_list = [];   // 本轮每颗陨石的落点列（Other_11 里填）

/// 这只老鼠能不能被本卡打到（官方：海陆空全方位，不含非主流 & 幽灵）
/// 🔴 命中类型判定的**唯一**入口：Other_11 收候选、Step 结算都调它，别在各处重复写数组查询。
/// 守 target_type：obj_enemy_parent 的 297 个直接子对象里有没写这个字段的
/// （obj_beverage_skill_1_bullet / _3_bullet），直接读是硬崩。
gh_can_hit = function(_e)
{
    if (!instance_exists(_e)) return false;
    if (!variable_instance_exists(_e, "hp")) return false;
    if (_e.hp <= 0) return false;
    if (!variable_instance_exists(_e, "target_type")) return false;
    // 卡面「无法攻击非主流」：非主流三兄弟啃食时 target_type 会变回 "normal"（见 is_non_mainstream
    // 的注释），只查 gh_hittable 白名单拦不住 → 按身份排一次。
    if (is_non_mainstream(_e)) return false;
    return (array_get_index(gh_hittable, _e.target_type) != -1);
};

/// 索敌：本行 ±gh_search_rows 行、卡片前方（含自身格）有没有可打目标
/// 🔴 口径必须与 Other_11 收集落点候选**完全一致**：两者不一致就会出现
///    「开火了但没有候选 → 陨石砸空地」（2026-11-14 用户报的索敌问题就是这种）。
///    改动这里时同步改 Other_11。
gh_has_target = function()
{
    var _hit = false;
    with (obj_enemy_parent)
    {
        // 守 3 个字段：297 个直接子对象里有没写 target_type 的，直接读会硬崩
        if (hp > 0
            && variable_instance_exists(id, "target_type")
            && variable_instance_exists(id, "grid_row")
            && variable_instance_exists(id, "grid_col")
            && abs(grid_row - other.grid_row) <= other.gh_search_rows
            && grid_col >= other.grid_col
            && grid_col <= global.grid_cols + 1
            && !is_non_mainstream(id)
            && array_get_index(other.gh_hittable, target_type) != -1)
        {
            _hit = true;
            break;
        }
    }
    return _hit;
};
