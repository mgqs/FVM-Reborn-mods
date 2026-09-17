function unlock_task(task_id){
	if !is_task_unlocked(task_id){
		var task_data = get_task_data(task_id)
		var length = array_length(task_data.requirements)
		var task_struct = {
			"id":task_id,
			"state":"new",
			"progress":[]
		}
		for(var i = 0; i < length;i++){
			array_push(task_struct.progress,0)
		}
		array_push(global.save_data.tasks,task_struct)
	}
}

function remove_task(task_id,is_complete){
	if is_task_unlocked(task_id){
		if is_complete{
			array_push(global.save_data.completed_tasks,task_id)
		}
		var task_index = get_task_index(task_id)
		array_delete(global.save_data.tasks,task_index,1)
	}
}

function edit_task_state(task_id,new_state){
	if is_task_unlocked(task_id){
		var task_index = get_task_index(task_id)
		global.save_data.tasks[task_index].state = new_state
	}
}

function get_task_state(task_id){
	if is_task_unlocked(task_id){
		var task_index = get_task_index(task_id)
		return global.save_data.tasks[task_index].state
	}
}

function edit_task_progress(task_id,progress_index,new_progress){
	if is_task_unlocked(task_id){
		var task_index = get_task_index(task_id)
		global.save_data.tasks[task_index].progress[progress_index] = new_progress
	}
}

function add_task_progress(task_id,progress_index,new_progress){
	if is_task_unlocked(task_id){
		var task_index = get_task_index(task_id)
		global.save_data.tasks[task_index].progress[progress_index] += new_progress
	}
}

function get_task_progress(task_id,progress_index){
	if is_task_unlocked(task_id){
		var task_index = get_task_index(task_id)
		return global.save_data.tasks[task_index].progress[progress_index]
	}
}

function is_task_unlocked(task_id){
	for(var i = 0 ; i < array_length(global.save_data.tasks);i++){
		if global.save_data.tasks[i].id == task_id{
			return true
		}
	}
	return false
}

function is_task_complete(task_id){
	if array_get_index(global.save_data.completed_tasks,task_id) != -1{
		return true
	}
	return false
}

function get_task_index(task_id){
	for(var i = 0 ; i < array_length(global.save_data.tasks);i++){
		if global.save_data.tasks[i].id == task_id{
			return i
		}
	}
	return -1
}