// 石榴爆爆冰 —— 被提前击破时也要炸（数据表：「死亡碎冰效果」）
// 正常流程是 Other_11 里 event_user(1) → instance_destroy()，此时 triggered = true，不再重复结算；
// 只有在准备阶段被鼠啃死（triggered 仍为 false）才补一次引爆。
if (variable_instance_exists(id, "triggered") && !triggered) {
    if (variable_instance_exists(id, "explode_timer")) {
        triggered = true;
        event_user(1);
    }
}
event_inherited();
