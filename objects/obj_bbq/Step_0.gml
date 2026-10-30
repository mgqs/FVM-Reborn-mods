// obj_bbq（街头烤肉大师）Step 事件
// 只负责：① 判断本行（二转三行）前方有没有敌人；② 推进攻击动画并到帧开火。
// 动画：待机 0~12 交给父对象循环；开火前切 ATTACK，父对象在 13~21 之间推帧。
if (global.is_paused) exit;

event_inherited();

if (is_frozen) exit;
if (state == CARD_STATE.SLEEP) exit;

// 🔴 2026-10-31 补：缺了这两个局部变量 → Step 第 48 行读 current_flash_speed 直接崩
//   （Variable obj_bbq.current_flash_speed not set before reading it）
//   flash_speed 在 Create 里 = 5；被减速时翻倍，与 obj_eightcake / obj_spicy_pot 同一写法
var current_flash_speed = flash_speed;
if (is_slowdown) current_flash_speed *= 2;

// 二转照顾上下各一行
var _rows = (shape >= 2) ? [grid_row - 1, grid_row, grid_row + 1] : [grid_row];
var _hittable = ["normal", "air", "invisible"];

var _has_enemy = false;
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
            if (_e.x <= x) continue;
            for (var _r = 0; _r < array_length(_rows); _r++)
            {
                if (_e.grid_row == _rows[_r])
                {
                    _has_enemy = true;
                    break;
                }
            }
            if (_has_enemy) break;
        }
        if (_has_enemy) break;
    }
}

if (_has_enemy)
{
    attack_timer++;

    // 进入攻击动画窗口（父对象在 13~21 推帧；cycle 小时窗口被压到 1 帧也不影响出弹，
    // 因为出弹看的是 image_index 而不是剩余帧数）
    if (attack_timer >= max(1, cycle - attack_anim * current_flash_speed))
        state = CARD_STATE.ATTACK;

    // 串串最长那帧（image_index 16 = 第 17 帧）出弹，一次攻击只发一次
    if (state == CARD_STATE.ATTACK && !bbq_fired && image_index >= 16)
    {
        bbq_fired = true;
        event_user(1);
    }

    if (attack_timer > cycle)
    {
        attack_timer = 0;
        bbq_fired = false;
        state = CARD_STATE.IDLE;
    }
}
else
{
    attack_timer = 0;
    bbq_fired = false;
    state = CARD_STATE.IDLE;
}
