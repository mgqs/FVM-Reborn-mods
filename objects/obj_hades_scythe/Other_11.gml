var inst = instance_create_depth(x + 120, y + 50, depth - 500, obj_hades_scythe_bullet);
inst.damage = atk;
inst.shape_b = bullet_shape;

switch (inst.shape_b)
{
    case 0:
        inst.sprite_index = spr_hades_scythe_bullet;
        break;
    
    case 1:
        inst.sprite_index = spr_hades_scythe_bullet_1;
        break;
    
    case 2:
        inst.sprite_index = spr_hades_scythe_bullet_2;
        break;
    
    case 3:
        inst.sprite_index = spr_hades_scythe_bullet_3;
        break;
    
    case 4:
        inst.sprite_index = spr_hades_scythe_bullet_4;
        break;
}
