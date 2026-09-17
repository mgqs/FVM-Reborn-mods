if (shape == 2)
{
    var inst = instance_create_depth(x + 40, y - 50, depth - 500, obj_war_god_bullet_super);
    inst.damage = 8 * atk;
    inst.move_speed = 8;
    inst.row = grid_row;
}

if (shape == 3)
{
    var inst = instance_create_depth(x + 40, y - 50, depth - 500, obj_war_god_bullet_super);
    inst.damage = 12 * atk;
    inst.move_speed = 8;
    inst.row = grid_row;
    var inst2 = instance_create_depth(x - 40, y - 50, depth - 500, obj_war_god_bullet_super);
    inst2.damage = 12 * atk;
    inst2.move_speed = -8;
    inst2.row = grid_row;
    inst2.image_angle = 180;
}
