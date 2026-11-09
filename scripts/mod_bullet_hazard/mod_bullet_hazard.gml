/// =====================================================================
/// 过火 / 反弹的公共实现 —— 父类 obj_bullet_parent 的 2 个 Collision 事件都调这里
///
///   火源（火盆 / 火神 / 金牛 / 能量喵 / 融合火盆，共用父对象 obj_fire_source）
///        → bullet_hazard_fire(id, other, other.atk * other.fire_mult_scale);
///   反弹源（樱桃布丁 / 布丁汪 / 水神，共用父对象 obj_rebound_source）
///        → bullet_hazard_rebound(id, other);
///
///   🔴 只用「引擎碰撞事件」驱动。任何情况下都不要再写 with(obj_bullet_parent) 轮询 ——
///      融盆第一版就是那种全表扫描（每张火盆 × 每颗子弹），多放两张直接掉帧。
///   🔴 子弹侧不要再写任何 Collision 事件，也不要在 Step 里手动 with(火源) 扫描。
///      要吃火 / 反弹：Create 里写 hazard_fire = true / hazard_rebound = true，
///      或去 scripts/mod_bullet_hazard_table 加一行。
///
///   调试：把 global.hazard_debug 设为 true，控制台会打每次过火/反弹的判定过程。
/// =====================================================================

/// @function hazard_dbg(_msg)
function hazard_dbg(_msg) {
    if (variable_global_exists("hazard_debug") && global.hazard_debug)
        show_debug_message("[hazard] " + string(_msg));
}

