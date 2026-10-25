/// 转职凭证（transfer credit）数据层
/// 2026-10-25 建立：只做「凭证本体」——id 规则、名字、底板/卡面绘制、持有列表
/// 详细方案见 桌面\fvm的ai\转职系统方案.md
///
/// id 规则：transfer_<card_id>_<shape>，shape 1=一转 / 2=二转（本期只做普卡 1/2）
/// 数量存在 global.save_data.inventory 里（复用 add_material_amount / get_material_amount），
/// 但**不注册进 global.material_pool** —— 否则道具页会被上百个空格子塞满。

/// @function transfer_credit_id(card_id, shape)
function transfer_credit_id(_card_id, _shape) {
    if (_shape <= 0) return "";
    return "transfer_" + string(_card_id) + "_" + string(_shape);
}

/// @function transfer_credit_parse(id)
/// @desc 解析凭证 id → { card_id, shape }；不是凭证返回 undefined
function transfer_credit_parse(_id) {
    if (!is_string(_id)) return undefined;
    if (string_pos("transfer_", _id) != 1) return undefined;

    var _rest = string_delete(_id, 1, 9);           // 去掉 "transfer_"
    var _pos = 0;
    // 从后往前找最后一个下划线（卡 id 里本身可能有下划线）
    for (var _i = string_length(_rest); _i >= 1; _i--) {
        if (string_char_at(_rest, _i) == "_") { _pos = _i; break; }
    }
    if (_pos <= 0) return undefined;

    var _cid = string_copy(_rest, 1, _pos - 1);
    var _sh_s = string_delete(_rest, 1, _pos);
    if (_cid == "" || _sh_s == "") return undefined;
    if (!is_real(real(_sh_s))) return undefined;

    var _sh = real(_sh_s);
    if (_sh < 1) return undefined;
    return { card_id: _cid, shape: floor(_sh) };
}

/// @function transfer_credit_is(id)
function transfer_credit_is(_id) {
    return !is_undefined(transfer_credit_parse(_id));
}

/// @function transfer_credit_tier_name(shape)
function transfer_credit_tier_name(_shape) {
    switch (_shape) {
        case 1: return "一转凭证";
        case 2: return "二转凭证";
        case 3: return "三转凭证";
        case 4: return "四转凭证";
        case 5: return "终转凭证";
    }
    return "转职凭证";
}

/// @function transfer_credit_name(card_id, shape)
/// @desc 名字用**本体（0 转）名字** + 档位，不带形态名、不带 A/B/C 字母
function transfer_credit_name(_card_id, _shape) {
    var _nm = string(_card_id);
    var _d = deck_get_card_data(_card_id, 0);
    if (_d != noone && ds_exists(_d, ds_type_map)) {
        if (ds_map_exists(_d, "name")) _nm = _d[? "name"];
    }
    return _nm + "（" + transfer_credit_tier_name(_shape) + "）";
}

/// @function transfer_credit_name_from_id(id)
function transfer_credit_name_from_id(_id) {
    var _p = transfer_credit_parse(_id);
    if (is_undefined(_p)) return "";
    return transfer_credit_name(_p.card_id, _p.shape);
}

/// @function transfer_credit_description(card_id, shape)
function transfer_credit_description(_card_id, _shape) {
    return transfer_credit_name(_card_id, _shape) + "\n"
        + "转职凭证：在合成屋「卡片转职」中使用。\n"
        + "持有数量：" + string(get_material_amount(transfer_credit_id(_card_id, _shape)));
}

/// @function transfer_credit_bg_sprite(shape, slot)
/// @desc slot: 0/A = A 底板，1/B = B 底板，2/C = C 底板（一转只有 A/B）
function transfer_credit_bg_sprite(_shape, _slot) {
    if (_shape <= 1) {
        if (_slot == 1) return spr_transfer_bg_1b;
        return spr_transfer_bg_1a;
    }
    switch (_slot) {
        case 1: return spr_transfer_bg_2b;
        case 2: return spr_transfer_bg_2c;
    }
    return spr_transfer_bg_2a;
}

