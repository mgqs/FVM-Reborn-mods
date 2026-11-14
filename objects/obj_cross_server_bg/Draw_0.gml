draw_set_alpha(1);
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
// 手动绘制精灵，保持1.8x视觉缩放（image_xscale/yscale设为10是为了全屏碰撞遮罩）
draw_sprite_ext(sprite_index, image_index, x, y, 1.8, 1.8, 0, c_white, 1);
draw_set_font(font_yuan);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text_ext_transformed(302, 55, string(level_passed), 25, 1920, 1.5, 1.5, 0);

// 远征章节页签：前 8 帧为未选中，后 8 帧为选中状态。
for (var _page = 0; _page < 8; _page++) {
    var _tab_x = x - 700 + _page * 200;
    var _tab_y = y - 420;
    var _tab_frame = (_page == selected_page) ? _page + 8 : _page;
    var _tab_enabled = ds_map_exists(global.maps_map, cross_server_page_map_ids[_page]);
    draw_sprite_ext(spr_mod_cs_level_choose, _tab_frame, _tab_x, _tab_y, 1.5, 1.5, 0, _tab_enabled ? c_white : c_gray, 1);
}

// 跨服商店入口覆盖在最右侧第 8 个页签位置，使用精灵第 8 帧。
var _shop_x = x + 700;
var _shop_y = y - 420;
draw_sprite_ext(spr_mod_cs_level_choose, 7, _shop_x, _shop_y, 1.5, 1.5, 0, c_white, 1);

if (!ds_map_exists(global.maps_map, cross_server_page_map_ids[selected_page])) {
    draw_set_font(font_yuan);
    draw_set_color(c_ltgray);
    draw_text(x, y - 255, "该章节的关卡内容尚未开放");
}

var _active_map_id = cross_server_page_map_ids[selected_page];
var _active_has_data = ds_map_exists(global.maps_map, _active_map_id);
var _active_levels = _active_has_data ? ds_map_find_value(global.maps_map, _active_map_id).levels_data : [];
var _active_level_count = array_length(_active_levels);
var level_name = [];
for (var _name_index = 0; _name_index < _active_level_count; _name_index++) {
    array_push(level_name, _active_levels[_name_index].name);
}
var k = 0;

// 关卡卡片图标：
//   梦魇天空 —— 专用 8 帧缩略图 spr_mod_cs_level_icon_nightmare，第 k 帧对应第 k 关；
//   灼热地域 —— 直接放地图底图 spr_zhuorediyu（只有 1 帧，等比缩到图标框大小；
//               该精灵 origin 在左上角，需要补一个半宽半高的偏移才能居中）；
//   水火之间 —— 底图 2 帧：_0 给 0~3 关、_1 给 4~7 关（循环内按 k 选图）；
//   巫毒研究所 —— 底图 8 帧 spr_wuduyanjiusuo_0..7，第 k 关用第 k 帧；
//   其它章节 —— 沿用通用图标（1 帧）。
var _icon_is_nightmare = (_active_map_id == "cross_server_nightmare_sky");
var _icon_is_zhuore = (_active_map_id == "cross_server_hot_hell");
var _icon_is_water_fire = (_active_map_id == "cross_server_water_fire");
var _icon_is_voodoo = (_active_map_id == "cross_server_voodoo_lab");
var _level_icon_spr = spr_mod_cs_level_icon;
var _level_icon_frame = 0;
var _level_icon_xs = 1.2;
var _level_icon_ys = 1.2;
var _level_icon_dx = 0;
var _level_icon_dy = 0;
if (_icon_is_nightmare){
    _level_icon_spr = spr_mod_cs_level_icon_nightmare;
}
else if (_icon_is_zhuore){
    _level_icon_spr = spr_zhuorediyu;
    _level_icon_xs = 1.2 * 108 / sprite_get_width(spr_zhuorediyu);   // 108 = 通用图标宽度，缩到同宽
    _level_icon_ys = _level_icon_xs;
    _level_icon_dx = -sprite_get_width(spr_zhuorediyu) * _level_icon_xs * 0.5;
    _level_icon_dy = -sprite_get_height(spr_zhuorediyu) * _level_icon_ys * 0.5;
}

