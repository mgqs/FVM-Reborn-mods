if (target_type == "normal" && row == other.row && precise_bbox_collision(id, other))
{
    if (burnt == 0)
    {
        var inst = instance_create_depth(x + 25, y, depth, obj_coffeecup_bullet_effect);
        inst.sprite_index = spr_waterpipe_bullet_effect;
    }
    else
    {
        var inst = instance_create_depth(x + 25, y, depth, obj_fire_bullet_effect);
        inst.sprite_index = spr_fire_bullet_effect;
    }
    
    instance_destroy();
}
