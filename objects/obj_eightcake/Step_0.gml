// obj_eightcake（8周年蛋糕）Step 事件
// 单线投手：只打本行；索敌覆盖整行，但**最远只到场内第 9 格**（场外 / 第 9 格右边站着的老鼠不算）。
// 动画全部自己推帧（父对象那套 0~20/21~32 会被这里覆盖），按「本轮丢什么」选帧段：
//   普通轮        待机 0~9   / 挥勺 21~31  （第 25 帧脱手）
//   蜡烛轮(3n)    装填 32~34 / 待机 35~44 / 挥勺 56~66  （第 60 帧脱手）
//   炸弹轮(10n)   装填 67~69 / 待机 70~79 / 挥勺 91~101 （第 94 帧脱手）—— 只有二转精灵有这段
//   补蛋糕块      本体·一转 67~69，二转 102~104（二转的 67~101 整段是可乐炸弹专用段）
// 🔴 节拍由 **ec_cd（冷却）** 驱动：有目标每帧 +1，到 cycle 开一轮攻击；攻击进度由 **ec_atk_t** 独立计。
//    旧版用 attack_timer 同时管「进攻击 / 出弹 / 回待机」，状态一抖就会一轮里把蛋糕块 / 蜡烛 / 炸弹全丢出去。
//    出弹带 **ec_firing 守卫**（Other_11 检查），保证一轮攻击最多只投一件。
if (global.is_paused) exit;

event_inherited();

if (is_frozen) exit;
if (state == CARD_STATE.SLEEP) exit;

var _step_frames = max(1, flash_speed * (is_slowdown ? 2 : 1));
var _load_frames = max(1, _step_frames div 2);   // 装填帧播快一倍

// ===== 索敌：本行 + 卡片右侧，列上限 = 最后一列 + 1，取最近一只（同双菇 / 融合煮蛋器）=====
var _has_enemy = false;
var _tgt_col = -1;
var _tgt = noone;
var _min_d = 99999;

with (obj_enemy_parent)
{
    if (hp > 0
        && grid_row == other.grid_row
        && grid_col >= other.grid_col
        && grid_col <= (global.grid_cols + 1)
        && can_target_on(other.target_type, target_type))
    {
        var _d = grid_col - other.grid_col;
        if (_d < _min_d)
        {
            _min_d = _d;
            _tgt_col = grid_col;
            _tgt = id;
            _has_enemy = true;
        }
    }
}
// 落点：记下最前面那只本身，Other_11 直接取它的坐标投掷
if (_tgt_col != -1)
{
    eightcake_target_col = _tgt_col;
    eightcake_target = _tgt;
}

// ===== 轮次类型：0 普通蛋糕块 / 1 蜡烛 / 2 可乐炸弹 =====
//   发数从 1 数起（_next_no = 已投发数 + 1）：
//     二转第 10/20/30… 发 = 可乐 —— 10 的倍数**优先**，第 30 发撞上 3 的倍数也照样出可乐
//     其余第 3/6/9/12… 发 = 蜡烛
//     剩下全是蛋糕块。前 10 发实际是：蛋糕 蛋糕 蜡烛 蛋糕 蛋糕 蜡烛 蛋糕 蛋糕 蜡烛 **可乐**
var _next_no = eightcake_shot_count + 1;
var _next_type = 0;
if (shape >= 2 && _next_no mod 10 == 0) _next_type = 2;
else if (_next_no mod 3 == 0) _next_type = 1;

// 挥勺期间锁死本轮（开火后 shot_count 会 +1，不能中途把帧段换掉）
if (state != CARD_STATE.ATTACK) ec_round = _next_type;
var _cur = ec_round;

var _atk_start = (_cur == 2) ? 91 : ((_cur == 1) ? 56 : 21);
var _atk_len   = 11;                                            // 三种挥勺都是 11 帧
var _release_off = (_cur == 2) ? 3 : 4;                         // 94-91 / 60-56 / 25-21
// 补蛋糕块的帧段：二转（110 帧）在 102~104，本体 / 一转在 67~69
var _load_block_spr = (shape >= 2) ? 102 : 67;

// ===== 节拍：冷却到点 → 开一轮攻击 =====
if (state != CARD_STATE.ATTACK)
{
    if (_has_enemy) ec_cd++;                 // 没目标就冻结冷却（不清零，回来接着数）
    if (ec_cd >= cycle)
    {
        ec_cd = 0;
        ec_atk_t = 0;
        ec_firing = false;
        state = CARD_STATE.ATTACK;
    }
}

// ===== 推帧（每个分支都给 image_index 赋值，否则父对象会插一帧进来 → 看着「抽」）=====
if (state == CARD_STATE.ATTACK)
{
    ec_atk_t++;
    var _fi = min(ec_atk_t div _step_frames, _atk_len - 1);
    image_index = _atk_start + _fi;

    // 挥到脱手帧才投出。ec_firing = 「本轮已投过」的**锁存位**：
    //   这里置 true，只有下一轮攻击开始（上面那段）才复位；Other_11 只管消费、不回写。
    if (!ec_firing && _fi >= _release_off)
    {
        ec_firing = true;
        event_user(1);
    }

    // 挥完（含手臂收回）回待机，并按「下一发是什么」接对应装填
    if (ec_atk_t >= _atk_len * _step_frames)
    {
        state = CARD_STATE.IDLE;
        ec_phase = (_next_type == 1) ? 1 : ((_next_type == 2) ? 4 : 3);
        ec_phase_t = 0;
        ec_cd = ec_atk_t;        // 攻击占掉的帧数计入冷却 → 一轮攻击的间隔正好 = cycle
    }
}
else
{
    ec_phase_t++;
    var _li = ec_phase_t div _load_frames;       // 装填帧序号 0/1/2

    switch (ec_phase)
    {
        case 1:                                  // 装填蜡烛：32~34
            if (_li < 3) image_index = 32 + _li;
            else { ec_phase = 2; ec_phase_t = 0; image_index = 35; }
            break;

        case 2:                                  // 蜡烛待机：35~44（10 帧一循环）
            image_index = 35 + ((ec_phase_t div _step_frames) mod 10);
            break;

        case 3:                                  // 补蛋糕块：67~69 / 102~104
            if (_li < 3) image_index = _load_block_spr + _li;
            else { ec_phase = 0; ec_phase_t = 0; image_index = 0; }
            break;

        case 4:                                  // 装填可乐炸弹：67~69
            if (_li < 3) image_index = 67 + _li;
            else { ec_phase = 5; ec_phase_t = 0; image_index = 70; }
            break;

        case 5:                                  // 可乐炸弹待机（勺子托着罐子）：70~79
            image_index = 70 + ((ec_phase_t div _step_frames) mod 10);
            break;

        default:                                 // 普通待机：0~9（10 帧一循环）
            image_index = (ec_phase_t div _step_frames) mod 10;
            break;
    }
}
