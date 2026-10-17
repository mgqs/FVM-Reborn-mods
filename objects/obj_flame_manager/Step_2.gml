// 火苗上限由龙柱模块动态计算（无贪婪龙柱时保持基础上限 15000，见 scripts/longzhu/longzhu.gml）
longzhu_flame_cap_refresh()
if global.flame > global.flame_cap{
	global.flame = global.flame_cap
}
if global.debug || global.level_id == "test_level"{
	global.flame = global.flame_cap
}