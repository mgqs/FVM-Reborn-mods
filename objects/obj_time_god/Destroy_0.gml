event_inherited();

if (instance_exists(time_god_effect_obj))
    instance_destroy(time_god_effect_obj);

for (var _ci = 0; _ci < array_length(tg_corner_effects); _ci++)
{
    if (instance_exists(tg_corner_effects[_ci]))
        instance_destroy(tg_corner_effects[_ci]);
}
