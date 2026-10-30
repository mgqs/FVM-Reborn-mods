/// obj_hex_panel —— 三选一面板
/// 触发：开局首抽（每关一次）/ 敌人掉落（1%，直接开面板，不再落地拾取）
/// 表现：全场暂停 + 中央横排三张，银/金/彩三套视觉（docs 5.2）

depth  = -9000;
offer  = hex_roll_offer();

// 池抽干 / 非海克斯模式：不要留下一个既没牌可点又把全场暂停的面板
if (!hex_active() || array_length(offer) == 0) {
    global.hex_pick_open = false;
    if (instance_exists(obj_battle)) global.is_paused = false;
    // 没牌可选也算首抽处理完，否则放置会一直被锁着
    if (variable_global_exists("hex_state") && is_struct(global.hex_state)) {
        global.hex_state.first_done = true;
    }
    instance_destroy();
    exit;
}

global.hex_pick_open = true;
global.is_paused     = true;

t      = 0;            // 入场计时
closing = 0;           // 关闭动画计数
hover_idx = -1;
taken_idx = -1;
msg_timer = 0;
msg_text  = "";

card_w = 300;
card_h = 420;
card_gap = 50;
base_x = room_width / 2 - (card_w * 3 + card_gap * 2) / 2;
base_y = room_height / 2 - card_h / 2 - 40;

// 底部三键：放弃 / 选择 / 重随
// 「选择」是唯一能拿到词条的入口 —— 点卡只算选中，其余任何操作都不会确认
btn_w = 176;
btn_h = 56;
select_x = room_width / 2;
giveup_x = room_width / 2 - 214;
reroll_x = room_width / 2 + 214;
btn_y    = base_y + card_h + 46;

sel_idx      = -1;      // 当前选中的牌索引（-1 = 没选）
select_hover = false;

var _cfg = hex_cfg();
reroll_cost_now = (_cfg.reroll_cost[min(global.hex_state.rerolls, 2)]);

audio_play_sound(snd_button, 0, 0);

/// @function hex_panel_card_rect(_i)
/// @desc 第 i 张卡的矩形
function hex_panel_card_rect(_i) {
    var _x = base_x + _i * (card_w + card_gap);
    return { x1: _x, y1: base_y, x2: _x + card_w, y2: base_y + card_h };
}

/// @function hex_panel_pick(_i)
/// @desc 选定第 i 张
function hex_panel_pick(_i) {
    if (_i < 0 || _i >= array_length(offer)) return;
    var _id = offer[_i];
    var _d  = hex_get(_id);
    if (is_undefined(_d)) return;
    if (hex_taken(_id) >= _d.stack) {
        msg_text  = "这条已经拿到上限了";
        msg_timer = 60;
        // 玩家已经对首抽做出选择动作了，标记处理完：
        // 否则这条死牌一直占着牌面、面板关不掉，hex_place_locked() 会把整局的放置锁死
        if (variable_global_exists("hex_state") && is_struct(global.hex_state)) {
            global.hex_state.first_done = true;
        }
        return;
    }
    hex_note_pick_form(_d.form);
    hex_apply(_id);
    taken_idx = _i;
    closing   = 10;
    // 首抽到这里算处理完：解锁放置
    if (variable_global_exists("hex_state")) global.hex_state.first_done = true;
}

/// @function hex_panel_select(_i)
/// @desc 只把第 i 张牌设为「已选中」，不生效。
///       真正拿到词条必须再点一次「选择」按钮 —— 防止手滑点错一张就锁死整局
function hex_panel_select(_i) {
    if (_i < 0 || _i >= array_length(offer)) return;
    var _id = offer[_i];
    var _d  = hex_get(_id);
    if (is_undefined(_d)) return;
    if (hex_taken(_id) >= _d.stack) {
        msg_text  = "这条已经拿到上限了";
        msg_timer = 60;
        sel_idx   = -1;
        return;
    }
    sel_idx = _i;
    audio_play_sound(snd_button, 0, 0);
}

/// @function hex_panel_confirm()
/// @desc 唯一确认入口
function hex_panel_confirm() {
    if (sel_idx < 0) {
        msg_text  = "请先点选一条词条";
        msg_timer = 60;
        return;
    }
    hex_panel_pick(sel_idx);
}

/// @function hex_panel_reroll()
function hex_panel_reroll() {
    var _free = global.hex_state.free_reroll > 0;
    var _cost = reroll_cost_now;
    if (!_free) {
        if (!variable_global_exists("flame") || global.flame < _cost) {
            msg_text  = "火苗不足,需要 " + string(_cost);
            msg_timer = 60;
            return;
        }
        global.flame -= _cost;
        global.hex_state.rerolls += 1;
        reroll_cost_now = hex_cfg().reroll_cost[min(global.hex_state.rerolls, 2)];
    } else {
        global.hex_state.free_reroll -= 1;
    }
    offer = hex_roll_offer();
    hover_idx = -1;
    sel_idx   = -1;      // 新牌面，之前的选中作废
    audio_play_sound(snd_button, 0, 0);
}

/// @function hex_panel_giveup()
function hex_panel_giveup() {
    var _wave = (instance_exists(obj_battle)) ? obj_battle.current_wave : 0;
    var _gain = hex_cfg().giveup_flame + _wave * 40;
    if (variable_global_exists("flame")) global.flame += _gain;
    global.hex_state.giveups += 1;
    global.hex_state.first_done = true;   // 弃权也算处理完，否则整局都不能放卡
    hex_pi_recalc();
    closing = 10;
    audio_play_sound(snd_button, 0, 0);
}

// 交互态（Step 里赋值，Draw 里读取，必须先建）
reroll_hover = false;
giveup_hover = false;
