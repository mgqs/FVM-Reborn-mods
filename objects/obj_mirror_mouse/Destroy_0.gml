// Inherit the parent event
event_inherited();

// 先把「还在飞向本体、还没进 return_flame」的火苗一起算进返还量。
// 玩家最常见的击杀时机就是它在吸收的这几秒里 —— 那些火苗 is_capture = true，
// 原来的收尾 `with obj_flame { is_capture = false; speed = 0 }` 只是把它们停在空中，
// 既不加到 return_flame，也不会落地/过期，结果就是「吸走的火苗死后不返还」。
with (obj_flame)
{
	if (is_capture
		&& variable_instance_exists(id, "capture_owner")
		&& capture_owner == other.id)
	{
		other.return_flame += value;
		instance_destroy();
	}
}

if return_flame > 0
{
	var inst = instance_create_depth(x,y-80,-800,obj_flame)
	inst.value = return_flame
	inst.is_capture = false
	inst.is_collected = false
	inst.speed = 0
}
