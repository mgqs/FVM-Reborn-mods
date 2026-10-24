// 融合咖啡杯子弹碰障碍：穿透形态直接穿过，不穿透的照原版销毁
// （与 obj_obstacle/Step_0 里对 pierce_all 的放行配套）
if (pierce_all) exit;

if (target_type == "normal" && row == other.row && precise_bbox_collision(id, other)){
	instance_destroy()
}
