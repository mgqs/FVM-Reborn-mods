/// obj_hex_test_picker —— 测试关卡「自选海克斯」面板
/// 触发：对局中按 F5 展开 / 再按 F5 收起（默认收起，不挡对局）
/// 交互：点卡片 = 立刻加 / 减一条词条并整局重建
/// 限制：只在 hex_test_enabled() 为真时存在，正式关一行都不走这里
///
/// 层级与点击：展开时 depth = -11000，比所有局内 UI 都靠前
/// （HUD -2900 / 暂停菜单 -3000 / 情报岛 F4 -10000 / 三选一面板 -9000），
/// 并且整段对局被 global.is_paused 冻住 —— 卡槽、地图放置、老鼠 AI 的 Step 首行都是
/// `if (global.is_paused) exit`，所以点在面板上绝不会穿透到下面的按钮。

depth = -11000;

// 进关时 hex_test_cleanup 已经把本局清空过一次，这里按上次的自选列表重新叠回来
hex_test_rebuild();

collapsed = true;        // 默认收起：进关先能正常打，按 F5 才展开
t         = 0;
msg_text  = "";
msg_timer = 0;

// ── 展开期间的暂停记账 ──
// 展开 = 强制暂停；收起时必须还回「打开之前」的暂停状态，
// 不能一律写 false（玩家可能是在「等待放置角色」的暂停里按的 F5）
paused_by_me = false;
prev_paused  = false;
resume_in    = 0;        // >0：关闭后延 N 帧才恢复对局（吃掉「点关闭」那一下鼠标）
global.hex_picker_open = false;

// ── 筛选状态 ──
sel_batch = -1;      // -1 全部 / 1 本体 / 2 第二批 / 3 第三批 / 4 特殊（卦·契约）
sel_tier  = -1;      // -1 全部 / 0 银 / 1 金 / 2 彩
sel_form  = -1;      // -1 全部 / 0 加码 A / 1 减码 C
only_sel  = false;   // 只看已选
only_impl = true;    // 只看已实装（默认开：没实装的选了也不会有任何效果）

// ── 布局（1920×1080）──
grid_x    = 40;
grid_y    = 176;
card_w    = 344;
card_h    = 196;
gap_x     = 12;
gap_y     = 10;
cols_show = 4;
rows_show = 4;
row_h     = card_h + gap_y;                                 // 206
col_w     = card_w + gap_x;                                 // 356
grid_w    = cols_show * card_w + (cols_show - 1) * gap_x;   // 1420
grid_h    = rows_show * card_h + (rows_show - 1) * gap_y;   // 814

side_x     = 1484;
side_w     = 396;
side_row_h = 30;
side_pad   = 40;     // 侧栏顶部标题占位

scroll      = 0;     // 以「行」为单位滚动：整行滚，永远不会露出半张卡
max_scroll  = 0;
side_scroll = 0;
side_max    = 0;

hover_id  = "";

// ── 搜索框（复用工程通用 SearchBox：自带输入法 / 粘贴 / 失焦处理）──
// 位置放在右栏顶部，正好和「本局已选」同宽，也不挤左侧那排筛选按钮
search_text = "";
var _sb = instance_create_depth(side_x, 108, -11100, SearchBox);
_sb.set_position(side_x, 108)
   .set_size(side_w, 40)
   .set_placeholder("搜索词条名 / 效果 / ID")
   .set_theme({
        bg:           make_colour_rgb(17, 25, 33),
        bg_focus:     make_colour_rgb(26, 40, 54),
        border:       make_colour_rgb(58, 76, 92),
        border_focus: make_colour_rgb(255, 212, 121),
        text:         #F4F8FB,
        placeholder:  make_colour_rgb(111, 132, 150)
   })
   .set_on_change(method({ pk: id }, function(_t) {
        with (pk) {
            search_text = _t;
            scroll      = 0;      // 结果变了，回到第一屏
        }
   }))
   .set_should_correspond(method({ pk: id }, function() {
        // 收起 / 面板被销毁时不接受输入（instance_exists 兜底，避免关闭那帧读越界）
        return (instance_exists(pk) && !pk.collapsed);
   }));
