// obj_galaxy_horse_bullet Step 事件
if (global.is_paused)
    exit;

// 延迟段（二转 3 发之间的错帧）
if (gh_delay > 0)
{
    gh_delay--;
    exit;
}

image_alpha = 1;
image_index += gh_frame_speed;

// 进入炸点帧那一瞬间结算一次
if (!gh_done && image_index >= gh_impact_idx)
{
    gh_done = true;

    var _cx    = gh_col;
    var _cy    = gh_row;
    var _cols  = gh_splash_cols;
    var _rows  = gh_splash_rows;
    var _dmg   = gh_damage;
    var _ratio = gh_splash_ratio;
    var _stun  = gh_stun;

    // 索敌目标 = 本行里离落点最近的那只（只有它吃全额）
    var _primary = noone;
    var _best = 999999;
    with (obj_enemy_parent)
    {
        if (hp > 0
            && grid_row == _cy
            && array_get_index(other.gh_hittable, target_type) != -1)
        {
            var _d = abs(grid_col - _cx);
            if (_d < _best)
            {
                _best = _d;
                _primary = id;
            }
        }
    }

    with (obj_enemy_parent)
    {
        if (hp > 0
            && abs(grid_col - _cx) <= _cols
            && abs(grid_row - _cy) <= _rows
            && array_get_index(other.gh_hittable, target_type) != -1)
        {
            damage_amount = (id == _primary) ? _dmg : _dmg * _ratio;
            damage_type   = "ash";
            event_user(0);

            // 一转起：眩晕 2 秒（不查 immune_to_ash —— 官方「眩晕防爆鼠」）
            if (hp > 0 && _stun > 0 && stun_timer < _stun)
                stun_timer = _stun;

            // 击杀一律出灰烬（同 obj_burn_cell / 石榴爆爆冰 的口径）
            if (hp <= 0)
            {
                if (special_ash)
                {
                    var _ash = instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                    _ash.special_ash = true;
                    _ash.sprite_index = sprite_index;
                    _ash.image_index = image_index;
                }
                else
                {
                    instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                }
                instance_destroy();
            }
        }
    }

    audio_play_sound(snd_coke_bomb_explode, 0, 0);
    if (global.screen_shake)
        Camera_Shock(4, 14);
}

if (image_index >= sprite_get_number(sprite_index))
    instance_destroy();
