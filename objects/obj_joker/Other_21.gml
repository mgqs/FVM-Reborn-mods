var bullet_obj = obj_joker_bullet;

switch (shape)
{
    case 0:
        bullet_obj = obj_joker_bullet;
        break;
    
    case 1:
        bullet_obj = obj_joker_bullet_1;
        break;
    
    case 2:
        bullet_obj = obj_joker_bullet_2;
        break;
    
    case 3:
        bullet_obj = obj_joker_bullet_3;
        break;
}

var inst = instance_create_depth(x + 20, y - 85, depth - 45, bullet_obj);
inst.damage = atk;
inst.move_speed = 7;
inst.row = grid_row;
inst.target_type = target_t;
inst.shape = shape;