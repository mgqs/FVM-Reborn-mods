// obj_tianxie 用户事件 1（Other_11）：出弹
//
// 0 / 1 转（shape 0~1）：猩红毒针 —— 取本行**整行**最左敌人所在列（2026-11-09 取消盲区），
//   交给 tianxie_fire 放演出 + 定 4 格范围。伤害不在这里结算，由演出对象按「四根针依次落下」逐格打。
//   海克斯「疑神疑鬼」空放时没有目标：往自身格 +4 那带打，保证演出不指向虚空。
//
// 2 转（shape >= 2）：**随机发射其他卡种的一次攻击**（2026-11-09 用户定稿，见 Create 里的 tx_shoot）。
//   权重 / 11 张卡的复刻口径全在 Create_0 底部的 tx_* 段；这里只负责分流。
if (shape >= 2)
{
    tx_shoot();
    exit;
}

var _col = tianxie_left_enemy();
if (_col < 0) _col = grid_col + 4;

tianxie_fire(_col);
