// obj_immortal_pick Step 事件（房间坐标判点，跟 Draw_0 同一套坐标）
if (committed) exit;

if (input_guard > 0){
    input_guard -= 1;
    exit;
}

var mx = mouse_x;
var my = mouse_y;

var _hw = sprite_get_width(spr_slot) * slot_sc * 0.5;
var _hh = sprite_get_height(spr_slot) * slot_sc * 0.5;

hover_card = -1;
var _n   = array_length(cards);
var _off = (_n - 1) * 0.5;      // 按卡片数居中（2026-10-31：不再是写死 3 张）
for (var i = 0; i < _n; i++){
    var _x = cx + (i - _off) * spacing;
    if (point_in_rectangle(mx, my, _x - _hw, card_cy - _hh, _x + _hw, card_cy + _hh)){
        hover_card = i;
    }
}

var _bw = sprite_get_width(spr_common_button) * btn_sc;    // 按钮是 2× 贴图，半宽按整宽算（2026-10-30 修）
var _bh = sprite_get_height(spr_common_button) * btn_sc;
hover_btn = point_in_rectangle(mx, my, cx - _bw, btn_y - _bh, cx + _bw, btn_y + _bh);

if (mouse_check_button_pressed(mb_left)){
    if (hover_card != -1){
        // 只改选中态，不发奖
        if (selected != hover_card){
            selected = hover_card;
            audio_play_sound(snd_button, 0, 0);
        }
    }
    else if (hover_btn){
        if (selected == -1 || selected >= array_length(cards)){
            show_notice("先点一张卡，再点确定", 60);
        }
        else if (immortal_pick_commit(cards[selected])){
            committed = true;
            audio_play_sound(snd_button, 0, 0);
            show_notice("已获得" + transfer_credit_card_name(cards[selected]), 90);
            instance_destroy();
        }
    }
}
