event_inherited();
plant_id = "time_god";
event_user(0);

if (shape == 0)
    sprite_index = spr_time_god;
else if (shape == 1)
    sprite_index = spr_time_god_1;
else if (shape == 2)
    sprite_index = spr_time_god_2;
else if (shape == 3)
    sprite_index = spr_time_god_3;

attack_anim = 0;
idle_anim = 35;
flash_speed = 5;
plant_type = "coffee";
is_slowdown = false;
current_hp = hp;
image_speed = 0;

phase = 0;
exec_count = 0;

if (skill == 0)
    max_exec = 3;
else if (skill == 6)
    max_exec = 4;
else if (skill == 8)
    max_exec = 5;
else
    max_exec = 3;

var first_delay_frames = 72;
if (shape >= 1)
    first_delay_frames = 108;

cycle_interval = 420;
anim_play_frames = idle_anim * flash_speed;
hide_duration = cycle_interval - anim_play_frames;
if (hide_duration < 0)
    hide_duration = 0;

wait_timer = first_delay_frames;
tg_timer = 0;
anim_frame = 0;
hide_timer = 0;

var eff_spr = spr_time_god_effect;
if (shape == 1)
    eff_spr = spr_time_god_effect_1;
else if (shape == 2)
    eff_spr = spr_time_god_effect_2;
else if (shape == 3)
    eff_spr = spr_time_god_effect_3;

time_god_effect_obj = instance_create_depth(x, y - 30, 0, obj_time_god_effect);
time_god_effect_obj.sprite_index = eff_spr;
time_god_effect_obj.is_one_shot = false;

if (shape >= 1)
{
    var start_spr = spr_time_god_start_1;
    if (shape == 2)
        start_spr = spr_time_god_start_2;
    else if (shape == 3)
        start_spr = spr_time_god_start_3;

    var boom = instance_create_depth(x, y, depth - 100, obj_time_god_effect);
    boom.sprite_index = start_spr;
    boom.is_one_shot = true;
    boom.frame_counter = 0;

    with (obj_enemy_parent)
    {
        if (hp > 0)
        {
            var dx = abs(x - other.x);
            var dy = abs(y - other.y);
            if (dx < 200 && dy < 200)
            {
                damage_amount = other.atk;
                damage_type = "explosion";
                event_user(0);
            }
        }
    }
}
