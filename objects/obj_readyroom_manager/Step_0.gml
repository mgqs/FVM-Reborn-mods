
    if (not audio_is_playing(readyroom_music)) {
        // 停止可能存在的暂停实例
        audio_stop_sound(readyroom_music);
        // 从头开始播放新实例
        global.audio.play(readyroom_music, 0, 0);
    }
if keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_right){
	if instance_exists(obj_quit_confirm){
		instance_destroy(obj_quit_confirm)
	}
	else{
		if !is_submenu_open{
			instance_create_depth(room_width / 2,room_height / 2,-100,obj_quit_confirm)
		}
	}
}

if instance_exists(obj_quit_confirm) || instance_exists(obj_level_preview){
	is_submenu_open = true
}
else{
	is_submenu_open = false
}

if (fly_active) {
	fly_t++;
	if (fly_t >= fly_dur) fly_active = false;
}
for (var _bi = array_length(fly_batch) - 1; _bi >= 0; _bi--) {
	fly_batch[_bi].t++;
	if (fly_batch[_bi].t >= fly_batch[_bi].dur) array_delete(fly_batch, _bi, 1);
}

// Allow a hovered pool card to be assigned directly to its bound deck slot.
if (hover_card_index != -1 && !is_submenu_open && !instance_exists(obj_package_bg)) {
	var _pool_index = deck_sort_order[hover_card_index];
	var _hot_card = global.player_deck[| _pool_index];
	for (var _slot_key = 1; _slot_key <= deck_slot_max(); _slot_key++) {
		var _key = global.keybind_map[? "卡槽" + string(_slot_key)];
		if (_key == undefined || !keyboard_check_pressed(_key)) continue;

		var _slot = _slot_key - 1;
		if ((_hot_card == "lihe" && !is_random_gift_mode())
		|| (is_random_gift_mode() && !random_gift_is_direct_card_allowed(_hot_card))) break;

		var _card_info = get_card_info_simple(_hot_card);
		if (_card_info != false) {
			var _page = (_slot >= 11) ? 10 : 0;
			if (deck_first_slot_index != _page) deck_first_slot_index = _page;
			global.audio.play(snd_button, 0, 0);
			if (!deck_slot_is_empty(_slot)) {
				var _old = global.selected_deck[| _slot];
				var _old_id = _old[? "card_id"];
				var _old_index = readyroom_pool_visual_index(_old_id);
				if (_old_index >= 0) array_push(fly_batch, {add:false, spr:_old[? "data"][? "sprite"], sx:x+805+(_slot-deck_first_slot_index)*86, sy:y+132, tx:(x+42+(_old_index mod slot_rows)*84)+(x-25+803-42), ty:(y+48+(_old_index div slot_rows)*96-y_offset)+(y+375-48), t:0, dur:18, pool_i:_old_index});
			}
			if (add_to_deck(_hot_card, _card_info.shape, _slot)) {
				fly_active = true; fly_add = true; fly_t = 0; fly_dur = 18;
				fly_spr = hover_card_spr; fly_sx = hover_card_x; fly_sy = hover_card_y;
				fly_tx = x+805+(_slot-deck_first_slot_index)*86; fly_ty = y+132; fly_slot = _slot;
			}
		}
		break;
	}
}

// Advance queued flight animations after input has had a chance to enqueue them.

