if obj_task_bg.target_task_index != -1 && obj_task_bg.button_select != -1{
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