combat_targets_invalidate(object_index);
if hp < max_hp && !invincible{
	obj_task_manager.card_loss ++
}

// 海克斯：以牙还牙 / 灰烬爆炸 / 大锅饭反噬 / 一锅端标记（实例还活着，能读到坐标与攻击）
if (hex_enabled()) hex_on_card_destroyed(id);
// 海克斯二期：以我残躯化烈火 / 中指的义理 / 鲨鱼的厚皮
if (hex_enabled()) hex_b3_card_destroyed(id);

// 常驻状态标记跟随宿主一起清掉（标记自身也有兜底，这里避免同帧残影）
if (variable_instance_exists(id, "awake_mark_obj") && instance_exists(awake_mark_obj)) instance_destroy(awake_mark_obj);
if (variable_instance_exists(id, "guard_mark_obj") && instance_exists(guard_mark_obj)) instance_destroy(guard_mark_obj);

// 2026-11-13：星级图标是独立对象，父对象销毁时**必须一起带走**
//   （以前没清：时光机自毁 / 卡被啃死 / 被铲掉 / 被顶掉都会留一颗星在场上）
if (variable_instance_exists(id, "banding_star_obj") && instance_exists(banding_star_obj)) instance_destroy(banding_star_obj);

var _was_shoveled = variable_instance_exists(id, "is_shoveled") && is_shoveled;
var _no_revive_record = variable_instance_exists(id, "no_revive_record") && no_revive_record;

var should_record = false;

if (variable_instance_exists(id, "plant_id") && !_was_shoveled && !_no_revive_record)
{
    if (hp <= 0)
        should_record = true;
    else if (variable_global_exists("game_over") && !global.game_over && instance_exists(obj_battle))
        should_record = true;

    if (should_record)
    {
        // 不记进死亡名单的卡（炸弹 / 一次性 / 辅助 / 复制类…）统一在 card_special_flags 的 no_death_record
        if (!card_records_death(plant_id))
            should_record = false;
    }
}

if (should_record)
{
    if (!variable_global_exists("dead_cards") || !ds_exists(global.dead_cards, ds_type_list))
    {
        global.dead_cards = ds_list_create();
    }

    var _death_cause = "mouse";
    if (hp > 0)
        _death_cause = "destroyed";

    var dead_data = ds_map_create();
    ds_map_add(dead_data, "plant_id", plant_id);
    ds_map_add(dead_data, "shape", shape);
    ds_map_add(dead_data, "level", current_level);
    ds_map_add(dead_data, "skill", skill);
    ds_map_add(dead_data, "grid_col", grid_col);
    ds_map_add(dead_data, "grid_row", grid_row);
    ds_map_add(dead_data, "death_cause", _death_cause);
    ds_list_add(global.dead_cards, dead_data);
}

card_destroyed(id);
