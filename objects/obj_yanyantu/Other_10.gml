// 用户事件0：火苗增幅查询。
// 产火卡片先置 global.zodiac_flame_mult = 1、global.zodiac_query_card = id，
// 再 with(obj_yanyantu) event_user(0)；
// 每个存活且处于调用方光环范围内的炎焱兔，把自身攻击力倍率并入该全局值（同类取最高）。
// 注意：event_user(0) 也在 Create 事件中被调用用于初始化；
// 当 global.zodiac_query_card 未设置时，委托父类完成属性初始化。
if (!variable_global_exists("zodiac_query_card") || !instance_exists(global.zodiac_query_card)) {
    event_inherited();
    return;
}
if (hp <= 0) exit;
var _c = global.zodiac_query_card;
if (get_plant_upgrade(_c.plant_id,0,0) == undefined) exit;
// 仅对指定产火卡片生效：太阳神/双子座按 plant_id 直判，其余按名称匹配
if (_c.plant_id != "sun_god" && _c.plant_id != "shuangzi") {
    var _pd = get_plant_shape_data(_c.plant_id,0);
    if (_pd == undefined) exit;
    var _n = _pd[? "name"];
    var _names = ["小火炉","大火炉","酒杯灯","双子座","太阳神","暖暖鸡","咕咕鸡","火焰牛","7周年蜡烛","生日帽","守能汪","喵喵炉","扑克牌护罩"];
    var _ok = false;
    for (var _i = 0; _i < array_length(_names); _i++) {
        if (_n == _names[_i] || string_pos(_names[_i],_n) > 0) {_ok = true; break;}
    }
    if (!_ok) exit;
}
var _r = shape == 2 ? 2 : 1; // 0/1转3×3，2转5×5
if (abs(grid_col-_c.grid_col) <= _r && abs(grid_row-_c.grid_row) <= _r) {
    var _d = get_plant_data_with_skill(plant_id,shape,current_level,skill);
    if (_d != undefined) global.zodiac_flame_mult = max(global.zodiac_flame_mult,_d[? "atk"]);
}
