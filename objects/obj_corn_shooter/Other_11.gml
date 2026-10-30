// 出弹口对齐炮管（2026-10-31 用户反馈原 y-45 偏低）：
// 卡片按 image_xscale=1.8 绘制，三个形态的炮口都在贴图原点上方 52 px → 屏幕上约 y-94；
// 子弹贴图（57x36，原点 23,23）的可见云朵中心在原点上方 11.7 px → y-80 时云朵正好与炮管齐平。
// 同工程其它直射卡也是 y-75 ~ y-105 这一档（小龙包 y-75、离子神 y-105），判定不受影响。
var inst = instance_create_depth(x + 60, y - 80, depth - 500, obj_corn_shooter_bullet);

if (shape >= 1)
    inst.sprite_index = spr_corn_shooter_bullet_2;

inst.damage = atk;
inst.move_speed = 8;
inst.row = grid_row;
