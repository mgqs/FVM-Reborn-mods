// obj_dangdanghu_bullet（糕饼）Create：抛物线飞向落点，落地炸出灼烧格
image_speed = 0;
image_index = 0;
image_alpha = 1;
image_blend = c_white;
image_xscale = 1.6;
image_yscale = 1.6;

sx = 0;
sy = 0;
tx = 0;
ty = 0;
row = 0;
col = 0;
damage = 0;
shape = 0;
T = 30;
arc = 110;
t = 0;
tick_gap = 12;
tick_count = 10;

// 2026-11-06：三段式自己演（0 飞行 / 1 落地炸开 / 2 火焰循环 + 结算伤害）
phase = 0;
burn_t = 0;
ticks = 0;
tick_timer = 0;
