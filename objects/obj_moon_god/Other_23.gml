function find_priority_enemy()
{
    var priority_enemy = -4;
    var closest_left_enemy = -4;
    var air_enemy = -4;
    var min_x = room_width;
    var max_hp = 0;
    var right_range = 150;
    
    with (obj_enemy_parent)
    {
        if (hp > 0 && can_hit(other.target_type, target_type))
        {
            if (x >= other.x && x <= (other.x + right_range) && grid_row == other.grid_row)
            {
                if (priority_enemy == -4 || hp > priority_enemy.hp)
                    priority_enemy = id;
            }
            
            if (target_type == "air")
            {
                if (air_enemy != -4 && instance_exists(air_enemy))
                {
                    if (x < air_enemy.x)
                        air_enemy = id;
                }
                else
                {
                    air_enemy = id;
                }
            }
            
            if (x < min_x || (x == min_x && hp > max_hp))
            {
                min_x = x;
                max_hp = hp;
                closest_left_enemy = id;
            }
        }
    }
    
    if (priority_enemy != -4)
        return priority_enemy;
    
    if (air_enemy != -4)
        return air_enemy;
    
    return closest_left_enemy;
}

var target = find_priority_enemy();
var inst = instance_create_depth(x, y - 55, depth - 500, obj_moon_god_bullet_super);

if (shape == 2)
    inst.sprite_index = spr_moon_god_bullet_2_s;

if (shape == 3)
    inst.sprite_index = spr_moon_god_bullet_3_s;

inst.damage = 2 * final_atk;
inst.move_speed = 10;
inst.target_enemy = target;
inst.banding_card_obj = id;
inst.row = grid_row;
audio_play_sound(snd_throw, 0, 0);