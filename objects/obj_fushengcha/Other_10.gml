// user event 0：浮生茶增幅查询。
// 调用约定（与音盒马一致）：
//   被增幅卡片先置 global.fushengcha_mult = 1、global.fushengcha_query_card = id，
//   再 with (obj_fushengcha) event_user(0)；
//   每张存活且覆盖调用方的浮生茶把自身倍率并入全局值，同类取最高（不叠加）。
// 注意：event_user(0) 也在 Create 中被调用用于初始化；
//       当 global.fushengcha_query_card 未设置时，委托父类完成属性初始化。
if (variable_instance_exists(id, "fushengcha_initializing") && fushengcha_initializing) {
    event_inherited();
    return;
}
if (!variable_global_exists("fushengcha_query_card") || !instance_exists(global.fushengcha_query_card)) {
    event_inherited();
    return;
}
if (hp <= 0) exit;

var _c = global.fushengcha_query_card;
if (get_plant_upgrade(_c.plant_id, 0, 0) == undefined) exit;

// 仅对「直射类 / 固定轨迹类」卡片生效（分类来自 docs/卡片分类.md，见 card_buff_category 模块）
if (!card_in_category(_c.plant_id, "固定轨迹类")) exit;

// 0转 3*3，1/2转 5*5
var _r = (shape == 0) ? 1 : 2;
if (abs(grid_col - _c.grid_col) <= _r && abs(grid_row - _c.grid_row) <= _r) {
    var _d = get_plant_data_with_skill(plant_id, shape, current_level, skill);
    if (_d != undefined) global.fushengcha_mult = max(global.fushengcha_mult, _d[? "atk"]);
}
