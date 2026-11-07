// obj_mianbao（融合菠萝面包）Destroy 事件
// 死亡爆炸：**只要不是铲除就炸**（2026-11-07 改口径 —— 战神齿轮 / 木鸭木轮 / 滚木 / 洞君 / 阿诺
//   都是满血直接 instance_destroy()，原来按 hp <= 0 判会整片不炸；铲除 / 龙渊偷卡都置 is_shoveled，仍不炸）
// 这里只负责起一个 obj_mianbao_boom 播爆炸段；**伤害在爆炸对象播到「炸开」那一帧时才结算**
var _shoveled = variable_instance_exists(id, "is_shoveled") && is_shoveled;

if (!_shoveled){
	// ① 爆炸段首帧（0 转 87 / 1 转 78 / 2 转 72）→ 播到精灵末帧
	var _boom = instance_create_depth(x, y, depth, obj_mianbao_boom);
	_boom.sprite_index = sprite_index;
	_boom.death_first = SEG_BOOM_FIRST;
	_boom.death_last = sprite_get_number(sprite_index) - 1;
	// ② 播到这一帧（视觉炸开）才结算伤害：偏移 7 帧 ≈ 0.47 秒（flash 4）
	_boom.hit_index = SEG_BOOM_FIRST + 7;
	_boom.flash_speed = 4;
	// ③ 5*5 范围以卡片所属格子为中心
	_boom.grid_row = grid_row;
	_boom.grid_col = grid_col;
}

event_inherited();
