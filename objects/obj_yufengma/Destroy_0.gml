if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
if (instance_exists(obj_battle) && (!variable_global_exists("game_over") || !global.game_over)
    && !(variable_instance_exists(id,"is_shoveled") && is_shoveled)) {
    if (shape >= 1) {
        // 死亡时吹飞全场非BOSS空中老鼠
        var yf_list = [];
        for (var yf_i = 0; yf_i < instance_number(obj_enemy_parent); yf_i++) {
            var yf_e = instance_find(obj_enemy_parent,yf_i);
            if (instance_exists(yf_e) && yf_e.hp > 0) array_push(yf_list,yf_e);
        }
        for (var yf_i = 0; yf_i < instance_number(obj_kuileima_decoy); yf_i++) {
            var yf_d = instance_find(obj_kuileima_decoy,yf_i);
            if (instance_exists(yf_d) && yf_d.hp > 0 && !array_contains(yf_list,yf_d)) array_push(yf_list,yf_d);
        }
        for (var i = 0; i < array_length(yf_list); i++) {
            var e = yf_list[i];
            if (e.target_type == "air" && !e.is_boss) {
                var effect = instance_create_depth(e.x,e.y,-3000,obj_mouse_blow_effect);
                effect.sprite_index = e.sprite_index;
                effect.image_index = e.image_index;
                effect.image_xscale = e.image_xscale;
                effect.image_yscale = e.image_yscale;
                e.is_blown_away = true;
                instance_destroy(e);
            }
        }
        var death_spr = spr_yufengma_bullet_big;
        if (shape == 1) death_spr = spr_yufengma_bullet_big_1;
        else if (shape >= 2) death_spr = spr_yufengma_bullet_big_2;
        var de = instance_create_depth(x,y,-3000,obj_zodiac_effect);
        de.sprite_index = death_spr;
        de.life = max(1,sprite_get_number(death_spr)*5);
        de.image_index = 0;
        de.image_speed = 0.5;
    }
}
event_inherited();