search_box = _sb;
_sb.visible = false;     // 面板收起时连画都不画

audio_play_sound(snd_button, 0, 0);

/// @function picker_match_search(_id, _d, _q)
/// @desc 搜索命中：词条名 / 卡片侧描述 / 老鼠侧描述 / id（_q 已小写，空串 = 全通过）
function picker_match_search(_id, _d, _q) {
    if (_q == "") return true;
    if (string_pos(_q, string_lower(_id)) > 0) return true;
    // 描述字段理论上都是字符串，但注册表里有个别条目漏填 —— is_string 兜底，
    // 免得 string_lower(undefined) 直接抛异常把整块 Draw 拖死
    if (is_string(_d.name)       && string_pos(_q, string_lower(_d.name)) > 0)       return true;
    if (is_string(_d.card_desc)  && string_pos(_q, string_lower(_d.card_desc)) > 0)  return true;
    if (is_string(_d.enemy_desc) && string_pos(_q, string_lower(_d.enemy_desc)) > 0) return true;
    return false;
}

/// @function picker_filter_ids()
/// @desc 按当前筛选返回要显示的词条 id（顺序 = 注册顺序）
function picker_filter_ids() {
    var _out = [];
    if (!variable_global_exists("hex_ids")) return _out;
    var _q = string_lower(search_text);     // 循环外小写一次，别在循环里反复转
    var _n = array_length(global.hex_ids);
    for (var i = 0; i < _n; i++) {
        var _id = global.hex_ids[i];
        var _d  = hex_get(_id);
        if (is_undefined(_d)) continue;
        if (sel_batch > 0 && hex_test_batch_of(_id) != sel_batch) continue;
        if (sel_tier >= 0 && _d.tier != sel_tier) continue;
        if (sel_form == 0 && _d.form != "A") continue;
        if (sel_form == 1 && _d.form != "C") continue;
        if (only_impl && !_d.impl) continue;
        if (only_sel && !hex_test_has(_id)) continue;
        if (!picker_match_search(_id, _d, _q)) continue;
        array_push(_out, _id);
    }
    return _out;
}

/// @function picker_card_rect(_i)
/// @desc 视口内第 i 格（0 .. cols_show*rows_show-1）的矩形
function picker_card_rect(_i) {
    var _c = _i mod cols_show;
    var _r = _i div cols_show;
    var _x = grid_x + _c * col_w;
    var _y = grid_y + _r * row_h;
    return { x1: _x, y1: _y, x2: _x + card_w, y2: _y + card_h };
}

/// @function picker_max_scroll()
function picker_max_scroll() {
    var _rows = ceil(array_length(picker_filter_ids()) / cols_show);
    return max(0, _rows - rows_show);
}

/// @function picker_hit_card(_mx, _my)
/// @desc 鼠标落在哪一格；返回筛选结果里的绝对下标，没命中返回 -1
function picker_hit_card(_mx, _my) {
    if (_mx < grid_x || _mx > grid_x + grid_w) return -1;
    if (_my < grid_y || _my > grid_y + grid_h) return -1;
    var _c = floor((_mx - grid_x) / col_w);
    var _r = floor((_my - grid_y) / row_h);
    if (_c < 0 || _c >= cols_show || _r < 0 || _r >= rows_show) return -1;
    // 落在格子之间的缝里不算命中
    if ((_mx - grid_x) - _c * col_w > card_w) return -1;
    if ((_my - grid_y) - _r * row_h > card_h) return -1;
    return (scroll + _r) * cols_show + _c;
}

