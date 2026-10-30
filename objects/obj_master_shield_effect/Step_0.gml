if (global.is_paused)
    exit;

if (!instance_exists(shield_owner))
{
    instance_destroy();
    exit;
}

x = shield_owner.x;
y = shield_owner.y + y_offset;
depth = shield_owner.depth - 1;

anim_timer++;

if (image_number > 0)
    image_index = (anim_timer div 5) mod image_number;