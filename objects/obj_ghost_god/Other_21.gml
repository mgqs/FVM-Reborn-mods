var inst = instance_create_depth(x, y - 50, depth - 500, obj_ghost_god_bullet_ping);

if (shape == 1)
    inst.sprite_index = spr_ghost_god_bullet_1;

if (shape == 2)
    inst.sprite_index = spr_ghost_god_bullet_2;

if (shape == 3)
    inst.sprite_index = spr_ghost_god_bullet_3;

inst.damage = atk;
inst.move_speed = -8;
inst.row = grid_row;
inst.image_angle = 180;
var inst2 = instance_create_depth(x, y - 50, depth - 500, obj_ghost_god_bullet_zhi);

if (shape == 1)
    inst2.sprite_index = spr_ghost_god_bullet_1;

if (shape == 2)
    inst2.sprite_index = spr_ghost_god_bullet_2;

if (shape == 3)
    inst2.sprite_index = spr_ghost_god_bullet_3;

inst2.damage = atk;
inst2.move_speed = 8;
inst2.col = grid_col;
inst2.image_angle = 270;
var inst3 = instance_create_depth(x, y - 50, depth - 500, obj_ghost_god_bullet_zhi);

if (shape == 1)
    inst3.sprite_index = spr_ghost_god_bullet_1;

if (shape == 2)
    inst3.sprite_index = spr_ghost_god_bullet_2;

if (shape == 3)
    inst3.sprite_index = spr_ghost_god_bullet_3;

inst3.damage = atk;
inst3.move_speed = -8;
inst3.col = grid_col;
inst3.image_angle = 90;
var inst4 = instance_create_depth(x, y - 50, depth - 500, obj_ghost_god_bullet_xie);

if (shape == 1)
    inst4.sprite_index = spr_ghost_god_bullet_1;

if (shape == 2)
    inst4.sprite_index = spr_ghost_god_bullet_2;

if (shape == 3)
    inst4.sprite_index = spr_ghost_god_bullet_3;

inst4.damage = atk;
inst4.move_speed = 8;
inst4.col = grid_col;
inst4.image_angle = 315;
var inst5 = instance_create_depth(x, y - 50, depth - 500, obj_ghost_god_bullet_xie);

if (shape == 1)
    inst5.sprite_index = spr_ghost_god_bullet_1;

if (shape == 2)
    inst5.sprite_index = spr_ghost_god_bullet_2;

if (shape == 3)
    inst5.sprite_index = spr_ghost_god_bullet_3;

inst5.damage = atk;
inst5.move_speed = -8;
inst5.col = grid_col;
inst5.image_angle = 45;
