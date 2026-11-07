// 能量喵·平射过火（星弹 / 焚寂马 / 普通子弹共用这一份）
// 2026-11-05 两处修正：
//   ① 星弹没有 row（Create 里 row 恒 0，发射时才写 center_row）→ 原来按 row 判，只有第 0 行能点燃；
//   ② 改成 center_row 之后又变成「五发全吃」——星星兔五发共用同一个 center_row，
//      所以还得按「水平飞行」区分，只让中路（angle 0，move_y = 0）那一发吃增幅。
//      与同目录的火盆 / 火神 / 金牛三处完全同口径。
// 另外补 variable_instance_exists 门禁：挂这个事件的普通子弹没有 kind / center_row，
// 裸读会报「变量未设置」。判定顺序：星弹看水平 + center_row → 其它星座马看 center_row → 普通子弹看 row。
// 注意星座马的 row 也一直存在（恒 0），所以 center_row 必须排在 row 前面。
if (ds_list_find_index(brazier_list, other.id) != -1) exit;
if (burnt != 0) exit;

var _is_star = variable_instance_exists(id, "kind") && kind == "star";
var _same_line;
if (_is_star){
    _same_line = (abs(move_y) < 0.001) && (center_row == other.grid_row);
}
else if (variable_instance_exists(id, "center_row")){
    // 其它星座马（焚寂马等）：也有 row（恒 0），但正确值一直写在 center_row 里
    _same_line = (center_row == other.grid_row);
}
else if (variable_instance_exists(id, "row")){
    _same_line = (row == other.grid_row);
}
else{
    _same_line = false;
}
if (!_same_line) exit;

burnt += 1;
damage = round(damage * other.atk / 100);
bullet_fire_mult_up(id, other.atk / 100);
// 焚寂马分裂波按 base_damage 生成，必须同步增幅，否则过火后的实际伤害没有提升
// （与 obj_brazier / 火神 / 金牛 / 融合火盆同口径；能量喵 atk 存 ×100，要 /100）
if (variable_instance_exists(id, "kind") && kind == "fire" && variable_instance_exists(id, "base_damage")){
    base_damage = round(base_damage * other.atk / 100);
}
ds_list_add(brazier_list, other.id);
audio_play_sound(snd_bullet_burnt, 0, 0);
image_xscale = 1.8;
image_yscale = 1.8;
