// obj_task_claim_all_btn 左键点击：一次领完所有已完成任务
// 2026-11-15：不限类别（主线 / 支线 / 挑战 / 卡片情报），只认 state == "completed"。
if (disabled) exit;
if (!is_array(global.save_data.tasks)) exit;

// 先收集 id、再统一处理：task_grant_rewards 里的 unlock_task 会往 tasks 里 push 新任务，
// 边遍历边改数组会漏条或越界。
var _ids = [];
for (var i = 0; i < array_length(global.save_data.tasks); i++)
{
    var _t = global.save_data.tasks[i];
    if (_t.state != "completed") continue;
    if (get_task_data(_t.id) == undefined) continue;   // 孤儿任务：发不出奖，跳过
    array_push(_ids, _t.id);
}
if (array_length(_ids) == 0) exit;

var _n = 0;
for (var _k = 0; _k < array_length(_ids); _k++)
{
    task_grant_rewards(_ids[_k]);
    edit_task_state(_ids[_k], "claimed");
    _n++;
}

// 只落盘一次：一批 50 条就写 50 次会卡帧，而且中途失败会留下「领了一半」的半截存档
save_file(global.save_slot);

with (obj_task_bg)
{
    // 列表重建后旧下标已经指向别的任务（领完的会排到最末），清掉选区免得详情面板串行
    target_task_index = -1;
    refresh_task_list();
}

global.audio.play(snd_button, 0, 0);
show_notice("已领取 " + string(_n) + " 个任务奖励", 60);
