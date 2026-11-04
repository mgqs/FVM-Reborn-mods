// obj_mianbao_boom（融合菠萝面包 · 死亡爆炸）Create 事件
// 本体实例被销毁后接过来：① 把精灵尾部的爆炸段播完 ② 播到「炸开」那一帧才结算 5*5 伤害
//   sprite_index / death_first / death_last / hit_index / grid_row / grid_col 由 obj_mianbao 的 Destroy_0 写入
image_speed = 0;
image_index = 0;
image_angle = 0;
image_alpha = 1;
image_blend = c_white;
// 卡牌本体在 obj_card_parent/Draw_0 里是按 1.8 倍画的，爆炸对象必须同比例，否则会「突然变小」
image_xscale = 1.8;
image_yscale = 1.8;

death_first = 0;    // 爆炸段首帧：0 转 87 / 1 转 78 / 2 转 72
death_last  = 0;
hit_index   = 0;    // 视觉炸开的那一帧（到这一帧才结算伤害）
hit_done    = false;

grid_row = 0;
grid_col = 0;

flash_speed = 5;
t = 0;
