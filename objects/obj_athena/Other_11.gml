var target_enemy = -4;
var min_x = 9999;

with (obj_enemy_parent)
{
    if (hp > 0 && x < min_x)
    {
        min_x = x;
        target_enemy = id;
    }
}

if (target_enemy != -4)
{
    var enemy_speed = 0;
    
    if (variable_instance_exists(target_enemy, "move_speed"))
        enemy_speed = target_enemy.move_speed;
    
    var predicted_x = target_enemy.x - (enemy_speed * 30);
    var target_y = target_enemy.y - 50;
    var target_row = target_enemy.grid_row;
    var target_col = target_enemy.grid_col;
    var bullet = instance_create_depth(predicted_x + 100, target_y, depth - 1, obj_athena_bullet);
    bullet.atk = atk;
    bullet.target_x = predicted_x;
    bullet.target_y = target_y;
    bullet.grid_row = target_row;
    bullet.grid_col = target_col;
}
