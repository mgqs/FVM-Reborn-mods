// obj_nengliangmiao Destroy：摘掉增幅源并重建网格
mod_buff_source_remove(id);

global.buff_dirty = true;
event_inherited();
