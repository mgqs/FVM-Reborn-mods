// 用户事件0：音乐增幅查询。
// 被增幅卡片先置 global.zodiac_music_mult = 1、global.zodiac_query_card = id，
// 再 with(obj_yinhema) event_user(0)；
// 每个存活且处于调用方光环范围内的音盒马，把自身攻击力倍率并入该全局值（同类取最高）。
if (hp <= 0) exit;
var _c = global.zodiac_query_card;
if (!instance_exists(_c)) exit;
if (get_plant_upgrade(_c.plant_id,0,0) == undefined) exit;
// 仅对指定卡片生效：迷你披萨炉、赖皮蛇、工匠神、炎凰马、炎帝
var _pd = get_plant_shape_data(_c.plant_id,0);
if (_pd == undefined) exit;
var _n = _pd[? "name"];
var _names = ["迷你披萨炉","赖皮蛇","工匠神","炎凰马","炎帝"];
var _ok = false;
for (var _i = 0; _i < array_length(_names); _i++) {
    if (_n == _names[_i] || string_pos(_names[_i],_n) > 0) {_ok = true; break;}
}
if (!_ok) exit;
var _r = shape == 0 ? 1 : 2; // 0转3×3，1/2转5×5
if (abs(grid_col-_c.grid_col) <= _r && abs(grid_row-_c.grid_row) <= _r) {
    var _d = get_plant_data_with_skill(plant_id,shape,current_level,skill);
    if (_d != undefined) global.zodiac_music_mult = max(global.zodiac_music_mult,_d[? "atk"]);
}
