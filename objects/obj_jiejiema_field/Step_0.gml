// obj_jiejiema_field Step 事件
// 每帧：领队校验 → 同步参数 → 重算格集 → 按 cycle 结算一次伤害。
//
// 🔴 伤害不写进各只马，只写在这里：一块结界就是一个整体，
//    多写一份就会出现「三只马叠三份伤害」。谁当领队由 obj_jiejiema 选举产生。
if (global.is_paused)
    exit;

// ── 领队必须在场 ─────────────────────────────────────────────────────────
if (!instance_exists(jj_owner) || jj_owner.hp <= 0 || jj_owner.jj_field != id)
{
    instance_destroy();
    exit;
}

// ── 参数同步（星级强化 / 技能 / 词条改 atk 都能即时吃到）────────────────
jj_atk       = jj_owner.atk;
jj_cycle     = max(1, round(jj_owner.cycle));
jj_use_mult  = jj_owner.jj_use_mult;
jj_mult      = jj_owner.jj_mult;
jj_mult_tail = jj_owner.jj_mult_tail;
jj_can_hit_types = jj_owner.jj_can_hit_types;

// ── 收集全部马的格子 ─────────────────────────────────────────────────────
var _cols = [];
var _rows = [];
var _sx = 0;
var _sy = 0;
with (obj_jiejiema)
{
    if (hp > 0)
    {
        array_push(_cols, grid_col);
        array_push(_rows, grid_row);
        _sx += x;
        _sy += y;
    }
}
jj_count = array_length(_cols);
if (jj_count <= 0)
{
    instance_destroy();
    exit;
}

var _geo = jiejiema_cells_of(_cols, _rows);

// 成形方式变了（加了一只 / 铲了一只 / 挪了格）→ 刷新计数 +1，逐次递增计数跟着清零
if (!jiejiema_cells_equal(jj_cells, _geo.cells))
    jj_refresh++;
jj_cells = _geo.cells;
jj_verts = _geo.verts;
jj_edges = _geo.edges;
jj_mode  = _geo.mode;

x = _sx / jj_count;
y = _sy / jj_count;

// ── 图层：压在卡片之下（2026-11-18 用户口径）─────────────────────────────
//   卡片 depth = -10 - row*45 - col*5 - 层偏移（scripts/card_depth），越靠后（row 小）值越大。
//   取场上最上一行的行基准 -10 - row_min*45，再 +1：
//     ① +1 让「同格 gridless 卡」不会和特效同深度（相等深度时的绘制顺序未定义）；
//     ② 这个值仍远小于 obj_battle 的 +50，所以不会掉到地图背景后面。
//   与 obj_bbq 的地面火同一套口径（obj_bbq/Create_0:102 用 -10 - row*45）。
var _row_min = _rows[0];
for (var _ri = 1; _ri < jj_count; _ri++)
{
    if (_rows[_ri] < _row_min) _row_min = _rows[_ri];
}
depth = -10 - _row_min * 45 + 1;

// ── 伤害结算 ─────────────────────────────────────────────────────────────
jj_anim++;
jj_hit_timer--;
if (jj_hit_timer > 0)
    exit;

jj_hit_timer = jj_cycle;

// 结界结算的这一帧，让场上所有马播一遍「技能」动画（素材 21/24 帧里带的施法段）。
// 守 jj_skill_timer：老存档里已在场的实例没有这个字段，直接写会抛变量未设置。
with (obj_jiejiema)
{
    if (hp > 0 && variable_instance_exists(id, "jj_skill_timer"))
        jj_skill_timer = max(jj_skill_timer, attack_anim * flash_speed);
}

var _atk       = jj_atk;
var _use_mult  = jj_use_mult;
var _mult_tab  = jj_mult;
var _mult_tail = jj_mult_tail;
var _types     = jj_can_hit_types;
var _ref       = jj_refresh;
var _cells     = jj_cells;
var _ncells    = array_length(_cells);

with (obj_enemy_parent)
{
    // 自制敌人有没写 target_type / grid_row 的，直接读是硬崩，先守字段
    if (!variable_instance_exists(id, "hp")
        || !variable_instance_exists(id, "grid_col")
        || !variable_instance_exists(id, "grid_row")
        || !variable_instance_exists(id, "target_type"))
        continue;
    if (hp <= 0) continue;

    // 卡面「攻击内部空、陆、地鼠军」
    if (array_get_index(_types, target_type) == -1) continue;

    // 在不在格集里
    var _in = false;
    for (var _k = 0; _k < _ncells; _k++)
    {
        if (_cells[_k].col == grid_col && _cells[_k].row == grid_row) { _in = true; break; }
    }
    if (!_in) continue;

    // 同一只老鼠的逐次递增：结界重新成形（jj_refresh 变了）就清零
    if (!variable_instance_exists(id, "jj_stage") || !variable_instance_exists(id, "jj_stage_ref")
        || jj_stage_ref != _ref)
    {
        jj_stage = 0;
        jj_stage_ref = _ref;
    }
    var _mult = 1;
    if (_use_mult)
        _mult = (jj_stage < 7) ? _mult_tab[jj_stage] : _mult_tail;
    jj_stage++;

    // 秒杀不防爆非精英鼠；防爆鼠与 BOSS 吃「攻击力 × 倍率」
    var _burst_proof = variable_instance_exists(id, "immune_to_ash") && immune_to_ash;
    var _elite       = variable_instance_exists(id, "is_boss") && is_boss;

    if (!_burst_proof && !_elite)
    {
        // 直接把血打空，交给 obj_enemy_parent/Step_0:428 的死亡分支收尾
        // （绕过去的话 hex_on_kill / hex_try_drop 全丢，见 MISTAKES B18）
        hp = 0;
        flash_value = 255;
    }
    else
    {
        damage_amount = round(_atk * _mult);
        damage_type = "normal";
        event_user(0);
    }
}
