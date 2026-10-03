// 披萨炉子弹发射事件 - 单发三角形穿透披萨
var inst = instance_create_depth(x + 40, y - 70, depth - 500, obj_pizzaoven_bullet)

// 设置伤害
inst.damage = atk

// 设置移动速度
inst.move_speed = 8

// 设置三角形路径的三个顶点
// point0: 卡牌位置
// point1: 最右列第一行上顶点
// point2: 最右列最后一行下顶点
// 路径：point0 -> point1 -> point2 -> point0
var pos_self = get_world_position_from_grid(grid_col, grid_row)

var right_edge_x = global.grid_offset_x + global.grid_cols * global.grid_cell_size_x
var top_edge_y = global.grid_offset_y
var bottom_edge_y = global.grid_offset_y + global.grid_rows * global.grid_cell_size_y

inst.point0_x = pos_self.x
inst.point0_y = pos_self.y - 70
inst.point1_x = right_edge_x
inst.point1_y = top_edge_y
inst.point2_x = right_edge_x
inst.point2_y = bottom_edge_y

// 当前目标点索引（0->1->2->0）
inst.target_point = 1

// 设置子弹精灵
if shape == 1{
	inst.sprite_index = spr_pizza_oven_bullet_1
}
else if shape == 2{
	inst.sprite_index = spr_pizza_oven_bullet_2
}
else{
	inst.sprite_index = spr_pizza_oven_bullet
}
