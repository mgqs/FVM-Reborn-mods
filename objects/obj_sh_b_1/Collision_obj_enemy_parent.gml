if (ds_list_find_index(hitted_enemy, other.id) == -1)
{
    if (other.hp > 0 && (row == (other.grid_row - 1) || row == other.grid_row || row == (other.grid_row + 1)) && can_hit(target_type, other.target_type))
    {
        with (other)
        {
            audio_play_sound(hit_sound, 0, 0);
            
            if (random(100) < 20)
            {
                if (stun_timer < 120)
                    stun_timer = 120;
            }
            
            if (hp > other.damage)
            {
                hp -= other.damage;
                event_user(0);
            }
            else
            {
                if (special_ash)
                {
                    var inst = instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                    inst.special_ash = true;
                    inst.sprite_index = sprite_index;
                    inst.image_index = image_index;
                }
                else
                {
                    instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                }
                
                instance_destroy();
            }
        }
        
        ds_list_add(hitted_enemy, other.id);
    }
}
