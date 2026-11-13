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

function ensure_task_progress_size(task_id){
	if is_task_unlocked(task_id){
		var task_index = get_task_index(task_id)
		var task_data = get_task_data(task_id)
		var required_size = array_length(task_data.requirements)
		var current_size = array_length(global.save_data.tasks[task_index].progress)
		while(current_size < required_size){
			array_push(global.save_data.tasks[task_index].progress,0)
			current_size++
		}
	}
}

function edit_task_progress(task_id,progress_index,new_progress){
	if is_task_unlocked(task_id){
		ensure_task_progress_size(task_id)
		var task_index = get_task_index(task_id)
		if progress_index >= 0 && progress_index < array_length(global.save_data.tasks[task_index].progress){
			global.save_data.tasks[task_index].progress[progress_index] = new_progress
		}
	}
}

function add_task_progress(task_id,progress_index,new_progress){
	if is_task_unlocked(task_id){
		ensure_task_progress_size(task_id)
		var task_index = get_task_index(task_id)
		if progress_index >= 0 && progress_index < array_length(global.save_data.tasks[task_index].progress){
			global.save_data.tasks[task_index].progress[progress_index] += new_progress
		}
	}
}

function get_task_progress(task_id,progress_index){
	if is_task_unlocked(task_id){
		ensure_task_progress_size(task_id)
		var task_index = get_task_index(task_id)
		if progress_index >= 0 && progress_index < array_length(global.save_data.tasks[task_index].progress){
			return global.save_data.tasks[task_index].progress[progress_index]
		}
	}
	return 0
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

// ══════════════════════════════════════════════════════════════════════════
//  卡片情报任务（card_info_task）
//  需求：每解锁一张新卡 → 生成一个任务「在情报岛查看这张卡的信息」→ 奖励 5000 金币
//  任务 id 用动态形式 info_view_<card_id>，与静态任务池共存于 global.task_pool
//  ⚠ register_task 是 ds_map_add（重复 key 静默失败），所以注册前必须先 ds_map_exists
// ══════════════════════════════════════════════════════════════════════════

/// @function card_info_task_id(card_id)
/// @desc 卡片情报任务的任务 id
function card_info_task_id(card_id){
	return "info_view_" + string(card_id)
}

/// @function card_info_task_card_id(task_id)
/// @desc 反解任务 id → card_id；不是卡片情报任务返回空串
function card_info_task_card_id(task_id){
	if (!is_string(task_id)) return ""
	if (string_length(task_id) <= 10) return ""
	if (string_copy(task_id, 1, 10) != "info_view_") return ""
	return string_delete(task_id, 1, 10)
}

/// @function card_info_task_name(card_id)
/// @desc 取卡名（形态 0 的 name），取不到退回 card_id
function card_info_task_name(card_id){
	var _sd = get_plant_shape_data(card_id, 0)
	if _sd != undefined{
		var _n = _sd[? "name"]
		if _n != undefined && string(_n) != "" return string(_n)
	}
	return string(card_id)
}

/// @function card_info_task_sync(card_id)
/// @desc 给一张卡补发情报任务（幂等：已注册就只补 unlock，不动 state / progress）
function card_info_task_sync(card_id){
	if card_id == "" || card_id == undefined return
	if !variable_global_exists("task_pool") return
	if !is_array(global.save_data.tasks) return
	var _tid = card_info_task_id(card_id)
	// 已领奖的任务会被 obj_task_bg/Destroy_0 从 tasks 里移除并记进 completed_tasks，
	// 不做这层拦截 → 下次进游戏会重新发一遍，变成刷金币漏洞
	// （旧存档 1.4 迁移时 completed_tasks 可能还没补出来，先判类型再查）
	if is_array(global.save_data.completed_tasks){
		if is_task_complete(_tid) return
	}
	if !ds_map_exists(global.task_pool, _tid){
		var _name = card_info_task_name(card_id)
		register_task(_tid, {
			"type":"card_info_task",
			"title":"查看【" + _name + "】的情报",
			"desc":"这张卡已经听说了。去情报岛亲眼看看它的底细。",
			"single_game":false,
			"oneshot":false,
			"task_unlock":"none",
			"requirements":[
				{
					"type":"card_info_view",
					"card_id":string(card_id),
					"desc":"在情报岛查看【" + _name + "】的卡片信息",
					"require":1
				}
			],
			"rewards":[
				{
					"type":"gold",
					"amount":5000
				}
			]
		})
	}
	if !is_task_unlocked(_tid) unlock_task(_tid)
}

/// @function card_info_task_complete(card_id)
/// @desc 情报岛点开卡片时调用：置 progress 1 + state completed + 提示（幂等）
function card_info_task_complete(card_id){
	if card_id == "" || card_id == undefined return
	var _tid = card_info_task_id(card_id)
	if !is_task_unlocked(_tid) return
	var _st = get_task_state(_tid)
	if _st == "completed" || _st == "claimed" return
	edit_task_progress(_tid, 0, 1)
	edit_task_state(_tid, "completed")
	show_notice("任务完成：查看【" + card_info_task_name(card_id) + "】的情报", 60)
}

/// @function card_info_task_prune()
/// @desc 清掉「卡已经不在存档里」的情报任务（mod 卡被卸载 / 孤儿卡被清理）
///       否则这些任务会永远挂在存档里，点不开也领不了
function card_info_task_prune(){
	if !is_array(global.save_data.tasks) return 0
	var _removed = 0
	for (var i = array_length(global.save_data.tasks) - 1; i >= 0; i--){
		var _tid = global.save_data.tasks[i].id
		var _cid = card_info_task_card_id(_tid)
		if _cid == "" continue
		if get_task_data(_tid) == undefined || !is_card_unlocked(_cid){
			// 外部 mod 包只是被禁用时卡仍在存档里（unlocked_cards 保留进度），
			// 但 player_deck 里没有它 → is_card_unlocked 仍为真，这里只在注册表真丢了才清
			if external_mod_known(_cid) continue
			remove_task(_tid, 0)
			_removed++
		}
	}
	return _removed
}

/// @function task_red_dot(kind)
/// @desc 红点判定："task" = 任务栏按钮；"package" = 背包按钮
///       new/viewed → 两处都亮；completed → 只亮任务栏（奖励待领）；claimed → 都不亮
function task_red_dot(kind){
	if !is_array(global.save_data.tasks) return false
	for(var i = 0 ; i < array_length(global.save_data.tasks) ; i++){
		var _t = global.save_data.tasks[i]
		if card_info_task_card_id(_t.id) == "" continue
		// 卡被 cleanup_orphan_cards 清掉后任务条目还留在存档里，注册表却没了 →
		// 不拦的话这条永远点不开，红点会一直亮着
		if get_task_data(_t.id) == undefined continue
		var _s = _t.state
		if _s == "claimed" continue
		if kind == "task" return true
		if kind == "package"{
			if _s != "completed" return true
		}
	}
	return false
}