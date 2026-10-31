// obj_tangchaolizi_bullet（滚烫栗子）Create 事件
// 素材：0 转 32 帧 / 1·2 转 36 帧 —— 0~7 飞行、8~13 爆开、14 起火焰（末尾 1 帧是空帧）
// 原地形：抛物线（lerp + 拱高）飞到落点，落地生成 obj_tangchaolizi_bullet_effect 结算灼烧。
event_inherited();

damage = 0;
row = 0;
col = 0;
shape = 0;

sx = x; sy = y;
tx = x; ty = y;
t = 0;
T = 26;
arc = 100;
fly_end = 7;

image_speed = 0;            // 自己推帧，别让引擎把爆开/火焰帧播到空中
image_index = 0;
image_angle = 0;

// 与生煎锅子弹同一口径
image_xscale = 1.8;
image_yscale = 1.8;

damage_type = "throw";
target_type = "throw";
