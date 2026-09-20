if global.is_paused{
	image_speed = 0
	exit
	
}
image_speed = 1
x += move_speed
if y > target_y{
	y -= 5
}
if x > 2200 or y > 1200 or x < 0 or y < 0{
	instance_destroy()
}

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
            if (_e.hp > 0 && row == _e.grid_row
                && bbox_right >= _e.bbox_left && bbox_left <= _e.bbox_right
                && bbox_bottom >= _e.bbox_top && bbox_top <= _e.bbox_bottom)
            {
                with (_e)
                {
                    if ice_timer < 600{
                        ice_timer = 600
                    }
                    audio_play_sound(hit_sound,0,0)
                    damage_amount = other.damage
                    damage_type = other.damage_type
                    event_user(0)
                }
                var inst = instance_create_depth(x,y,depth,obj_xiaolongbao_bullet_effect)
                inst.sprite_index = spr_hotdogcannon_bullet_effect
                instance_destroy()
                exit
            }
        }
    }
}