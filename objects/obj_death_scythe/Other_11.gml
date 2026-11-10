var inst = instance_create_depth_define(x + 50, y + 50, depth - 500, obj_death_scythe_bullet);
inst.damage = atk;
inst.shape_b = bullet_shape;

// 子弹外观由 Create 里按「死神意志」星级选定的 bullet_spr 直接指定
inst.sprite_index = bullet_spr;
