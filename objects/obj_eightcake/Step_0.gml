// obj_eightcake（8周年蛋糕）Step 事件
// 单线投手：只打本行；索敌覆盖整行，落点 = 本行最前面那只老鼠的**实际位置**（不受格子 / 第 9 格限制）。
// 动画自己推帧：普通轮 / 蜡烛轮各一套帧段 + 装填过渡（见下面的帧段表），出弹看帧不看时间。
if (global.is_paused) exit;

event_inherited();

if (is_frozen) exit;
if (state == CARD_STATE.SLEEP) exit;

var current_flash_speed = flash_speed;
if (is_slowdown) current_flash_speed *= 2;

// 索敌覆盖**整行**：从卡片右边一直到屏幕最右（含还在场外往左走、没进格子的老鼠）
var _max_x = room_width;
var _hittable = ["normal", "air", "invisible"];

var _has_enemy = false;
var _tgt_col = -1;
var _tgt = noone;
if (variable_global_exists("enemy_by_type"))
{
    for (var _t = 0; _t < array_length(_hittable); _t++)
    {
        var _key = _hittable[_t];
        if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
        var _list = global.enemy_by_type[$ _key];
        for (var _i = 0; _i < array_length(_list); _i++)
        {
            var _e = _list[_i];
            if (!instance_exists(_e) || _e.hp <= 0) continue;
            if (_e.grid_row != grid_row) continue;
            if (_e.x <= x || _e.x > _max_x) continue;
            _has_enemy = true;
            if (_tgt_col == -1 || _e.grid_col < _tgt_col)
            {
                _tgt_col = _e.grid_col;
                _tgt = _e;
            }
        }
    }
}
// 落点：记下最前面那只本身（= 本行离卡片最近的敌人），Other_11 直接取它的坐标投掷
if (_tgt_col != -1)
{
    eightcake_target_col = _tgt_col;
    eightcake_target = _tgt;
}

// ===== 帧段（精灵 70 帧；按每帧内容包围盒实测）=====
//   普通轮：待机 0~20 → 挥勺 21~31（第 25 帧挥出/脱手，26~31 手臂收回）
//           → 装填蛋糕块 67~69 → 待机
//   蜡烛轮：装填蜡烛 32~34（两个 8 飞进、落到勺子上）→ 待机 34~59
//           → 挥勺 60~66（第 60 帧脱手，65~66 手臂收回）→ 装填蛋糕块 67~69 → 待机
var _candle_next = ((eightcake_shot_count + 1) mod 3 == 0);
// 攻击期间锁住本轮形态（开火后计数会 +1，不能中途切形态）
if (state != CARD_STATE.ATTACK && eightcake_candle_round != _candle_next)
    eightcake_candle_round = _candle_next;
var _candle = eightcake_candle_round;
var _atk_start  = _candle ? 60 : 21;
var _atk_end    = _candle ? 66 : 31;
var _release    = _candle ? 60 : 25;
var _atk_len    = _atk_end - _atk_start + 1;
var _step_frames = max(1, current_flash_speed);

if (_has_enemy)
{
    attack_timer++;

    // 进入攻击动画窗口
    if (attack_timer >= cycle - _atk_len * _step_frames)
        state = CARD_STATE.ATTACK;

    // 出弹点看帧：普通轮第 25 帧、蜡烛轮第 60 帧（勺子挥出、东西脱手的那一帧）
    if (state == CARD_STATE.ATTACK && !eightcake_fired && image_index >= _release)
    {
        eightcake_fired = true;
        event_user(1);
    }

    // 挥完（含手臂收回那几帧）才回待机，然后接装填过渡
    if (state == CARD_STATE.ATTACK && image_index >= _atk_end)
    {
        state = CARD_STATE.IDLE;
        // 下一发是蜡烛轮 → 直接接「装填蜡烛 32~34」；否则接「装填蛋糕块 67~69」
        //   （旧写法固定先播 67~69，轮到蜡烛时会先摆一下蛋糕块再装蜡烛）
        eightcake_phase = _candle_next ? 2 : 4;
        eightcake_phase_t = 0;
    }

    if (attack_timer > cycle)
    {
        attack_timer = 0;
        eightcake_fired = false;
        state = CARD_STATE.IDLE;
    }
}
else
{
    attack_timer = 0;
    eightcake_fired = false;
    if (state == CARD_STATE.ATTACK)              // 挥到一半没目标了：照样走装填，别停在挥勺帧
    {
        state = CARD_STATE.IDLE;
        eightcake_phase = _candle_next ? 2 : 4;
        eightcake_phase_t = 0;
    }
}

// ===== 推帧（全部自己控；父对象那套 0~20/21~32 会被这里覆盖） =====
//   phase 0 = 普通待机(0~20)  2 = 装填蜡烛(32~34)  3 = 蜡烛待机(34~59)  4 = 装填蛋糕块
//   装填蛋糕块的帧号**按形态不同**：本体 / 一转 = 67~69；二转（110 帧）67~101 被可乐炸弹段占用，
//   蛋糕块回勺在 **102~104**（逐帧内容比对形状、颜色都对得上），写死 67 就会播成「装可乐炸弹」
var _load_start = (shape >= 2) ? 102 : 67;
eightcake_phase_t++;

if (state == CARD_STATE.ATTACK)
{
    var _elapsed = attack_timer - (cycle - _atk_len * _step_frames);
    var _fi = clamp(floor(_elapsed / _step_frames), 0, _atk_len - 1);
    image_index = _atk_start + _fi;
}
else
{
    var _fi2 = eightcake_phase_t div _step_frames;

    switch (eightcake_phase)
    {
        case 4:                                     // 装填：蛋糕块飞回勺子（本体/一转 67~69，二转 102~104）
            if (_fi2 >= 3)
            {
                eightcake_phase = _candle_next ? 2 : 0;
                eightcake_phase_t = 0;
            }
            else image_index = _load_start + _fi2;
            break;

        case 2:                                     // 装填蜡烛：8 飞到勺子上（32~34）
            if (_fi2 >= 3)
            {
                eightcake_phase = 3;
                eightcake_phase_t = 0;
            }
            else image_index = 32 + _fi2;
            break;

        case 3:                                     // 蜡烛待机（34~59）
            image_index = 34 + (_fi2 mod 26);
            break;

        default:                                    // 普通待机（0~20）
            image_index = _fi2 mod 21;
            break;
    }
}
