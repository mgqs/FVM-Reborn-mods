// 只给「当前页可见的 9 行」定位；其余行挪出画面，避免它们按创建时的 y 叠到可见区
if !instance_exists(obj_task_bg) exit
if btn_index >= obj_task_bg.y_offset && btn_index <= obj_task_bg.y_offset + 8{
	y = obj_task_bg.y-65+52*(btn_index-obj_task_bg.y_offset)
}
else{
	y = -9999
}
