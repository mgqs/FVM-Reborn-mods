var total_bullets = 8;

if (shape == 2)
    total_bullets = 10;
else if (shape == 3)
    total_bullets = 12;

var enemy_queue = ds_priority_create();

with (obj_enemy_parent)
{
    if (hp > 0)
        ds_priority_add(enemy_queue, id, x);
}

var valid_enemies = [];

while (!ds_priority_empty(enemy_queue))
    array_push(valid_enemies, ds_priority_delete_min(enemy_queue));

ds_priority_destroy(enemy_queue);
var enemy_count = array_length(valid_enemies);

if (enemy_count > 0)
{
    for (var i = 0; i < total_bullets; i++)
    {
        var target_index = i % enemy_count;
        var target_enemy = valid_enemies[target_index];
        var enemy_x = target_enemy.x;
        var enemy_y = target_enemy.y;
        var enemy_speed = 0;
        
        if (variable_instance_exists(target_enemy, "move_speed"))
            enemy_speed = target_enemy.move_speed;
        
        var spawn_y = enemy_y - 600 - (i * 50);
        var predicted_x = enemy_x - ((enemy_speed * (600 - (i * 50))) / 40);
        var inst = instance_create_depth(predicted_x, spawn_y, depth - 500, obj_ice_god_bullet);
        
        if (shape == 3)
            inst.sprite_index = spr_ice_god_bullet_1;
        
        inst.damage = atk;
        inst.target_instance = target_enemy;
        inst.target_x = predicted_x;
        inst.target_y = enemy_y;
        inst.move_speed = 40;
        inst.shape = shape;
    }
}