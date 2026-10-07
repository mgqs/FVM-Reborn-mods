var middle_y = y - 75;
var spread = 20;
var col0_x = get_world_position_from_grid(0, 0).x;
var fire_flags = [fire_up, fire_mid, fire_down];
var row_offsets = [-1, 0, 1];
var y_offsets = [-spread, 0, spread];

// 根据转职计算伤害倍率和特性
var dmg_mul_mid = 3;
var dmg_mul_side = 3;
var burn_chance = fire_chance;
var burn_bonus = false;
var ash_kill = false;
var sanwei_stack = 1;

switch (shape)
{
    case 0: // 0转：全弹3倍
        dmg_mul_mid = 3;
        dmg_mul_side = 3;
        break;
    case 1: // 1转：灼烧效果增加，中路4倍/边路3倍
        dmg_mul_mid = 4;
        dmg_mul_side = 3;
        burn_chance *= 1.5;
        burn_bonus = true;
        break;
    case 2: // 2转：全弹4倍，击杀灰烬
        dmg_mul_mid = 4;
        dmg_mul_side = 4;
        ash_kill = true;
        burn_chance *= 1.5;
        burn_bonus = true;
        break;
    case 3: // 终转：全弹5倍，三昧真火叠加提高
        dmg_mul_mid = 5;
        dmg_mul_side = 5;
        sanwei_stack = 2;
        ash_kill = true;
        burn_chance *= 2;
        burn_bonus = true;
        break;
}

// 永远只创建3颗子弹（上、中、下各1发）
for (var i = 0; i < 3; i++)
{
    if (fire_flags[i])
    {
        var target_row = grid_row + row_offsets[i];
        var start_x = col0_x;
        var start_y = middle_y + y_offsets[i];
        var is_mid = (i == 1);
        var dmg_mul = is_mid ? dmg_mul_mid : dmg_mul_side;

        if (target_row < 0 || target_row >= global.grid_rows)
            target_row = grid_row;

        var inst = instance_create_depth(start_x, start_y, depth - 500, obj_houyi_god_bullet);
        inst.damage = atk * dmg_mul;
        inst.move_speed = 8;
        inst.row = grid_row;
        inst.target_row = target_row;
        inst.start_y = middle_y;
        inst.fire_chance = burn_chance;
        inst.shape = shape;
        inst.ash_kill = ash_kill;
        inst.sanwei_stack = sanwei_stack;
        inst.burn_bonus = burn_bonus;

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

if (fire_up || fire_mid || fire_down)
    audio_play_sound(snd_shot, 0, 0);
