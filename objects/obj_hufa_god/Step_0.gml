if (global.is_paused)
    exit;

event_inherited();

if (is_frozen)
    exit;

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

// 喷壶类可命中钻地中的地精鼠
var _hittable = (shape < 2) ? ["normal", "air", "invisible", "underground"] : ["normal", "air", "underground", "invisible"];

var has_enemy = false;

if (variable_global_exists("enemy_by_type"))
{
    for (var _t = 0; _t < array_length(_hittable); _t++)
    {
        var _key = _hittable[_t];
        if (variable_struct_exists(global.enemy_by_type, _key))
        {
            var _list = global.enemy_by_type[$ _key];
            for (var _i = 0; _i < array_length(_list); _i++)
            {
                var _e = _list[_i];
                // underground 只对本关钻地中的地精鼠开放
                if (_key == "underground" && !is_digging_dijing(_e)) continue;
                if (instance_exists(_e) && _e.hp > 0)
                {
                    has_enemy = true;
                    break;
                }
            }
        }
        if (has_enemy) break;
    }
}

// ── 攻击循环：1-12 待机 / 13-29 攻击，第 19 帧发射 ──────────────────
if (state != CARD_STATE.ATTACK)
{
    if (has_enemy)
    {
        attack_timer++;

        // cycle 不足以播完整套攻击动画时，按 cycle 压缩每帧时钟，保证发射帧一定播得到；
        // 攻击窗口 = attack_anim * _spd，总周期仍是 cycle（不改变 DPS）
        var _spd = min(current_flash_speed, max(1, floor(cycle / max(1, attack_anim))));
        var _window = attack_anim * _spd;

        if (attack_timer >= cycle - _window)
        {
            attack_timer = 0;
            state = CARD_STATE.ATTACK;
            image_index = idle_anim + 1;
            hufa_fired = false;
            flash_speed = is_slowdown ? max(1, _spd * 0.5) : _spd;
        }
    }
    else
    {
        attack_timer = 0;
        state = CARD_STATE.IDLE;
    }
}
else
{
    // 攻击动画播到第 19 帧 → 发射
    if (!hufa_fired && image_index >= hufa_shoot_frame)
    {
        event_user(1);
        hufa_fired = true;
    }

    // 攻击动画播完 → 回待机
    if (image_index >= idle_anim + attack_anim)
    {
        state = CARD_STATE.IDLE;
        image_index = 0;
        attack_timer = 0;
        flash_speed = flash_speed_base;
    }
}
