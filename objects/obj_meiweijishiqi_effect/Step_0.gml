if (global.is_paused) exit;
if (!instance_exists(parent_plant)){
    instance_destroy();
    exit
}
x = parent_plant.x;
y = parent_plant.y + 6;
depth = parent_plant.depth - 20;
anim_t++;
image_index = (anim_t div 4) mod sprite_get_number(sprite_index);
