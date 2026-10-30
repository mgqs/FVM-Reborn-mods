// obj_immortal_pick · Draw 事件（房间坐标，模态、盖在菜单之上）
//   2026-10-30：由 Draw GUI 改回 Draw —— 工程统一用房间坐标画界面，GUI 层尺寸跟房间不一致会画不到位置
draw_set_alpha(0.7);
draw_set_colour(c_black);
draw_rectangle(0, 0, gw, gh, false);
draw_set_alpha(1);

draw_set_font(font_yuan);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// ── 标题（黑描边 + 金字）──
draw_set_colour(c_black);
draw_text_transformed(cx + 3, title_y + 3, "不朽难度 · 开局奖励", 2.2, 2.2, 0);
draw_set_colour(make_colour_rgb(255, 226, 130));
draw_text_transformed(cx, title_y, "不朽难度 · 开局奖励", 2.2, 2.2, 0);

// ── 副标题 ──
draw_set_colour(make_colour_rgb(226, 232, 240));
draw_text_transformed(cx, sub_y, "15 万金币 · 暖暖鸡 已发放，请选择一张自选卡", 1.15, 1.15, 0);

// ── 卡位（按卡片数自动居中，2026-10-31 从写死 3 张改成通用）──
var _n   = array_length(cards);
var _off = (_n - 1) * 0.5;
for (var i = 0; i < _n; i++){
    var _cid = cards[i];
    var _inf = immortal_pick_info_of(_cid);     // {dif, star}
    var _x   = cx + (i - _off) * spacing;
    var _sel = (selected == i);
    var _hov = (hover_card == i);
    var _sc  = slot_sc * (_sel ? 1.04 : (_hov ? 1.02 : 1.0));
    var _w   = sprite_get_width(spr_slot) * _sc;
    var _h   = sprite_get_height(spr_slot) * _sc;

    if (_sel){
        // 选中：金色外发光 + 粗描边
        draw_set_alpha(0.30);
        draw_set_colour(make_colour_rgb(255, 216, 96));
        draw_roundrect_ext(_x - _w * 0.5 - 16, card_cy - _h * 0.5 - 16,
                           _x + _w * 0.5 + 16, card_cy + _h * 0.5 + 16, 26, 26, false);
        draw_set_alpha(1);
        draw_set_colour(make_colour_rgb(255, 232, 130));
        draw_roundrect_ext(_x - _w * 0.5 - 9, card_cy - _h * 0.5 - 9,
                           _x + _w * 0.5 + 9, card_cy + _h * 0.5 + 9, 24, 24, true);
    }
    else if (_hov){
        // 悬停（未选中）：淡白框
        draw_set_alpha(0.5);
        draw_set_colour(c_white);
        draw_roundrect_ext(_x - _w * 0.5 - 6, card_cy - _h * 0.5 - 6,
                           _x + _w * 0.5 + 6, card_cy + _h * 0.5 + 6, 22, 22, true);
        draw_set_alpha(1);
    }

    draw_sprite_ext(spr_slot, 0, _x, card_cy, _sc, _sc, 0, c_white, 1);

    // 卡面：最长边缩到框宽的 82%，**按可见内容**垂直居中到白条上方的可视区
    //   🔴 两个坑（2026-10-31 修）：
    //   ① 卡面精灵原点是「内容底部中点」（origin 9/7，如 spr_pan_fried_bun = 37,83），
    //      直接画在卡框中心等于把内容底边贴到中心 → 图案整体往上浮、顶出上沿；
    //   ② 画布下方还有一大截透明留白（生煎锅 88 高只有 y30~84 有内容），
    //      所以不能按画布居中 → 内容高走 immortal_pick_face_h() 的表。
    //   可视区 = 卡框上沿(-0.5h) 到 名字白条上沿(+0.293h)，中心 = -0.103h。
    var _deck = deck_get_card_data(_cid, 0);
    if (_deck != noone){
        var _spr = _deck[? "sprite"];
        if (_spr != undefined){
            var _fs  = (_w * 0.82) / max(sprite_get_width(_spr), sprite_get_height(_spr));
            var _dvh = immortal_pick_face_h();
            var _chc = variable_struct_exists(_dvh, _cid) ? _dvh[$ _cid] : 0;
            var _ay;
            if (_chc > 0){
                // 内容中心落在可视区中心 → 原点(内容底边)在该点下方 内容高/2 处
                _ay = (card_cy - _h * 0.103) + _chc * _fs * 0.5;
            }
            else{
                // 表里没有：按画布中心兜底（原点 → 画布中心的偏移）
                _ay = (card_cy - _h * 0.103)
                    + (sprite_get_yoffset(_spr) - sprite_get_height(_spr) * 0.5) * _fs;
            }
            draw_sprite_ext(_spr, 0, _x, _ay, _fs, _fs, 0, c_white, 1);
        }
    }

    // 卡框上方：开局难度（易=绿 / 中=蓝 / 难=红），文案与颜色走 difficulty_rules
    var _dl = _inf.dif;
    if (_dl != ""){
        var _dt = "开局难度：" + _dl;
        var _ly = card_cy - _h * 0.5 - 46;
        draw_set_colour(c_black);
        draw_text_transformed(_x + 2, _ly + 2, _dt, 1.05, 1.05, 0);
        draw_set_colour(immortal_pick_difficulty_colour(_dl));
        draw_text_transformed(_x, _ly, _dt, 1.05, 1.05, 0);
    }

    // 卡框左上角：开局星级（spr_star_slot 第 star-1 帧，原点在右下角 → 画点 = 图标右下角）
    //   0 星不画（和游戏里 level 0 的表现一致：obj_card_slot 也是 level > 0 才画）
    var _star = _inf.star;
    if (_star > 0){
        var _ss = slot_sc * 1.4;                       // 星级图标缩放（跟着卡框一起缩）
        var _inset = 14 * (slot_sc / 1.15);            // 距卡框左上内边
        var _sw2 = sprite_get_width(spr_star_slot) * _ss;
        var _sh2 = sprite_get_height(spr_star_slot) * _ss;
        draw_sprite_ext(spr_star_slot, min(_star, sprite_get_number(spr_star_slot)) - 1,
                        _x - _w * 0.5 + _inset + _sw2, card_cy - _h * 0.5 + _inset + _sh2,
                        _ss, _ss, 0, c_white, 1);
    }

    // 名字写进卡框下半那条白条
    //   spr_slot 白条在贴图 y 284~336（原点 179 = 中心），即条中心在卡框中心下方 131px；
    //   1.15 倍下 = _h * 0.366。原来用 0.30（=中心下方 123px）偏上约 27px，2026-10-31 下移到 0.365
    var _sd = get_plant_shape_data(_cid, 0);
    var _nm = (_sd != undefined) ? _sd[? "name"] : transfer_credit_card_name(_cid);
    draw_set_colour(_sel ? make_colour_rgb(150, 96, 10) : make_colour_rgb(92, 96, 104));
    draw_text_transformed(_x, card_cy + _h * 0.365, _nm, 1.35, 1.35, 0);

    // 卡框下方一行：选中态写「已选择」
    if (_sel){
        draw_set_colour(make_colour_rgb(255, 232, 130));
        draw_text_transformed(_x, card_cy + _h * 0.5 + 24, "已选择", 1.05, 1.05, 0);
    }
    else{
        draw_set_colour(make_colour_rgb(150, 158, 170));
        draw_text_transformed(_x, card_cy + _h * 0.5 + 24, "点一下选中", 1.0, 1.0, 0);
    }
}

// ── 确定按钮（没选卡时压暗）──
var _bfr = hover_btn ? (mouse_check_button(mb_left) ? 2 : 1) : 0;
mod_ui_common_btn_draw(_bfr, cx, btn_y, btn_sc, (selected == -1) ? 0.45 : 1);
draw_set_colour(c_white);
draw_text_transformed(cx, btn_y, "确定", 1.5, 1.5, 0);

// ── 提示 ──
draw_set_colour(make_colour_rgb(235, 240, 248));
draw_text_transformed(cx, gh * 0.864, "点卡 = 选中；点「确定」正式发放", 1.0, 1.0, 0);
draw_set_colour(make_colour_rgb(168, 176, 190));
draw_text_transformed(cx, gh * 0.910, "异常退出自动按第一张补发", 0.95, 0.95, 0);

// 复位绘制状态，别污染后面的界面
draw_set_colour(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
