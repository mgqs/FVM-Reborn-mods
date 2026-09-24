event_inherited();

// 清除由本卡片施加的所有回血Buff
with (obj_zhiyumiao_regen_buff) {
    if (source_id == other.id)
        instance_destroy();
}
