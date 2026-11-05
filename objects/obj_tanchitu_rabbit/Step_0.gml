if (global.is_paused) exit;

y += move_speed;
life++;
image_index = (life div 4) mod sprite_get_number(sprite_index);

if (variable_global_exists("enemy_by_type") && precise_bbox_prepare(id)){
    // 🔴 2026-11-06 修「_al not set」：precise_bbox_prepare 的结果在 global._pbc_* 里，
    //    是**本实例（兔子）**的碰撞框；下面 with 里 self 变成老鼠，`other` 才是兔子。
    //    原来写成 `var _al = ...`（局部变量）再用 `other._al` 读 → 局部变量不在实例上，直接报错。
    //    这里改成挂到实例变量 pbc_* 上，with 里用 other.pbc_* 读。
    pbc_l = global._pbc_l;
    pbc_r = global._pbc_r;
    pbc_t = global._pbc_t;
    pbc_b = global._pbc_b;
    with (obj_enemy_parent){
        if (hp <= 0) continue;
        if (grid_col != other.grid_col) continue;
        if (ds_list_find_index(other.hitted, id) != -1) continue;
        if (bbox_right < other.pbc_l || bbox_left > other.pbc_r || bbox_bottom < other.pbc_t || bbox_top > other.pbc_b) continue;
        ds_list_add(other.hitted, id);
        damage_amount = other.damage;
        damage_type = "ash";
        event_user(0);
    }
}

if (y > bottom_y) instance_destroy();
