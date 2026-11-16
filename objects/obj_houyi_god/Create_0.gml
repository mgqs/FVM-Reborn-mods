event_inherited();
plant_id = "houyi_god";
event_user(0);

if (shape == 0)
    sprite_index = spr_houyi_god;
else if (shape == 1)
    sprite_index = spr_houyi_god_1;
else if (shape == 2)
    sprite_index = spr_houyi_god_2;
else if (shape == 3)
    sprite_index = spr_houyi_god_3;

fire_mid = false;
fire_up = false;
fire_down = false;
// 帧布局（2026-10-28 用户）：1-12 待机 / 13-23 攻击，第 20 帧发射子弹
idle_anim = 11;
attack_anim = 11;
// 形态 3 的精灵只有 22 帧（0..21），攻击段只能到第 22 帧
if (shape == 3) attack_anim = 10;
flash_speed = 5;
flash_speed_base = 5;
houyi_shoot_frame = 19;      // 第 20 帧（0 起算）
houyi_fired = false;
plant_type = "normal";
is_slowdown = false;

// ── 三昧真火（地火）参数：读注册表 custom，改表即生效 ──
//   情报岛里的 {灼烧格数} / {灼烧时间} / {灼烧次数} / {叠加层数} 读的是同一份 key
//   口径：场地最右方 {灼烧格数} 格、持续 {灼烧时间} 秒、共 {灼烧次数} 跳、每跳 = 一发子弹的伤害、
//         同一格最多同时叠 {叠加层数} 片（多片各自结算 = 叠层伤害）
var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("houyi_god", shape, clamp(current_level, 0, 16), _sk);

burn_cells = 3;
burn_time  = 2;
burn_ticks = 5;
burn_stack = 8;
if (_info != undefined && ds_map_exists(_info, "灼烧格数")) burn_cells = _info[? "灼烧格数"];
if (_info != undefined && ds_map_exists(_info, "灼烧时间")) burn_time  = _info[? "灼烧时间"];
if (_info != undefined && ds_map_exists(_info, "灼烧次数")) burn_ticks = _info[? "灼烧次数"];
if (_info != undefined && ds_map_exists(_info, "叠加层数")) burn_stack = _info[? "叠加层数"];

burn_frames   = max(1, round(burn_time * 60));
burn_interval = max(1, round(burn_frames / max(1, burn_ticks)));

// 每行跨轮累计的「原版发数」，用来判第 3n 发（压缩后 1 发代表 N 发）
burn_acc = [0, 0, 0];

// 铺本行最右 burn_cells 格地火（照 obj_fashishe 的 fashishe_poison_at 写法）
//   _n = 该行的压缩倍数（本体 3 / 三转中路 4 / 终转 5），每跳伤害 = atk × _n
houyi_burn_at = function(_row, _n)
{
    var _c0 = global.grid_cols - 1;

    var _gf_spr = spr_houyi_god_ground_fire;
    var _gf_fw = 81, _gf_fh = 85;
    if (shape == 1) _gf_spr = spr_houyi_god_ground_fire_1;
    else if (shape == 2) { _gf_spr = spr_houyi_god_ground_fire_2; _gf_fw = 100; _gf_fh = 104; }
    else if (shape == 3) { _gf_spr = spr_houyi_god_ground_fire_3; _gf_fw = 116; _gf_fh = 115; }

    var _gf_sx = global.grid_cell_size_x / _gf_fw;
    var _gf_sy = global.grid_cell_size_y / _gf_fh;
    var _gf_art_up = 36;   // 贴图格线比逻辑网格高 36px（同 bbq_art_up / fashishe_art_up）

    for (var _i = 0; _i < burn_cells; _i++)
    {
        var _c = _c0 - _i;
        if (_c < 0) continue;

        // 叠加上限：同一格已有 >= burn_stack 片就不再加（多片各自跳伤 = 叠层）
        //   不用 with：函数里的 var 局部变量在 with 体内读不到（交接 §三.12）
        var _cnt = 0;
        var _gfn = instance_number(obj_houyi_god_ground_fire);
        for (var _gi = 0; _gi < _gfn; _gi++)
        {
            var _g = instance_find(obj_houyi_god_ground_fire, _gi);
            if (_g.grid_col == _c && _g.grid_row == _row) _cnt++;
        }
        if (_cnt >= burn_stack) continue;

        var _cell = get_world_position_from_grid(_c, _row);
        var _gx = _cell.x;
        var _gy = _cell.y - _gf_art_up + global.grid_cell_size_y * 0.5;

        var _gf = instance_create_depth(_gx, _gy, -10 - _row * 45, obj_houyi_god_ground_fire);
        _gf.sprite_index = _gf_spr;
        _gf.image_xscale = _gf_sx;
        _gf.image_yscale = _gf_sy;
        _gf.frame_start  = 0;
        _gf.frame_end    = sprite_get_number(_gf_spr) - 1;
        _gf.anim_loop_frames = 30;
        _gf.life          = burn_frames;
        _gf.tick_interval = burn_interval;
        _gf.damage        = atk * _n;
        _gf.damage_type   = "fire";
        _gf.lock_grid     = true;
        _gf.grid_col      = _c;
        _gf.grid_row      = _row;
        // 只有最右一格放宽到场外 1 格（第 10 列 / BOSS 出生位）；中间几格放宽会互相重复烧
        _gf.extra_col_right = (_i == 0) ? 1 : 0;
        _gf.hittable_types = get_hittable_enemy_types("all");
        _gf.shape          = shape;
        _gf.mouse_fx_life  = burn_interval + 4;
    }
};