/// @function bullet_hazard_fire(_bullet, _src, _mult, _scale = 1.8)
/// @desc 过火增幅：门禁 / 同排 / 冰弹两步 / **取最高倍率** / 融合火盆二转变冰弹 / 音效 / 放大
/// @param _bullet 子弹实例
/// @param _src    点火源实例（火盆 / 火神 / 金牛 / 能量喵 / 融合火盆）
/// @param _mult   增幅倍率（普通火源传 other.atk；能量喵目前传 other.atk / 100）
/// @param _scale  点燃后放大到几倍；0 = 不放大（bbq / 法师蛇 自己在 Step 里处理）
/// @return bool   是否真的点燃 / 提升了倍率
function bullet_hazard_fire(_bullet, _src, _mult, _scale = 1.8) {
    if (!instance_exists(_bullet) || !instance_exists(_src)) return false;

    var _nm  = object_get_name(_bullet.object_index);
    var _cfg = bullet_hazard_cfg(_bullet.object_index).fire;
    // 默认关；子弹自己写了 hazard_fire = true 也算（两者都支持，表优先）
    var _self_on = variable_instance_exists(_bullet, "hazard_fire") && _bullet.hazard_fire;
    if (!_cfg.on && !_self_on) return false;

    if (!variable_instance_exists(_bullet, "burnt"))        return false;
    if (!variable_instance_exists(_bullet, "brazier_list")) return false;
    if (variable_instance_exists(_bullet, "can_burn") && !_bullet.can_burn) return false;
    if (variable_instance_exists(_bullet, "disabled") && _bullet.disabled) return false;
    // kind 门禁：只有 fire / star 能过火；没有 kind 字段的子弹（大多数）直接放行
    if (variable_instance_exists(_bullet, "kind")
        && !(_bullet.kind == "fire" || _bullet.kind == "star")) return false;

    // 入口白名单（默认 "*"；数组时只认列出的对象）
    if (is_array(_cfg.srcs)) {
        var _ok = false;
        for (var i = 0; i < array_length(_cfg.srcs); i++) {
            var _si = asset_get_index(_cfg.srcs[i]);
            if (_si != -1 && _src.object_index == _si) { _ok = true; break; }
        }
        if (!_ok) return false;
    }

    // 原卡门禁（冰冻长枪那颗要求 source_card_id == gatlin_ice_long_bao）
    if (_cfg.src_gate != "") {
        if (!variable_instance_exists(_bullet, "source_card_id")) return false;
        if (_bullet.source_card_id != _cfg.src_gate) return false;
    }

    // 同一座火源只记一次
    if (ds_list_find_index(_bullet.brazier_list, _src.id) != -1) return false;

    // ── 同排判定 ──
    //   星弹（星星兔）不判行（2026-11-10 用户口径：碰到哪一行的火盆都算）；
    //   焚寂马 kind == "fire"，仍按本行（center_row）
    var _same;
    if (variable_instance_exists(_bullet, "kind") && _bullet.kind == "star") {
        _same = true;
    } else if (variable_instance_exists(_bullet, "kind") && _bullet.kind == "fire"
               && variable_instance_exists(_bullet, "center_row")) {
        _same = (_bullet.center_row == _src.grid_row);
    } else {
        _same = (variable_instance_exists(_bullet, "row") && _bullet.row == _src.grid_row)
             || (variable_instance_exists(_bullet, "col") && _bullet.col == _src.grid_col);
    }
    if (!_same) {
        hazard_dbg(_nm + " 不同排，跳过（row=" + string(_bullet.row) + " 源 row=" + string(_src.grid_row) + "）");
        return false;
    }

    var _is_ice = _cfg.ice;

    // 融合火盆 2 转（缤纷杂果冰盘）：点燃后把子弹换成冰弹外观
    //   用 ancestor 判断，以后给融盆加子对象也认
    var _ice_pit = false;
    if ((_src.object_index == obj_ronghehuopen
         || object_is_ancestor(_src.object_index, obj_ronghehuopen))
        && variable_instance_exists(_src, "shape"))
        _ice_pit = (_src.shape >= 2);

    // ── 冰弹两步：0→1 只融化（不增幅、fire_mult 归 1），1→2 才点燃 ──
    if (_is_ice && _cfg.step2 && _bullet.burnt < 2) {
        _bullet.burnt += 1;
        ds_list_add(_bullet.brazier_list, _src.id);
        audio_play_sound(snd_bullet_burnt, 0, 0);
        if (_bullet.burnt < 2) {
            // 融化：不增幅、不变火球；只把尺寸按融化后的贴图重新配平，玩家能看出「降级了」
            _bullet.fire_mult = 1;
            if (variable_instance_exists(_bullet, "melt_scale") && _bullet.melt_scale > 0) {
                _bullet.image_xscale = _bullet.melt_scale;
                _bullet.image_yscale = _bullet.melt_scale;
            }
            hazard_dbg(_nm + " 融化（burnt=1），源=" + object_get_name(_src.object_index));
            return false;
        }
    }

    // ── 到这里 = 要点燃 / 提升倍率 ──
    // 过火取最高：不高于当前已获得的倍率就不生效（相等也不算）
    var _cur = (variable_instance_exists(_bullet, "fire_mult") && _bullet.fire_mult > 0)
             ? _bullet.fire_mult : 1;
    if (_mult <= _cur) {
        hazard_dbg(_nm + " 倍率不更高（" + string(_mult) + " <= " + string(_cur) + "），跳过");
        return false;
    }

    if (_bullet.burnt == 0) _bullet.burnt = 1;   // 点燃；冰弹此时 burnt 已是 2

    // 换乘（不是叠乘）：把之前那次增幅替换成更高的这一档
    _bullet.damage = round(_bullet.damage / _cur * _mult);
    _bullet.fire_mult = _mult;   // 直接赋值（取最高，不累乘）
    // 焚寂马（kind == "fire"）的分裂波按 base_damage 生成，必须同步增幅
    if (variable_instance_exists(_bullet, "kind") && _bullet.kind == "fire"
        && variable_instance_exists(_bullet, "base_damage"))
        _bullet.base_damage = round(_bullet.base_damage / _cur * _mult);

    if (_ice_pit) {
        // 二转专属：点燃后换成冰弹（贴图锁定 / 减速 / 冰冻特效交给 obj_ronghehuopen_ice_ctrl）
        if (ds_list_find_index(_bullet.brazier_list, -9999) == -1)
            ds_list_add(_bullet.brazier_list, -9999);
        _bullet.sprite_index = spr_ronghehuopen_ice_bullet;
        _bullet.image_xscale = 1.4;
        _bullet.image_yscale = 1.4;
        if (!instance_exists(obj_ronghehuopen_ice_ctrl))
            instance_create_depth(0, 0, -10000, obj_ronghehuopen_ice_ctrl);
    } else if (_scale > 0) {
        // 普通火源：点燃后放大一圈
        _bullet.image_xscale = _scale;
        _bullet.image_yscale = _scale;
    }

    ds_list_add(_bullet.brazier_list, _src.id);
    audio_play_sound(snd_bullet_burnt, 0, 0);
    hazard_dbg(_nm + " 点燃/升倍率 →" + string(_mult) + "，源=" + object_get_name(_src.object_index));
    return true;
}

