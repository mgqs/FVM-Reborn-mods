// obj_wuxingshe Destroy 事件：清理光环 + 从增幅源列表摘掉自己 + 触发一次重建
for (var i = 0; i < array_length(wuxingshe_effects); i++) {
    if (instance_exists(wuxingshe_effects[i])) instance_destroy(wuxingshe_effects[i]);
}
array_resize(wuxingshe_effects, 0);

var idx = ds_list_find_index(global.buff_sources, id);
if (idx != -1) ds_list_delete(global.buff_sources, idx);

global.buff_dirty = true;
event_inherited();
