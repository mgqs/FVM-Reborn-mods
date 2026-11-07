// obj_nutfrier_bullet · 金牛座过火增幅
// 口径与同对象的 Collision_obj_brazier 完全一致：本卡是五向弹，斜向弹会跨行，所以**不判行**
if ds_list_find_index(brazier_list,other.id) == -1 && burnt == 0{
	burnt += 1
	damage = round(damage * other.atk)
	bullet_fire_mult_up(id, other.atk)
	ds_list_add(brazier_list,other.id)
	audio_play_sound(snd_bullet_burnt,0,0)
}
