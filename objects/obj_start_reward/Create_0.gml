// obj_start_reward（开局奖励 · 领取确认窗）Create 事件
// 点「领取」才发奖；点「以后再说」不发也不记放弃。创建方负责再写 sr_diff。
sr_diff = global.difficulty;    // 要领的是哪一档（4 永恒 / 5 不朽）
sr_hover = -1;                  // 悬停按钮（0 = 领取 / 1 = 取消）
sr_guard = 2;                   // 创建出来先吃掉这一帧的点击，避免「点难度那一下」把窗里的按钮也点了
sr_done = false;                // true = 已经处理过（按钮或异常关闭），不再响应
