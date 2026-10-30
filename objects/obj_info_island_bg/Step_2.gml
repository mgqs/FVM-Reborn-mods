if (instance_exists(obj_player_info_ui))
    obj_player_info_ui.menu_type = 4
if (instance_exists(obj_world_map_button))
    obj_world_map_button.world_map = 2
if (!ui_anim_on(1)) {
    pnl_o = 1
    pnl_t = pnl_closing ? pnl_close_time : pnl_open_time
    for (var _gi = 0; _gi < array_length(anim_kids); _gi++) {
        var _gc = anim_kids[_gi][0]
        if (instance_exists(_gc)) { _gc.x = _gc.anim_base_x; _gc.image_alpha = 1 }
    }
    with (obj_info_island_edit_menu) { image_alpha = 1 }
    with (obj_info_island_edit_menu_btn) { image_alpha = 1 }
    with (obj_info_island_card_edit_select_btn) { image_alpha = 1 }
    if (pnl_closing) instance_destroy()
    exit
}
if (!variable_instance_exists(id, "tab_fade")) { tab_fade = 1; tab_fade_t = -1; tab_shown = info_button_select }
panel_anim_step(id, false)
var _shift = (1 - pnl_o) * anim_slide
for (var _i = 0; _i < array_length(anim_kids); _i++) {
    var _c = anim_kids[_i][0]
    if (instance_exists(_c)) {
        _c.x = _c.anim_base_x + anim_kids[_i][1] * _shift
        _c.pnl_po = pnl_o
        _c.image_alpha = pnl_o
    }
}
with (obj_info_island_edit_menu) { pnl_po = other.pnl_o; image_alpha = other.pnl_o }
with (obj_info_island_edit_menu_btn) { pnl_po = other.pnl_o; image_alpha = other.pnl_o }
with (obj_info_island_card_edit_select_btn) { pnl_po = other.pnl_o; image_alpha = other.pnl_o }
