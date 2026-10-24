if (shape >= 1)
{
    var _x = x;
    
    if (instance_exists(hitted_enemy))
        _x = hitted_enemy.x;
    
    var _range = 165;
    var splash_ratio = 0.4;
    
    with (obj_enemy_parent)
    {
        if (hp > 0 && abs(x - _x) < _range && abs(grid_row - other.row) <= 1 && id != other.hitted_enemy && can_hit("rotate", target_type))
        {
            damage_amount = other.damage * splash_ratio;
            damage_type = other.damage_type;
            // 已通过 can_hit("rotate") 判定，允许命中钻地中的地精鼠（同鼹鼠规则）
            if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
            event_user(0);
        }
    }
}
