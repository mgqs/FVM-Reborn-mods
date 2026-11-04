// obj_bbq（街头烤肉大师）开火事件（event_user(1)）
// 2026-10-31 改版：**固定攻击** —— 单行恒 1 发、不随冷却堆发数。
// 2026-11-02 出膛点 = **地图最左沿（第 1 格左沿）**，不跟卡片位置走（就是红框标的那个位置）；弹道**永远向右固定**，右端到第 11 格右沿（出图 2 格）。
//   速度 3 格/秒（5.35 px/帧），过火后 4.5 格/秒（8.02 px/帧），见 obj_bbq_bullet。
// 🔴 索敌是**整行**（左右都认，身后的地精鼠出土后走过来也会触发开火）—— 但子弹只往右飞，别改成双向。
// 灼烧弹：**按「发」计数，一律每 4n 发**（第 4/8/12…）。
// 1 转起：**每轮子弹数量 +1（2 发）** —— 原「灼烧频率翻倍」口径 2026-11-03 作废，改成加弹。
//   一拍两发 → 第 4 发落在**第 2 轮的第 2 发**（第 1 轮 = 第 1、2 发，第 2 轮 = 第 3、4 发）。
//   2026-11-04 用户口径：第二发**不在同一帧冒出**，要从发射点**晚一点**出来（第一发当帧出，后面的延迟出膛）。
// 灼烧区：该行第 9 格整格铺满，**存在 2 秒**，每秒一跳 100（共 200）；详见 obj_burn_cell。
//   2026-11-04 用户口径：火格**跟烤串那一发同帧铺**（延迟出膛的第二发就是烤串时，火格也一起延后），
//   不能再随「本轮第一发」提前出现 —— 铺法统一在 Create_0 的 bbq_spawn_burn_cell()。

// 🔧 可调参数（改这里就行，不用往下翻）
var _per_row   = (shape >= 1) ? 2 : 1;   // 每行每轮子弹数：0 转 1 发 / 1·2 转 2 发
var _shot_delay = 14;                    // 第二发比第一发**晚几帧**出膛（14 帧 ≈ 0.23s ≈ 75px 间距）
var _split_dx  = 0;                      // 同轮多发的 x 偏移；0 = 同一点出膛，间距只靠 _shot_delay 拉开
var _burn_every = 4;                     // 每几「发」出一颗爆辣烤串

var _shot_base = bbq_shot_count;
bbq_shot_count += _per_row;

// 上一轮如果还有没出膛的（正常不会，cycle 远大于延迟），先补发，别吞掉一发
if (array_length(bbq_pending) > 0)
{
    for (var _lp = 0; _lp < array_length(bbq_pending); _lp++)
    {
        var _lp_d = bbq_pending[_lp];
        var _lp_b = instance_create_depth(_lp_d.x, _lp_d.y, depth - 500, obj_bbq_bullet);
        _lp_b.damage = atk;
        _lp_b.row = _lp_d.row;
        _lp_b.burn_shot = _lp_d.burn;
        _lp_b.start_x = _lp_d.x;
        _lp_b.end_x = _lp_d.end_x;
        _lp_b.end_x_left = _lp_d.end_x_left;
        _lp_b.move_dir = 1;
        _lp_b.hittable_types = get_hittable_enemy_types(target_type);
        if (_lp_d.burn)
        {
            _lp_b.sprite_index = spr_bbq_bullet_burn;
            // 火格跟着**烤串本身**铺（2026-11-04 用户口径）
            bbq_spawn_burn_cell(_lp_d.row);
        }
    }
    bbq_pending = [];
    bbq_pending_timer = 0;
}

var _rows = (shape >= 2) ? [grid_row - 1, grid_row, grid_row + 1] : [grid_row];

// 🔴 贴图格线与逻辑网格不是同一原点：地图是静态背景图（obj_battle/Draw 直接 draw_sprite 到 0,0），
//   它画的格子缝比 global.grid_offset_y 那套网格高 36px（实测：格子行高两边都是 116，只是原点差 36）。
//   用户是按「看到的格子」判断位置的，所以串串的飞行高度和灼烧火格都往上抬 36 贴图格线对齐。要微调只改这一个数。
var _art_up = bbq_art_up;

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

    for (var _j = 0; _j < _per_row; _j++)
    {
        // 这一发的序号（按「发」数，跨轮累加）→ 每 _burn_every 发一颗烤串
        var _shot_no = _shot_base + _j + 1;
        var _burn = (_shot_no mod _burn_every == 0);

        // 出膛点：_split_dx = 0 时两发同一点；要微调可以给个几像素
        var _bx0 = _start_x + _j * _split_dx;

        if (_j == 0)
        {
            // 第一发：当帧出膛
            var inst = instance_create_depth(_bx0, _lane_y, depth - 500, obj_bbq_bullet);
            inst.damage = atk;
            inst.row = _row;
            inst.burn_shot = _burn;
            inst.start_x = _bx0;
            inst.end_x = _right_end;
            inst.end_x_left = _left_end;
            inst.move_dir = 1;
            inst.hittable_types = _hittable;
            if (_burn)
            {
                inst.sprite_index = spr_bbq_bullet_burn;
                // 🔴 火格跟着**烤串本身**铺：这一发就是烤串 → 当帧同步铺
                bbq_spawn_burn_cell(_row);
            }
        }
        else
        {
            // 后面的发：先记账，由 Step_0 倒计时 bbq_pending_timer 到点再创建
            //   （烤串落在这里时，火格也一起延后到补发那一帧，见 Step_0）
            array_push(bbq_pending, {
                row: _row, x: _bx0, y: _lane_y, burn: _burn,
                end_x: _right_end, end_x_left: _left_end
            });
        }
    }

    // 本轮有延迟发 → 交给 Step_0 倒计时（多行时一起到点，同一帧出膛）
    if (array_length(bbq_pending) > 0 && bbq_pending_timer <= 0) bbq_pending_timer = _shot_delay;
}

audio_play_sound(snd_shot, 0, 0);
