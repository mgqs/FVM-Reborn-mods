if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;

if (burnt == 1)
    sprite_index = spr_fire_bullet;

x += move_speed;

if (target_row != -1)
{
    var target_y = global.grid_offset_y + (global.grid_cell_size_y * target_row);
    var transition_speed = 0.15;
    y = lerp(y, target_y, transition_speed);

    if (abs(y - target_y) < 30)
        row = target_row;
}

if (x > 2200 || y > 1200 || x < 0 || y < 0)
{
    if (ds_exists(hitted_enemy, ds_type_list))
        ds_list_destroy(hitted_enemy);
    instance_destroy();
    exit;
}

hit_tick++;
if (hit_tick >= global.bullet_hit_interval)
{
	hit_tick = 0;
	if (bullet_enemy_reachable(id)) {
if (variable_global_exists("enemy_by_type"))
{
    for (var _t = 0; _t < array_length(hittable_types); _t++)
    {
        var _key = hittable_types[_t];
        if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
        var _list = bullet_sap_type_list(id, _key);
        for (var _i = 0; _i < array_length(_list); _i++)
        {
            var _e = _list[_i];
            if (!instance_exists(_e)) continue;
            if (ds_list_find_index(hitted_enemy, _e.id) == -1
                && _e.hp > 0 && row == _e.grid_row
    && precise_bbox_collision(id, _e))
            {
                var _prev_hp = _e.hp;

                with (_e)
                {
                    if (other.burnt == 1)
                        audio_play_sound(snd_fire_hit, 0, 0);
                    else
                        audio_play_sound(hit_sound, 0, 0);
                    damage_amount = other.damage;
                    damage_type = other.damage_type;
                    event_user(0);
                }

                ds_list_add(hitted_enemy, _e.id);

                if (ash_kill && _prev_hp > 0 && _e.hp <= 0)
                {
                    if (shape >= 2)
                    {
                        var _ash = instance_create_depth(_e.x, _e.y - 20, depth, obj_mouse_ash_death);
                        _ash.special_ash = true;
                        _ash.sprite_index = _e.sprite_index;
                        _ash.image_index = _e.image_index;
                    }
                    else
                    {
                        instance_create_depth(_e.x, _e.y - 20, depth, obj_mouse_ash_death);
                    }
                }

                // ── 地火（2026-11-13）：首次命中就在本行命中格往右铺地面火焰 ──
                //   0/1/2/3 转分别是 3/5/5/5 格，持续 0.5s（30 帧），格内每只敌人整段吃一次 700。
                //   一发只铺一次（ground_fire_done）：穿透弹烧到后面几只时不重复铺，否则格子会叠成一片。
                if (!ground_fire_done)
                {
                    ground_fire_done = true;

                    var _cells = ground_fire_cells;
                    if (_cells <= 0)
                    {
                        if (shape == 0) _cells = 3;
                        else            _cells = 5;
                    }

                    // 铺格用的实心内容框（20 帧并集 alpha>=128）：底心 = 精灵原点，
                    //   所以摆放只要「x = 格中心、y = 视觉格子底边」，缩放直接把内容框撑满一格
                    var _gf_spr = spr_houyi_god_ground_fire;
                    var _gf_fw  = 81,  _gf_fh = 85;    // shape0 / shape1
                    if (shape == 1)      _gf_spr = spr_houyi_god_ground_fire_1;
                    else if (shape == 2)
                    {
                        _gf_spr = spr_houyi_god_ground_fire_2;
                        _gf_fw = 100; _gf_fh = 104;
                    }
                    else if (shape == 3)
                    {
                        _gf_spr = spr_houyi_god_ground_fire_3;
                        _gf_fw = 116; _gf_fh = 115;
                    }

                    var _gf_sx = global.grid_cell_size_x / _gf_fw;
                    var _gf_sy = global.grid_cell_size_y / _gf_fh;
                    var _gf_art_up = 36;   // 贴图格线比逻辑网格高 36px（同 bbq_art_up / fashishe_art_up）

                    for (var _gfi = 0; _gfi < _cells; _gfi++)
                    {
                        var _gcol = _e.grid_col + _gfi;      // 命中格算第 1 格，往右依次铺
                        if (!combat_col_in(_gcol)) break;    // 出战斗域就停（第 10 列 = BOSS 出生位仍算）
                        var _grow = _e.grid_row;
                        if (!combat_row_in(_grow)) continue;

                        var _gcell = get_world_position_from_grid(_gcol, _grow);
                        var _gx = _gcell.x;
                        var _gy = _gcell.y - _gf_art_up + global.grid_cell_size_y * 0.5;

                        var _gf = instance_create_depth(_gx, _gy, -10 - _grow * 45, obj_houyi_god_ground_fire);
                        _gf.sprite_index = _gf_spr;
                        _gf.image_xscale = _gf_sx;
                        _gf.image_yscale = _gf_sy;
                        _gf.frame_start  = 0;
                        _gf.frame_end    = sprite_get_number(_gf_spr) - 1;
                        _gf.anim_loop_frames = 0;       // 整段 life 播一遍，末帧正好火散
                        _gf.life         = ground_fire_life;
                        _gf.damage       = ground_fire_damage;
                        _gf.damage_type  = "fire";
                        _gf.lock_grid    = true;
                        _gf.grid_col     = _gcol;
                        _gf.grid_row     = _grow;
                        _gf.extra_col_right = 0;        // 每格只烧自己那一列，相邻格不重复烧同一只
                        _gf.single_hit   = true;
                        // 地面火固定烧地面上的一切（含钻地/地下/舞者/隐形/障碍），与烤肉地火同口径
                        _gf.hittable_types = ["normal", "dance", "invisible", "diver", "obstacle", "underground"];
                        _gf.shape        = shape;
                        _gf.mouse_fx_scale = 1.8;
                        _gf.mouse_fx_y_off = 50;
                        _gf.mouse_fx_life  = 30;        // 身上着火 0.5s，与地火同寿命
                    }
                }

                if (random(1) < fire_chance)
                {
                    var fire_spr = spr_houyi_god_fire;
                    if (shape == 1) fire_spr = spr_houyi_god_fire_1;
                    else if (shape == 2) fire_spr = spr_houyi_god_fire_2;
                    else if (shape == 3) fire_spr = spr_houyi_god_fire_3;

                    var inst = instance_create_depth(_e.x, _e.y, depth, obj_houyi_god_fire);
                    inst.sprite_index = fire_spr;
                    inst.damage = damage * (burn_bonus ? 1.5 : 1);
                    inst.damage_type = "pierce";
                    inst.grid_row = _e.grid_row;
                    inst.grid_col = _e.grid_col;
                    inst.shape = shape;
                    inst.target_type = target_type;
                    inst.stack_count = sanwei_stack;
                }
            }
        }
    }
}
	}
}
