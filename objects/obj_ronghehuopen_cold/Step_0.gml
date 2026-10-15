// obj_ronghehuopen_cold（融合火盆·寒气柱特效）Step 事件
// timer 驱动 19 帧动画（每 2 帧 1 张），播完后淡出销毁
if global.is_paused{
	exit
}
timer++
image_index = min(floor(timer / 2), 18)
if timer > 44{
	instance_destroy()
}
else if timer > 38{
	image_alpha = (44 - timer) / 6
}
