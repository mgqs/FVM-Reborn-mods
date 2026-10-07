var inst = instance_create_depth(x, y - 330, depth - 45, obj_gaia_bullet);

if (target_x != -4)
{
    inst.target_x = target_x;
    inst.target_y = target_y;
    inst.row = target_row;
}
else
{
    inst.target_x = get_world_position_from_grid(9, grid_row);
    inst.target_y = y;
    inst.row = grid_row;
}

inst.damage = atk;
inst.shape_bullet = shape;

if (shape == 0)
    inst.sprite_index = spr_gaia_bullet;
else if (shape == 1)
    inst.sprite_index = spr_gaia_bullet_1;
else if (shape == 2)
    inst.sprite_index = spr_gaia_bullet_2;
else
    inst.sprite_index = spr_gaia_bullet_3;
