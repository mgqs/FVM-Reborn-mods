var bullet_obj;

if (shape == 0)
    bullet_obj = obj_sh_b;
else if (shape == 1)
    bullet_obj = obj_sh_b_1;
else if (shape == 2)
    bullet_obj = obj_sh_b_2;
else if (shape == 3)
    bullet_obj = obj_sh_b_3;

var inst = instance_create_depth(x + 50, y - 153, depth - 500, bullet_obj);
audio_play_sound(snd_shot, 0, 0);
inst.damage = atk;
inst.move_speed = 0;
inst.shape = shape;
inst.row = grid_row;
inst.start_col = grid_col;
