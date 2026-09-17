var inst = instance_create_depth(x + 40, y - 95, depth - 500, obj_tianxie_bullet);
audio_play_sound(snd_shot, 0, 0);
inst.damage = atk;
inst.move_speed = 20;
inst.row = grid_row;
