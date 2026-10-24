if hover_card_index != -1 && !is_submenu_open{
	if deck_slot_first_empty() != -1{
		global.audio.play(snd_button,0,0)
		var card_id = global.player_deck[| deck_sort_order[hover_card_index]];
		if ((card_id == "lihe" && !is_random_gift_mode()) || (is_random_gift_mode() && !random_gift_is_direct_card_allowed(card_id))) exit;
		var _shape_info = get_card_info_simple(card_id)
		if _shape_info != false{
			var _slot = deck_slot_first_empty();
			if (add_to_deck(card_id,_shape_info.shape)) {
				fly_active = true; fly_add = true; fly_t = 0; fly_dur = 18;
				fly_spr = hover_card_spr; fly_sx = hover_card_x; fly_sy = hover_card_y;
				fly_slot = _slot; fly_tx = x+805+(_slot-deck_first_slot_index)*86; fly_ty = y+132;
			}
		}
	}
}
if hover_slot_index != -1 && !is_submenu_open{
	if !deck_slot_is_empty(hover_slot_index){
		global.audio.play(snd_button,0,0)
		var _removed = global.selected_deck[| hover_slot_index];
		var _removed_id = _removed[? "card_id"];
		var _removed_spr = _removed[? "data"][? "sprite"];
		var _pool_i = readyroom_pool_visual_index(_removed_id);
		if (_pool_i >= 0 && sprite_exists(_removed_spr)) {
			fly_active = true; fly_add = false; fly_t = 0; fly_dur = 18;
			fly_spr = _removed_spr; fly_slot = hover_slot_index; fly_pool_i = _pool_i;
			fly_sx = x+805+(hover_slot_index-deck_first_slot_index)*86; fly_sy = y+132;
			fly_tx = (x+42+(_pool_i mod slot_rows)*84)+(x-25+803-42); fly_ty = (y+48+(_pool_i div slot_rows)*96-y_offset)+(y+375-48);
		}
		remove_from_deck(hover_slot_index)
	}
}
if(mouse_x > 785 && mouse_x < 1546 && mouse_y > 762 && mouse_y < 980) && !is_submenu_open{
	global.audio.play(snd_button,0,0)
	var inst = instance_create_depth(0,0,-500,obj_level_preview)
	inst.enemy_type_list = enemy_type_list
	inst.boss_type_list = boss_type_list
}
