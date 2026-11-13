// 列表会被 refresh_task_list 重建（切页签 / 领奖 / 翻页），下标可能已越界 → 先判范围再取
if obj_task_bg.target_task_index != -1 && obj_task_bg.button_select != -1
&& obj_task_bg.target_task_index < array_length(obj_task_bg.current_task_list){
	var task_state = obj_task_bg.current_task_list[obj_task_bg.target_task_index].state
	if task_state == "completed"{
		disabled = false
	}
	else{
		disabled = true
	}
}
else{
	disabled = true
}