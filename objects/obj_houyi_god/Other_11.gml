var middle_y = y - 75;
var row_height = 100;
var spread = 20;
var fire_flags = [fire_up, fire_mid, fire_down];
var row_offsets = [-1, 0, 1];
var y_offsets = [-spread, 0, spread];

var extra_mid = 0;
var extra_side = 0;

if (current_wave == 3)
{
    switch (shape)
    {
        case 0:
            extra_mid = 0;
            extra_side = 0;
            break;
        case 1:
            extra_mid = 1;
            extra_side = 0;
            break;
        case 2:
            extra_mid = 1;
            extra_side = 1;
            break;
        case 3:
            extra_mid = 2;
            extra_side = 1;
            break;
    }
}

if (current_wave == 2 && shape == 3)
{
    extra_mid = 1;
    extra_side = 1;
}

for (var i = 0; i < 3; i++)
{
    if (fire_flags[i])
    {
        var target_row = grid_row + row_offsets[i];
        var start_x = x + 40;
        var start_y = middle_y + y_offsets[i];
        var is_mid = (i == 1);
        var is_side = !is_mid;
        var extra = 0;

        if (is_mid)
            extra = extra_mid;
        else
            extra = extra_side;

        if (target_row < 0 || target_row >= global.grid_rows)
        {
            target_row = grid_row;
            start_x -= 20;
        }

        var num_bullets = 1 + extra;
        for (var j = 0; j < num_bullets; j++)
        {
            var bullet_x = start_x + j * 15;
            var inst = instance_create_depth(bullet_x, start_y, depth - 500, obj_houyi_god_bullet);
            inst.damage = atk;
            inst.move_speed = 8;
            inst.row = grid_row;
            inst.target_row = target_row;
            inst.start_y = middle_y;
            inst.fire_chance = fire_chance;
            inst.shape = shape;

            switch (shape)
            {
                case 0:
                    inst.sprite_index = spr_houyi_god_bullet;
                    break;
                case 1:
                    inst.sprite_index = spr_houyi_god_bullet_1;
                    break;
                case 2:
                    inst.sprite_index = spr_houyi_god_bullet_2;
                    break;
                case 3:
                    inst.sprite_index = spr_houyi_god_bullet_3;
                    break;
            }
        }
    }
}

if (fire_up || fire_mid || fire_down)
    audio_play_sound(snd_shot, 0, 0);
