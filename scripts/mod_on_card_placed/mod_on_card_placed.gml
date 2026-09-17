function mod_on_card_placed(arg0, arg1)
{
    if (arg0 != "brahma" && arg0 != "ice_cream")
    {
        show_debug_message("已记录" + string(arg0) + string(arg1));
        global.last_placed_card_id = arg0;
        global.last_placed_card_shape = arg1;
    }
}
