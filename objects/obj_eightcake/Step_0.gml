// obj_eightcake（8周年蛋糕）Step 事件
// 单线投手：只打本行；索敌覆盖整行，但**最远只到场内第 9 格**（场外 / 第 9 格右边站着的老鼠不算）。
// 动画全部自己推帧（父对象那套 0~20/21~32 会被这里覆盖），按「本轮丢什么」选帧段：
//   普通轮        待机 0~9   / 挥勺 21~31  （第 25 帧脱手）
//   蜡烛轮(3n)    装填 32~34 / 待机 35~44 / 挥勺 56~66  （第 60 帧脱手）
//   炸弹轮(10n)   装填 67~69 / 待机 70~79 / 挥勺 91~101 （第 94 帧脱手）—— 只有二转精灵有这段
//   补蛋糕块      本体·一转 67~69，二转 102~104（二转的 67~101 整段是可乐炸弹专用段）
// 🔴 待机段都是 **10 帧一个循环**（实测 0==10==20、35==45==55、70==80==90），
//    循环尾部那几帧（56~59 / 91~93）是「抡勺起手」，不属于待机 —— 把它们放进循环会来回抽。
if (global.is_paused) exit;

event_inherited();

if (is_frozen) exit;
if (state == CARD_STATE.SLEEP) exit;

var _step_frames = max(1, flash_speed * (is_slowdown ? 2 : 1));
// 装填帧播快一倍：3 帧的「飞回来」如果也按 4 步/帧播，会变成三段位移，看着像在抽
var _load_frames = max(1, _step_frames div 2);

// ===== 索敌：整行，但只认**场内**（卡片右边 ~ 第 9 格右沿）=====
var _max_x = global.grid_offset_x + global.grid_cols * global.grid_cell_size_x;
var _last_col = global.grid_cols - 1;
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
            if (_e.grid_col > _last_col) continue;              // 第 9 格右边（场外）不算
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
// 落点：记下最前面那只本身，Other_11 直接取它的坐标投掷
if (_tgt_col != -1)
{
    eightcake_target_col = _tgt_col;
    eightcake_target = _tgt;
}

// ===== 轮次类型：0 普通蛋糕块 / 1 蜡烛 / 2 可乐炸弹 =====
//   下一发（shot_count + 1）：二转每 10n 发炸弹；其余每 3n 发蜡烛（10 与 3 互质，不会撞）
var _next_no = eightcake_shot_count + 1;
var _next_type = 0;
if (shape >= 2 && _next_no mod 10 == 0) _next_type = 2;
else if (_next_no mod 3 == 0) _next_type = 1;

// 挥勺期间锁死本轮（开火后 shot_count 会 +1，不能中途把帧段换掉）
if (state != CARD_STATE.ATTACK) ec_round = _next_type;
var _cur = ec_round;

var _atk_start = (_cur == 2) ? 91 : ((_cur == 1) ? 56 : 21);
var _atk_end   = (_cur == 2) ? 101 : ((_cur == 1) ? 66 : 31);
var _release   = (_cur == 2) ? 94 : ((_cur == 1) ? 60 : 25);
var _atk_len   = _atk_end - _atk_start + 1;
// 补蛋糕块的帧段：二转（110 帧）在 102~104，本体 / 一转在 67~69
var _load_block_spr = (shape >= 2) ? 102 : 67;

// ===== 攻击节拍 =====
var _enter_load = false;

if (_has_enemy)
{
    attack_timer++;

    if (state != CARD_STATE.ATTACK && attack_timer >= cycle - _atk_len * _step_frames)
    {
        state = CARD_STATE.ATTACK;
        eightcake_fired = false;
    }

    // 挥完（含手臂收回那几帧）才回待机，然后按「下一发是什么」接对应装填
    if (state == CARD_STATE.ATTACK && image_index >= _atk_end)
    {
        state = CARD_STATE.IDLE;
        _enter_load = true;
    }

    if (attack_timer > cycle)
    {
        attack_timer = 0;
        if (state == CARD_STATE.ATTACK)
        {
            state = CARD_STATE.IDLE;
            _enter_load = true;
        }
    }
}
else
{
    attack_timer = 0;
    eightcake_fired = false;
    if (state == CARD_STATE.ATTACK)              // 挥到一半没目标了：照样走装填，别停在挥勺帧
    {
        state = CARD_STATE.IDLE;
        _enter_load = true;
    }
}

// 装填：下一发是蜡烛 → 32~34；是炸弹 → 67~69；否则补蛋糕块 67~69 / 102~104
if (_enter_load)
{
    ec_phase = (_next_type == 1) ? 1 : ((_next_type == 2) ? 4 : 3);
    ec_phase_t = 0;
}

// ===== 推帧（每个分支都给 image_index 赋值，否则父对象会插一帧进来 → 看着「抽」）=====
ec_phase_t++;

if (state == CARD_STATE.ATTACK)
{
    var _elapsed = attack_timer - (cycle - _atk_len * _step_frames);
    var _fi = clamp(floor(_elapsed / _step_frames), 0, _atk_len - 1);
    image_index = _atk_start + _fi;
}
else
{
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

        case 5:                                  // 可乐炸弹待机（勺子托着罐子）：70~79（10 帧一循环）
            image_index = 70 + ((ec_phase_t div _step_frames) mod 10);
            break;

        default:                                 // 普通待机：0~9（10 帧一循环）
            image_index = (ec_phase_t div _step_frames) mod 10;
            break;
    }
}

// ===== 出弹：挥到脱手帧才真正投出去 =====
if (state == CARD_STATE.ATTACK && !eightcake_fired && image_index >= _release)
{
    eightcake_fired = true;
    event_user(1);
}
