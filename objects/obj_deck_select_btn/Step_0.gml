if obj_readyroom_manager.selected_custom_deck == deck_index{
	image_index = 1
}
else{
	image_index = 0
}
if !instance_exists(banding_button_index){
	banding_button_index = instance_create_depth(x-48,y+3,depth-1,obj_deck_save_btn)
	banding_button_index.deck_index = deck_index
}
deck_name = global.save_data.saved_decks[deck_index-1].name