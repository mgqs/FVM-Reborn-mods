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
///    mod_tg_pity_max(tier) 转职保底次数：一转 6 / 二转 12 / 三·四·终转 15（与保险金无关）
///
///  二、规则（纯函数，不碰实例变量 —— 状态全由调用方传进来）
///    mod_tg_target_shape(card_id)              目标形态 = 练到过的最高形态 + 1
///    mod_tg_check(card_id, assure_on, gold, debug)  能不能转 → { ok, reason, shape, gold, rate, assure, has_credit }
///    mod_tg_roll(rate, pity, pity_max)   掷骰 + 保底 → { win, pity }
///
///  二·b、缺凭证时「当场补全并转职」（2026-10-28，取代原购买按钮）
///    mod_tg_balance(currency)                      某货币余额（gold 走存档）
///    mod_tg_assure_tip(assure_on)                  未勾保险金的提醒句
///    mod_tg_fill_check(card_id, assure_on, debug)  能不能「买一张 + 直接转职」→ { ok, reason, price, currency, ... }
///    mod_tg_fill_apply(price, currency, credit_id, debug) 扣货币 + 发 1 张凭证（卡不动）
///    mod_tg_fill_confirm_draw(hover, price, currency_name, credit_name, assure_on, currency) 补凭证弹窗
///
///  三、确认窗绘制
///    mod_tg_confirm_rect(i)          按钮矩形（0 = 确定 / 1 = 取消），Draw 与 Step 共用
///    mod_tg_modal_draw(hover, lines, tip, tip_bottom)  通用两按钮弹窗（转职确认 / 补凭证确认共用）
///    mod_tg_confirm_draw(hover, assure_on)  转职确认窗（调 mod_tg_modal_draw）
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

