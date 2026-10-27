/// =============================================================================
///  mod/craft · 转职表（合成屋左侧第 3 按钮，craft_top_tab == 2）
///  这个文件 = 转职的**全部数值 + 全部规则 + 确认窗绘制**，obj_craft_bg 只调它
///  对象那边只留：几何（tg_* 坐标）/ 界面状态（tg_card·tg_assure·tg_pity·tg_confirm·tg_fx）
///                列表与元数据缓存（tg_rebuild）/ Draw 与 Step
///  详细方案：桌面\fvm的ai\转职系统方案.md
///
///  一、数值（要改就改这里；参数是**凭证档位 1~5**，不是卡形态）
///    mod_tg_gold(tier)    3000 / 15000 / 5000 / 20000 / 50000
///    mod_tg_assure(tier)  7500 / 50000 / 7500 / 50000 / 50000
///    mod_tg_rate(tier)    30 / 20 / 30 / 20 / 20
///    mod_tg_pity_max()    转职保底次数 = 15（开保险金时连转第 15 次必成）
///
///  二、规则（纯函数，不碰实例变量 —— 状态全由调用方传进来）
///    mod_tg_target_shape(card_id)              目标形态 = 练到过的最高形态 + 1
///    mod_tg_check(card_id, assure_on, gold, debug)  能不能转 → { ok, reason, shape, gold, rate, assure, has_credit }
///    mod_tg_roll(rate, pity, pity_max, assure_on)   掷骰 + 保底 → { win, pity }
///
///  三、确认窗绘制
///    mod_tg_confirm_rect(i)          按钮矩形（0 = 确定 / 1 = 取消），Draw 与 Step 共用
///    mod_tg_confirm_draw(hover)      hover = 当前悬停的按钮下标（-1 无）
/// =============================================================================

/// @func mod_tg_gold(tier) 转职金币（tier = 凭证档位 1~5，不是卡形态）
/// 🔴 用户定价（2026-10-27 定稿）：一转 3,000 / 二转 15,000 / 三转 5,000 / 四转 20,000 / 终转 50,000
function mod_tg_gold(_tier){
    switch (_tier){
        case 1: return 3000;      // 一转
        case 2: return 15000;     // 二转
        case 3: return 5000;      // 三转（金卡）
        case 4: return 20000;     // 四转（金卡）
        case 5: return 50000;     // 终转（金卡）
    }
    return 15000;
}

/// @func mod_tg_assure(tier) 保险金（货币 = 金币；tier = 凭证档位 1~5）
/// 🔴 用户定价（2026-10-27 定稿）：一转 7,500 / 二转 50,000 / 三转 7,500 / 四转 50,000 / 终转 50,000
function mod_tg_assure(_tier){
    switch (_tier){
        case 1: return 7500;      // 一转
        case 2: return 50000;     // 二转
        case 3: return 7500;      // 三转（金卡）
        case 4: return 50000;     // 四转（金卡）
        case 5: return 50000;     // 终转（金卡）
    }
    return 50000;
}

/// @func mod_tg_rate(tier) 成功率（%）：一转 / 三转 30，其余 20
function mod_tg_rate(_tier){
    if (_tier == 1 || _tier == 3) return 30;
    return 20;
}

/// @func mod_tg_pity_max() 转职保底次数：开保险金时，同一张卡、同一次开合成屋，第 15 次必成
function mod_tg_pity_max(){
    return 15;
}

/// @func mod_tg_target_shape(card_id) 目标形态 = 练到过的最高形态 + 1（没拥有按 0 算 → 1）
function mod_tg_target_shape(_card_id){
    var _ms = transfer_credit_card_max_shape(_card_id);
    if (_ms < 0) _ms = 0;
    return _ms + 1;
}

