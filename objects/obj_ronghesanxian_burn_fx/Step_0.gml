// obj_ronghesanxian_burn_fx Step：5 帧循环 + 跟随目标老鼠（贴图在脚下上移 35px）
if global.is_paused{
	exit
}
timer++;
image_index = floor(timer / 5) mod sprite_get_number(sprite_index);

// 目标没了就自毁（控制器也会兜一层）
if (!instance_exists(follow)){
	instance_destroy();
	exit;
}
x = follow.x;
y = follow.y - 35;
