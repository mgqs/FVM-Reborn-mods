// obj_bbq（街头烤肉大师）开火事件（event_user(1)）
// 2026-10-31 改版：**固定攻击** —— 单行恒 1 发、不随冷却堆发数。
// 2026-11-02 出膛点 = **地图最左沿（第 1 格左沿）**，不跟卡片位置走（就是红框标的那个位置）；弹道**永远向右固定**，右端到第 11 格右沿（出图 2 格）。
//   速度 3 格/秒（5.35 px/帧），过火后 4.5 格/秒（8.02 px/帧），见 obj_bbq_bullet。
// 🔴 索敌是**整行**（左右都认，身后的地精鼠出土后走过来也会触发开火）—— 但子弹只往右飞，别改成双向。
// 灼烧弹：0 转每 4n 发（第 4/8/12…），1 转起每 2n 发（第 2/4/6…）。
// 灼烧区：该行第 9 格整格铺满，**存在 2 秒**，每秒一跳 100（共 200）；详见 obj_burn_cell。
bbq_shot_count++;

var _is_burn = (shape >= 1) ? (bbq_shot_count mod 2 == 0) : (bbq_shot_count mod 4 == 0);

var _rows = (shape >= 2) ? [grid_row - 1, grid_row, grid_row + 1] : [grid_row];

// 🔴 贴图格线与逻辑网格不是同一原点：地图是静态背景图（obj_battle/Draw 直接 draw_sprite 到 0,0），
//   它画的格子缝比 global.grid_offset_y 那套网格高 36px（实测：格子行高两边都是 116，只是原点差 36）。
//   用户是按「看到的格子」判断位置的，所以串串的飞行高度和灼烧火格都往上抬 36 贴图格线对齐。要微调只改这一个数。
var _art_up = 36;

// 两端销毁点：右 = 第 11 格右沿（出图 2 格）；左只给**被反弹**的串串用（出图 1 格）
// 🔴 2026-11-02：右端原来收到第 9 格右沿（x 1658），第 10 列出生点（1741）和同行排队的第二只（1848）根本打不到 → 丢伤害。
//   出图 2 格刚好盖住这两个出生点；再远（第 12 列 1955）已在屏幕外，老鼠一出生就往左走，不值得追。
var _right_end = global.grid_offset_x + (global.grid_cols + 2) * global.grid_cell_size_x;
var _left_end  = global.grid_offset_x - global.grid_cell_size_x;
var _hittable  = get_hittable_enemy_types(target_type);

for (var _r = 0; _r < array_length(_rows); _r++)
{
    var _row = _rows[_r];
    if (_row < 0 || _row >= global.grid_rows) continue;

    // 出膛点固定 = **地图最左沿（第 1 格左沿）**，不跟卡片位置走（2026-10-31 的固定攻击口径）
    // 🔴 2026-11-02：别再按卡片偏移写 x±40 —— 卡面 1.8 倍、半宽约 61px，±40 都落在卡身里，看着像从猫身上/背后钻出来。
    //   要再往左到边框外就写 `global.grid_offset_x - 20`。
    var _start_x = global.grid_offset_x;

    // 行内飞行高度：贴图格子的中线（含 _art_up 修正）
    var _lane_y = global.grid_offset_y + _row * global.grid_cell_size_y
                + global.grid_cell_size_y * 0.5 - _art_up;

    for (var _j = 0; _j < bbq_per_row; _j++)
    {
        // 多发出膛口沿行进方向错开，连起来像一整串
        var inst = instance_create_depth(_start_x + _j * 26, _lane_y, depth - 500, obj_bbq_bullet);
        inst.damage = atk;
        inst.row = _row;
        inst.burn_shot = _is_burn;
        inst.start_x = _start_x;
        inst.end_x = _right_end;
        inst.end_x_left = _left_end;
        inst.move_dir = 1;
        inst.hittable_types = _hittable;
        if (_is_burn) inst.sprite_index = spr_bbq_bullet_burn;
    }

    // 爆辣烤串：该行第 9 格整格铺灼烧（存在 2 秒，每秒 100）
    if (_is_burn)
    {
        var _bc = global.grid_cols - 1;
        var _cell = get_world_position_from_grid(_bc, _row);
        // 🔴 贴图 112×141 的画布里只有中间一块是火：按画布缩放只会铺出一小块，必须按**实心火**的内容框放大。
        //   _fw/_fh/_fcx/_fcy = 20 帧并集里 alpha≥128 的实心区域（x 28~84 / y 48~114，中心 (56,81)）；
        //   之前用的 70×99 是按画布中心估的，竖向只铺到格子的 6 成，所以「没占满格子」。
        var _fw = 56, _fh = 66, _fcx = 56, _fcy = 81;
        // 火格画面本身比贴图格子略偏左下，单独补：_fire_dx 往右、_fire_dy 往上（负 = 上）
        var _fire_dx = 9, _fire_dy = -10;
        var _sx = global.grid_cell_size_x / _fw;
        var _sy = global.grid_cell_size_y / _fh;
        var _bx = (_cell.x + _fire_dx) - (_fcx - sprite_get_xoffset(spr_bbq_burn_ground)) * _sx;
        var _by = (_cell.y - _art_up + _fire_dy) - (_fcy - sprite_get_yoffset(spr_bbq_burn_ground)) * _sy;
        // 图层：压在老鼠和卡片后面（跟 calculate_plant_depth 同一套行距，但取「行首之外」的值）
        var _b = instance_create_depth(_bx, _by, -10 - _row * 45, obj_burn_cell);
        _b.sprite_index = spr_bbq_burn_ground;
        // 只播「火最旺」的 3~16 段：0/1/18/19 帧几乎全透明（烧起来前 / 灭掉后），
        //   整段循环会看到火格「闪一下没了」，2026-10-31 用户反馈的问题
        _b.frame_start = 3;
        _b.frame_end = 16;
        _b.anim_loop_frames = 42;      // 14 帧 × 3 = 20fps，1 秒不到一轮，一直有火
        _b.damage = max(50, atk);      // 每跳伤害 = 卡片 atk，最低 50（站满 4 跳 = 最少 200）
        _b.life = 120;                 // 火格存在 2 秒
        _b.tick_interval = 30;         // 每 30 帧（0.5 秒）结算一跳 → 站满全程 4 跳（第 1/31/61/91 帧）
                                       //   后来走进来的老鼠只吃剩下的跳数，不补前面的伤害（2026-11-03 用户口径）
        _b.lock_grid = true;
        _b.grid_col = _bc;
        _b.grid_row = _row;
        // 地面单位全烧：普通 / 非主流 / 幽灵 / 潜水 / 障碍；空军、钻地不烧
        _b.hittable_types = ["normal", "dance", "invisible", "diver", "obstacle"];
        // 被烧到的老鼠身上挂辣椒燃烧特效
        _b.mouse_fx_spr = spr_bbq_burn_mouse;
        // 铺满整格（按内容缩放，per-axis 保证不溢到上下行）
        _b.image_xscale = _sx;
        _b.image_yscale = _sy;
    }
}

audio_play_sound(snd_shot, 0, 0);
