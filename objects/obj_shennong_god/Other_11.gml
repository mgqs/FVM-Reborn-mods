// ========== 炎帝：发射水平轨迹子弹 ==========
// 基础（shape 0/1/2）：召唤2只子弹，沿2条固定行轨迹移动（上路、中路，从左向右飞行）
// 场上至少8张炎帝时：增加下路轨迹，变为3行攻击
//
// 终转（shape 3）：依据《数据信息.xlsx》A6 / A19-B21
//   · 子弹从场地左右两边对向飞出，飞到对面边界消失
//   · 单只朱雀子弹伤害范围扩大到 3 行（自身行 ±1）
//   · 沿途上中下 5 行分别受击 1/2/3/2/1 次（合计 9 次）
//   · 边路特化：
//       炎帝在第1行 → 子弹在 1,1,2 行，对 1~3 行造成 5/3/1 倍伤害
//       炎帝在第2行 → 子弹在 1,2,3 行，对 1~4 行造成 3/3/2/1 倍伤害

var col0_x = get_world_position_from_grid(0, 0).x;
var col_last_x = get_world_position_from_grid(global.grid_cols - 1, 0).x;
var grid_cell_y = global.grid_cell_size_y;
var middle_y_offset = 30; // 子弹y偏移

// ==================== 终转（shape 3） ====================
if (shape == 3)
{
    var _rows_n = global.grid_rows;
    var _r = grid_row;

    // ---- 1. 三发子弹的飞行行（绝对行号），越界夹到边界 ----
    var _fly_off = [-1, 0, 1];
    var _fly_rows = array_create(3, 0);

    for (var _b1 = 0; _b1 < 3; _b1++)
    {
        _fly_rows[_b1] = clamp(_r + _fly_off[_b1], 0, _rows_n - 1);
    }

    // ---- 2. 逐行伤害倍率表（数据表口径，合计 9） ----
    var _mult = array_create(_rows_n, 0);

    if (_r == 0)
    {
        // 炎帝在第1行：子弹在 1,1,2 行，对 1~3 行 5/3/1 倍
        _mult[0] = 5;
        if (_rows_n > 1) _mult[1] = 3;
        if (_rows_n > 2) _mult[2] = 1;
    }
    else if (_r == 1 && _rows_n >= 4)
    {
        // 炎帝在第2行：子弹在 1,2,3 行，对 1~4 行 3/3/2/1 倍
        _mult[0] = 3;
        _mult[1] = 3;
        _mult[2] = 2;
        _mult[3] = 1;
    }
    else
    {
        // 常规：每发覆盖自身行 ±1，5 行合计 1/2/3/2/1
        for (var _b2 = 0; _b2 < 3; _b2++)
        {
            for (var _d = -1; _d <= 1; _d++)
            {
                var _tr = _fly_rows[_b2] + _d;
                if (_tr >= 0 && _tr < _rows_n)
                    _mult[_tr] += 1;
            }
        }
    }

    // ---- 3. 把每行的倍率平摊给覆盖该行的子弹，保证合计不变 ----
    var _share = array_create(3);
    for (var _i = 0; _i < 3; _i++)
    {
        _share[_i] = array_create(_rows_n, 0);
    }

    for (var _ri = 0; _ri < _rows_n; _ri++)
    {
        var _k = _mult[_ri];
        if (_k <= 0) continue;

        var _cover = [];
        for (var _j = 0; _j < 3; _j++)
        {
            if (abs(_fly_rows[_j] - _ri) <= 1)
                array_push(_cover, _j);
        }

        var _m = array_length(_cover);
        if (_m <= 0) continue;

        var _per = floor(_k / _m);
        var _extra = _k - _per * _m;

        for (var _c = 0; _c < _m; _c++)
        {
            var _bi = _cover[_c];
            _share[_bi][_ri] = _per + ((_c < _extra) ? 1 : 0);
        }
    }

    // ---- 4. 生成 3 发朱雀：上路/下路由左向右，中路（自身行）由右向左 ----
    var _from_right = [false, true, false];

    for (var _i2 = 0; _i2 < 3; _i2++)
    {
        var _row_y = global.grid_offset_y + grid_cell_y * _fly_rows[_i2] + middle_y_offset;
        var _sx = col0_x - 40;
        var _spd = 6;

        if (_from_right[_i2])
        {
            _sx = col_last_x + 40;
            _spd = -6;
        }

        var _inst = instance_create_depth(_sx, _row_y, depth - 500, obj_shennong_god_bullet_h);
        _inst.damage = atk; // 行倍率走 row_hits，这里不再乘 dmg_mul
        _inst.move_speed = _spd;
        _inst.row = _fly_rows[_i2];
        _inst.target_row = _fly_rows[_i2];
        _inst.shape = 3;
        _inst.ash_kill = true;
        if (shape >= 2) {
            _inst.target_type = "all";   // 四转起：陆 + 空 + 地（不含潜水 / 非主流 / 幽灵）
            _inst.hittable_types = ["normal", "air", "underground", "obstacle"];
        } else {
            _inst.target_type = "normal";
            _inst.hittable_types = get_hittable_enemy_types("normal");
        }
        _inst.row_hits = _share[_i2];

        // 精灵原点是「鸟头」（spr_shennong_god_bullet_3 origin 242,50，贴图朝右飞）。
        // 中路是从右往左飞的，不转 180° 就是「倒着飞」——用户 2026-11-14 报的正是这个。
        // 这里用 image_angle 而不是 image_xscale = -1：衣服 ① `obj_bullet_parent/BeginStep_0`
        // 每帧把 image_xscale 夹回 1、只留 visual_scale_* 给绘制；② `precise_bbox_collision`
        // 会按 image_angle 旋转判定框、但**不读缩放与翻转**——用角度翻转，图与判定框才一起转头。
        _inst.sprite_index = spr_shennong_god_bullet_3;
        _inst.image_xscale = 1.5;
        _inst.image_yscale = 1.5;
        _inst.image_angle = _from_right[_i2] ? 180 : 0;
    }

    audio_play_sound(snd_shot, 0, 0);
    exit;
}

