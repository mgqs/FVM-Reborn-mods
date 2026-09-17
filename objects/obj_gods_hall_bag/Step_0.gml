if (parent_gui.is_wishing)
{
    anim_timer++;
    image_index = floor(anim_timer / 5);
    
    if (image_alpha < 1)
    {
        if ((anim_timer % 3) == 0)
            image_alpha += 0.1;
    }
    
    if (anim_timer == 105)
        event_user(0);
    
    if (anim_timer >= 249)
    {
        parent_gui.wish_completed = true;
        anim_timer = 200;
    }
}
else if (is_hovered)
{
    anim_timer++;
    image_index = floor(anim_timer / 5);
    
    if (anim_timer >= 84)
        anim_timer = 0;
}
else if (list_num != 0)
{
    instance_destroy();
}
else
{
    anim_timer = 0;
    image_index = 16;
}
