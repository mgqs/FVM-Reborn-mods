event_inherited();
plant_id = "nizhuanniu";
obj_type = object_index;
event_user(0);

sprite_index = spr_nizhuanniu;
if (shape == 1)
    sprite_index = spr_nizhuanniu_1;
else if (shape == 2)
    sprite_index = spr_nizhuanniu_2;

attack_anim = 0;
idle_anim = sprite_get_number(sprite_index);
flash_speed = 5;
plant_type = "normal";
target_type = "normal";
is_slowdown = false;
invincible = true;

// 逆转范围：半径1=3*3，半径2=5*5
effect_radius = (shape >= 2) ? 2 : 1;
// 固定效果伤害：仅一转及以后，不参与星级/攻击力 buff
reverse_damage = (shape >= 1) ? 1000 : 0;

activate_delay = 4 * flash_speed;
state_timer = 0;
has_activated = false;
is_activating = false;