// 牛油果飞镖：可穿透障碍，直接穿过、不销毁
// （与 obj_obstacle/Step_0 里对 pierce_all 的放行配套）
if (pierce_all) exit;

if (precise_bbox_collision(id, other)){
	var inst = instance_create_depth(x, y, depth, obj_coffeecup_bullet_effect)
	inst.sprite_index = spr_ronghesanxian_bullet_effect
	instance_destroy()
}
