// obj_tangchaolizi（糖炒栗子）Step 事件
// 单行投手：只打本行（射程 range 格），落点 = 本行最前面那只老鼠。
// 动画自己推帧：待机 0~11（12 帧一循环）/ 挥锅 18~26（第 21 帧脱手）。
// 🔴 节拍用 **tc_cd（冷却帧）+ tc_atk_t（本轮攻击进度）** 两个独立计数器：
//    ① 不再读 image_index —— 父对象 obj_card_parent/Step_0 会把 image_index 掰回
//       idle_anim+1 ~ idle_anim+attack_anim（12~20），而挥锅帧是 18~26，
//       读回来永远到不了 26，「挥完回待机」判定永远不成立 → state 卡死 ATTACK、卡面钉在甩锅帧。
//    ② 不用 attack_timer 推算窗口 —— 目标抖动 / 减速会让窗口偏移，动画跟着抽。
if (global.is_paused) exit;

event_inherited();

if (is_frozen) exit;
if (state == CARD_STATE.SLEEP) exit;

var _step_frames = max(1, flash_speed * (is_slowdown ? 2 : 1));
var _atk_start   = 18;
var _atk_len     = 9;                  // 18~26 共 9 帧
var _release_off = 2;                  // 第 21 帧（18 + 2）锅翻到最大、栗子脱手
var _cycle_frames = max(30, cycle);    // 兜底：cycle 万一为 0/极小，也不至于每帧开一轮

// ===== 索敌：照生煎锅 —— 上下各一行、卡片右侧能丢多远打多远（不夹地图列），取最近一只 =====
var _has_enemy = false;
var _tgt = noone;
var _min_d = 99999;

with (obj_enemy_parent)
{
    if (hp > 0
        && abs(grid_row - other.grid_row) <= 1
        && grid_col >= other.grid_col
        && can_target_on(other.target_type, target_type))
    {
        var _d = grid_col - other.grid_col;
        if (_d < _min_d)
        {
            _min_d = _d;
            _tgt = id;
            _has_enemy = true;
        }
    }
}

// 落点目标每帧刷新（老鼠死了 / 跑了，脱手时按最新坐标算）
// 落点 = 目标所在**格子**（可到第 10 列地图外），不再用敌人的精确 x，否则火焰会烧歪
if (_tgt != noone)
{
    tc_target = _tgt;
    tc_tcol = _tgt.grid_col;      // 不夹地图列：老鼠在哪儿就丢到哪一列（同生煎锅的射程口径）
    // 落点行**恒 = 卡片本行**（同生煎锅：上下行的老鼠只负责让这张卡出手，不改变投掷行）
    tc_trow = grid_row;
}

// ===== 节拍 =====
tc_shot_cd++;                          // 距上一次出弹的帧数（硬保护，见下面的 12 帧门槛）

if (state != CARD_STATE.ATTACK)
{
    if (_has_enemy) tc_cd++;           // 没目标就冻结冷却（不清零，回来接着数）
    // 必须有目标才开打：不然刚放下就会朝空处丢一颗
    // 🔴 2026-11-04 用户口径：**起手要和生煎锅一致**（生煎锅是 `attack_timer == cycle - 30` 就脱手）。
    //   栗子脱手在本轮 ATTACK 开始后第 10 帧（_release_off=2 × 5 帧），所以门槛要提前 40 帧：
    //   (cycle - 40) 进 ATTACK，+10 帧脱手 → 首发 = cycle - 30，跟生煎锅同口径。
    if (_has_enemy && tc_cd >= _cycle_frames - 40)
    {
        tc_cd = 0;
        tc_atk_t = 0;
        tc_fired = false;
        tc_firing = false;
        state = CARD_STATE.ATTACK;
    }
}

if (state == CARD_STATE.ATTACK)
{
    tc_atk_t++;
    var _fi = min(tc_atk_t div _step_frames, _atk_len - 1);
    image_index = _atk_start + _fi;
    external_animation_sync_native(id, _step_frames, tc_atk_t, "tc_atk_t");

    // 脱手帧投出：tc_fired = 本轮已投（锁存，只在开新一轮时复位）；
    //   tc_shot_cd ≥ 12 是硬门槛 —— 任何路径都不可能连着投第二颗
    if (!tc_fired && _fi >= _release_off && tc_shot_cd >= 12)
    {
        tc_fired = true;
        tc_firing = true;              // 一次性令牌：Other_11 消费掉，不回写 tc_fired
        tc_shot_cd = 0;
        event_user(1);
    }

    // 挥完（含收手帧）回待机，接着播待机循环；攻击占掉的帧计入冷却 → 出弹间隔 = cycle
    //   2026-11-04：门槛提前 40 帧后，这里要补回 40 帧（-40），间隔才回到 cycle。
    //   对账：脱手后还剩 (45-10)=35 帧攻击 → 冷却从 5 数到 (cycle-40) 用 cycle-45 帧 → 再 10 帧脱手
    //         35 + (cycle-45) + 10 = cycle ✓
    if (tc_atk_t >= _atk_len * _step_frames)
    {
        state = CARD_STATE.IDLE;
        tc_cd = tc_atk_t - 40;
        tc_anim_t = 0;
    }
}
else
{
    tc_anim_t++;
    image_index = (tc_anim_t div _step_frames) mod 12;      // 待机 0~11
    external_animation_sync_native(id, _step_frames, tc_anim_t, "tc_anim_t");
}
