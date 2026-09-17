if (!instance_exists(parent_gui))
    instance_destroy();
else if (parent_gui.anim_timer <= 100)
    instance_destroy();

if (anim_timer <= 500)
    anim_timer++;

if (anim_timer == (20 + (list_num * 40)))
    show_notice("恭喜获得 " + string(reward_id[0]) + "x" + string(reward_id[1]), 40);

if (image_alpha >= 1)
{
    image_alpha = 1;
    exit;
}

if ((anim_timer % 5) == 0)
{
    y--;
    image_alpha += 0.1;
}