/// @function picker_buttons()
/// @desc 顶部筛选按钮表（Step 判命中、Draw 画，都用这一份，保证位置永远一致）
function picker_buttons() {
    var _b  = [];
    var _by = 110;
    var _bh = 40;
    array_push(_b, { k: "batch", v: -1, x: 40,   w: 72,  label: "全部" });
    array_push(_b, { k: "batch", v:  1, x: 120,  w: 88,  label: "一批" });
    array_push(_b, { k: "batch", v:  2, x: 216,  w: 88,  label: "二批" });
    array_push(_b, { k: "batch", v:  3, x: 312,  w: 88,  label: "三批" });
    array_push(_b, { k: "batch", v:  4, x: 408,  w: 88,  label: "特殊" });

    array_push(_b, { k: "tier", v: -1, x: 520, w: 72, label: "全部" });
    array_push(_b, { k: "tier", v:  0, x: 600, w: 64, label: "银" });
    array_push(_b, { k: "tier", v:  1, x: 672, w: 64, label: "金" });
    array_push(_b, { k: "tier", v:  2, x: 744, w: 64, label: "彩" });

    array_push(_b, { k: "form", v: -1, x: 832, w: 72, label: "全部" });
    array_push(_b, { k: "form", v:  0, x: 912, w: 56, label: "A" });
    array_push(_b, { k: "form", v:  1, x: 976, w: 56, label: "C" });

    array_push(_b, { k: "only_sel",  v: 0, x: 1060, w: 120, label: "只看已选" });
    array_push(_b, { k: "only_impl", v: 0, x: 1196, w: 120, label: "只看已实装" });

    for (var i = 0; i < array_length(_b); i++) {
        _b[i].y = _by;
        _b[i].h = _bh;
    }
    return _b;
}

/// @function picker_btn_on(_b)
/// @desc 这个按钮当前是不是「选中态」
function picker_btn_on(_b) {
    switch (_b.k) {
        case "batch":     return (sel_batch == _b.v);
        case "tier":      return (sel_tier  == _b.v);
        case "form":      return (sel_form  == _b.v);
        case "only_sel":  return only_sel;
        case "only_impl": return only_impl;
    }
    return false;
}

/// @function picker_btn_click(_b)
function picker_btn_click(_b) {
    switch (_b.k) {
        case "batch":     sel_batch = _b.v; break;
        case "tier":      sel_tier  = _b.v; break;
        case "form":      sel_form  = _b.v; break;
        case "only_sel":  only_sel  = !only_sel; break;
        case "only_impl": only_impl = !only_impl; break;
    }
    scroll = 0;              // 换了筛选条件，回到顶部
    audio_play_sound(snd_button, 0, 0);
}

/// @function picker_toggle(_id, _right)
/// @desc 左键：加一层（可叠加的每点一次 +1，到 stack 上限就不再加）；右键：整条清除
function picker_toggle(_id, _right) {
    var _d = hex_get(_id);
    if (is_undefined(_d)) return;
    if (!_d.impl) {
        msg_text  = "这条还没实装，选了也不会有任何效果";
        msg_timer = 90;
        return;
    }
    var _cur = hex_test_stack(_id);
    var _cap = max(1, _d.stack);

    if (_right) {
        // 右键永远是「整条移除」，不管叠了几层
        hex_test_remove_all(_id);
    } else if (_cur >= _cap) {
        // 到上限就停住，不再叠 —— 移除只能走右键 / 右侧 ✕ / 清空全部
        msg_text  = (_cap > 1)
            ? ("已叠满 " + string(_cap) + " 层，不能再加（右键可整条移除）")
            : ("这条不可叠加，右键可移除");
        msg_timer = 90;
        return;
    } else {
        hex_test_add(_id);
    }
    hex_test_rebuild();
    audio_play_sound(snd_button, 0, 0);
}

/// @function picker_side_rect(_i)
/// @desc 右侧「本局已选」第 i 行的矩形
function picker_side_rect(_i) {
    var _y = grid_y + side_pad + _i * side_row_h;
    return { x1: side_x, y1: _y, x2: side_x + side_w, y2: _y + side_row_h };
}

