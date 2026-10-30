// obj_ronghedapao_bullet_effect Step 事件：13 帧，每 3 帧一帧，播完销毁
if global.is_paused{
	exit
}
timer++
image_index = floor(timer/3)
if timer >= image_number*3{
	instance_destroy()
}
