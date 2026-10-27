// 行门禁：只被「逻辑行 == 本障碍行」的子弹撞到才销毁（口径见 obstacle_should_block）
if (!obstacle_should_block(id, other)) exit;

// 焚寂马直线弹、分裂波和星星兔星弹均可穿过障碍物。
if (kind != "fire" && kind != "wave" && kind != "star" && kind != "wind") instance_destroy();
