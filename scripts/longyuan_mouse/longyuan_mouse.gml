/// 每个动作使用SWF标签对应的闭区间，不依赖move_anim等固定偏移。
function longyuan_play(_action, _once = false) {
    if (ly_action == _action) return;
    if (!variable_struct_exists(ly_anims, _action)) {
        show_debug_message("龙渊缺少动作: " + ly_kind + "/" + _action);
        return;
    }
    ly_action = _action;
    ly_frame = 0;
    ly_done = false;
    ly_hit = false;
    ly_once = _once;
    var _clip = ly_anims[$ _action];
    sprite_index = _clip[0];
    image_index = _clip[1] - 1;
}

function longyuan_animate() {
    if (ly_action == "") return;
    var _clip = ly_anims[$ ly_action];
    var _count = _clip[2] - _clip[1] + 1;
    ly_frame += 10 / game_get_speed(gamespeed_fps) / (is_slowdown ? 2 : 1);
    ly_done = ly_frame >= _count;
    image_index = _clip[1] - 1 + (ly_once ? min(floor(ly_frame), _count - 1) : floor(ly_frame) mod _count);
}

function longyuan_mouse_setup(_kind, _hp, _speed, _atk, _cycle) {
    ly_kind = _kind;
    ly_anims = longyuan_animation_table(_kind);
    mouse_id = "longyuan_" + _kind;
    hp = _hp; maxhp = _hp; ly_original_hp = _hp;
    move_speed = _speed; atk = _atk; atk_cycle = _cycle;
    if (variable_struct_exists(global.level_file, "is_night")) ly_night = global.level_file.is_night;
    else if (variable_global_exists("level_id")) {
        var _level = string(global.level_id);
        ly_night = string_pos("night", _level) > 0 || string_pos("_ye", _level) > 0;
    }
    switch (_kind) {
        case "dijing":
            target_type = "underground"; attack_range = -90; ly_mode = "dig";
            ly_anims[$ "挖地"] = [spr_dijing_dig, 1, 6];
            ly_anims[$ "出土"] = [spr_dijing_apper, 1, 29];
            ly_anims[$ "眩晕"] = [spr_dijing_stun, 1, 4];
            break;
        case "langyabang": giant_type = true; immune_to_ash = true; attack_range = 120; break;
        case "longmu": shield_hp = 80; shield_max_hp = 80; break;
        case "dongfeng": target_type = "air"; break;
        case "gaoqiao": target_type = "air"; break;
        case "yaoguan": is_soul = true; ly_fire = 3; break;
        case "zhibuji": is_vehicle = true; giant_type = true; break;
        case "fuzhou": is_soul = true; ly_fire = 3; ly_cooldown = 180; break;
        case "fuzhou_minion": is_soul = true; ly_mode = "spawn"; longyuan_play("出生", true); break;
        case "zhizhujing": ly_mode = "wait"; break;
    }
}

function longyuan_variant(_normal, _hurt) {
    return hp <= maxhp * hurt_rate ? _hurt : _normal;
}

function longyuan_move_action() {
    switch (ly_kind) {
        case "pingmin": return longyuan_variant("正常行走", "重伤行走");
        case "dijing": return longyuan_variant("正常走路", "受伤走路");
        case "langyabang": return longyuan_variant("正常行走", "受伤行走");
        case "longmu": return ly_egg ? longyuan_variant("正常有蛋前进", "破损有蛋前进") : longyuan_variant("正常无蛋前进", "破损无蛋前进");
        case "gaoqiao": return longyuan_variant("正常移动", "破损移动");
        case "dongfeng": return ly_fan ? "持扇前进" : longyuan_variant("正常行走", "破损行走");
        case "kailu": return longyuan_variant("正常无火前进", "破损无火前进");
        case "zhizhujing": return "正常待机";
        case "zhibuji":
            if (hp > maxhp * 0.75) return "全丝线移动";
            if (hp > maxhp * 0.5) return "剩余2份丝线移动";
            if (hp > maxhp * 0.3) return "剩余1份丝线移动";
            if (hp > maxhp * 0.15) return "破损剩余1份丝线移动";
            return "破损无丝线移动";
        case "kailu_soul": return longyuan_variant("正常前进", "破损前进");
        case "zhinian_soul": return longyuan_variant("正常灵魂前进", "破损灵魂前进");
    }
    return longyuan_variant("正常前进", "破损前进");
}

