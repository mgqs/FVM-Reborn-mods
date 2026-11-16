// obj_task_claim_all_btn Step 事件
// 统计待领取条数。口径必须和 Mouse_4 的领取口径**逐条对齐**，否则会出现
// 「按钮显示 3、点下去只领到 2」这种对不上的情况：
//   ① state == "completed"（claimed / new / viewed 都不算）
//   ② get_task_data 能取到（注册表里没有的孤儿任务既领不了、也不该计入）
// 任务总量在百级，每帧一次线性扫描的开销可以忽略（面板一关就没了）。
claim_count = 0;
if (is_array(global.save_data.tasks))
{
    for (var i = 0; i < array_length(global.save_data.tasks); i++)
    {
        var _t = global.save_data.tasks[i];
        if (_t.state != "completed") continue;
        if (get_task_data(_t.id) == undefined) continue;
        claim_count++;
    }
}
disabled = (claim_count <= 0);
