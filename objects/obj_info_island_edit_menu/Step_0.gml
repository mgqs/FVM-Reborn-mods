var _closing = variable_instance_exists(id, "pnl_closing") && pnl_closing
if (_closing && pop_p >= 1) {
    if (pop_back_p >= 1) { exit }
    var _cd = variable_instance_exists(id, "pnl_close_time") ? max(pnl_close_time, 0.01) : 0.14
    pop_back_t += ui_anim_dt()
    pop_back_p = clamp(pop_back_t / _cd, 0, 1)
    pop_s = lerp(1, pop_from, power(pop_back_p, 2))
} else if (pop_p < 1) {
    if (ui_anim_on(1)) {
        pop_t += ui_anim_dt()
        var _p = clamp(pop_t / max(pop_dur, 0.0001), 0, 1)
        var _c1 = 1.70158
        var _e = 1 + (_c1 + 1) * power(_p - 1, 3) + _c1 * power(_p - 1, 2)
        pop_s = lerp(pop_from, 1, _e)
        if (_p >= 1) { pop_p = 1 }
    } else {
        pop_p = 1
        pop_s = 1
    }
}

image_xscale = pop_base_s * pop_s
image_yscale = pop_base_s * pop_s
with (obj_info_island_card_edit_select_btn) {
    if (variable_instance_exists(id, "pop_bx")) {
        x = other.pop_mx + (pop_bx - other.pop_mx) * other.pop_s
        y = other.pop_my + (pop_by - other.pop_my) * other.pop_s
        image_xscale = pop_sx * other.pop_s
        image_yscale = pop_sx * other.pop_s
    }
}
with (obj_info_island_edit_menu_btn) {
    if (variable_instance_exists(id, "pop_bx")) {
        x = other.pop_mx + (pop_bx - other.pop_mx) * other.pop_s
        y = other.pop_my + (pop_by - other.pop_my) * other.pop_s
        image_xscale = pop_sx * other.pop_s
        image_yscale = pop_sx * other.pop_s
    }
}