/// @func mod_tg_check(card_id, assure_on, gold, debug) 能不能转
///   提示优先级（用户 2026-10-25 定）：① 没选卡 ② 形态上限（此卡已无法转职）③ 缺凭证 ④ 金币不足
///   一次只返回一个 reason —— 对象那边配 tg_notice 保证屏幕上不会叠第二条提示
/// @param _card_id    主卡槽里的卡 id（"" = 没选）
/// @param _assure_on  保险金开关
/// @param _gold       玩家当前金币
/// @param _debug      debug 模式（跳过金币判定）
/// @return { struct } ok / reason / shape / gold / rate / assure / has_credit
function mod_tg_check(_card_id, _assure_on, _gold, _debug = false){
    var _r = { ok:false, reason:"", shape:0, gold:0, rate:0, assure:0, has_credit:false };
    _r.assure = _assure_on ? mod_tg_assure(1) : 0;          // 还没选卡时先按一档价显示
    if (_card_id == ""){ _r.reason = "先选一张卡"; return _r; }

    var _shape = mod_tg_target_shape(_card_id);              // 只能按顺序：目标形态 = max_shape + 1
    var _tier  = transfer_credit_tier(_card_id, _shape);     // 档位：普卡 1/2，金卡 3/4/5
    _r.shape  = _shape;
    _r.rate   = mod_tg_rate(_tier);
    _r.gold   = mod_tg_gold(_tier);
    _r.assure = _assure_on ? mod_tg_assure(_tier) : 0;

    // 上限走 transfer_credit_card_shapes_max（player_deck 形态表 ∪ plant_registry）；
    // 只读 card_max_available_shape 会把「注册表里只有 0 转」的卡全部误报成已转满
    if (_shape > transfer_credit_card_shapes_max(_card_id)){ _r.reason = "此卡已无法转职"; return _r; }

    _r.has_credit = transfer_credit_has(_card_id, _shape);
    if (!_r.has_credit){ _r.reason = "缺少" + transfer_credit_tier_name(_tier); return _r; }

    if (!_debug && _gold < _r.gold + _r.assure){ _r.reason = "金币不足"; return _r; }
    _r.ok = true;
    return _r;
}

/// @func mod_tg_roll(rate, pity, pity_max, assure_on) 掷骰 + 保底
///   保底口径（2026-10-27 用户定）：**只有开保险金的转职才累计**；累计到 pity_max 那一次必成。
///   保险金开关本身不清零（开关不影响次数）；换卡 / 转职成功 / 退出合成屋 由对象那边负责清零。
/// @return { struct } win（这次成不成）/ pity（新的累计次数，调用方存回）
function mod_tg_roll(_rate, _pity, _pity_max, _assure_on){
    if (_assure_on) _pity += 1;
    var _win = (irandom(99) < _rate);
    if (_assure_on && _pity >= _pity_max) _win = true;
    return { win:_win, pity:_pity };
}

/// @func mod_tg_confirm_rect(i) 确认窗按钮矩形（0 = 确定 / 1 = 取消）：Draw 与 Step 共用
function mod_tg_confirm_rect(_i){
    var _bx = room_width * 0.5 + ((_i == 0) ? -80 : 80);
    var _by = room_height * 0.5 + 70;
    var _hw = sprite_get_width(spr_common_button) * 0.75 * 0.5;   // 0.75 与 obj_shop_buy_confirm 同一手感
    var _hh = sprite_get_height(spr_common_button) * 0.75 * 0.5;
    return [_bx - _hw, _by - _hh, _bx + _hw, _by + _hh];
}

/// @func mod_tg_confirm_draw(hover) 转职确认窗：面板复用 spr_battle_escape_menu、按钮复用 spr_common_button
///      （跟融合页的「系统提示」同一套观感；在 panel_anim_end_parts 之后调用 = 盖在最上层）
/// @param hover 当前悬停的按钮下标（-1 = 没有）
function mod_tg_confirm_draw(_hover){
    var _px = room_width * 0.5, _py = room_height * 0.5;
    draw_set_alpha(0.55);
    draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
    draw_set_alpha(1);
    draw_sprite_ext(spr_battle_escape_menu, 0, _px, _py, 1.5, 1.5, 0, c_white, 1);
    draw_set_font(font_yuan);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(c_white);
    draw_text(_px, _py - 112, "系统提示");
    draw_text(_px, _py - 20, "转职后凭证将消失，您确定");
    draw_text(_px, _py + 12, "要进行卡片转职吗？");
    var _lbl = ["确定", "取消"];
    for (var _i = 0; _i < 2; _i++){
        var _r  = mod_tg_confirm_rect(_i);
        var _bx = (_r[0] + _r[2]) * 0.5, _by = (_r[1] + _r[3]) * 0.5;
        var _fr = (_hover == _i) ? (mouse_check_button(mb_left) ? 2 : 1) : 0;
        draw_sprite_ext(spr_common_button, _fr, _bx, _by, 0.75, 0.75, 0, c_white, 1);
        draw_set_colour(c_white);
        draw_text(_bx, _by, _lbl[_i]);
    }
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
