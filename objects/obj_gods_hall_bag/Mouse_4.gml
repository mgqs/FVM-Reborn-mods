if (parent_gui.is_wishing && !parent_gui.wish_completed && !parent_gui.is_submenu_opened)
{
    audio_play_sound(snd_button, 0, 0);
    parent_gui.skip_animation = true;
}
