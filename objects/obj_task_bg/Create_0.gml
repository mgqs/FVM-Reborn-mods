image_xscale = 0.9
image_yscale = 0.9
image_speed = 0

is_submenu_opened = false
button_select = -1
target_task_index = -1

current_task_list = []
y_offset = 0

instance_create_depth(x+680,y-450,depth-1,obj_closetask_btn)
instance_create_depth(x+300,y+400,depth-1,obj_task_claim_btn)

var btn1 = instance_create_depth(x-400,y-290,depth-1,obj_task_select_btn)
btn1.btn_index = 0
btn1.btn_text = "主线任务"
var btn2 = instance_create_depth(x-400,y-235,depth-1,obj_task_select_btn)
btn2.btn_index = 1
btn2.btn_text = "支线任务"
var btn3 = instance_create_depth(x-400,y-180,depth-1,obj_task_select_btn)
btn3.btn_index = 2
btn3.btn_text = "挑战任务"
var btn4 = instance_create_depth(x-400,y-125,depth-1,obj_task_select_btn)
btn4.btn_index = 3
btn4.btn_text = "卡片情报"

//检查卡片强化任务是否完成
function check_card_upgrade(){
	for(var i = 0 ; i < array_length(global.save_data.tasks) ; i++){
		var task_id = global.save_data.tasks[i].id
		if global.save_data.tasks[i].state != "completed" && global.save_data.tasks[i].state != "claimed"{
			var task_data = get_task_data(task_id)
			if task_data == undefined continue
			var complete_require = array_length(task_data.requirements)
			var complete_count = 0
			for(var j = 0 ; j < array_length(task_data.requirements) ; j++){
				//根据任务类型，判断是否完成
				//卡片强化类任务
				if task_data.requirements[j].type == "card_upgrade"{
					//先重置进度
					edit_task_progress(task_id,j,0)
					//遍历检查所有卡片等级
					for(var k = 0 ; k < array_length(global.save_data.unlocked_cards) ; k++){
						if global.save_data.unlocked_cards[k].max_level >= task_data.requirements[j].target_card_level{
							add_task_progress(task_id,j,1)
						}
					}
					//如果进度满足要求，则增加完成计数
					if get_task_progress(task_id,j) >= task_data.requirements[j].require{
						complete_count++
					}
				}
			}
			//如果所有任务要求均达成，则完成任务
			if complete_count >= complete_require{
				edit_task_state(task_id,"completed")
			}
		}
	}
}


// 卡片情报页的排序权重：待办优先
function card_info_state_pri(_s){
	if (_s == "new") return 0
	if (_s == "completed") return 1
	if (_s == "viewed") return 2
	return 3
}

function refresh_task_list(){
	check_card_upgrade()
	instance_destroy(obj_task_line_bg)
	y_offset = 0
	//target_task_index = -1
	current_task_list = []
	var saved_task_list = global.save_data.tasks
	for(var i = 0;i < array_length(saved_task_list);i++){
		var task_data = get_task_data(saved_task_list[i].id)
		if task_data == undefined continue
		if (button_select == 0 && task_data.type == "main_task")
		|| (button_select == 1 && task_data.type == "side_task")
		|| (button_select == 2 && task_data.type == "challenge_task")
		|| (button_select == 3 && task_data.type == "card_info_task"){
			array_push(current_task_list,saved_task_list[i])
		}
	}
	// 卡片情报页：待办优先（new → completed → viewed），同档保持解锁顺序
	// 新卡一多就会超出可见行数，不排序的话刚解锁的那条要翻好几页才找得到
	if (button_select == 3){
		for (var _si = 1; _si < array_length(current_task_list); _si++){
			var _cur = current_task_list[_si]
			var _cur_p = card_info_state_pri(_cur.state)
			var _sj = _si - 1
			while (_sj >= 0 && card_info_state_pri(current_task_list[_sj].state) > _cur_p){
				current_task_list[_sj + 1] = current_task_list[_sj]
				_sj--
			}
			current_task_list[_sj + 1] = _cur
		}
	}
	for(var i = 0;i < array_length(current_task_list);i++){
		var task_data = get_task_data(current_task_list[i].id)
		// 首行 y-65（=475）：第 4 页签占 y-125（=415，视觉 387~443），列表整体下移 65px；
		// 可见行数 11 → 9（52*9=468，末行中心 891，分隔线 916，仍在列表底边 950 之内）
		var inst = instance_create_depth(x-400,y-65+52*i,depth-1,obj_task_line_bg)
		inst.btn_index = i
		inst.wf_t = ui_anim_on(2) ? -(i * 2) : 18
		inst.task_title = task_data.title
		inst.state = current_task_list[i].state
	}
}

// 有卡片情报任务待处理（看情报 / 领奖）→ 默认落在第 4 页签，省得玩家去找
// 必须在 panel_anim_init 之前建好行，否则新行不在入场动画的 kids 名单里
if (task_red_dot("task")){
	button_select = 3
	refresh_task_list()
	// 顺手选中第一条，右侧详情直接出内容（否则打开是一片「请选择一个任务」）
	// 不在这里写 viewed —— 卡片情报任务的「已查看」只由情报岛点开卡片负责
	if (array_length(current_task_list) > 0) target_task_index = 0
}

panel_anim_init(id, 0.28, 0.18, 260)
panel_anim_kids(id, [obj_closetask_btn, obj_task_claim_btn, obj_task_line_bg, obj_task_select_btn])
