if global.is_paused{
	image_speed = 0
	exit
}
else{
	if (custom_playback) {
		playback_progress += playback_speed;
		if (playback_progress >= sprite_get_number(sprite_index)) {
			instance_destroy();
			exit;
		}
		image_speed = 0;
		image_index = floor(playback_progress);
	} else {
		image_speed = 1;
	}
}

if (!custom_playback && timer <= 18){
	timer ++
	} else if (!custom_playback) {
	instance_destroy()
}
