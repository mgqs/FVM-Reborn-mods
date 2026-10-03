// 赖皮蛇击杀特效 - 创建事件
// effect_shape: 0=基础, 1=一转, 2=二转
effect_shape = 0;
sprite_index = spr_laipishe_effect;

if (effect_shape == 1)
    sprite_index = spr_laipishe_effect_1;
else if (effect_shape >= 2)
    sprite_index = spr_laipishe_effect_2;

image_xscale = 1.5;
image_yscale = 1.5;
timer = 0;
image_speed = 1;
