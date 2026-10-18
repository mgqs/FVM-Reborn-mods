var _source_index = ds_list_find_index(global.buff_sources, id);
if (_source_index >= 0)
    ds_list_delete(global.buff_sources, _source_index);
global.buff_dirty = true;
