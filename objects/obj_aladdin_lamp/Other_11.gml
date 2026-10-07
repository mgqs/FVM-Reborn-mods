var _traces = [];

switch (bullet_trace)
{
    case 0:
        _traces = [[8, 270], [5, 90], [2, 270]];
        break;
    
    case 1:
        _traces = [[4, 90], [8, 90], [2, 270], [6, 270]];
        break;
    
    case 2:
        _traces = [[0, 270], [4, 270], [8, 270], [2, 90], [6, 90]];
        break;
    
    case 3:
        _traces = [[0, 270], [4, 270], [8, 270], [2, 90], [6, 90], [9, 90]];
        break;
}

for (var ti = 0; ti < array_length(_traces); ti++)
{
    var _col = _traces[ti][0];
    var _dir = _traces[ti][1];
    
    if (_dir != fire_dir)
        continue;
    
    var _pos = get_world_position_from_grid(_col, 0);
    var _sx = _pos.x;
    var _sy = (_dir == 270) ? (global.grid_offset_y - 80) : (global.grid_offset_y + (global.grid_rows * global.grid_cell_size_y) + 80);
    var inst = instance_create_depth_define(_sx, _sy, depth - 500, obj_aladdin_lamp_bullet);
    inst.damage = atk;
    inst.direction = _dir;
    inst.splash_ratio = splash_ratio;
    
    switch (bullet_shape)
    {
        case 0:
            inst.sprite_index = spr_aladdin_lamp_bullet;
            break;
        
        case 1:
            inst.sprite_index = spr_aladdin_lamp_bullet_1;
            break;
        
        case 2:
            inst.sprite_index = spr_aladdin_lamp_bullet_2;
            break;
        
        case 3:
            inst.sprite_index = spr_aladdin_lamp_bullet_3;
            break;
        
        case 4:
            inst.sprite_index = spr_aladdin_lamp_bullet_4;
            break;
    }
}
