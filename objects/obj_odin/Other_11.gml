var inst = instance_create_depth(x + 40, y - 95, depth - 500, obj_odin_bullet);

if (shape == 1)
    inst.sprite_index = spr_odin_bullet_1;

if (shape == 2)
    inst.sprite_index = spr_odin_bullet_2;

if (shape == 3)
    inst.sprite_index = spr_odin_bullet_3;

inst.damage = atk;
inst.move_speed = 8;
inst.row = grid_row;
