event_inherited();
plant_id = "liehuohu";
obj_type = object_index;
event_user(0);

sprite_index = spr_liehuohu;
if (shape == 1) sprite_index = spr_liehuohu_1;
else if (shape == 2) sprite_index = spr_liehuohu_2;

attack_anim = 11;
idle_anim = 11;
first_produce_delay = 60;
flash_speed = 6;
plant_type = "normal";
is_slowdown = false;

flame_unit_value = 35;
flame_produce = 35;
flame_burst_count = 1;
storage_limit = 1500;
storage_amount = 0;
return_pending = false;

if (shape == 1) {
    flame_burst_count = 2;
} else if (shape == 2) {
    flame_burst_count = 2;
    storage_limit = 3000;
}

var _ratios = [12, 13, 14, 15, 16, 17, 18, 19, 20, 25, 30, 35, 45, 55, 65, 75, 85];
var _clamped_level = clamp(current_level, 0, 16);
storage_ratio = _ratios[_clamped_level];
