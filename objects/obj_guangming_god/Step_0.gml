if (global.is_paused)
    exit;

event_inherited();

if (is_frozen)
    exit;

image_alpha = 1;

// 检测是否有黑暗神在场，计算伤害倍率
var dark_god_present = false;
var dark_god_final = false;
with (obj_heian_god)
{
    if (hp > 0)
    {
        dark_god_present = true;
        if (shape >= 3)
            dark_god_final = true;
        break;
    }
}

var damage_multiplier = 1;
if (shape == 2 && dark_god_present)
    damage_multiplier = 4;
else if (shape == 3)
{
    if (dark_god_final)
        damage_multiplier = 8;
    else if (dark_god_present)
        damage_multiplier = 5;
}

// 范围检测辅助变量
var _chk_range = grid_range;
var _chk_row = grid_row;
var _chk_col = grid_col;

// 检测范围内是否有敌人
var _has_enemy = false;

with (obj_enemy_parent)
{
    if (hp > 0)
    {
        var _rd = abs(grid_row - _chk_row);
        var _cd = abs(grid_col - _chk_col);
        if (_rd <= _chk_range && _cd <= _chk_range)
        {
            var _can_atk = true;
            if (variable_instance_exists(id, "is_non_mainstream") && is_non_mainstream)
                _can_atk = false;
            if (_can_atk)
            {
                _has_enemy = true;
                break;
            }
        }
    }
}

// 更新光环效果的位置和透明度
if (instance_exists(guangming_effect_obj))
{
    guangming_effect_obj.x = x;
    guangming_effect_obj.y = y - 30;
    if (state == CARD_STATE.ATTACK)
        guangming_effect_obj.image_alpha = 1;
    else
        guangming_effect_obj.image_alpha = 0.6;
}

if (state != CARD_STATE.SLEEP)
{
    if (state == CARD_STATE.IDLE)
    {
        attack_timer++;

        if (attack_timer >= cycle)
        {
            if (_has_enemy)
            {
                state = CARD_STATE.ATTACK;
                has_fired = false;
                timer = 0;
                image_index = idle_anim + 1;
                attack_timer = 0;

                // 攻击开始特效
                if (shape >= 1)
                {
                    var start_spr = spr_guangming_god_start_1;
                    if (shape >= 2)
                        start_spr = spr_guangming_god_start_2;

                    var boom = instance_create_depth(x, y - 30, depth - 100, obj_guangming_god_effect);
                    boom.sprite_index = start_spr;
                    boom.is_one_shot = true;
                    boom.frame_counter = 0;
                    boom.flash_speed = 5;
                }
            }
            else
            {
                attack_timer = 0;
            }
        }
    }
    else if (state == CARD_STATE.ATTACK)
    {
        // 第21帧：释放子弹并造成伤害
        if (!has_fired && image_index >= attack_fire_frame)
        {
            has_fired = true;

            var _atk = floor(atk * damage_multiplier);
            var _gm_shape = shape;
            var _gbullet_spr = spr_guangming_god_bullet;
            if (_gm_shape == 1) _gbullet_spr = spr_guangming_god_bullet_1;
            else if (_gm_shape >= 2) _gbullet_spr = spr_guangming_god_bullet_2;

            // Phase 1: 收集范围内所有可攻击敌人
            var _enemies = [];
            with (obj_enemy_parent)
            {
                if (hp > 0)
                {
                    var _row_diff = abs(grid_row - _chk_row);
                    var _col_diff = abs(grid_col - _chk_col);
                    if (_row_diff <= _chk_range && _col_diff <= _chk_range)
                    {
                        var _can_attack = true;
                        if (variable_instance_exists(id, "is_non_mainstream") && is_non_mainstream)
                            _can_attack = false;
                        if (_can_attack)
                            array_push(_enemies, id);
                    }
                }
            }

            // Phase 2: 为每个敌人创建子弹并造成伤害
            for (var _i = 0; _i < array_length(_enemies); _i++)
            {
                var _e = _enemies[_i];
                if (!instance_exists(_e)) continue;
                if (_e.hp <= 0) continue;

                // 创建子弹（视觉效果，出现在敌人位置）
                var _gbullet = instance_create_depth(_e.x, _e.y - 20, depth - 100, obj_guangming_god_bullet);
                _gbullet.sprite_index = _gbullet_spr;

                // 爆炸光效
                var _boom = instance_create_depth(_e.x, _e.y - 20, depth - 150, obj_guangming_god_effect);
                _boom.sprite_index = _gbullet_spr;
                _boom.is_one_shot = true;
                _boom.frame_counter = 0;
                _boom.flash_speed = 4;
                _boom.image_xscale = 1.5;
                _boom.image_yscale = 1.5;

                // 子弹出现时立即造成伤害
                if (_e.hp <= _atk)
                {
                    instance_create_depth(_e.x, _e.y - 20, _e.depth, obj_mouse_ash_death);
                    instance_destroy(_e);
                }
                else
                {
                    with (_e)
                    {
                        damage_amount = _atk;
                        damage_type = "holy";
                        event_user(0);
                    }
                }
            }
        }

        // 攻击动画播放完毕（image_index回到攻击起点），回到待机
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
                attack_timer = 0;
            }
        }
    }
}
