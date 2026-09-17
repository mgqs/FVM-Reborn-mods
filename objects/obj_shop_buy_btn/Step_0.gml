if btn_type == "item"{
	is_disabled = false
	if target_item == "card_slot_19" && global.save_data.unlocked_items.max_slot > 18{
		is_disabled = true
	}
	if target_item == "card_slot_20" && global.save_data.unlocked_items.max_slot > 19{
		is_disabled = true
	}
	if target_item == "card_slot_21" && global.save_data.unlocked_items.max_slot > 20{
		is_disabled = true
	}
	if target_item == "card_slot" && global.save_data.unlocked_items.max_slot >= 18{
		is_disabled = true
	}
}