/// @func mod_tg_pity_max(tier) 转职保底次数（按凭证档位）
///   2026-10-28 用户定：**一转 6 次 / 二转 12 次 / 三转·四转·终转 15 次**
///   与保险金开关无关（开关不影响累计，也不影响必成）
/// @param _tier 凭证档位 1~5（不是卡形态；金卡 = shape + 2）
function mod_tg_pity_max(_tier){
    switch (_tier){
        case 1: return 6;
        case 2: return 12;
    }
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

    // 🔴 2026-10-27：卡还没拥有 → 直接拒绝。
    //    没拥有的卡 max_shape = -1，目标形态会被算成 1，于是「一张一转凭证 + 金币」就能
    //    凭空解锁一张从没拥有过的卡。转职列表本来就只从 unlocked_cards 建（走不到这里），
    //    这句是兜底，别把这扇后门留着。
    if (transfer_credit_card_max_shape(_card_id) < 0){ _r.reason = "还没拥有这张卡"; return _r; }

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

/// @func mod_tg_roll(rate, pity, pity_max) 掷骰 + 保底
///   保底口径（2026-10-28 用户定）：
///     ① **每次转职都累计**，跟保险金开不开无关（保险金只管失败退不退凭证）；
///     ② 累计到 pity_max 的那一次**必成**（也不要求开保险金）；
///     ③ 只有「换卡 / 切换界面 / 退出合成屋」由对象那边负责清零；
///        转职成功、开关保险金、用补全凭证买来再转 —— 都不清零、也不额外计数。
/// @return { struct } win（这次成不成）/ pity（新的累计次数，调用方存回）
function mod_tg_roll(_rate, _pity, _pity_max){
    _pity += 1;
    var _win = (irandom(99) < _rate);
    if (_pity >= _pity_max){
        // 保底这一次必成，然后**把计数用掉归零**（重新开始数）
        //   —— 否则计数会一直 ≥ 上限，之后每次转职都必成（用户要的是「第 N 次必成」不是「永远必成」）
        _win  = true;
        _pity = 0;
    }
    return { win:_win, pity:_pity };
}

// ── 缺凭证时「当场补一张并转职」（2026-10-28 用户要求，取代原「凭证槽左侧购买」按钮）──
//   点转职 → 缺凭证 → 这里算价：读 transfer_credit_price_info（威望商店 / 诸神 / 跨服）
//   确定 = 扣对应货币 + 发 1 张凭证 + 立刻走一次转职

/// @func mod_tg_balance(currency) 某货币的余额（"gold" 走存档金币，其它走背包材料 id）
function mod_tg_balance(_currency){
    if (_currency == "gold") return global.save_data.player.gold;
    return get_material_amount(_currency);
}

/// @func mod_tg_assure_tip(assure_on) 未勾保险金时的提醒句（两种确认窗共用；勾了就返回 ""）
function mod_tg_assure_tip(_assure_on){
    if (_assure_on) return "";
    return "请注意，本次转职暂未勾选保险金";
}

/// @func mod_tg_fill_check(card_id, assure_on, debug) 缺凭证时能不能「买一张 + 直接转职」
///   判定顺序：没选卡 → 已转满 → 其实有凭证 → 商店没卖 → 购买资格（已转职/爬塔）→ 货币与金币余额
/// @return { struct } ok / reason / price / currency / currency_name / credit_id / credit_name / shop
function mod_tg_fill_check(_card_id, _assure_on, _debug = false){
    var _r = { ok:false, reason:"", price:0, currency:"", currency_name:"",
               credit_id:"", credit_name:"", shop:"" };
    if (_card_id == ""){ _r.reason = "先选一张卡"; return _r; }
    // 还没拥有 → 不能补（否则花了钱也转不了：tg_check 会以「还没拥有这张卡」拒绝）
    if (transfer_credit_card_max_shape(_card_id) < 0){ _r.reason = "还没拥有这张卡"; return _r; }

    var _shape = mod_tg_target_shape(_card_id);
    if (_shape > transfer_credit_card_shapes_max(_card_id)){ _r.reason = "此卡已无法转职"; return _r; }
    if (transfer_credit_has(_card_id, _shape)){ _r.reason = "凭证已在背包"; return _r; }

    var _pi = transfer_credit_price_info(_card_id, _shape);
    // 文案（2026-10-28 用户口径）：说人话，别把内部判定名抛给玩家
    if (_pi.price <= 0){ _r.reason = "该凭证无法快速补齐"; return _r; }

    var _blk = transfer_credit_buyable(_card_id, _shape);
    if (_blk != ""){ _r.reason = "缺少凭证，不满足购买条件，无法补齐"; return _r; }

    _r.price         = _pi.price;
    _r.currency      = _pi.currency;
    _r.currency_name = _pi.name;
    _r.shop          = _pi.shop;
    _r.credit_id     = transfer_credit_id(_card_id, _shape);
    _r.credit_name   = transfer_credit_name(_card_id, _shape);

    if (!_debug){
        // ① 买凭证的钱 ② 这次转职本身要的金币（含保险金）—— 两笔都够才让点确定
        if (mod_tg_balance(_pi.currency) < _pi.price){ _r.reason = _pi.name + "不足"; return _r; }
        var _tier = transfer_credit_tier(_card_id, _shape);
        var _gold = mod_tg_gold(_tier) + (_assure_on ? mod_tg_assure(_tier) : 0);
        if (global.save_data.player.gold < _gold){ _r.reason = "金币不足"; return _r; }
    }
    _r.ok = true;
    return _r;
}

/// @func mod_tg_fill_apply(price, currency, credit_id, debug) 补凭证：扣货币 + 发 1 张（卡、形态都不动）
function mod_tg_fill_apply(_price, _currency, _credit_id, _debug = false){
    if (_credit_id == "") return false;
    if (!_debug){
        if (_currency == "gold") global.save_data.player.gold -= _price;
        else                     add_material_amount(_currency, -_price);
    }
    add_material_amount(_credit_id, 1);
    save_file(global.save_slot);
    return true;
}

/// @func mod_tg_fill_confirm_draw(hover, price, currency_name, credit_name, assure_on, currency) 补凭证弹窗
///   currency 传货币 material id，用来在价格后写「（当前拥有N）」
function mod_tg_fill_confirm_draw(_hover, _price, _currency_name, _credit_name, _assure_on, _currency = ""){
    // 价格后面带上当前余额（2026-10-28 用户要求）：「是否消耗 5神石（当前拥有305）」
    var _bal = (_currency != "") ? mod_tg_balance(_currency) : 0;
    var _lines = [
        { text: "缺少" + _credit_name, red: false },
        { text: "是否消耗 " + string(_price) + _currency_name + "（当前拥有" + string(_bal) + "）", red: false },
        { text: "补全凭证并进行一次转职？", red: false }
    ];
    // 提醒跟普通转职窗一样画在**按钮下方**（红字 ×1.1；2026-10-28 用户改）
    mod_tg_modal_draw(_hover, _lines, mod_tg_assure_tip(_assure_on), true);
}

/// @func mod_tg_confirm_rect(i) 确认窗按钮矩形（0 = 确定 / 1 = 取消）：Draw 与 Step 共用
function mod_tg_confirm_rect(_i){
    var _bx = room_width * 0.5 + ((_i == 0) ? -80 : 80);
    var _by = room_height * 0.5 + 70;
    var _hw = sprite_get_width(spr_common_button) * 0.75 * 0.5;   // 0.75 与 obj_shop_buy_confirm 同一手感
    var _hh = sprite_get_height(spr_common_button) * 0.75 * 0.5;
    return [_bx - _hw, _by - _hh, _bx + _hw, _by + _hh];
}

/// @func mod_tg_modal_draw(hover, lines, tip, tip_bottom) 通用两按钮弹窗（转职确认 / 补凭证确认共用）
///      面板复用 spr_battle_escape_menu、按钮复用 spr_common_button（跟融合页「系统提示」同一套观感）
///      在 panel_anim_end_parts 之后调用 = 盖在最上层
/// @param hover 当前悬停的按钮下标（-1 = 没有）
/// @param lines 正文行数组，元素 = { text:"...", red:true/false }（red 画红字；行数 1~4 自动排）
/// @param tip   附注（「暂未勾选保险金」）；空串不画
/// @param tip_bottom true = 画在按钮下方，false = 画在标题下方
function mod_tg_modal_draw(_hover, _lines, _tip = "", _tip_bottom = false){
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

    // 正文：行数越多越往上压，最后一行与按钮之间至少留 18px
    var _n    = array_length(_lines);
    var _y0   = (_n >= 4) ? -60 : ((_n == 3) ? -44 : -20);
    var _step = (_n >= 4) ? 28  : ((_n == 3) ? 30  : 32);
    for (var _i = 0; _i < _n; _i++){
        var _ln = _lines[_i];
        draw_set_colour(_ln.red ? make_colour_rgb(215, 40, 40) : c_white);
        draw_text(_px, _py + _y0 + _step * _i, _ln.text);
    }
    draw_set_colour(c_white);

    // 附注（未勾保险金）：红色、比正文大一号
    if (_tip != ""){
        draw_set_colour(make_colour_rgb(215, 40, 40));
        draw_text_transformed(_px, _py + (_tip_bottom ? 112 : -78), _tip, 1.1, 1.1, 0);
        draw_set_colour(c_white);
    }

    var _lbl = ["确定", "取消"];
    for (var _b = 0; _b < 2; _b++){
        var _r  = mod_tg_confirm_rect(_b);
        var _bx = (_r[0] + _r[2]) * 0.5, _by = (_r[1] + _r[3]) * 0.5;
        var _fr = (_hover == _b) ? (mouse_check_button(mb_left) ? 2 : 1) : 0;
        draw_sprite_ext(spr_common_button, _fr, _bx, _by, 0.75, 0.75, 0, c_white, 1);
        draw_set_colour(c_white);
        draw_text(_bx, _by, _lbl[_b]);
    }
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

/// @func mod_tg_confirm_draw(hover, assure_on) 转职确认窗（文案不变；未勾保险金时顶部加一句提醒）
function mod_tg_confirm_draw(_hover, _assure_on = true){
    var _lines = [
        { text: "转职后凭证将消失，您确定", red: false },
        { text: "要进行卡片转职吗？", red: false }
    ];
    // 提醒画在**按钮下方**（2026-10-28 用户要求），红字放大
    mod_tg_modal_draw(_hover, _lines, mod_tg_assure_tip(_assure_on), true);
}
