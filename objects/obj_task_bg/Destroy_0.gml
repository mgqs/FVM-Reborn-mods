instance_destroy(obj_closetask_btn)
instance_destroy(obj_task_claim_btn)
instance_destroy(obj_task_line_bg)
instance_destroy(obj_task_select_btn)
panel_anim_free(id)
var remove_task_id_list = []
for(var i = 0 ; i < array_length(global.save_data.tasks);i++){
	if global.save_data.tasks[i].state == "claimed"{
		array_push(remove_task_id_list,global.save_data.tasks[i].id)
	}
}
if array_length(remove_task_id_list) > 0{
	for(var i = 0 ; i < array_length(remove_task_id_list);i++){
		remove_task(remove_task_id_list[i],1)
	}
	// 移除 + 记进 completed_tasks 是一次真实的存档变更：不落盘的话下次进游戏
	// 这些任务还在 tasks 里（卡片情报任务靠 completed_tasks 防重复发，脏了就会多发一份）
	save_file(global.save_slot)
}
obj_player_info_ui.menu_type = 0
obj_world_map_button.world_map = 0
