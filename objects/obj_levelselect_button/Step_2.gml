if global.save_data.player.level >= player_level_require{
	unlock = true
	for(var i = 0 ; i < array_length(pre_level_require) ; i++){
		if !is_level_completed(pre_level_require[i]){
			unlock = false
		}
	}
}
else{
	unlock = false
}