/// 索敌 / 命中判定的公共入口。
///
/// 🔴 2026-11-17 **行桶已彻底移除**（原 combat_targets_state / begin_step / invalidate / row 全删）。
///   行桶存的是「本 step 首次查询那一瞬间的实例 id 快照」，建好之后同一 step 里被打死的敌人、
///   或被对象池 instance_change(obj_pool_holder) 换走的尸体，id 仍留在数组里；
///   `instance_exists` 对这种「同 step 内刚失效」的 id 仍可能返回 true（它只保证跨 step 的死 id 为 false），
///   于是 combat_target_alive 放行 → 紧跟的 `with (死 id)` 直接抛：
///       Unable to find instance for object index 103546 / 100203
///   且行号报 -1（崩在原生 with 解析 id 那一步），看上去像崩在函数入口。
///   现在所有查询都直扫活实例（`with (obj_enemy_parent)` / `with (obj_card_parent)`）：
///   引擎只枚举活实例，构造上不可能取到死 id；遍历顺序仍是原生 with 顺序，
///   等距优先 / 每层最后一张卡 / 啃食优先级 4 档的规则与旧行桶完全一致。
///   代价只有每个调用点每帧 O(场上敌人数 或 卡片数)，与 d6ae7a5b7d 重构前相同。

/// 行赋值入口。行桶移除后本函数只回写 row —— 保留名字是为了不动那 20 处调用点
/// （card_created / get_grid_position_from_world / obj_card_parent / cat_chest / cat_box /
///   面粉袋 / 傀儡马假身 / 孟婆传送 / 椰子 / 马里奥洞穴 / 平台 / 万辟龙 / hex_hooks）。
function combat_targets_row_value(_inst, _row) {
    return _row;
}

/// 实例是否仍然「可选」。
/// 注意：它挡不住「同一 step 内刚销毁 / 刚被对象池换走」的 id（见文件头），
/// 所以**不要**用它给带 `with (缓存 id)` 的查询兜底——查询一律直扫活实例。
/// 现在它只服务于按 id 逐个校验的场景（如 obj_houyi_god 的多行扫描、子弹的跨帧目标）。
function combat_target_alive(_inst) {
    if (!instance_exists(_inst)) return false;
    if (object_exists(_inst)) return false;
    // 对象池回收后用 instance_change(obj_pool_holder) 换掉对象：id 不销毁、
    // grid_row / target_type / hp 这些变量全都留着，前两条判据会放行。
    if (_inst.object_index == obj_pool_holder) return false;
    return true;
}

/// These queries deliberately do not add an hp check: legacy cards which can
/// start their animation against dying enemies must retain that behaviour.
function combat_enemy_in_rows(_card, _first_row, _last_row, _first_col, _last_col, _type) {
    with (obj_enemy_parent) {
        if (grid_row < _first_row || grid_row > _last_row) continue;
        if (grid_col < _first_col || grid_col > _last_col) continue;
        if (!can_target_on(_type, target_type)) continue;
        if (instance_exists(_card)) _card.combat_row_target = id;
        return true;
    }
    if (instance_exists(_card)) _card.combat_row_target = noone;
    return false;
}

function combat_enemy_nearest_in_row(_card, _type) {
    if (!instance_exists(_card)) return noone;
    var _row = _card.grid_row;
    var _col = _card.grid_col;
    var _last_col = global.grid_cols + 1;
    var _best = noone;
    var _distance = 10000;
    with (obj_enemy_parent) {
        if (grid_row != _row) continue;
        if (grid_col < _col || grid_col > _last_col) continue;
        if (!can_target_on(_type, target_type)) continue;
        var _delta = grid_col - _col;
        if (_delta < _distance) { _distance = _delta; _best = id; }
    }
    return _best;
}

function combat_enemy_find_plant(_enemy) {
    var _order = [noone, noone, noone, noone];
    var _ladder_hosts = [];
    if (_enemy.can_use_ladder) with (obj_ladder) array_push(_ladder_hosts, host_plant);
    with (obj_card_parent) {
        if (grid_row != _enemy.grid_row) continue;
        if (_enemy.mouse_id == "longyuan_gaoqiao" && plant_id != "chocolate_bread"
            && plant_id != "pineapple_explosive_bread" && plant_id != "mianbao"
            && plant_id != "lightning_baguette") continue;
        var _dx = x - _enemy.x;
        var _in_front = _enemy.attack_range > 0 ? (_dx < 0 && _dx > -_enemy.attack_range)
            : (_dx > 0 && _dx < -_enemy.attack_range);
        if (!_in_front || (feature_type == "dwarf" && !_enemy.giant_type)
            || array_contains(_ladder_hosts, id)) continue;
        var _priority = ds_list_find_index(global.eat_order, plant_type);
        if (_priority >= 0 && _priority < 4) _order[_priority] = id;
    }
    for (var _i = 0; _i < 4; _i++) if (_order[_i] != noone) return _order[_i];
    return noone;
}
