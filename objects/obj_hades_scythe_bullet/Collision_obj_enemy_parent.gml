if (ds_list_find_index(hitted_enemy, other.id) == -1 && !disabled)
{
    if (other.hp > 0)
    {
        with (other)
        {
            damage_amount = other.damage;
            damage_type = other.damage_type;
            event_user(0);
        }
        
        ds_list_add(hitted_enemy, other.id);
    }
}
