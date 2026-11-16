// obj_task_claim_all_btn Create 事件
// 任务看板右上角「一键领取」：把所有 state == "completed" 的任务奖励一次领完。
// 2026-11-15 用户口径：**不限类别** —— 主线 / 支线 / 挑战 / 卡片情报，只要已完成就能一键领。
// 位置由 obj_task_bg/Create_0 写入（标题栏右侧、关闭按钮左边），本对象不自己定位。
image_speed  = 0;
image_xscale = 1;
image_yscale = 1;

disabled    = true;   // 由 Step 每帧按待领取条数刷新
on_click    = false;  // Mouse_10 / Mouse_11 维护，仅影响按下态贴图
claim_count = 0;      // 待领取条数，显示在按钮文字里