// ==================== shape 0 / 1 / 2 ====================

// 根据shape计算伤害倍率
var dmg_mul = 1;
var ash_kill = true; // 击杀产生灰烬

switch (shape)
{
    case 0:
        dmg_mul = 1;
        break;
    case 1:
        dmg_mul = 1.3; // 三转攻击力+30%
        break;
    default:
        dmg_mul = 1.6; // 四转攻击力+60%
        break;
}

// 2026-11-17 用户口径：子弹要像炎凰马那样夹在**两行之间**，每发同时打中上下两行，
//   而不是落在单行正中只打本行（旧版实测三行受击 1/1/0）。
//   缝隙 g = 第 g-1 行与第 g 行之间；炎帝在第 R 行时：
//     2 发 → 缝隙 R、R+1         → 覆盖 R-1 / R / R+1，受击 1 / 2 / 1
//     3 发（场上 >7 只）→ 追加缝隙 R+2 → 覆盖到 R+2，受击 1 / 2 / 2 / 1
//   缝隙夹到 [1, rows-1]：贴边越界时两条缝隙会重合 → 该两行各吃两次，
//   与旧版「越界改中路」的重叠语义一致，不会凭空多打一行。
var _gap_max = max(1, global.grid_rows - 1);
var bullet_gaps = [];
bullet_gaps[0] = clamp(grid_row,     1, _gap_max);
bullet_gaps[1] = clamp(grid_row + 1, 1, _gap_max);

// 场上炎帝>7只时，增加一条轨迹（向下延伸一行）
var shennong_count = instance_number(obj_shennong_god);
if (shennong_count > 7)
{
    bullet_gaps[2] = clamp(grid_row + 2, 1, _gap_max);
}

for (var i = 0; i < array_length(bullet_gaps); i++)
{
    var gap = bullet_gaps[i];

    var start_x = col0_x - 40;
    // 缝隙重合（贴边）时把后面的几发错开，否则两张贴图完全叠在一起看不出是多发
    var _dup = 0;
    for (var _d = 0; _d < i; _d++) if (bullet_gaps[_d] == gap) _dup++;
    if (_dup > 0) start_x -= 40 * _dup;

    // 与炎凰马同一条公式：缝隙 g 的视觉中心 = 第 g 行上移 0.25 格（夹在 g-1 / g 之间）
    var start_y = global.grid_offset_y + (gap - 0.25) * grid_cell_y;

    var inst = instance_create_depth(start_x, start_y, depth - 500, obj_shennong_god_bullet_h);
    inst.damage = atk * dmg_mul;
    inst.move_speed = 6;
    inst.row = gap - 1;
    inst.target_row = gap - 1;
    inst.cover_a = gap - 1;   // 缝隙制：上下两行都吃这一发
    inst.cover_b = gap;
    inst.shape = shape;
    inst.ash_kill = ash_kill;
    if (shape >= 2) {
        inst.target_type = "all";   // 四转起：陆 + 空 + 地（不含潜水 / 非主流 / 幽灵）
        inst.hittable_types = ["normal", "air", "underground", "obstacle"];
    } else {
        inst.target_type = "normal";
        inst.hittable_types = get_hittable_enemy_types("normal");
    }

    // 设置子弹精灵
    if (shape == 0)
        inst.sprite_index = spr_shennong_god_bullet;
    else if (shape == 1)
        inst.sprite_index = spr_shennong_god_bullet_1;
    else
        inst.sprite_index = spr_shennong_god_bullet_2;
}

audio_play_sound(snd_shot, 0, 0);
