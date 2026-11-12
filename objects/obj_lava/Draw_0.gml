draw_self()
// 海克斯「以我残躯化烈火 / 喷涌的地脉」会在空格子上刷岩浆。
// 原来的写法直接 ds_grid_get(global.grid_plants, col, row) 再 ds_list_size：
//   · 格子还没有卡片列表时 ds_grid_get 返回 undefined（不是空 ds_list）→
//     ds_list_size(undefined) 直接抛
//     「ds_list_size argument 1 incorrect type (undefined) expecting a ds_list」；
//   · 关卡收尾/切场景时 grid_plants 本身可能已经被销毁，同样崩。
// 老曙（BOSS）死亡时正是「大量空格同时刷岩浆」，所以最先在这里炸。
var _has_card = false
if (variable_global_exists("grid_plants") && !is_undefined(global.grid_plants)
    && ds_exists(global.grid_plants, ds_type_grid)) {
    var _gw = ds_grid_width(global.grid_plants)
    var _gh = ds_grid_height(global.grid_plants)
    if (col >= 0 && col < _gw && row >= 0 && row < _gh) {
        var _cell = ds_grid_get(global.grid_plants, col, row)
        if (ds_exists(_cell, ds_type_list) && ds_list_size(_cell) > 0) _has_card = true
    }
}
var grid_pos = get_world_position_from_grid(col,row)
if (!is_undefined(grid_pos) && (_has_card || has_mouse)){
	draw_sprite_ext(spr_lava_burn_effect,floor(timer/5),grid_pos.x,grid_pos.y+15,1.8,1.8,0,c_white,1)
}
