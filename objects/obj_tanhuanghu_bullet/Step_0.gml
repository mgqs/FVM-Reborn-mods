/// 弹簧虎 弹体 Step
if (global.is_paused) exit;

x += move_speed;

if (x > combat_right_x() + 200 || x < combat_left_x() - 200){
    instance_destroy();
    exit;
}

hit_tick++;
if (hit_tick < global.bullet_hit_interval) exit;
hit_tick = 0;

if (!bullet_enemy_reachable(id)) exit;
if (!variable_global_exists("enemy_by_type")) exit;

var _hit = false;

for (var _t = 0; _t < array_length(hittable_types); _t++){
    var _key = hittable_types[_t];
    if (!variable_struct_exists(global.enemy_by_type, _key)) continue;

    if (_key == "obstacle"){
        // 弹簧虎 xlsx：子弹可穿过岩浆和障碍 → 障碍不拦、不消耗
        continue;
    }

    var _sap_gen = -1;
    var _list = bullet_sap_type_list(id, _key);

    for (var _i = 0; _i < array_length(_list); _i++){
        var _e = _list[_i];
        if (!instance_exists(_e)) continue;
        if (_e.hp <= 0) continue;
        if (_key == "underground" && !is_digging_dijing(_e)) continue;
        if (!precise_bbox_collision(id, _e)) continue;

        with (_e){
            damage_amount         = other.damage;
            damage_type           = other.damage_type;
            damage_source_object  = obj_tanhuanghu;
            damage_source_card_id = "tanhuanghu";
            if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
            event_user(0);
            damage_source_card_id = "";
        }

        _hit = true;
        hitted_enemy = _e.id;
        break;
    }

    if (_hit) break;
}

if (_hit) instance_destroy();
