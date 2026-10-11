for (var i = 0; i < array_length(zodiac_effects); i++) if (instance_exists(zodiac_effects[i])) instance_destroy(zodiac_effects[i]);
if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
event_inherited();
