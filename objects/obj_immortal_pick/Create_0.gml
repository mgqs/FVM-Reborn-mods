// obj_immortal_pick（不朽开局奖励 · 自选一张）Create 事件
// 🔴 2026-10-31（三改）：候选卡**回到 3 张**（生煎锅 / 披萨炉 / 玉蜀黍，麻辣香锅已去掉），
//   难度与开局星级走 difficulty_rules 的 immortal_pick_info()：生煎锅 易·0星 / 披萨炉 中·2星 / 玉蜀黍 难·4星。
//   星级画在卡框左上角（spr_star_slot 第 star-1 帧，0 星不画）。
//   Draw / Step 的卡位按 array_length(cards) 自动居中，spacing 不变（390 * 缩放）。
// 🔴 2026-10-30 改：**从 Draw GUI 改成普通 Draw（房间坐标）**。
//   工程里所有界面（含能正常显示的 obj_gacha_reward_popup）都是房间坐标绘制，
//   且从未调用 display_set_gui_size —— GUI 层尺寸 = 窗口像素，跟 1920×1080 的房间对不上，
//   结果是「实例建出来了但画不到该在的地方」，用户看到的就是「弹窗不出现」。
// 版式基准 1920×1080，按房间尺寸等比缩放。
// 流程：点卡 → 只高亮选中；点「确定」→ 才 unlock_card + 存盘 + 关窗。
// 异常：没点确定就被销毁（强关 / ESC / 切房间）→ Destroy 里默认发第一张。
cards = immortal_pick_card_list();
selected = -1;          // 已点中的卡下标（-1 = 还没选）
hover_card = -1;
hover_btn = false;
committed = false;      // true = 已经点过确定（Destroy 不再兜底）

gw = room_width;
gh = room_height;
_s  = gw / 1920;                 // 版式缩放
cx = gw * 0.5;

title_y = gh * 0.100;
sub_y   = gh * 0.198;
card_cy = gh * 0.500;           // 2026-10-31 由 0.4675 下移：上面要留「开局难度」一行
btn_y   = gh * 0.7926;

spacing = 390 * _s;
slot_sc = 1.15 * _s;
btn_sc  = 1.85 * _s;

// 弹窗是模态：创建出来先吃掉这一帧的点击，避免「点不朽那一下」把窗里的按钮也点了
input_guard = 2;
