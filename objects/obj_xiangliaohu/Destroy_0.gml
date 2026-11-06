event_inherited();
var _idx = ds_list_find_index(global.buff_sources, id);
if (_idx != -1) ds_list_delete(global.buff_sources, _idx);
global.buff_dirty = true;
