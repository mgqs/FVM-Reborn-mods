/// 神装「变装」入场特效（2026-11-13）
///
/// 规则（用户 2026-11-13 定）：
///   ① 变装立绘 = 「携带对应宝石」+「穿对应套装」**同时满足**才播；
///   ② 星之神杖本体入场特效（spr_ruchang）与宝石/套装完全无关，只看是否装备星之神杖
///      → 用 player_has_weapon("star_wand") 单独判定，不再并进本表。
///
/// 立绘两种版式（照搬既有 3 段的用法，别自创）：
///   "banner"    —— 1332×h 横版切入，按 box 给的内容框等比放大 2 倍、中心对齐屏幕中心
///                  （2026-11-14 用户要求：原来按精灵原点 1:1 画，观感太小）；
///                  box=[x,y,w,h] 是「红条完整宽度 + 立绘头顶到底边」的并集框，实测值见各行注释；
///   "left_half" —— 1811×2044 立绘，铺满屏幕左半边，内容框 box=[x,y,w,h] 由调用方给定
///                  （同 spr_huan_bianshen2 / spr_yao_bianshen2 在 obj_12yinliao_effect/Draw_0 的口径）。
/// 两种版式都靠 obj_12yinliao_effect 的 center_src_* / half_src_* 传源框，缩放只在 Draw 里算。
///
/// 改表只改 attire_fx_table()；UI（角色信息栏「变装特效」弹窗）也遍历这张表，不另存副本。

/// @func attire_fx_banner_scale()
/// @desc 横版立绘的放大倍数（用户 2026-11-14 定：2 倍）
function attire_fx_banner_scale() {
    return 2;
}

