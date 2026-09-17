if is_card_unlocked(target_card_id){
	if get_card_info_simple(target_card_id).max_shape >= target_shape{
		unlocked = false
	}
}