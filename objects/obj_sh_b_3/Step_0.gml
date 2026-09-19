if (global.is_paused)
    exit;

timer++;
image_index = floor(timer / 5);

// AABB 包围盒重叠检测：补充物理碰撞事件对地下敌人的漏检
with (obj_enemy_parent)
{
    if (ds_list_find_index(other.hitted_enemy, id) == -1
        && hp > 0
        && (other.row == grid_row - 1 || other.row == grid_row || other.row == grid_row + 1)
        && can_hit(other.target_type, target_type)
        && bbox_right >= other.bbox_left && bbox_left <= other.bbox_right
        && bbox_bottom >= other.bbox_top && bbox_top <= other.bbox_bottom)
    {
        audio_play_sound(hit_sound, 0, 0);
        if (random(100) < 20 && stun_timer < 120)
            stun_timer = 120;

        var is_crit = false;
        if (random(100) < 20)
        {
            is_crit = true;
            instance_create_depth(x, y - 30, depth + 10, obj_sh_b_3_e);
        }

        var final_damage = other.damage;
        if (is_crit) final_damage *= 2;

        if (hp > final_damage)
        {
            hp -= final_damage;
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
                instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
            instance_destroy();
        }
        ds_list_add(other.hitted_enemy, id);
    }
}

if (!instance_exists(banding_card_obj) || banding_card_obj.state != CARD_STATE.ATTACK)
    event_user(7);
