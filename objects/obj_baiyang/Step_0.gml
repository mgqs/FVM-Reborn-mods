if (global.is_paused)
    exit;

event_inherited();

if (!spawned)
{
    spawned = true;
    var car_mid = instance_create_depth(x, y, depth - 500, obj_baiyang_effect);
    car_mid.atk = atk;
    car_mid.grid_row = grid_row;
    
    if (shape == 2)
    {
        if ((grid_row - 1) >= 0)
        {
            var car_up = instance_create_depth(x, y - 100, depth - 500, obj_baiyang_effect);
            car_up.atk = atk;
            car_up.grid_row = grid_row - 1;
        }
        
        if ((grid_row + 1) < global.grid_rows)
        {
            var car_down = instance_create_depth(x, y + 100, depth - 500, obj_baiyang_effect);
            car_down.atk = atk;
            car_down.grid_row = grid_row + 1;
        }
    }
    
    instance_destroy();
}