/// @function picker_side_list()
/// @desc 自选列表去重后的 [{ id, n }]，顺序 = 第一次加进来的先后
function picker_side_list() {
    var _out = [];
    if (!variable_global_exists("hex_test_picks") || !is_array(global.hex_test_picks)) return _out;
    var _len = array_length(global.hex_test_picks);
    for (var i = 0; i < _len; i++) {
        var _id  = global.hex_test_picks[i];
        var _hit = -1;
        for (var k = 0; k < array_length(_out); k++) {
            if (_out[k].id == _id) { _hit = k; break; }
        }
        if (_hit == -1) array_push(_out, { id: _id, n: 1 });
        else            _out[_hit].n += 1;
    }
    return _out;
}

/// @function picker_side_rows()
/// @desc 侧栏一屏能放几行
function picker_side_rows() {
    return (grid_h - side_pad) div side_row_h;
}

/// @function picker_open()
/// @desc 展开：置顶 + 冻结对局 + 打开点击闸门。只有 F5 走这里
function picker_open() {
    if (!collapsed) return;
    collapsed = false;
    depth     = -11000;

    // 记下「打开之前」的暂停状态。玩家可能本来就在暂停里（例如还没放置角色），
    // 收起时如果一律写 false，会把局内的暂停解除，出现「鼠标能选卡但放不下去」。
    // paused_by_me 还是 true = 上一轮关闭后的 1 帧延迟还没走完（暂停尚未还回去），
    // 这时不能重新采样，否则会把「暂停中」错记成原始状态，收起后永远停着
    if (!paused_by_me) {
        prev_paused = (variable_global_exists("is_paused")) ? global.is_paused : false;
    }
    paused_by_me = true;
    global.is_paused       = true;
    global.hex_picker_open = true;

    scroll      = 0;
    side_scroll = 0;
    resume_in   = 0;

    if (instance_exists(search_box)) search_box.visible = true;
}

/// @function picker_close()
/// @desc 收起：延迟一帧再把暂停还回去（见 resume_in 的说明），释放点击闸门
function picker_close() {
    if (collapsed) return;
    collapsed = true;
    global.hex_picker_open = false;

    // 搜索框跟着一起收：不收的话它还在后台吃键盘输入
    if (instance_exists(search_box)) {
        with (search_box) { blur(); }
        search_box.visible = false;
    }
    keyboard_string = "";

    // 点「关闭面板」时那一下左键还按在同一帧里：如果立刻解除暂停，
    // 下方的卡槽会把它当成一次正常的选卡。所以延一帧再恢复。
    resume_in = paused_by_me ? 1 : 0;
}

/// @function picker_freeze()
/// @desc 展开期间每帧压一次暂停。暂停菜单 / 放置角色提示等外部逻辑
///       都可能把 is_paused 改回 false，一旦被改掉就会出现「点面板同时点到卡槽」
function picker_freeze() {
    if (collapsed) return;
    paused_by_me = true;
    if (!global.is_paused) global.is_paused = true;
    global.hex_picker_open = true;
}

/// @function picker_can_toggle()
/// @desc 还有别的模态开着时不开面板，免得两层界面叠在一起抢鼠标
function picker_can_toggle() {
    if (instance_exists(obj_hex_panel))     return false;   // 三选一
    if (instance_exists(obj_pause_menu))    return false;   // 暂停菜单
    if (instance_exists(obj_info_island_bg)) return false;  // F4 情报岛
    return true;
}

