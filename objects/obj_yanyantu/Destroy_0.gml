for (var i = 0; i < array_length(zodiac_effects); i++) if (instance_exists(zodiac_effects[i])) instance_destroy(zodiac_effects[i]);
if (instance_number(obj_yanyantu) <= 1) {
    with (obj_zodiac_effect) {
        if (variable_instance_exists(id, "yanyantu_target")) {
            if (instance_exists(yanyantu_target)) yanyantu_target.yanyantu_effect_id = noone;
            instance_destroy();
        }
    }
}
if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
event_inherited();