/// @func attire_fx_table()
/// @desc 9 组「宝石 + 套装 → 立绘」配置
function attire_fx_table() {
    return [
        // box 实测（全帧并集）：红条 155..1176 = 1021 宽；top/bottom 取角色头顶与条底
        { name: "魔影圣衣男变身", gem: "poseidon_dart_gun_gem_1", attire: "player_attire_moyingshengyi_nan",
          spr: spr_bianshen_moyingshengyi_nan, style: "banner", box: [155, 59, 1021, 266] },
        { name: "魔影迅疾男变身", gem: "poseidon_dart_gun_gem_4", attire: "player_attire_moyingxunji_nan",
          spr: spr_bianshen_moyingxunji_nan, style: "banner", box: [155, 6, 1021, 262] },
        { name: "魔影迅疾女变身", gem: "poseidon_dart_gun_gem_4", attire: "player_attire_shouhuzhishen",
          spr: spr_bianshen_moyingxunji_nv, style: "banner", box: [155, 15, 1021, 359] },
        { name: "天神之影男变身", gem: "zeus_shadow_gem", attire: "player_attire_tianshenzhiying_nan",
          spr: spr_bianshen_tianshenzhiying_nan, style: "banner", box: [155, 0, 1021, 239] },
        { name: "天神之影女变身", gem: "zeus_shadow_gem", attire: "player_attire_tianshenzhiyingbanbensan",
          spr: spr_bianshen2, style: "banner", box: [155, 0, 1021, 241] },
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
/// @desc 三个武器槽里任意一个**真正生效地**镶了这颗宝石
function player_has_gem(_gem_id) {
    if (!variable_global_exists("save_data")) return false;
    if (!variable_struct_exists(global.save_data, "equipped_items")) return false;
    var _eq = global.save_data.equipped_items;
    // 槽位名必须与 _slots 的下标一一对应（gem_fits_weapon 要拿它比 gem_data.slot）
    var _names = ["main_weapon", "secondary_weapon", "super_weapon"];
    var _slots = [_eq.main_weapon, _eq.secondary_weapon, _eq.super_weapon];
    for (var _i = 0; _i < array_length(_slots); _i++) {
        var _s = _slots[_i];
        if (!is_struct(_s)) continue;
        // ① 槽位必须真的装着武器。remove_weapon() 卸武器时刻意保留 gems 数组
        //    （装回同一把武器时宝石原样还在），所以「id 为空 + gems 非空」是残留，
        //    不是携带 —— 少了这条，卸掉武器后旧宝石的变装立绘会一直误触发。
        if (!variable_struct_exists(_s, "id")) continue;
        if (!is_string(_s.id)) continue;
        if (_s.id == "") continue;
        if (!variable_struct_exists(_s, "gems")) continue;
        if (!is_array(_s.gems)) continue;
        if (array_get_index(_s.gems, _gem_id) == -1) continue;
        // ② 宝石还得在这把武器上生效（同槽位 + allowed_weapons 命中）。
        //    换武器时 reconcile 已经按这条判据清理过，这里再判一次是防手工改存档 /
        //    旧版本残留数据：数组里躺着但装了别的武器，一样不算携带。
        if (gem_fits_weapon(_gem_id, _s.id, _names[_i])) return true;
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
    else if (_cfg.style == "banner") {
        // 横版立绘：按内容框放大 2 倍居中（2026-11-14）。不设的话走 draw_self()，
        // 会按精灵原点 1:1 画在 (0,0)，观感偏小且垂直不居中。
        _e.center_screen = true;
        _e.scale_multiplier = attire_fx_banner_scale();
        _e.center_src_x = _cfg.box[0];
        _e.center_src_y = _cfg.box[1];
        _e.center_src_w = _cfg.box[2];
        _e.center_src_h = _cfg.box[3];
    }
    return _e;
}

// ── 一键「穿戴」（2026-11-14）──
// 弹窗每行右侧一个按钮：武器 + 宝石 + 套装三件齐了才动手，缺一件就只提示、不改存档。
// 武器不写死在本表里，从宝石的 allowed_weapons[0] 反查 —— 5 颗变装宝石都是一对一专属，
// 以后换武器只改 mod_weapons_init 的注册，这里不用同步。

/// @func attire_fx_gem_weapon(gem_id)
/// @desc 宝石的专属武器 id（取 allowed_weapons 第一个）；通用宝石 / 未注册返回 ""
function attire_fx_gem_weapon(_gem_id) {
    var _gd = get_gem_info(_gem_id);
    if (!is_struct(_gd)) return "";
    if (!variable_struct_exists(_gd, "allowed_weapons")) return "";
    if (!is_array(_gd.allowed_weapons)) return "";
    if (array_length(_gd.allowed_weapons) <= 0) return "";
    return _gd.allowed_weapons[0];
}

/// @func attire_fx_gem_slot(gem_id)
/// @desc 宝石所属槽位（5 颗变装宝石都是 main_weapon；取不到时兜底 main_weapon）
function attire_fx_gem_slot(_gem_id) {
    var _gd = get_gem_info(_gem_id);
    if (!is_struct(_gd)) return "main_weapon";
    if (!variable_struct_exists(_gd, "slot")) return "main_weapon";
    if (!is_string(_gd.slot)) return "main_weapon";
    return _gd.slot;
}

/// @func attire_fx_own_all(cfg)
/// @desc 三件是否都在手上（只判「解锁/拥有」，不要求已经装/穿在身上）
function attire_fx_own_all(_cfg) {
    var _w = attire_fx_gem_weapon(_cfg.gem);
    if (_w == "") return false;
    if (!is_weapon_unlocked(_w)) return false;
    if (!is_gem_unlocked(_cfg.gem)) return false;
    if (!is_attire_unlocked(_cfg.attire)) return false;
    return true;
}

/// @func attire_fx_is_worn(cfg)
/// @desc 这一组是不是已经「武器在身 + 宝石在槽 + 套装穿着」（按钮显示「已穿戴」）
function attire_fx_is_worn(_cfg) {
    if (!player_has_weapon(attire_fx_gem_weapon(_cfg.gem))) return false;
    if (!player_has_gem(_cfg.gem)) return false;
    return (card_equipped_attire_id("player") == _cfg.attire);
}

/// @func attire_fx_wear(cfg)
/// @desc 一键穿戴：换武器 → 镶宝石 → 换套装 → 存档
/// @return -1 = 三件不齐（什么都不改）；1 = 已穿戴；2 = 已穿戴但宝石位满、替换了最后一颗
function attire_fx_wear(_cfg) {
    if (!attire_fx_own_all(_cfg)) return -1;
    var _w = attire_fx_gem_weapon(_cfg.gem);
    // 槽位优先取武器自己的 slot；取不到才退回宝石的 slot
    var _slot = attire_fx_gem_slot(_cfg.gem);
    var _wd = get_weapon_info(_w);
    if (is_struct(_wd) && variable_struct_exists(_wd, "slot") && is_string(_wd.slot)) _slot = _wd.slot;
    // 顺序不能换：equip_gem 要校验「专属武器已装备」，所以武器必须先到位；
    // equip_weapon 内部会按新武器重算该槽宝石（不兼容的卸下、旧武器的记忆表补回），
    // 所以这里镶的宝石不会被它冲掉（equip_gem 在 equip_weapon 之后调用）。
    equip_weapon(_w, _slot);
    equip_gem(_cfg.gem);

    // 该槽 4 个宝石位已满时 equip_gem 会静默不动（array_length < 4 才镶），
    // 变装就不会触发；这里摘掉最后一颗（最近镶的那颗）再镶一次，并如实告诉玩家。
    // 数组一律走「全路径」写法，与 remove_gem 一致（别用 var 别名，数组是写时复制的）
    var _replaced = false;
    if (!player_has_gem(_cfg.gem)) {
        var _freed = false;
        if (_slot == "main_weapon") {
            if (variable_struct_exists(global.save_data.equipped_items.main_weapon, "gems")
             && is_array(global.save_data.equipped_items.main_weapon.gems)) {
                var _gn = array_length(global.save_data.equipped_items.main_weapon.gems);
                if (_gn > 0) {
                    array_delete(global.save_data.equipped_items.main_weapon.gems, _gn - 1, 1);
                    _freed = true;
                }
            }
        }
        else if (_slot == "secondary_weapon") {
            if (variable_struct_exists(global.save_data.equipped_items.secondary_weapon, "gems")
             && is_array(global.save_data.equipped_items.secondary_weapon.gems)) {
                var _gn2 = array_length(global.save_data.equipped_items.secondary_weapon.gems);
                if (_gn2 > 0) {
                    array_delete(global.save_data.equipped_items.secondary_weapon.gems, _gn2 - 1, 1);
                    _freed = true;
                }
            }
        }
        else if (_slot == "super_weapon") {
            if (variable_struct_exists(global.save_data.equipped_items.super_weapon, "gems")
             && is_array(global.save_data.equipped_items.super_weapon.gems)) {
                var _gn3 = array_length(global.save_data.equipped_items.super_weapon.gems);
                if (_gn3 > 0) {
                    array_delete(global.save_data.equipped_items.super_weapon.gems, _gn3 - 1, 1);
                    _freed = true;
                }
            }
        }
        if (_freed) {
            equip_gem(_cfg.gem);
            _replaced = player_has_gem(_cfg.gem);
        }
    }

    equip_attire(_cfg.attire);
    save_file(global.save_slot);
    if (_replaced) return 2;
    return 1;
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

/// @func attire_fx_row_rect(index)
/// @desc 第 index 行「穿戴」按钮的矩形 [x1, y1, x2, y2]
///       行基线必须与 Draw_0 的 _top / _step 完全一致（_r[1]+184 / 55），改一处必须改两处
function attire_fx_row_rect(_i) {
    var _r = attire_fx_panel_rect();
    var _w = 96, _h = 34;
    var _cy = _r[1] + 184 + _i * 55;
    var _x2 = _r[2] - 40;
    return [_x2 - _w, _cy - _h * 0.5, _x2, _cy + _h * 0.5];
}