/// @function picker_draw_card(_id, _r)
/// @desc 画一张词条卡。_r 是 picker_card_rect() 算出来的矩形
function picker_draw_card(_id, _r) {
    var _d = hex_get(_id);
    if (is_undefined(_d)) return;

    var _own = hex_test_stack(_id);
    var _x1  = _r.x1;
    var _x2  = _r.x2;
    var _y1  = _r.y1;
    var _y2  = _r.y2;

    // 悬停时整张抬起 4px
    if (hover_id == _id) { _y1 -= 4; _y2 -= 4; }

    // 底色 / 描边：银冷、金暖、彩流光
    var _bg, _bc;
    switch (_d.tier) {
        case 0:
            _bg = make_color_rgb(20, 25, 32);
            _bc = #C9D3DD;
            break;
        case 1:
            _bg = make_color_rgb(36, 28, 15);
            _bc = #FFE3A3;
            break;
        default:
            _bg = make_color_rgb(24, 18, 34);
            _bc = make_color_hsv((current_time / 14) mod 255, 150, 240);
            break;
    }

    var _a = _d.impl ? 1 : 0.38;     // 未实装整体压暗

    draw_set_alpha(_a);
    draw_set_color(_bg);
    draw_roundrect(_x1, _y1, _x2, _y2, false);
    draw_set_color(_bc);
    draw_roundrect(_x1, _y1, _x2, _y2, true);

    // 已选：金色双框 + 右上角勾
    if (_own > 0) {
        draw_set_alpha(1);
        draw_set_color(#FFD479);
        draw_roundrect(_x1 - 2, _y1 - 2, _x2 + 2, _y2 + 2, true);
        draw_roundrect(_x1 - 4, _y1 - 4, _x2 + 4, _y2 + 4, true);
        draw_line_width(_x2 - 34, _y1 + 24, _x2 - 27, _y1 + 31, 3);
        draw_line_width(_x2 - 27, _y1 + 31, _x2 - 15, _y1 + 13, 3);
    } else {
        draw_set_alpha(_a);
    }

    // 形态竖色条：A 加码绿 / C 减码红
    var _fc = (_d.form == "C") ? #FF6E6E : #7CE38B;
    draw_set_color(_fc);
    draw_rectangle(_x1 + 3, _y1 + 8, _x1 + 7, _y2 - 8, false);

    // 档位徽章（名字左侧）+ 名字。档位不能再放右上角：那里留给「已选」的对勾
    draw_set_font(font_yuan);
    draw_set_valign(fa_middle);
    draw_set_halign(fa_right);
    draw_set_color(_bc);
    draw_text(_x1 + 44, _y1 + 24, hex_tier_name(_d.tier));

    draw_set_halign(fa_left);
    draw_set_color(#F4F8FB);
    draw_text(_x1 + 54, _y1 + 24, hex_ellipsis(_d.name, card_w - 130));

    // 分隔线
    draw_set_color(make_color_rgb(64, 78, 94));
    draw_line(_x1 + 18, _y1 + 42, _x2 - 18, _y1 + 42);

    var _tw = card_w - 36;

    // 卡片侧（形态色）
    draw_set_halign(fa_left);
    draw_set_color(_fc);
    hex_draw_lines(hex_wrap_text(_d.card_desc, _tw), _x1 + 18, _y1 + 46, 21, 3, _tw);

    // 老鼠侧（灰）
    draw_set_alpha(_a * 0.85);
    draw_set_color(#9FB6C9);
    hex_draw_lines(hex_wrap_text(_d.enemy_desc, _tw), _x1 + 18, _y1 + 110, 21, 2, _tw);

    // 底部：左 id / 右叠层或未实装
    draw_set_alpha(_a);
    draw_set_halign(fa_left);
    draw_set_color(#6F8496);
    draw_text(_x1 + 18, _y2 - 15, string_upper(_id));

    draw_set_halign(fa_right);
    if (_own > 0) {
        draw_set_color(#FFD479);
        var _t = "×" + string(_own);
        if (_d.stack > 1) _t = "叠 " + string(_own) + "/" + string(_d.stack);
        draw_text(_x2 - 16, _y2 - 15, _t);
    } else if (!_d.impl) {
        draw_set_color(#8A8F96);
        draw_text(_x2 - 16, _y2 - 15, "未实装");
    }

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
