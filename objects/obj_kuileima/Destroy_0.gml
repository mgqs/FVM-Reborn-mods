// 销毁巫毒代理与常驻光环特效
if (instance_exists(zodiac_decoy)) instance_destroy(zodiac_decoy);
for (var i = 0; i < array_length(zodiac_effects); i++) if (instance_exists(zodiac_effects[i])) instance_destroy(zodiac_effects[i]);
if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
// 战斗结束后不再结算死亡爆炸
if (!instance_exists(obj_battle) || (variable_global_exists("game_over") && global.game_over)) {event_inherited(); exit;}
if (shape >= 1) {
    // 死亡或铲除都播放完整特效动画：形态1用effect2_2，形态2用effect3_1，均为7×7范围拉伸
    var death_spr = spr_kuileima_effect3_1;
    if (shape == 1) death_spr = spr_kuileima_effect2_2;
    var _death_effect = instance_create_depth(x,y,-3000,obj_zodiac_effect);
    _death_effect.sprite_index = death_spr;
    _death_effect.life = max(1,sprite_get_number(death_spr)*5);
    _death_effect.image_index = 0;
    _death_effect.image_speed = 0.5;
    _death_effect.image_xscale = 7*global.grid_cell_size_x/sprite_get_width(death_spr);
    _death_effect.image_yscale = 7*global.grid_cell_size_y/sprite_get_height(death_spr);
    // 枚举7×7范围内全部存活老鼠（含傀儡马代理），造成900灰烬伤害
    var ke_list = [];
    for (var ke_i = 0; ke_i < instance_number(obj_enemy_parent); ke_i++) {
        var ke_e = instance_find(obj_enemy_parent,ke_i);
        if (instance_exists(ke_e) && ke_e.hp > 0) array_push(ke_list,ke_e);
    }
    for (var ke_i = 0; ke_i < instance_number(obj_kuileima_decoy); ke_i++) {
        var ke_d = instance_find(obj_kuileima_decoy,ke_i);
        if (instance_exists(ke_d) && ke_d.hp > 0 && !array_contains(ke_list,ke_d)) array_push(ke_list,ke_d);
    }
    for (var i = 0; i < array_length(ke_list); i++) {
        var e = ke_list[i], g = get_grid_position_from_world(e.x,e.y);
        if (abs(g.col-grid_col) <= 3 && abs(g.row-grid_row) <= 3 && instance_exists(e) && e.hp > 0) {
            var kh_dmg = 900;
            with (e) {
                damage_amount = kh_dmg;
                damage_type = "ash";
                event_user(0);
                if (hp <= 0 && !immune_to_ash) {
                    ash_death = true;
                    if (special_ash) {
                        var ash_inst = instance_create_depth(x,y-20,depth,obj_mouse_ash_death);
                        ash_inst.special_ash = true;
                        ash_inst.sprite_index = sprite_index;
                        ash_inst.image_index = image_index;
                    } else {
                        instance_create_depth(x,y-20,depth,obj_mouse_ash_death);
                    }
                    instance_destroy();
                }
            }
        }
    }
}
event_inherited();
