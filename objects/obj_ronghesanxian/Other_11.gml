// 融合三线 · 开火：一次齐射 = 向前方三行各发射 1 发葡萄酒弹（本行 / 上一行 / 下一行）
//   一轮攻击按 shots_per_row 齐射 2~3 次（0 转 2 次 / 1、2 转 3 次）
// 出弹口沿用基础卡 obj_triple_wine_rack 的写法：三行子弹从同一 y 出生，再各自 lerp 到目标行
// 灵魂融合（2 转）的子弹置 pierce_all = true（穿透全部老鼠与障碍，无数量上限）
var middle_y = y - 75;

var _pierce = (shape >= 2);
var _burn_dmg = burn_dmg_table[clamp(current_level, 0, array_length(burn_dmg_table) - 1)];

// 本行
var inst_middle = instance_create_depth(x + 40, middle_y, depth - 500, obj_ronghesanxian_bullet);
inst_middle.damage = atk;
inst_middle.move_speed = 8;
inst_middle.row = grid_row;
inst_middle.target_row = grid_row;
inst_middle.burn_damage = _burn_dmg;
inst_middle.pierce_all = _pierce;

// 上一行
var inst_up = instance_create_depth(x + 40, middle_y, depth - 500, obj_ronghesanxian_bullet);
inst_up.damage = atk;
inst_up.move_speed = 8;
inst_up.row = grid_row;
inst_up.start_y = middle_y;
inst_up.burn_damage = _burn_dmg;
inst_up.pierce_all = _pierce;
if grid_row - 1 >= 0{
	inst_up.target_row = grid_row - 1;
}
else{
	inst_up.target_row = grid_row;
	inst_up.x -= 20;
}

// 下一行
var inst_down = instance_create_depth(x + 40, middle_y, depth - 500, obj_ronghesanxian_bullet);
inst_down.damage = atk;
inst_down.move_speed = 8;
inst_down.row = grid_row;
inst_down.start_y = middle_y;
inst_down.burn_damage = _burn_dmg;
inst_down.pierce_all = _pierce;
if grid_row + 1 < global.grid_rows{
	inst_down.target_row = grid_row + 1;
}
else{
	inst_down.target_row = grid_row;
	inst_down.x -= 20;
}

audio_play_sound(snd_shot, 0, 0);
