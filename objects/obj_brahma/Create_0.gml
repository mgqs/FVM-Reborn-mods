event_inherited();
plant_id = "brahma";
obj_type = object_index;
current_level = 1;
event_user(0);
sprite_index = spr_brahma;

if (shape == 1)
    sprite_index = spr_brahma_1;
else if (shape == 2)
    sprite_index = spr_brahma_2;
else if (shape == 3)
    sprite_index = spr_brahma_3;

attack_anim = 0;
idle_anim = sprite_get_number(sprite_index);
image_speed = 1;
flash_speed = 5;
plant_type = "coffee";
is_slowdown = false;
current_hp = hp;
can_mouse_list = ["can_mouse"];
exploded = false;
is_derivative = false;
copied = false;
target_card = global.last_placed_card_id;
target_shape = global.last_placed_card_shape;