function longyuan_attack_action() {
    switch (ly_kind) {
        case "pingmin": return longyuan_variant("正常吃东西循环", "重伤吃东西循环");
        case "dijing": return longyuan_variant("正常吃东西", "受伤吃东西");
        case "langyabang": return longyuan_variant("正常砸东西", "受伤砸东西");
        case "longmu": return ly_egg ? longyuan_variant("正常有蛋啃咬", "破损有蛋啃咬") : longyuan_variant("正常无蛋啃咬", "破损无蛋啃咬");
        case "gaoqiao": return longyuan_variant("正常啃咬", "破损啃咬");
        case "dongfeng": return ly_fan ? "持扇攻击" : longyuan_variant("正常啃咬", "破损啃咬");
        case "kailu": return longyuan_variant("正常无火撞击", "破损无火撞击");
        case "kailu_soul": return longyuan_variant("正常前进", "破损前进"); //魂态SWF没有啃咬段
        case "zhinian_soul": return "正常攻击卡片"; //破损攻击在表内另设别名
        case "fuzhou": return longyuan_variant("正常攻击", "破损攻击");
    }
    return longyuan_variant("正常啃咬", "破损啃咬");
}

function longyuan_find_plant(_heavy_only = false) {
    var _best = noone, _priority = 999, _distance = 1000000000;
    with (obj_card_parent) {
        if (hp <= 0 || plant_id == "player" || plant_type == "coffee") continue;
        var _dx = other.attack_range > 0 ? other.x - x : x - other.x;
        if (grid_row != other.grid_row || _dx < 0 || _dx > abs(other.attack_range)) continue;
        if (_heavy_only && plant_id != "chocolate_bread" && !(variable_instance_exists(id, "blocks_vault") && blocks_vault)) continue;
        if (feature_type == "dwarf" && !other.giant_type) continue;
        var _order = ds_list_find_index(global.eat_order, plant_type);
        if (_order < 0) continue;
        if (_order < _priority || (_order == _priority && _dx < _distance)) {
            _best = id; _priority = _order; _distance = _dx;
        }
    }
    return _best;
}

function longyuan_damage_plant(_plant, _damage) {
    if (!instance_exists(_plant) || _plant.hp <= 0 || _plant.invincible) return;
    with (_plant) { hp -= _damage; event_user(2); }
}

/// 桥头米线本体及连接线均可设置此标记；线段也可直接注册在global.longyuan_bridge_lines。
function longyuan_bridge_contact(_x1, _y1, _x2, _y2, _row) {
    var _found = noone;
    with (obj_card_parent) {
        if (hp > 0 && grid_row == _row && variable_instance_exists(id, "longyuan_bridge_connected") && longyuan_bridge_connected
            && x >= min(_x1, _x2) - 20 && x <= max(_x1, _x2) + 20) _found = id;
    }
    if (_found != noone) return _found;
    if (variable_global_exists("longyuan_bridge_lines")) {
        var _lines = global.longyuan_bridge_lines;
        for (var _i = 0; _i < array_length(_lines); ++_i) {
            var _l = _lines[_i];
            if (!instance_exists(_l.owner) || _l.owner.hp <= 0) continue;
            if (collision_line(_l.x1, _l.y1, _l.x2, _l.y2, id, false, false) != noone
                || (_row == _l.owner.grid_row && min(_x1, _x2) <= max(_l.x1, _l.x2) && max(_x1, _x2) >= min(_l.x1, _l.x2))) return _l.owner;
        }
    }
    return noone;
}

function longyuan_change_soul() {
    ly_soul = true; is_soul = true; target_type = "invisible";
    ly_kind += "_soul"; ly_anims = longyuan_animation_table(ly_kind);
    hp = maxhp; ash_death = false; image_alpha = 1;
    ly_mode = "spawn"; longyuan_play("出生", true);
    // 重复标签“正常攻击卡片”对应健康与破损两段，使用不同的代码别名。
    if (ly_kind == "zhinian_soul") {
        ly_anims[$ "正常攻击卡片"] = [spr_ly_zhinian_soul, 22, 31];
        ly_anims[$ "破损攻击卡片"] = [spr_ly_zhinian_soul, 66, 75];
        atk *= 2; move_speed = 0.6;
    }
}

function longyuan_begin_death() {
    ly_mode = "dead"; target_plant = noone; ly_action = "";
    var _death = "死亡";
    if (ly_kind == "pingmin") _death = "倒地";
    if (ly_kind == "langyabang") _death = "死亡倒地";
    if (ly_kind == "dijing") _death = "倒地";
    if (ly_kind == "kailu_soul") _death = ash_death ? "爆炸死亡" : "普通死亡";
    longyuan_play(_death, true);
}

function longyuan_fire_hit(_enemy, _source_card_id) {
    if (!instance_exists(_enemy) || !variable_instance_exists(_enemy, "ly_fire")) return;
    // 新卡通过此接口传入稳定ID，而不是用任意伤害类型猜测灯影花糕。
    if (_source_card_id == "dengying_huagao") {
        _enemy.ly_fire_hits++;
        if (_enemy.ly_fire_hits >= 5) {
            _enemy.ly_fire_hits = 0;
            _enemy.ly_fire = max(0, _enemy.ly_fire - 1);
        }
    }
}