/// @function bullet_hazard_rebound(_bullet, _src)
/// @desc 反弹（樱桃布丁 / 布丁汪 / 水神 —— 共用表里同一段 reb 参数）
///       附伤 = 源卡 atk × 当前过火倍率（bullet_rebound_bonus 里算），等价于「(子弹+增伤) × 过火倍率」
///       reset_hits 为 true 时还会清空命中记录 → 回程能再打一次已经打过的老鼠
/// @return bool 是否真的反弹了
function bullet_hazard_rebound(_bullet, _src) {
    if (!instance_exists(_bullet) || !instance_exists(_src)) return false;

    var _nm = object_get_name(_bullet.object_index);
    var _c  = bullet_hazard_cfg(_bullet.object_index).reb;
    // 默认关；子弹自己写了 hazard_rebound = true 也算（两者都支持，表优先）
    var _self_on = variable_instance_exists(_bullet, "hazard_rebound") && _bullet.hazard_rebound;
    if (!_c.on && !_self_on) return false;

    if (!variable_instance_exists(_bullet, "bounced")) _bullet.bounced = false;
    if (_bullet.bounced) return false;

    if (_c.judge == "row"
        && !(variable_instance_exists(_bullet, "row") && _bullet.row == _src.grid_row)) return false;
    if (_c.judge == "col"
        && !(variable_instance_exists(_bullet, "col") && _bullet.col == _src.grid_col)) return false;

    if (_c.kind_gate && variable_instance_exists(_bullet, "kind")
        && !(_bullet.kind == "fire" || _bullet.kind == "star")) return false;

    // 玫瑰盾：水平 / 垂直弹只看本行，斜向无视行
    if (_c.dir_guard && variable_instance_exists(_bullet, "direction")
        && (_bullet.direction mod 90) == 0
        && variable_instance_exists(_bullet, "row") && _bullet.row != _src.grid_row) return false;

    switch (_c.axis) {
        case "move_speed":
            if (!variable_instance_exists(_bullet, "move_speed")) return false;
            _bullet.move_speed *= -1;
            if (_c.flip_y && variable_instance_exists(_bullet, "y_move_speed"))
                _bullet.y_move_speed *= -1;
            break;
        case "move_dir":
            if (!variable_instance_exists(_bullet, "move_dir")) return false;
            _bullet.move_dir *= -1;
            break;
        case "move_x":
            if (!variable_instance_exists(_bullet, "move_x")) return false;
            _bullet.move_x *= -1;
            if (variable_instance_exists(_bullet, "move_y")) _bullet.move_y *= -1;
            break;
        case "move_speed_x":
            if (!variable_instance_exists(_bullet, "move_speed_x")) return false;
            _bullet.move_speed_x *= -1;
            break;
        case "vx":
            if (!variable_instance_exists(_bullet, "vx")) return false;
            _bullet.vx *= -1;
            if (variable_instance_exists(_bullet, "vy")) _bullet.vy *= -1;
            break;
        case "travel_dir":
            // 牛油果飞镖：竖直面镜像（0°→180°、+35°→+145°、-35°→-145°），并做角度归一化
            if (!variable_instance_exists(_bullet, "travel_dir")) return false;
            _bullet.travel_dir = 180 - _bullet.travel_dir;
            if (_bullet.travel_dir >  180) _bullet.travel_dir -= 360;
            if (_bullet.travel_dir <= -180) _bullet.travel_dir += 360;
            break;
    }

    if (_c.angle180) _bullet.image_angle += 180;
    _bullet.bounced = true;

    // 附伤 = 源卡 atk × 当前过火倍率
    //   = 「(子弹 + 增伤) × 过火倍率」：没被点燃过 fire_mult 就是 1，等于原来的加法
    var _fm = 1;
    if (variable_instance_exists(_bullet, "burnt") && _bullet.burnt > 0
        && variable_instance_exists(_bullet, "fire_mult")) _fm = _bullet.fire_mult;
    _bullet.damage += round((variable_instance_exists(_src, "atk") ? _src.atk : 0) * _fm);

    // 刷新命中记录：被弹回来的子弹可以再打一次已经打过的老鼠（只清命中表，别的状态一律不动）
    if (_c.reset_hits) {
        var _names = ["hitted", "hit_enemies", "hit_list", "hit_targets"];
        for (var i = 0; i < array_length(_names); i++) {
            if (!variable_instance_exists(_bullet, _names[i])) continue;
            var _l = _bullet[$ _names[i]];
            if (ds_exists(_l, ds_type_list)) ds_list_clear(_l);
        }
    }

    hazard_dbg(_nm + " 反弹，源=" + object_get_name(_src.object_index));
    return true;
}
