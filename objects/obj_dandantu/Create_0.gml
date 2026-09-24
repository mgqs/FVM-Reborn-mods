event_inherited();
plant_id = "dandantu";
obj_type = object_index;
current_level = 1;
event_user(0);
sprite_index = spr_dandantu;

if (shape == 1)
    sprite_index = spr_dandantu_1;
else if (shape == 2)
    sprite_index = spr_dandantu_2;

attack_anim = 0;
idle_anim = sprite_get_number(sprite_index);
image_speed = 0;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;

storage_ratio = atk;
storage_cap = 3000;
if (shape == 1 || shape == 2)
    storage_cap = 6000;

action_rows = 1;
if (shape == 2)
    action_rows = 3;

stored_damage = 0;
counted_bullets = ds_list_create();
has_exploded = false;
is_exploding = false;
storage_timer = cooldown;
if (storage_timer <= 0)
    storage_timer = 3000;

anim_frame = 0;
anim_timer = 0;
slowdown_tick = 0;
grow_stage = 0;

small_start = 0;
small_end = 15;
mid_start = 16;
mid_end = 31;
big_start = 32;
big_end = 48;
explode_start = 49;
explode_end = 70;
