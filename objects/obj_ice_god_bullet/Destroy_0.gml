// 1 转起的溅射：同行 ±1 行 + 横向 1.5 格（与冷萃机 / 雪球兔同口径，不写死像素）
// 只打主目标以外的、与卡片 target_type 同类的敌人（land_air_ug）
if (shape >= 1)
{
    var _x = x;
    var _row_range = 1;
    var _col_range = global.grid_cell_size_x * 1.5;
    var splash_ratio = 0.40;
    
    with (obj_enemy_parent)
    {
        if (hp > 0 && abs(x - _x) <= _col_range && grid_row <= (other.row + _row_range) && grid_row >= (other.row - _row_range) && id != other.hitted_enemy
            && !scatter_target_blocked(id) && can_target_on(other.target_type, target_type))
        {
            damage_amount = other.damage * splash_ratio;
            damage_type = other.damage_type;
            
            if (ice_timer < 600)
                ice_timer = 600;
            
            event_user(0);
        }
    }
}
