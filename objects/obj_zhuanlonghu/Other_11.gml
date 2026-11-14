// obj_zhuanlonghu 用户事件 1：把范围内正在冷却的实体卡，冷却条往前推「总冷却 × 缩减比例」
//   判定口径同计时器：`cooldown_timer < cooldown` 才算“正在冷却”

var _mc = grid_col;
var _mr = grid_row;
var _rc = zl_range_col;
var _rr = zl_range_row;

var _ids = ds_list_create();
with (obj_card_parent){
    if (card_cd_target_ok(plant_id)
        && abs(grid_col - _mc) <= _rc && abs(grid_row - _mr) <= _rr){
        if (ds_list_find_index(_ids, plant_id) == -1) ds_list_add(_ids, plant_id);
    }
}

with (obj_card_slot){
    if (cooldown_timer < cooldown && ds_list_find_index(_ids, card_id) != -1){
        var _cut = floor(cooldown * other.zl_reduce_ratio);
        cooldown_timer = min(cooldown, cooldown_timer + _cut);
    }
}

ds_list_destroy(_ids);
