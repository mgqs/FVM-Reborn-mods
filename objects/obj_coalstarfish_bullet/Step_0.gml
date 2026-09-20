if global.is_paused{
	image_speed = 0
	exit
	
}
image_speed = 1
if burnt == 1{
	sprite_index = spr_fire_bullet
}
x += move_speed
y += y_move_speed

// 类型过滤碰撞检测
if (variable_global_exists("enemy_by_type"))
{
    for (var _t = 0; _t < array_length(hittable_types); _t++)
    {
        var _key = hittable_types[_t];
        if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
        var _list = global.enemy_by_type[$ _key];
        for (var _i = 0; _i < array_length(_list); _i++)
        {
            var _e = _list[_i];
            if (!instance_exists(_e)) continue;
            if (_e.hp > 0 && (b_type == 0 || (b_type == 1 && row == _e.grid_row))
                && bbox_right >= _e.bbox_left && bbox_left <= _e.bbox_right
                && bbox_bottom >= _e.bbox_top && bbox_top <= _e.bbox_bottom)
            {
                with (_e)
                {
                    if other.burnt == 1{
                        audio_play_sound(snd_fire_hit,0,0)
                    }
                    else{
                        audio_play_sound(hit_sound,0,0)
                    }
                    damage_amount = other.damage
                    damage_type = other.damage_type
                    event_user(0)
                }
                if burnt == 0{
                    //instance_create_depth(x,y,depth,obj_xiaolongbao_bullet_effect)
                }
                else{
                    var inst = instance_create_depth(x+25,y,depth,obj_fire_bullet_effect)
                    inst.sprite_index = spr_fire_bullet_effect
                }
                instance_destroy()
                exit
            }
        }
    }
}

if x > 2200 or y > 1200 or x < 0 or y < -200{
    instance_destroy()
}