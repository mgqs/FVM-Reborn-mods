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
var _hittable = get_hittable_enemy_types(target_type);

// 同轮第二发延迟出膛（2026-11-04 用户口径）：Other_11 当帧只出第一发，后面的发记在 bbq_pending，
//   这里倒计时到点再创建 —— 两发从**同一点**先后出去，间距 = 延迟帧数 × 弹速（5.35 px/帧）。
//   多行（二转）的待发弹会一起到点、同一帧出膛，行与行之间仍然同步。
if (bbq_pending_timer > 0)
{
    bbq_pending_timer--;
    if (bbq_pending_timer <= 0 && array_length(bbq_pending) > 0)
    {
        for (var _p = 0; _p < array_length(bbq_pending); _p++)
        {
            var _pd = bbq_pending[_p];
            var _pb = instance_create_depth(_pd.x, _pd.y, depth - 500, obj_bbq_bullet);
            _pb.damage = atk;
            _pb.row = _pd.row;
            _pb.burn_shot = _pd.burn;
            _pb.start_x = _pd.x;
            _pb.end_x = _pd.end_x;
            _pb.end_x_left = _pd.end_x_left;
            _pb.move_dir = 1;
            _pb.hittable_types = _hittable;
            if (_pd.burn)
            {
                _pb.sprite_index = spr_bbq_bullet_burn;
                // 🔴 火格跟着**烤串本身**铺：这一发就是烤串 → 补发这一帧才铺，
                //   不再在本轮第一发（普通串）出膛时就提前出现（2026-11-04 用户口径）
                bbq_spawn_burn_cell(_pd.row);
            }
        }
        bbq_pending = [];
    }
}

// 2026-11-02：**整行索敌**（左右都认）—— 身后的地精鼠出土后从左边走过来咬卡，也会触发开火。
//   子弹轨迹是固定的（永远向右，见 Other_11），**不要**改成按方向左右发射。
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
