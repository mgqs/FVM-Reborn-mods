function deck_init(){
	global.player_deck = ds_list_create();
	global.selected_deck = ds_list_create();
	deck_empty_slot_ensure();
}