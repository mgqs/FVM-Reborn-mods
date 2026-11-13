/// 神装「变装」入场特效（2026-11-13）
///
/// 规则（用户 2026-11-13 定）：
///   ① 变装立绘 = 「携带对应宝石」+「穿对应套装」**同时满足**才播；
///   ② 星之神杖本体入场特效（spr_ruchang）与宝石/套装完全无关，只看是否装备星之神杖
///      → 用 player_has_weapon("star_wand") 单独判定，不再并进本表。
///
/// 立绘两种版式（照搬既有 3 段的用法，别自创）：
///   "banner"    —— 1332×h 横版切入，按精灵自己的 xorigin/yorigin 画（同 spr_bianshen2）；
///   "left_half" —— 1811×2044 立绘，铺满屏幕左半边，内容框 box=[x,y,w,h] 由调用方给定
///                  （同 spr_huan_bianshen2 / spr_yao_bianshen2 在 obj_12yinliao_effect/Draw_0 的口径）。
///
/// 改表只改 attire_fx_table()；UI（角色信息栏「变装特效」弹窗）也遍历这张表，不另存副本。

/// @func attire_fx_table()
/// @desc 9 组「宝石 + 套装 → 立绘」配置
function attire_fx_table() {
    return [
        { name: "魔影圣衣男变身", gem: "poseidon_dart_gun_gem_1", attire: "player_attire_moyingshengyi_nan",
          spr: spr_bianshen_moyingshengyi_nan, style: "banner", box: [0, 0, 0, 0] },
        { name: "魔影迅疾男变身", gem: "poseidon_dart_gun_gem_4", attire: "player_attire_moyingxunji_nan",
          spr: spr_bianshen_moyingxunji_nan, style: "banner", box: [0, 0, 0, 0] },
        { name: "魔影迅疾女变身", gem: "poseidon_dart_gun_gem_4", attire: "player_attire_shouhuzhishen",
          spr: spr_bianshen_moyingxunji_nv, style: "banner", box: [0, 0, 0, 0] },
        { name: "天神之影男变身", gem: "zeus_shadow_gem", attire: "player_attire_tianshenzhiying_nan",
          spr: spr_bianshen_tianshenzhiying_nan, style: "banner", box: [0, 0, 0, 0] },
        { name: "天神之影女变身", gem: "zeus_shadow_gem", attire: "player_attire_tianshenzhiyingbanbensan",
          spr: spr_bianshen2, style: "banner", box: [0, 0, 0, 0] },
        // 素材归属（2026-11-13 逐像素复核，别按文件夹名猜）：
        //   星之焕男 = 桌面「星之焕男变身」18 帧；
        //   星之焕女 = 桌面 DefineSprite_799_...StarRadianceGirlSkillEffectMovie 18 帧
        //              （与工程原有的 spr_huan_bianshen2 逐像素一致，直接复用旧精灵）
        { name: "星之焕男变身", gem: "star_wand_gem_1", attire: "player_attire_xingzhihuan_nan",
          spr: spr_bianshen_xingzhihuan_nan, style: "left_half", box: [685, 679, 518, 604] },
        { name: "星之焕女变身", gem: "star_wand_gem_1", attire: "player_attire_xingzhihuanbianshen3",
          spr: spr_huan_bianshen2, style: "left_half", box: [685, 679, 518, 604] },
        { name: "星之耀男变身", gem: "star_wand_gem_5", attire: "player_attire_xingzhiyao_nan",
          spr: spr_bianshen_xingzhiyao_nan, style: "left_half", box: [684, 679, 519, 604] },
        { name: "星之耀女变身", gem: "star_wand_gem_5", attire: "player_attire_xingzhiyao_nv",
          spr: spr_yao_bianshen2, style: "left_half", box: [684, 679, 519, 604] }
    ];
}

