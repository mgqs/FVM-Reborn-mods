if (shape >= 1)
{
    var _x = x;
    var _y = y;
    var _row_range = 1;
    var _range = 200;
    var splash_ratio = 0.45;
    
    with (obj_enemy_parent)
    {
        if (hp > 0 && point_distance(x, y, _x, _y) < _range && grid_row <= (other.row + _row_range) && grid_row >= (other.row - _row_range) && id != other.hitted_enemy)
        {
            damage_amount = other.damage * splash_ratio;
            damage_type = other.damage_type;
            
            if (ice_timer < 600)
                ice_timer = 600;
            
            event_user(0);
        }
    }
}
