/// =============================================================
/// 灯影花糕（huagao）—— 固定轨迹类卡片
/// 魂虫从场地左右两侧对向飞入（左侧的向右飞、右侧的向左飞），
/// 沿途攻击卡片所在的上/中/下三行陆军。
/// 命中魂系老鼠会使其现形；命中 15 次打掉 1 团鬼火（药罐鼠魂火）。
/// 数值注册见 mod_cards_init / mod_slots_init / mod_skill_init。
/// =============================================================

/// @function huagao_bullet_sprite(shape)
/// @desc 各形态对应的魂虫精灵：0/1/2 -> spr_huagao_bullet / bullet1 / bullet2
function huagao_bullet_sprite(_shape) {
    if (_shape >= 2) return spr_huagao_bullet2;
    if (_shape == 1) return spr_huagao_bullet1;
    return spr_huagao_bullet;
}

/// @function huagao_fushengcha_mult()
/// @desc 浮生茶增幅接口（历史预留）。
///       浮生茶已实装：倍率在 obj_mod_battle_manager 中并入卡片 atk（与音盒马同类取最高），
///       本卡直接读 atk 即已享受增幅。此函数恒返回 1，勿再写入 global.huagao_fushengcha_mult，
///       否则会与 atk 通道重复相乘。
function huagao_fushengcha_mult() {
    if (variable_global_exists("huagao_fushengcha_mult")) {
        var _m = global.huagao_fushengcha_mult;
        if (is_real(_m) && _m > 0) return _m;
    }
    return 1;
}

/// @function huagao_hit_enemy(_e, _damage, _owner)
/// @desc 魂虫单次命中结算。
///       1) 命中魂系老鼠使其现形：写 huagao_reveal，魂体减伤在
///          longyuan_apply_soul_damage_reduction 中按该标记跳过。
///       2) 鬼火（药罐鼠 ly_fire）每 15 次命中打掉 1 团。
function huagao_hit_enemy(_e, _damage, _owner) {
    if (!instance_exists(_e) || _e.hp <= 0) return;

    // 魂系口径：魂系敌人 + 药罐鼠（药罐鼠本体不算魂系，但按要求吃 1.5 倍增伤）
    var _is_soul = longyuan_is_soul_bonus_target(_e);
    if (_is_soul) {
        _e.huagao_reveal = true;
        _e.image_alpha = 1;
        // 灯影花糕对魂系：不吃 90% 魂体减伤 / 魂火减伤，额外增伤。
        // 倍率统一取自 longyuan_soul_bonus_mult()，不要在此另写数字。
        _damage = floor(_damage * longyuan_soul_bonus_mult(obj_huagao));
    }

    var _owner_obj = instance_exists(_owner) ? _owner.object_index : obj_huagao;
    with (_e) {
        damage_amount = _damage;
        damage_type = "normal";
        damage_source_object = _owner_obj;
        damage_source_card_id = "huagao";
        event_user(0);
        damage_source_card_id = "";

        // 鬼火：15 次命中破 1 团（其它卡片每次命中即破，灯影花糕刻意更慢）
        if (hp > 0 && _damage > 0 && variable_instance_exists(id, "ly_fire") && ly_fire > 0) {
            if (!variable_instance_exists(id, "huagao_fire_hits")) huagao_fire_hits = 0;
            huagao_fire_hits++;
            if (huagao_fire_hits >= 15) {
                ly_fire = max(0, ly_fire - 1);
                huagao_fire_hits = 0;
            }
        }
    }
}

/// @function huagao_next_attack_tag()
/// @desc 取一个全局递增的攻击标记。同一帧放出的多条魂虫共用它，
///       配合 obj_huagao_bullet 的「每只敌人每次攻击只结算一次」，避免伤害随魂虫条数翻倍。
function huagao_next_attack_tag() {
    if (!variable_global_exists("huagao_attack_tag_next")) global.huagao_attack_tag_next = 0;
    global.huagao_attack_tag_next++;
    if (global.huagao_attack_tag_next >= 1000000000) global.huagao_attack_tag_next = 1;
    return global.huagao_attack_tag_next;
}

/// @function huagao_spawn_bug(_owner, _x, _y, _dir, _vertical, _rows, _cols, _mid_row, _sprite, _damage, _mid_hits, _side_hits, _attack_tag)
/// @desc 生成一枚魂虫。_dir：1 向右 / -1 向左；_vertical 为真时忽略 _dir 向下飞行。
///       _attack_tag：同一次攻击的多条魂虫共用一个标记，配合 obj_huagao_bullet 的
///       「每只敌人每次攻击只结算一次」逻辑，保证总伤害与数值表一致（不会因条数增加而翻倍）。
function huagao_spawn_bug(_owner, _x, _y, _dir, _vertical, _rows, _cols, _mid_row, _sprite, _damage, _mid_hits, _side_hits, _attack_tag = 0) {
    var _b = instance_create_depth(_x, _y, -2500, obj_huagao_bullet);
    _b.owner_id = _owner;
    _b.sprite_index = _sprite;
    _b.damage = _damage;
    _b.base_damage = _damage;
    _b.dir = _dir;
    _b.vertical = _vertical;
    _b.rows = _rows;
    _b.cols = _cols;
    _b.mid_row = _mid_row;
    _b.hits_mid = _mid_hits;
    _b.hits_side = _side_hits;
    _b.attack_tag = _attack_tag;
    if (_owner != noone && instance_exists(_owner)) _b.shape = _owner.shape;
    if (_vertical) _b.image_angle = 270;           // 竖直下落：贴图朝下
    else if (_dir < 0) _b.image_xscale = -1;       // 向左飞：水平翻转
    return _b;
}
