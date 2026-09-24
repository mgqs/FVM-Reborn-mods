var bullet_count = 2;
var execute_threshold = 0.15;
var elite_multiplier = 5;
var bullet_spr = spr_shuangrenshe_bullet;

if (shape == 1) {
    bullet_count = 3;
    bullet_spr = spr_shuangrenshe_bullet_1;
} else if (shape == 2) {
    bullet_count = 4;
    execute_threshold = 0.25;
    elite_multiplier = 10;
    bullet_spr = spr_shuangrenshe_bullet_2;
}

var y_offsets = [-75, -65, -85, -70];

for (var i = 0; i < bullet_count; i++) {
    var inst = instance_create_depth(x + 40, y + y_offsets[i], depth - 500, obj_double_blade_snake_bullet);
    inst.damage = atk;
    inst.move_speed = 8;
    inst.row = grid_row;
    inst.execute_threshold = execute_threshold;
    inst.elite_multiplier = elite_multiplier;
    inst.sprite_index = bullet_spr;
}
