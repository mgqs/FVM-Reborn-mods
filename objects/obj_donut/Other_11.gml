var inst = instance_create_depth(x + 20, y - 30, depth - 45, obj_donut_bullet);
inst.damage = atk;
inst.move_speed = 6;
inst.row = grid_row;
inst.target_type = target_t;
inst.hittable_types = get_hittable_enemy_types(inst.target_type);
inst.shape = shape;
var spr = spr_donut_bullet;

switch (shape)
{
    case 0:
        spr = spr_donut_bullet;
        break;
    
    case 1:
        spr = spr_donut_bullet_1;
        break;
    
    case 2:
        spr = spr_donut_bullet_2;
        break;
}

inst.sprite_index = spr;
