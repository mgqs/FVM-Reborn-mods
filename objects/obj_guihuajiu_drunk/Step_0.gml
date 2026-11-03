if (global.is_paused) exit;

if (!instance_exists(target))
{
    instance_destroy();
    exit;
}

if (variable_instance_exists(target, "drunk_timer"))
{
    target.drunk_timer--;
    if (target.drunk_timer <= 0) target.drunk_timer = 0;
}

x = target.x;
y = target.y - y_off;
depth = target.depth - 2;

t++;
image_index = (t div 3) mod max(1, sprite_get_number(sprite_index));

if (target.drunk_timer <= 0)
{
    instance_destroy();
}
