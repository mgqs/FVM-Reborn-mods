// obj_wuxingshe Destroy 事件：清理光环 + 从增幅源列表摘掉自己 + 触发一次重建
for (var i = 0; i < array_length(wuxingshe_effects); i++) {
    if (instance_exists(wuxingshe_effects[i])) instance_destroy(wuxingshe_effects[i]);
}
array_resize(wuxingshe_effects, 0);

mod_buff_source_remove(id);

global.buff_dirty = true;
event_inherited();
