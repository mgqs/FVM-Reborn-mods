// obj_tianxie 用户事件 1（Other_11）：出弹
//   取本行**整行**最左敌人所在列（取消盲区，2026-11-09），交给 tianxie_fire 放演出 + 定 4 格范围。
//   伤害不在这里结算 —— 演出对象按「四根针依次落下」逐格打（见 obj_tianxie_needle）。
//   海克斯「疑神疑鬼」空放时没有目标：往自身格 +4 那带打，保证演出不指向虚空。
var _col = tianxie_left_enemy();
if (_col < 0) _col = grid_col + 4;

tianxie_fire(_col);
