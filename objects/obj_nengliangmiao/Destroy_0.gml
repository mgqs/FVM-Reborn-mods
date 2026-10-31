// obj_nengliangmiao Destroy：摘掉增幅源并重建网格
var idx = ds_list_find_index(global.buff_sources, id);
if (idx != -1) ds_list_delete(global.buff_sources, idx);

global.buff_dirty = true;
event_inherited();
