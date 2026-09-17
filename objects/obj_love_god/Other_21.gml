var middle_y = y - 75;
var row_height = 100;
var spread = 20;
var fire_flags = [fire_up, fire_mid, fire_down];
var row_offsets = [-1, 0, 1];
var y_offsets = [-spread, 0, spread];

for (var i = 0; i < 3; i++)
{
    if (fire_flags[i])
    {
        var target_row = grid_row + row_offsets[i];
        var start_x = x + 40;
        var start_y = middle_y + y_offsets[i];
        
        if (target_row < 0 || target_row >= global.grid_rows)
        {
            target_row = grid_row;
            start_x -= 20;
        }
        
        var inst = instance_create_depth(start_x, start_y, depth - 500, obj_love_god_bullet);
        inst.damage = atk;
        inst.move_speed = 8;
        inst.row = grid_row;
        inst.target_row = target_row;
        inst.start_y = middle_y;
        
        switch (shape)
        {
            case 0:
                inst.sprite_index = spr_love_god_bullet_0;
                break;
            
            case 1:
                inst.sprite_index = spr_love_god_bullet_1;
                break;
            
            case 2:
                inst.sprite_index = spr_love_god_bullet_2;
                break;
            
            case 3:
                inst.sprite_index = spr_love_god_bullet_3;
                break;
        }
    }
}

if (fire_up || fire_mid || fire_down)
    audio_play_sound(snd_shot, 0, 0);