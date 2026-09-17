if ds_list_find_index(brazier_list,other.id) == -1 && burnt == 0 && row == other.grid_row && timer >= 4*3 && !disabled{
	burnt += 1
	damage = round(damage * other.atk)
	ds_list_add(brazier_list,other.id)
	audio_play_sound(snd_bullet_burnt,0,0)
	sprite_index = spr_fire_tarsprayer_bullet
}