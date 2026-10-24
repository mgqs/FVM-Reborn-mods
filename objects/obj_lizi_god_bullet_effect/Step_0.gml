if (global.is_paused)
    exit;


timer++;

// 栗子子弹序列共 42 帧：1-8 飞行 / 9-17 爆炸 / 15 起火焰（落地特效）/ 18-38 火焰燃烧 / 39-42 燃烧结束
// 只有「深度爆炸波次」的子弹才播爆炸段（初融形态永远没有爆炸）；其余落地从火焰起始帧（第 15 帧）起播
// 灼烧只在燃烧帧内结算，每 0.2s 一次、共 10 次
var _total_frames = sprite_get_number(sprite_index);
var _boom_frame = 8;         // 第 9 帧：爆炸起始
var _flame_frame = 14;       // 第 15 帧：火焰开始出现（无爆炸落地特效的起播帧）
var _burn_from = 17;         // 第 18 帧：开始燃烧（灼烧结算起点）
var _burn_to = 37;           // 第 38 帧：燃烧结束
var _frame_speed = 5;        // 非燃烧帧速（tick / 帧）
var _burn_interval = 12;     // 灼烧间隔 0.2s
var _burn_ticks = _burn_interval * 10;                       // 燃烧段 120 tick = 2 秒
var _burn_frames = _burn_to - _burn_from + 1;                // 燃烧段 21 帧
var _start_frame = deep_boom ? _boom_frame : _flame_frame;   // 无爆炸时从火焰起始帧起播
var _pre_ticks = (_burn_from - _start_frame) * _frame_speed; // 爆炸段 45 tick / 火焰起始段 15 tick
var _total_time = _pre_ticks + _burn_ticks + (_total_frames - 1 - _burn_to) * _frame_speed;

// 帧推进：燃烧段把 21 帧摊满 2 秒，其余帧保持原速
if (timer <= _pre_ticks)
    image_index = _start_frame + (timer - 1) div _frame_speed;
else if (timer <= _pre_ticks + _burn_ticks)
    image_index = _burn_from + ((timer - _pre_ticks - 1) * _burn_frames) div _burn_ticks;
else
    image_index = _burn_to + 1 + (timer - _pre_ticks - _burn_ticks - 1) div _frame_speed;

if (image_index >= _total_frames)
    image_index = _total_frames - 1;

// 深度融合：特效从爆炸帧起播，开头即结算一次「深度爆炸伤害」点灰烬伤害
//（爆炸特效本来就在这条序列里，不额外加对象）
if (deep_boom && !deep_boom_done && image_index >= 8)
{
    deep_boom_done = true;
    with (obj_enemy_parent)
    {
        // 范围 3×3（col ±1 / row ±1），与落地灼烧 Other_10 同口径
        // 判定不设地图边界 → 落点在最右列时，col = grid_cols 那一列（地图外沿、同排排队的第 2 只）也在范围内
        if (hp > 0 && abs(grid_row - other.grid_row) <= 1 && abs(grid_col - other.grid_col) <= 1
            && can_hit(other.target_type, target_type))
        {
            if (immune_to_ash && hp > other.deep_boom_damage)
            {
                // 免疫灰烬的敌人只扣这一次伤害
                hp -= other.deep_boom_damage;
                event_user(0);
            }
            else
            {
                // 其余敌人直接化为灰烬
                if ((is_boss || string_pos("infected_", mouse_id) == 1) && special_ash)
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
}

// 灼烧：仅在燃烧帧区间内、每 0.2s 结算一次，共 10 次
var _burn_t = timer - _pre_ticks;
if (_burn_t >= 1 && _burn_t <= _burn_ticks
    && ((_burn_t - 1) div _burn_interval) != (_burn_t div _burn_interval))
    event_user(0);

if (timer > _total_time)
    instance_destroy();