/// @func player_has_gem(gem_id)
/// @desc 三个武器槽里任意一个镶了这颗宝石
function player_has_gem(_gem_id) {
    if (!variable_global_exists("save_data")) return false;
    if (!variable_struct_exists(global.save_data, "equipped_items")) return false;
    var _eq = global.save_data.equipped_items;
    var _slots = [_eq.main_weapon, _eq.secondary_weapon, _eq.super_weapon];
    for (var _i = 0; _i < array_length(_slots); _i++) {
        var _s = _slots[_i];
        if (!is_struct(_s)) continue;
        if (!variable_struct_exists(_s, "gems")) continue;
        if (!is_array(_s.gems)) continue;
        if (array_get_index(_s.gems, _gem_id) != -1) return true;
    }
    return false;
}

/// @func player_has_weapon(weapon_id)
/// @desc 三个武器槽里任意一个装的是这把武器（星之神杖本体特效只吃这一条）
function player_has_weapon(_weapon_id) {
    if (!variable_global_exists("save_data")) return false;
    if (!variable_struct_exists(global.save_data, "equipped_items")) return false;
    var _eq = global.save_data.equipped_items;
    var _slots = [_eq.main_weapon, _eq.secondary_weapon, _eq.super_weapon];
    for (var _i = 0; _i < array_length(_slots); _i++) {
        var _s = _slots[_i];
        if (!is_struct(_s)) continue;
        if (!variable_struct_exists(_s, "id")) continue;
        if (_s.id == _weapon_id) return true;
    }
    return false;
}

/// @func attire_fx_find(attire_id)
/// @desc 按当前套装查命中的变身配置；宝石没带 / 套装不匹配返回 undefined
function attire_fx_find(_attire_id) {
    if (!is_string(_attire_id)) return undefined;
    if (_attire_id == "") return undefined;
    var _t = attire_fx_table();
    for (var _i = 0; _i < array_length(_t); _i++) {
        if (_t[_i].attire != _attire_id) continue;
        if (!player_has_gem(_t[_i].gem)) continue;
        return _t[_i];
    }
    return undefined;
}

/// @func attire_fx_play(cfg)
/// @desc 播放一次变装立绘（走 obj_12yinliao_effect 的一次性播放）
function attire_fx_play(_cfg) {
    var _e = instance_create_depth(0, 0, -10000, obj_12yinliao_effect);
    _e.sprite_index = _cfg.spr;
    _e.is_one_shot = true;
    _e.flash_speed = 6;
    if (_cfg.style == "left_half") {
        _e.left_half = true;
        _e.half_src_x = _cfg.box[0];
        _e.half_src_y = _cfg.box[1];
        _e.half_src_w = _cfg.box[2];
        _e.half_src_h = _cfg.box[3];
    }
    return _e;
}

// ── 「变装特效」说明弹窗的几何（Step 判定与 Draw 绘制共用，避免两处漂移）──

/// @func attire_fx_panel_rect()
/// @desc 说明弹窗面板矩形 [x1, y1, x2, y2]（room_menu 高 1080，780 高仍居中留白 150）
function attire_fx_panel_rect() {
    var _w = 920, _h = 780;
    var _cx = room_width * 0.5, _cy = room_height * 0.5;
    return [_cx - _w * 0.5, _cy - _h * 0.5, _cx + _w * 0.5, _cy + _h * 0.5];
}

/// @func attire_fx_confirm_rect()
/// @desc 「确定」按钮判定框（spr_common_button 是 2× 贴图，0.75 倍下实画 117×49.5）
function attire_fx_confirm_rect() {
    var _r = attire_fx_panel_rect();
    var _cx = (room_width * 0.5);
    var _cy = _r[3] - 52;
    var _hw = sprite_get_width(spr_common_button) * 0.75;
    var _hh = sprite_get_height(spr_common_button) * 0.75;
    return [_cx - _hw, _cy - _hh, _cx + _hw, _cy + _hh];
}
