// 行门禁：只被「逻辑行 == 本障碍行」的子弹撞到才销毁（口径见 obstacle_should_block）
if (!obstacle_should_block(id, other)) exit;

if (damage_type != "pierce" && target_type == "normal" && precise_bbox_collision(id, other))
{
    if (burnt == 0)
    {
        instance_create_depth(x, y, depth, obj_xiaolongbao_bullet_effect);
    }
    else
    {
        var inst = instance_create_depth(x + 25, y, depth, obj_fire_bullet_effect);
        inst.sprite_index = spr_fire_bullet_effect;
    }
    
    instance_destroy();
}
