// 行门禁：只被「逻辑行 == 本障碍行」的子弹撞到才销毁（口径见 obstacle_should_block）
if (!obstacle_should_block(id, other)) exit;

if target_type == "normal" && precise_bbox_collision(id, other){
	instance_destroy()
}
