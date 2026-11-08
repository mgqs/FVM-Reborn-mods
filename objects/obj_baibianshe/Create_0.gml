event_inherited();
plant_id = "baibianshe";
obj_type = object_index;
current_level = 1;
event_user(0);
sprite_index = spr_baibianshe;

if (shape == 1)
    sprite_index = spr_baibianshe_1;
else if (shape == 2)
    sprite_index = spr_baibianshe_2;

attack_anim = 0;
idle_anim = 14;                               // 待机段 f0~f14（素材 f15~f25 是变身段，三形态都是 26 帧）
image_speed = 0;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
current_hp = hp;
can_mouse_list = ["can_mouse"];
is_derivative = false;
copied = false;

// 2026-11-03：放下后**不再立刻变身**——先待机，等玩家从手牌放下下一张卡才进变身段。
//   触发写在 scripts/mod_on_card_placed：它会写 target_card / target_shape、把 tb_waiting 置 false，
//   并把 image_index 拨到 tb_anim_start、idle_anim 抬到 tb_anim_end（不抬的话父对象 IDLE 分支
//   `image_index < idle_anim ? ++ : 0` 会把刚拨到 15 的帧立刻拽回 0）。
tb_waiting    = true;                         // true = 待机中（等下一张卡）
tb_anim_start = 15;                           // 变身段起始帧
tb_anim_end   = 25;                           // 变身段末帧（播到这帧才出卡）
target_card   = "";
target_shape  = 0;

// ── 二转「放下就占 3 格」（2026-11-08 用户口径）────────────────────────────
//   双子百变蛇不再「1 只变 3 张」，而是**放下来就占 3 格**：本格 + 同列上一格 + 同列下一格，
//   三只各自待机，之后玩家种下一张卡时**每只各变 1 张**（见 Step_0 顶部的 tb_siblings_done 段）。
//   上下两格被占 → 按「由近到远」顺延到最近可放格（baibianshe_free_cell）。
//   「放卡时看到的三格虚影」不在这个对象里 —— 那是放置预览 obj_card_preview 画的（见那边 Draw_0）。
tb_siblings_done = false;   // true = 这一只已经处理过「放兄弟」，也用来阻止兄弟再往下生

// 变身放卡用：目标卡资料在变身那一帧存成实例变量，给下面几个方法用
copy_card_id      = "";
copy_card_shape   = 0;
copy_plant_type   = "normal";
copy_feature_type = "normal";
copy_base_target  = "none";

// 找「百变蛇自己能放」的最近空格（二转放上下两只时用；起手格不能放就按距离外扩，同列优先）
baibianshe_free_cell = function(_col, _row)
{
    var _maxd = max(global.grid_cols, global.grid_rows);
    for (var d = 0; d <= _maxd; d++)
    {
        var _cands = [];
        var dr = -d;
        while (dr <= d)
        {
            var _dca = d - abs(dr);
            if (_dca == 0)
                array_push(_cands, { c: _col, r: _row + dr, p: 0 });
            else
            {
                for (var s = -1; s <= 1; s += 2)
                {
                    var _c2 = _col + s * _dca;
                    var _r2 = _row + dr;
                    array_push(_cands, { c: _c2, r: _r2, p: (_r2 == _row) ? 1 : 2 });
                }
            }
            dr++;
        }

        array_sort(_cands, function(a, b)
        {
            if (a.p != b.p) return a.p - b.p;
            if (a.r != b.r) return a.r - b.r;
            return a.c - b.c;
        });

        for (var j = 0; j < array_length(_cands); j++)
        {
            var _cc = _cands[j].c;
            var _rr = _cands[j].r;
            if (_cc < 0 || _cc >= global.grid_cols || _rr < 0 || _rr >= global.grid_rows) continue;
            var _w = get_world_position_from_grid(_cc, _rr);
            if (can_place_at_position(_w.x, _w.y, "normal", "normal", "none", "baibianshe")) return [_cc, _rr];
        }
    }
    return [];
};

