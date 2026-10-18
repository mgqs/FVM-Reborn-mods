if (global.is_paused) exit;
var _old_x = x;
x -= 6;
life++;
image_index = floor(life * 10 / game_get_speed(gamespeed_fps)) mod 9;

// 先拆连通米线桥（同段接触即破坏桥体，梭子继续）
var _bridge = longyuan_bridge_contact(x, y, _old_x, y, lane);
if (instance_exists(_bridge)) { _bridge.hp = 0; with (_bridge) event_user(2); }

// 本帧扫过的列区间（含判定余量 ±15），数据源用 global.grid_plants，
// 与 ly_damage_col / longyuan_web_make 一致，避免直接遍历 obj_card_parent
// 时因卡片原点/同格多卡导致漏判。
var _col0 = clamp(floor((min(x, _old_x) - 15 - global.grid_offset_x) / global.grid_cell_size_x), 0, global.grid_cols - 1);
var _col1 = clamp(floor((max(x, _old_x) + 15 - global.grid_offset_x) / global.grid_cell_size_x), 0, global.grid_cols - 1);
for (var _c = _col0; _c <= _col1; ++_c) {
    var _list = ds_grid_get(global.grid_plants, _c, lane);
    for (var _i = 0; _i < ds_list_size(_list); ++_i) {
        var _card = _list[| _i];
        if (!instance_exists(_card) || _card.hp <= 0) continue;
        if (_card.plant_id == "player" || _card.plant_type == "coffee") continue;
        // 阻挡者（火盆等）优先判定：碰到即销毁梭子，同格其他卡不受伤
        if (_card.plant_id == "brazier"
            || (variable_instance_exists(_card, "blocks_longyuan_shuttle") && _card.blocks_longyuan_shuttle)) {
            instance_destroy();
            exit;
        }
        if (_card.invincible || array_get_index(hit_cards, _card) != -1) continue;
        array_push(hit_cards, _card);
        longyuan_damage_plant(_card, damage);
    }
}

if (life > 600 || x < global.grid_offset_x - 100) instance_destroy();