/// @function transfer_credit_face_sprite(card_id, shape)
/// @desc 该卡对应形态的 sprite；拿不到退回本体；再拿不到返回 -1
function transfer_credit_face_sprite(_card_id, _shape) {
    var _sh = _shape;
    while (_sh > 0) {
        var _d = deck_get_card_data(_card_id, _sh);
        if (_d != noone && ds_exists(_d, ds_type_map)) {
            if (ds_map_exists(_d, "sprite")) {
                var _spr = _d[? "sprite"];
                if (_spr != -1) return _spr;
            }
        }
        _sh -= 1;
    }
    var _d0 = deck_get_card_data(_card_id, 0);
    if (_d0 != noone && ds_exists(_d0, ds_type_map) && ds_map_exists(_d0, "sprite")) {
        return _d0[? "sprite"];
    }
    return -1;
}

/// @function transfer_credit_draw(x, y, card_id, shape, size, slot, alpha)
/// @desc 画一张凭证：底板 + 卡面。x,y 是**左上角**（不是中心）
///       size = 凭证外框显示边长（像素）。44 = 原始大小；背包格子用 88；商店用 132
///       卡面按 sprite 非透明包围盒等比 fit 到 36/44 比例，居中，不会因画布留白而忽大忽小
function transfer_credit_draw(_x, _y, _card_id, _shape, _size, _slot = 0, _alpha = 1) {
    if (_size <= 0) _size = 44;
    var _s = _size / 44;

    draw_sprite_ext(transfer_credit_bg_sprite(_shape, _slot), 0, _x, _y, _s, _s, 0, c_white, _alpha);

    var _spr = transfer_credit_face_sprite(_card_id, _shape);
    if (_spr == -1) return;

    var _bl = sprite_get_bbox_left(_spr);
    var _bt = sprite_get_bbox_top(_spr);
    var _bw = sprite_get_bbox_right(_spr) - _bl + 1;
    var _bh = sprite_get_bbox_bottom(_spr) - _bt + 1;
    if (_bw <= 0 || _bh <= 0) return;

    var _target = 36 * _s;                       // 卡面目标边长（36/44 的窗口）
    var _k = min(_target / _bw, _target / _bh);
    var _dw = _bw * _k;
    var _dh = _bh * _k;
    var _cx = _x + 22 * _s;                      // 底板中心
    var _cy = _y + 22 * _s;

    draw_sprite_part_ext(_spr, 0, _bl, _bt, _bw, _bh,
        _cx - _dw * 0.5, _cy - _dh * 0.5, _k, _k, c_white, _alpha);
}

/// @function transfer_credit_draw_id(x, y, id, size, slot, alpha)
function transfer_credit_draw_id(_x, _y, _id, _size, _slot = 0, _alpha = 1) {
    var _p = transfer_credit_parse(_id);
    if (is_undefined(_p)) return;
    transfer_credit_draw(_x, _y, _p.card_id, _p.shape, _size, _slot, _alpha);
}

/// @function transfer_credit_owned_ids()
/// @desc 背包里持有的凭证 id 列表（数量 > 0），按 卡id → 档位 排序
function transfer_credit_owned_ids() {
    var _out = [];
    var _inv = global.save_data.inventory;
    for (var _i = 0; _i < array_length(_inv); _i++) {
        var _id = _inv[_i].id;
        if (!transfer_credit_is(_id)) continue;
        if (_inv[_i].amount <= 0) continue;
        array_push(_out, _id);
    }
    // 冒泡排序（数量很少，不用 array_sort 的回调）
    var _n = array_length(_out);
    for (var _a = 0; _a < _n - 1; _a++) {
        for (var _b = 0; _b < _n - 1 - _a; _b++) {
            var _p1 = transfer_credit_parse(_out[_b]);
            var _p2 = transfer_credit_parse(_out[_b + 1]);
            var _swap = false;
            if (_p1.card_id > _p2.card_id) _swap = true;
            else if (_p1.card_id == _p2.card_id && _p1.shape > _p2.shape) _swap = true;
            if (_swap) {
                var _tmp = _out[_b];
                _out[_b] = _out[_b + 1];
                _out[_b + 1] = _tmp;
            }
        }
    }
    return _out;
}
