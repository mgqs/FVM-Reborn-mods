// 用户事件0：音乐增幅查询。
// 被增幅卡片先置 global.zodiac_music_mult = 1、global.zodiac_query_card = id，
// 再 with(obj_yinhema) event_user(0)；
// 每个存活且处于调用方光环范围内的音盒马，把自身攻击力倍率并入该全局值（同类取最高）。
// 注意：event_user(0) 也在 Create 事件中被调用用于初始化；
// 当 global.zodiac_query_card 未设置时，委托父类完成属性初始化。
if (!variable_global_exists("zodiac_query_card") || !instance_exists(global.zodiac_query_card)) {
    event_inherited();
    return;
}
if (hp <= 0) exit;
var _c = global.zodiac_query_card;
if (get_plant_upgrade(_c.plant_id,0,0) == undefined) exit;
// 仅对指定卡片生效：迷你披萨炉、赖皮蛇、工匠神、炎凰马、炎帝
// 按 plant_id 匹配，避免名称随转职变化导致匹配失败
var _ids = ["pizza_oven","laipishe","gongjiang_god","yanhuangma","shennong_god"];
var _ok = false;
for (var _i = 0; _i < array_length(_ids); _i++) {
    if (_c.plant_id == _ids[_i]) {_ok = true; break;}
}
if (!_ok) exit;
var _r = shape == 0 ? 1 : 2; // 0转3×3，1/2转5×5
if (abs(grid_col-_c.grid_col) <= _r && abs(grid_row-_c.grid_row) <= _r) {
    var _d = get_plant_data_with_skill(plant_id,shape,current_level,skill);
    if (_d != undefined) global.zodiac_music_mult = max(global.zodiac_music_mult,_d[? "atk"]);
}
