if !obj_readyroom_manager.is_submenu_open{
	global.audio.play(snd_button,0,0)
	var _n = 0
	for (var _i = obj_readyroom_manager.deck_first_slot_index; _i < min(obj_readyroom_manager.deck_first_slot_index + 11, deck_slot_max()); _i++) {
		if (deck_slot_is_empty(_i)) continue;
		var _entry = global.selected_deck[| _i]; var _id = _entry[? "card_id"];
		var _pi = obj_readyroom_manager.readyroom_pool_visual_index(_id);
		if (_pi < 0) continue;
		array_push(obj_readyroom_manager.fly_batch, {add:false, spr:_entry[? "data"][? "sprite"], sx:obj_readyroom_manager.x+805+(_i-obj_readyroom_manager.deck_first_slot_index)*86, sy:obj_readyroom_manager.y+132, tx:(obj_readyroom_manager.x+42+(_pi mod obj_readyroom_manager.slot_rows)*84)+(obj_readyroom_manager.x-25+803-42), ty:(obj_readyroom_manager.y+48+(_pi div obj_readyroom_manager.slot_rows)*96-obj_readyroom_manager.y_offset)+(obj_readyroom_manager.y+375-48), t:(ui_anim_level() >= 2) ? -_n * 2 : 0, dur:18, pool_i:_pi});
		_n++
	}
	obj_readyroom_manager.deck_first_slot_index = 0;
	clear_deck()
}
