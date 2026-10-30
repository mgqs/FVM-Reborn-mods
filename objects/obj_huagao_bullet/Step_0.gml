if (global.is_paused) exit;

life++;
if (vertical) y += huagao_speed;
else x += dir * huagao_speed;

// ---------- 命中判定 ----------
// 只打已显形陆军（target_type == "normal"）：未显形幽灵(invisible)、非主流(dance)、
// 地下(underground)、空中(air)、障碍(obstacle)、潜水(diver) 一律不吃伤害。
for (var _i = 0; _i < instance_number(obj_enemy_parent); _i++) {
    var _e = instance_find(obj_enemy_parent, _i);
    if (!instance_exists(_e) || _e.hp <= 0) continue;
    if (_e.target_type != "normal") continue;
    if (array_contains(hit_ids, _e.id)) continue;
    // 同一次攻击的多条魂虫（左右对向 / 二转加条）只由先到的一条结算，
    // 否则横扫全场会让同一只敌人被打 2~3 次，伤害与数值表对不上。
    if (attack_tag != 0
        && variable_instance_exists(_e, "huagao_attack_tag")
        && _e.huagao_attack_tag == attack_tag) continue;

    if (vertical) {
        if (!array_contains(cols, _e.grid_col)) continue;
        if (abs(_e.y - y) > global.grid_cell_size_y * 0.5 + 8) continue;
    } else {
        if (!array_contains(rows, _e.grid_row)) continue;
        if (abs(_e.x - x) > 26) continue;
    }

    // 中路 2/2/4 次、上下路 1/1/2 次；竖向魂虫每只敌人 1 次
    var _need = vertical ? 1 : ((_e.grid_row == mid_row) ? hits_mid : hits_side);
    array_push(hit_ids, _e.id);
    if (attack_tag != 0) variable_instance_set(_e, "huagao_attack_tag", attack_tag);
    for (var _k = 0; _k < _need; _k++) {
        if (!instance_exists(_e) || _e.hp <= 0) break;
        huagao_hit_enemy(_e, damage, owner_id);
    }
}

// ---------- 出界回收 ----------
// 右边界用战斗域右沿（含第 10 列），否则向左飞的魂虫飞不到场外那一列
var _field_left = combat_left_x();
var _field_right = combat_right_x();
var _field_bottom = global.grid_offset_y + global.grid_rows * global.grid_cell_size_y;
if (vertical) {
    if (y > _field_bottom + 60) { instance_destroy(); exit; }
} else {
    if (x < _field_left - 80 || x > _field_right + 80) { instance_destroy(); exit; }
}
if (life > 480) instance_destroy();
