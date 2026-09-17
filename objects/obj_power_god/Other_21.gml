function find_priority_air_enemy()
{
    var air_enemy = -4;
    
    with (obj_enemy_parent)
    {
        if (hp > 0 && can_hit(other.target_type, target_type) && target_type == "air")
        {
            if (air_enemy == -4 || x < air_enemy.x)
                air_enemy = id;
        }
    }
    
    return air_enemy;
}

var target = find_priority_air_enemy();

if (target != -4)
{
    var bullet_obj;
    
    if (shape == 3)
        bullet_obj = obj_power_god_bullet_1;
    else
        bullet_obj = obj_power_god_bullet;
    
    var inst = instance_create_depth(x, y - 105, depth - 500, bullet_obj);
    inst.damage = atk;
    inst.move_speed = 10;
    inst.target_enemy = target;
    inst.banding_card_obj = id;
    inst.row = grid_row;
    inst.bullet_shape = shape;
}