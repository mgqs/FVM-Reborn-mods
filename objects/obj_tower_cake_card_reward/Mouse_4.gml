if unlocked && !obj_tower_cake_bg.is_submenu_opened{
	if is_card_unlocked(target_card_id){
		upgrade_card_shape(target_card_id,target_shape)
		audio_play_sound(snd_button,0,0)
		show_notice("卡片转职已获取",60)
	}
	else{
		show_notice("该卡片未解锁，无法领取",60)
	}
}