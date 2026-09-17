if (shape >= 1)
{
    var _x = x;
    
    if (instance_exists(hitted_enemy))
        _x = hitted_enemy.x;
    
    var _range = 165;
    var splash_ratio = 0.8;
    
    with (obj_enemy_parent)
    {
        if (hp > 0 && abs(x - _x) < _range && abs(grid_row - other.row) <= 1 && id != other.hitted_enemy && can_hit("rotate", target_type))
        {
            damage_amount = other.damage * splash_ratio;
            damage_type = other.damage_type;
            event_user(0);
        }
    }
}
