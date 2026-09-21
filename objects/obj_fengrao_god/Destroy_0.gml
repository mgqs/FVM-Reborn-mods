event_inherited();
if (instance_exists(fengrao_effect_obj))
    instance_destroy(fengrao_effect_obj);
var idx = ds_list_find_index(global.buff_sources, id);

if (idx != -1)
    ds_list_delete(global.buff_sources, idx);

global.buff_dirty = true;
