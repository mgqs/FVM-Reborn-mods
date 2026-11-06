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
        // 跨服远征的 BOSS 不参与冲撞（同白羊座 obj_baiyang_effect）
        if (is_boss && global.map_name == "跨服远征") continue;
        ds_list_add(other.hitted, id);

        // 🔴 2026-11-06 用户口径：冲撞型就该像白羊座那样**把老鼠撞飞**，不是扣血。
        //   白羊座（obj_baiyang_effect）的口径：魂系鼠 / BOSS 撞不飞 → 只扣 atk；
        //   其余一律「撞飞特效（obj_knock_back_effect）+ 本体直接销毁」，全程不扣血。
        if (crash_immune_enemy(id)){
            // 撞不飞的（魂系 / BOSS）只吃伤害：**照白羊座 obj_baiyang_effect 直接扣血**
            //   🔴 不能用 damage_type = "ash"：龙渊魂体会把 ash 伤害整额退还（hp += damage_amount），
            //      结果是「撞不飞的鼠一点血都不掉」，跟卡面「造成{攻击力}点伤害」对不上。
            hp -= other.damage;
            event_user(0);
        }
        else{
            var _fx = instance_create_depth(x, y, depth, obj_knock_back_effect);
            _fx.sprite_index = sprite_index;
            _fx.image_index = image_index;
            instance_destroy();
        }
    }
}

if (y > bottom_y) instance_destroy();
