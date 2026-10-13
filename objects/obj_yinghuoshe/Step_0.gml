if (global.is_paused) exit;
event_inherited();
if (hp <= 0) exit;

zodiac_age++;

if (is_frozen || state == CARD_STATE.SLEEP) exit;

// 枚举全场存活老鼠（含傀儡马代理）
// 老鼠首次进入自身3×3范围时造成一次伤害（每个目标只结算一次）
var yh1_list = [];
for (var yh_i = 0; yh_i < instance_number(obj_enemy_parent); yh_i++) {
    var yh_e = instance_find(obj_enemy_parent,yh_i);
    if (instance_exists(yh_e) && yh_e.hp > 0) array_push(yh1_list,yh_e);
}
for (var yh_i = 0; yh_i < instance_number(obj_kuileima_decoy); yh_i++) {
    var yh_d = instance_find(obj_kuileima_decoy,yh_i);
    if (instance_exists(yh_d) && yh_d.hp > 0 && !array_contains(yh1_list,yh_d)) array_push(yh1_list,yh_d);
}
var radius = 1;
for (var i = 0; i < array_length(yh1_list); i++) {
    var e = yh1_list[i];
    if (e.target_type == "underground" || e.target_type == "non_mainstream"
        || e.target_type == "ghost" || e.target_type == "invisible") continue;
    if (array_contains(zodiac_firefly_hit_ids,e.id)) continue;
    var eg = get_grid_position_from_world(e.x,e.y);
    if (abs(eg.col-grid_col) <= radius && abs(eg.row-grid_row) <= radius) {
        array_push(zodiac_firefly_hit_ids,e.id);
        var yhs_dmg = atk;
        with (e) {
            damage_amount = yhs_dmg;
            damage_type = "pierce";
            event_user(0);
        }
    }
}

var interval = cycle;
// 待机且无累计周期时，范围内已有目标则立即进入攻击计时
if (state == CARD_STATE.IDLE && zodiac_timer == 0) {
    var yh2_list = [];
    for (var yh2_i = 0; yh2_i < instance_number(obj_enemy_parent); yh2_i++) {
        var yh2_e = instance_find(obj_enemy_parent,yh2_i);
        if (instance_exists(yh2_e) && yh2_e.hp > 0) array_push(yh2_list,yh2_e);
    }
    for (var yh2_i = 0; yh2_i < instance_number(obj_kuileima_decoy); yh2_i++) {
        var yh2_d = instance_find(obj_kuileima_decoy,yh2_i);
        if (instance_exists(yh2_d) && yh2_d.hp > 0 && !array_contains(yh2_list,yh2_d)) array_push(yh2_list,yh2_d);
    }
    var has_target = false;
    for (var j = 0; j < array_length(yh2_list); j++) {
        var e2 = yh2_list[j];
        if (e2.target_type == "underground" || e2.target_type == "non_mainstream"
            || e2.target_type == "ghost" || e2.target_type == "invisible") continue;
        var eg2 = get_grid_position_from_world(e2.x,e2.y);
        if (abs(eg2.col-grid_col) <= radius && abs(eg2.row-grid_row) <= radius) {has_target = true; break;}
    }
    if (has_target) zodiac_timer = interval - 1;
}

zodiac_timer++;
if (zodiac_timer >= interval) {
    zodiac_timer = 0;
    state = CARD_STATE.ATTACK;
    image_index = idle_anim + 1;
    zodiac_shot_this_anim = false;
}
if (state == CARD_STATE.ATTACK) {
    // 与星星兔一致：动画第18帧执行攻击动作。
    if (!zodiac_shot_this_anim && image_index == 18) {
        zodiac_shot_this_anim = true;
        // 每15秒产生火苗：0转1朵，一二转各2朵
        var count = 2;
        if (shape == 0) count = 1;
        var value = 20;
        if (variable_instance_exists(id,"flame_produce")) {
            value = is_array(flame_produce)
                ? flame_produce[clamp(current_level,0,array_length(flame_produce)-1)]
                : flame_produce;
        }
        for (var f = 0; f < count; f++) {
            var inst = instance_create_depth(x,y-60,depth-1000,obj_flame);
            inst.value = value;
        }
    }
    if (zodiac_shot_this_anim && zodiac_timer > 0 && image_index == idle_anim + 1) {
        state = CARD_STATE.IDLE;
        image_index = 0;
        zodiac_shot_this_anim = false;
    }
}