for (var j = 0; j < 2; j++)
{
    for (var i = 0; i < 4; i++)
    {
        if (k >= _active_level_count) break;
        // 本关实际使用的图标（水火/巫毒按 k 换图换帧，其余章节用公共值）
        var _icon_use_spr = _level_icon_spr;
        var _icon_use_frame = _icon_is_nightmare ? k : _level_icon_frame;
        var _icon_use_xs = _level_icon_xs;
        var _icon_use_ys = _level_icon_ys;
        var _icon_use_dx = _level_icon_dx;
        var _icon_use_dy = _level_icon_dy;
        if (_icon_is_water_fire || _icon_is_voodoo){
            _icon_use_spr = _icon_is_water_fire
                ? (k < 4 ? spr_shuihuozhijian_0 : spr_shuihuozhijian_1)
                : (k >= 0 && k <= 7 ? asset_get_index("spr_wuduyanjiusuo_" + string(k)) : spr_mod_cs_level_icon);
            if (_icon_use_spr == -1) _icon_use_spr = spr_mod_cs_level_icon;
            _icon_use_frame = 0;
            _icon_use_xs = 1.2 * 108 / sprite_get_width(_icon_use_spr);
            _icon_use_ys = _icon_use_xs;
            _icon_use_dx = -sprite_get_width(_icon_use_spr) * _icon_use_xs * 0.5;
            _icon_use_dy = -sprite_get_height(_icon_use_spr) * _icon_use_ys * 0.5;
        }
        if (k >= level_unlocked)
        {
            draw_sprite_ext(spr_mod_cs_level, 0, (x - 608) + (405 * i), (y - 170) + (400 * j), 1.8, 1.8, 0, c_gray, 1);
            draw_sprite_ext(spr_mod_cs_silver_medal, 0, 256 + (405 * i), 328 + (400 * j), 2.3, 2.3, 0, c_gray, 1);
            draw_sprite_ext(spr_mod_cs_xunzhang, 0, 348 + (405 * i), 314 + (400 * j), 1.8, 1.8, 0, c_gray, 1);
            draw_set_font(font_hei);
            draw_set_color(c_black);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text_ext_transformed(233 + (405 * i), 202 + (400 * j), level_name[k], 25, 1920, 1, 1, 0);
            draw_sprite_ext(spr_star_slot, 7 + k, 508 + (405 * i), 204 + (400 * j), 1.8, 1.8, 0, c_gray, 1);
            draw_sprite_ext(_icon_use_spr, _icon_use_frame, (228 + (405 * i)) + _icon_use_dx, (478 + (400 * j)) + _icon_use_dy, _icon_use_xs, _icon_use_ys, 0, c_gray, 1);
            draw_set_alpha(1);
            draw_set_color(c_black);
            draw_roundrect((228 + (405 * i)) - 67, (478 + (400 * j)) - 67, 228 + (405 * i) + 65, 478 + (400 * j) + 65, true);
            draw_set_font(font_yuan);
            draw_set_color(c_ltgray);
            draw_text_ext_transformed(312 + (405 * i), 390 + (400 * j), "通过以下关卡后开启：", 25, 1920, 1.2, 1.2, 0);
            if (k > 0) {
                draw_set_font(font_hei);
                draw_set_color(c_black);
                draw_text_ext_transformed(412 + (405 * i), 422 + (400 * j), level_name[k - 1], 25, 1920, 1, 1, 0);
            }
        }
        else
        {
            draw_sprite_ext(spr_mod_cs_level, 0, (x - 608) + (405 * i), (y - 170) + (400 * j), 1.8, 1.8, 0, c_white, 1);
            draw_sprite_ext(spr_mod_cs_silver_medal, 0, 256 + (405 * i), 328 + (400 * j), 2.3, 2.3, 0, c_white, 1);
            draw_sprite_ext(spr_mod_cs_xunzhang, 0, 348 + (405 * i), 314 + (400 * j), 1.8, 1.8, 0, c_white, 1);
            draw_set_font(font_hei);
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text_ext_transformed(233 + (405 * i), 202 + (400 * j), level_name[k], 25, 1920, 1, 1, 0);
            draw_sprite_ext(spr_star_slot, 7 + k, 508 + (405 * i), 204 + (400 * j), 1.8, 1.8, 0, c_white, 1);
            draw_sprite_ext(_icon_use_spr, _icon_use_frame, (228 + (405 * i)) + _icon_use_dx, (478 + (400 * j)) + _icon_use_dy, _icon_use_xs, _icon_use_ys, 0, c_white, 1);
            draw_set_alpha(1);
            draw_set_color(c_dkgray);
            draw_roundrect((228 + (405 * i)) - 67, (478 + (400 * j)) - 67, 228 + (405 * i) + 65, 478 + (400 * j) + 65, true);
        }
        
        k++;
    }
}
