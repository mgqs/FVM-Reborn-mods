var spr = spr_spoon_rabbit_bullet;

if (shape == 1)
    spr = spr_spoon_rabbit_bullet_1;
else if (shape >= 2)
    spr = spr_spoon_rabbit_bullet_2;

var inst_mid = instance_create_depth(x, y - 160, depth - 45, obj_spoon_rabbit_bullet);
inst_mid.damage = atk;
inst_mid.row = grid_row;
inst_mid.thrower_y = y;
inst_mid.sprite_index = spr;
var move_speed = 10;
var cvspeed = 6;
var cgravity = 0.2;

if (target_instance != -4 && instance_exists(target_instance))
{
    var enemy_x = target_instance.x;
    var enemy_y = target_instance.y;
    var enemy_speed = target_instance.move_speed;
    var distance_x = enemy_x - inst_mid.x;
    var flight_time = clamp(30 + ((distance_x / 1000) * 45), 30, 75);
    var predicted_x = enemy_x - (enemy_speed * flight_time) - 70;
    
    if (predicted_x < x)
        predicted_x = x;
    
    var total_distance_x = predicted_x - inst_mid.x;
    var total_distance_y = 400;
    move_speed = total_distance_x / flight_time;
    cgravity = (2 * total_distance_y) / (flight_time * flight_time);
    cvspeed = (total_distance_y - (0 * cgravity * flight_time * flight_time)) / flight_time;
}

inst_mid.move_speed = move_speed;
inst_mid.cgravity = cgravity;
inst_mid.cvspeed = cvspeed;
inst_mid.hit_enemy = false;

if (shape == 2)
{
    var inst_up = instance_create_depth(x, y - 160 - global.grid_cell_size_y, depth, obj_spoon_rabbit_bullet);
    inst_up.damage = atk;
    inst_up.row = grid_row - 1;
    inst_up.thrower_y = y - global.grid_cell_size_y;
    inst_up.sprite_index = spr;
    
    if (grid_row == 0)
    {
        inst_up.x -= 15;
        inst_up.y += global.grid_cell_size_y;
        inst_up.image_angle -= 30;
        inst_up.row = grid_row;
        inst_up.thrower_y += global.grid_cell_size_y;
    }
    
    inst_up.move_speed = move_speed;
    inst_up.cgravity = cgravity;
    inst_up.cvspeed = cvspeed;
    inst_up.hit_enemy = false;
    var inst_down = instance_create_depth(x, (y - 160) + global.grid_cell_size_y, depth - 90, obj_spoon_rabbit_bullet);
    inst_down.damage = atk;
    inst_down.row = grid_row + 1;
    inst_down.thrower_y = y + global.grid_cell_size_y;
    inst_down.sprite_index = spr;
    
    if (grid_row == (global.grid_rows - 1))
    {
        inst_down.x -= 15;
        inst_down.y -= global.grid_cell_size_y;
        inst_down.image_angle -= 30;
        inst_down.row = grid_row;
        inst_down.thrower_y -= global.grid_cell_size_y;
    }
    
    inst_down.move_speed = move_speed;
    inst_down.cgravity = cgravity;
    inst_down.cvspeed = cvspeed;
    inst_down.hit_enemy = false;
}