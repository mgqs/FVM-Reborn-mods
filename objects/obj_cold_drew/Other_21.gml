var total_bullets = (shape == 2) ? 6 : array_length(target_list);
var temp_targets = [];

for (var i = 0; i < array_length(target_list); i++)
    array_push(temp_targets, target_list[i]);

if (shape == 2 && array_length(temp_targets) < total_bullets)
{
    var max_hp = -1;
    
    for (var i = 0; i < array_length(temp_targets); i++)
    {
        var t = temp_targets[i];
        
        if (t != -4 && instance_exists(t))
        {
            if (t.maxhp > max_hp)
            {
                max_hp = t.maxhp;
                main_target = t;
            }
        }
    }
    
    var bullets_to_add = total_bullets - array_length(temp_targets);
    
    for (var i = 0; i < bullets_to_add; i++)
        array_push(temp_targets, main_target);
}

var repeat_index = 0;

for (var i = 0; i < total_bullets; i++)
{
    var t = temp_targets[i];
    
    if (t != -4 && instance_exists(t))
    {
        var inst = instance_create_depth(t.x, t.y - 20, t.depth - 1, obj_cold_drew_bullet);
        inst.target_id = t.id;
        inst.damage = atk;
        inst.row = t.grid_row;
        inst.shape_bullet = shape;
        
        if (t == main_target)
        {
            inst.delay = repeat_index * 10;
            repeat_index++;
        }
        else
        {
            inst.delay = 0;
        }
    }
}