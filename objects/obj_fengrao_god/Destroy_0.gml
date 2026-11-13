event_inherited();
if (instance_exists(fengrao_effect_obj))
    instance_destroy(fengrao_effect_obj);
mod_buff_source_remove(id);

global.buff_dirty = true;
