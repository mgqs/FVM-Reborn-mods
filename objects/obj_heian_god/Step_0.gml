if (global.is_paused)
    exit;

event_inherited();

if (is_frozen)
    exit;

lifetime_timer--;
if (lifetime_timer <= 0)
{
    if (instance_exists(heian_effect_obj))
        instance_destroy(heian_effect_obj);
    if (ds_exists(hit_map, ds_type_map))
        ds_map_destroy(hit_map);
    instance_destroy();
    exit;
}

if (instance_exists(heian_effect_obj))
{
    heian_effect_obj.x = x;
    heian_effect_obj.y = y - 30;
    heian_effect_obj.image_alpha = image_alpha;
}

image_alpha = 1;

// 检测范围内是否有敌人
var _has_enemy = false;
var _cx = x;
var _cy = y;
var _rx = range_x;
var _ry = range_y;

with (obj_enemy_parent)
{
    if (hp > 0)
    {
        if (abs(x - _cx) <= _rx && abs(y - _cy) <= _ry)
        {
            _has_enemy = true;
            break;
        }
    }
}

if (state != CARD_STATE.SLEEP)
{
    if (state == CARD_STATE.IDLE)
    {
        if (_has_enemy)
        {
            state = CARD_STATE.ATTACK;
            has_fired = false;
            timer = 0;
            image_index = idle_anim + 1;
        }
    }
    else if (state == CARD_STATE.ATTACK)
    {
        // 在第18帧（0-indexed: 17）释放子弹
        if (!has_fired && image_index >= 17)
        {
            has_fired = true;

            var _bullet_spr = spr_heian_god_bullet;
            if (shape == 1) _bullet_spr = spr_heian_god_bullet_1;
            else if (shape == 2) _bullet_spr = spr_heian_god_bullet_2;
            else if (shape == 3) _bullet_spr = spr_heian_god_bullet_3;

            var _pulse = instance_create_depth(x, y - 30, depth - 100, obj_heian_god_bullet);
            _pulse.sprite_index = _bullet_spr;
            _pulse.damage = atk;
            _pulse.shape = shape;
            _pulse.freeze_chance = freeze_chance;
            _pulse.freeze_duration = freeze_duration;
            _pulse.hit_map = hit_map;
            _pulse.range_x = range_x;
            _pulse.range_y = range_y;
            _pulse.target_type = target_type;
            _pulse.damage_type = "normal";
        }

        // 检测攻击动画是否完成（image_index回到攻击起点）
        if (has_fired && image_index <= idle_anim + 1)
        {
            if (_has_enemy)
            {
                has_fired = false;
            }
            else
            {
                state = CARD_STATE.IDLE;
                has_fired = false;
                image_index = 0;
                timer = 0;
            }
        }
    }
}
