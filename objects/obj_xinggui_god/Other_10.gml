// obj_xinggui_god 用户事件 0（Other_10）：星轨神增幅查询。
// 调用约定（与音盒马 / 浮生茶完全一致）：
//   被增幅卡片先置 global.xinggui_mult = 1、global.xinggui_query_card = id，
//   再 with (obj_xinggui_god) event_user(0)；
//   每张存活且覆盖调用方的星轨神把自身倍率并入全局值，同类（含音盒马 / 浮生茶）取最高、不叠乘。
// 注意：event_user(0) 也在 Create 事件中被调用用于初始化；
//   当 global.xinggui_query_card 未设置时，委托父类完成属性初始化。
if (variable_instance_exists(id, "xinggui_initializing") && xinggui_initializing)
{
    event_inherited();
    return;
}
if (!variable_global_exists("xinggui_query_card") || !instance_exists(global.xinggui_query_card))
{
    event_inherited();
    return;
}
if (hp <= 0) exit;

var _c = global.xinggui_query_card;
if (get_plant_upgrade(_c.plant_id, 0, 0) == undefined) exit;

// 仅对「直射类 / 固定轨迹类」卡片生效（分类来自 card_buff_category 模块）
if (!card_in_category(_c.plant_id, "固定轨迹类")) exit;

// ── 覆盖范围：终转且场上 >= 4 张星轨神 → 全屏；否则 5*5 ──────────────
var _n_all = 0;      // 场上存活的星轨神总数（终转全屏条件）
var _n_high = 0;     // 其中四转 / 终转的数量（叠层条件）
with (obj_xinggui_god)
{
    if (hp > 0 && grid_col >= 0 && grid_col < global.grid_cols
        && grid_row >= 0 && grid_row < global.grid_rows)
    {
        _n_all++;
        if (shape >= 2) _n_high++;
    }
}

var _in_range = (shape >= 3 && _n_all >= xg_fullscreen_need);
if (!_in_range)
{
    var _r = xg_range;
    _in_range = (abs(grid_col - _c.grid_col) <= _r && abs(grid_row - _c.grid_row) <= _r);
}
if (!_in_range) exit;

// ── 倍率：注册表 atk 直接就是倍率（1.7 … 9 / 终转 3.2 … 10.5）──────────
var _d = get_plant_data_with_skill(plant_id, shape, current_level, skill);
if (_d == undefined) exit;

var _v = _d[? "atk"];

// 四转 / 终转：每多 1 张四转以上星轨神 +0.7，上限 +2.1
if (shape >= 2 && _n_high > 1)
{
    var _bonus = xg_stack_step * min(_n_high - 1, 3);
    if (_bonus > xg_stack_cap) _bonus = xg_stack_cap;
    _v += _bonus;
}

if (_v > global.xinggui_mult) global.xinggui_mult = _v;
