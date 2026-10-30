/// 障碍物（不可见的格子级阻挡体）
/// 碰撞遮罩 = 实际精灵图像大小，且严格限制在单个格子内。
///   · spr_pixel 是 2×2 的实心像素块，旧代码直接 image_xscale = grid_cell_size_x
///     会把遮罩放大成 2 倍格子（214×232），子弹提前一整格就被判定命中，
///     遮罩还会溢出到上下左右相邻格。这里按精灵实际尺寸换算缩放。
///   · 遮罩以 (x,y) 为中心，而外部创建点普遍带 y-35 偏移（注册表 y_offset=-35），
///     不吸附到格心就会有 35px 越出本格，所以出生时强制对齐格子中心。
image_alpha = 0

var _spr = sprite_index
if (!sprite_exists(_spr)) {
	_spr = spr_pixel
	sprite_index = _spr
}
// sprite_get_width/height 是单帧未缩放尺寸；1×1 兜底防止除零
var _spr_w = max(1, sprite_get_width(_spr))
var _spr_h = max(1, sprite_get_height(_spr))
var _cell_w = max(1, global.grid_cell_size_x)
var _cell_h = max(1, global.grid_cell_size_y)

// 缩放后绘制尺寸 == 遮罩尺寸 == 恰好一格
image_xscale = _cell_w / _spr_w
image_yscale = _cell_h / _spr_h

// 吸附到所属格子的中心（外部 -35 的 y 偏移不再影响判定范围）
var _cell = get_grid_position_from_world(x, y)
x = _cell.x
y = _cell.y

row = _cell.row
col = _cell.col
