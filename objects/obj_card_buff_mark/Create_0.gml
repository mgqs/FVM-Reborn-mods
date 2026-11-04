/// 卡片常驻状态标记
/// 龙柱的「清醒」「保护」原来只在施法瞬间播一次短特效（spr_mixian_effect2 约 1 秒），
/// 但效果本身持续 15~30 秒，视觉上「看不到效果在」。这里改成常驻标记：
/// 由 obj_card_parent/Step_0 在效果计时 > 0 期间维持本实例，计时归零即销毁，
/// 做到「效果持续几秒就显示几秒」。
/// 本对象没有 Draw 事件，走引擎自动 draw_self，靠 image_xscale / image_alpha 控外观。

mark_owner = noone;   // 跟随的卡片实例
mark_kind = 0;        // 0 = 清醒（松露大厅封印龙柱）  1 = 保护（百味关封印龙柱 / 星穹马减伤）
mark_timer = 0;       // 本地帧计数，驱动动画
mark_rate = 6;        // 每推进一帧动画所需步数
mark_pulse = 0;       // 脉动强度（0 = 不脉动）
mark_base_alpha = 1;
mark_off_x = 34;      // 相对宿主卡片的偏移（默认按「清醒」印记的右上角位置）
mark_off_y = -62;

image_speed = 0;
image_alpha = 1;
