var inst = instance_create_depth(x + 40, y + 50, depth - 500, obj_zeus_bolt_bullet);
inst.damage = atk;
inst.move_speed = 10;
inst.target_enemy = -4;
inst.banding_card_obj = id;
inst.row = grid_row;
inst.splash_ratio = splash_ratio;
inst.sprite_index = bullet_shape;
