if not disabled{
	var task_id = obj_task_bg.current_task_list[obj_task_bg.target_task_index].id
	var task_info = get_task_data(task_id)
	if task_info == undefined exit
	// 发奖逻辑统一走 task_edit 的 task_grant_rewards，与「一键领取」共用一份分支
	task_grant_rewards(task_id)
	edit_task_state(task_id,"claimed")
	save_file(global.save_slot) // 领奖后立即落盘，避免金币丢失
	with obj_task_bg{
		// 列表重建后旧下标已经指向别的任务（领完的那条会排到最末），清掉选区免得详情面板串行
		target_task_index = -1
		refresh_task_list()
	}
	global.audio.play(snd_button,0,0)
	show_notice("奖励已领取",60)
}