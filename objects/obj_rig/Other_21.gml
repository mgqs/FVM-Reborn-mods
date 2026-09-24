var buff_rg = min(1 + (0.05 * (global.rig_count - 1)), 1.45);
var final_mul = (shape == 3) ? 2 : 1;
var bullet_damage = atk * ((shape >= 2) ? buff_rg : 1) * final_mul;
var inst = instance_create_depth(x + 60, y - 40, depth - 500, obj_rig_bullet);
inst.damage = bullet_damage;
inst.move_speed_x = 8;
inst.row = grid_row;
var inst2 = instance_create_depth(x + 60, y - 40, depth - 500, obj_rig_bullet_oblique);
inst2.damage = bullet_damage;
inst2.move_speed_x = 5.658;
inst2.move_speed_y = 5.658;
var inst3 = instance_create_depth(x + 60, y - 40, depth - 500, obj_rig_bullet_oblique);
inst3.damage = bullet_damage;
inst3.move_speed_x = 5.658;
inst3.move_speed_y = -5.658;
var inst4 = instance_create_depth(x + 60, y - 40, depth - 500, obj_rig_bullet_oblique);
inst4.damage = bullet_damage;
inst4.move_speed_x = 7.391;
inst4.move_speed_y = 3.062;
var inst5 = instance_create_depth(x + 60, y - 40, depth - 500, obj_rig_bullet_oblique);
inst5.damage = bullet_damage;
inst5.move_speed_x = 7.391;
inst5.move_speed_y = -3.062;
var bullet_spr = spr_rig_bullet;

if (shape == 1)
    bullet_spr = spr_rig_bullet_1;
else if (shape == 2)
    bullet_spr = spr_rig_bullet_2;
else if (shape == 3)
    bullet_spr = spr_rig_bullet_3;

inst.sprite_index = bullet_spr;
inst2.sprite_index = bullet_spr;
inst3.sprite_index = bullet_spr;
inst4.sprite_index = bullet_spr;
inst5.sprite_index = bullet_spr;