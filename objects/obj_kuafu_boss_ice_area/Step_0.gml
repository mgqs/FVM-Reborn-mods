if global.is_paused{
	exit
}

timer ++

// 冰雾动画循环（Draw 里手动绘制，image_speed 不生效）
anim_index += anim_speed
if anim_index >= image_number{
	anim_index -= image_number
}

var _cx = global.grid_cell_size_x
var _cy = global.grid_cell_size_y

// 每帧冻结范围内的卡片。
// 格子索引判定 + 世界坐标判定取「或」：BOSS 悬空或刚落地时 grid_row 可能是负值/占位值，
// 只靠格子索引会整片漏判，世界坐标这条兜底。
with (obj_card_parent){
	if !invincible && plant_id != "player" && plant_type != "coffee"{
		var _in_grid = (other.ice_col >= 0) && (abs(grid_col - other.ice_col) <= other.ice_radius) && (abs(grid_row - other.ice_row) <= other.ice_radius)
		var _in_world = (abs(x - other.x) <= _cx * (other.ice_radius + 0.45)) && (abs(y - other.y) <= _cy * (other.ice_radius + 0.45))
		if _in_grid || _in_world{
			// 进入区域先冻 4 秒（等同冰企鹅炸弹）；解冻后若区域还在会再次冻结
			if frozen_timer <= 0{
				frozen_timer = 240
			}
			if ice_timer < 600{
				ice_timer = 600
			}
		}
	}
}

if timer >= ice_life{
	image_alpha -= 0.06
	if image_alpha <= 0{
		instance_destroy()
	}
}