// 这一格还放得下目标卡吗（= 变身逻辑里那份 can_copy_card_at_position，补了越界判断）
baibianshe_cell_ok = function(_col, _row)
{
    if (_col < 0 || _col >= global.grid_cols || _row < 0 || _row >= global.grid_rows) return false;
    var _w = get_world_position_from_grid(_col, _row);
    return can_copy_card_at_position(_w.x, _w.y, copy_plant_type, copy_feature_type, copy_card_id, copy_base_target);
};

// 选格子：先按 _pref 顺序（本格 → 同列上 → 同列下），不够再按曼哈顿距离由近到远补（同列 → 同行 → 斜角）
//   _oc/_or = 向外扩的中心格（默认就是自己这一格）
baibianshe_pick_cells = function(_want, _pref, _oc = undefined, _or = undefined)
{
    if (is_undefined(_oc)) _oc = grid_col;
    if (is_undefined(_or)) _or = grid_row;

    var _out  = [];
    var _seen = {};

    for (var i = 0; i < array_length(_pref); i++)
    {
        if (array_length(_out) >= _want) break;
        var _c = _pref[i][0];
        var _r = _pref[i][1];
        var _k = string(_c) + "_" + string(_r);
        if (variable_struct_exists(_seen, _k)) continue;
        _seen[$ _k] = true;
        if (baibianshe_cell_ok(_c, _r)) array_push(_out, [_c, _r]);
    }

    var _max = (shape >= 1) ? max(global.grid_cols, global.grid_rows) : 2;   // 0 转只认 5*5
    for (var d = 1; d <= _max; d++)
    {
        if (array_length(_out) >= _want) break;

        var _cands = [];
        var dr = -d;
        while (dr <= d)
        {
            var _dca = d - abs(dr);
            if (_dca == 0)
                array_push(_cands, { c: _oc, r: _or + dr, p: 0 });
            else
            {
                for (var s = -1; s <= 1; s += 2)
                {
                    var _c2 = _oc + s * _dca;
                    var _r2 = _or + dr;
                    array_push(_cands, { c: _c2, r: _r2, p: (_r2 == _or) ? 1 : 2 });
                }
            }
            dr++;
        }

        array_sort(_cands, function(a, b)
        {
            if (a.p != b.p) return a.p - b.p;
            if (a.r != b.r) return a.r - b.r;
            return a.c - b.c;
        });

        for (var j = 0; j < array_length(_cands); j++)
        {
            if (array_length(_out) >= _want) break;
            var _cc = _cands[j].c;
            var _rr = _cands[j].r;
            var _k2 = string(_cc) + "_" + string(_rr);
            if (variable_struct_exists(_seen, _k2)) continue;
            _seen[$ _k2] = true;
            if (baibianshe_cell_ok(_cc, _rr)) array_push(_out, [_cc, _rr]);
        }
    }

    return _out;
};

// 真正放一张卡（0/1 转 1 张、二转 3 张都走这里）
baibianshe_place_one = function(_col, _row)
{
    var _cell_world = get_world_position_from_grid(_col, _row);
    var _psx = 0;
    var _psy = 0;
    var _plat = instance_position(x, y, obj_platform);
    if (_plat != noone)
    {
        _psx = _plat.visual_x_shift;
        _psy = _plat.visual_y_shift;
    }

    // 升级型卡（如咖啡杯）先清掉底座那张，与原逻辑一致
    if (copy_feature_type == "upgrade" && copy_base_target != undefined && copy_base_target != "none")
    {
        var _base_plant_list = ds_grid_get(global.grid_plants, _col, _row);
        for (var j = 0; j < ds_list_size(_base_plant_list); j++)
        {
            var _base_plant = ds_list_find_value(_base_plant_list, j);
            if (instance_exists(_base_plant) && variable_instance_exists(_base_plant, "plant_id") && _base_plant.plant_id == copy_base_target)
            {
                card_destroyed(_base_plant);
                instance_destroy(_base_plant);
                break;
            }
        }
    }

    var new_card = external_mod_spawn(_cell_world.x + _psx, _cell_world.y + _psy, 0, copy_card_id, copy_card_shape);
    card_created(new_card, _col, _row);
};
