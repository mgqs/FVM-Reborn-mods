if (other.hp > 0 && row == other.grid_row && can_hit(target_type, other.target_type))
{
    with (other)
    {
        audio_play_sound(hit_sound, 0, 0);
        damage_amount = other.damage;
        damage_type = other.damage_type;
        event_user(0);
    }
    
    hitted_enemy = other.id;
    var ef = instance_create_depth(x, y, depth, obj_xiaolongbao_bullet_effect);
    var spr = spr_joker_be0;
    ef.sprite_index = spr;
    instance_destroy();
}
