// obj_bbq_bullet（街头烤肉大师的串串子弹）Create 事件
// 直线向右、全程穿透（同一条老鼠只吃一次），可吃火盆 / 融合火盆 / 火神 / 金牛的过火增幅。
// 池复用：显示变量一律在 Create 清零（父对象 Draw 会按 visual_scale 画，别留上一条子弹的缩放）。
event_inherited();
can_dandantu_store = true;

sprite_index = spr_bbq_bullet;
image_speed = 0;
image_index = 0;
image_angle = 0;
image_alpha = 1;
image_blend = c_white;
image_xscale = 1.6;
image_yscale = 1.6;

damage = 0;
// 速度：3 格/秒 = 107*3/60 ≈ 5.35 px/帧；过火后 4.5 格/秒 ≈ 8.02（2026-10-31 固定攻击改版）
move_speed = 5.35;
burnt_speed = 8.02;
move_dir = 1;            // 1 = 向右飞；被布丁 / 水神反弹后变 -1
start_x = 0;             // 出膛点（由 obj_bbq 传，反弹后往回飞出这里就销毁）
end_x = 2200;            // 第 9 格右沿（由 obj_bbq 传）
bounced = false;
row = 0;
burn_shot = false;
damage_type = "pierce";
target_type = "normal";

// 过火相关（ronghehuopen_pass_fire / 火盆碰撞都按这几个字段判定）
kind = "fire";
burnt = 0;
can_burn = true;
brazier_list = ds_list_create();

hitted = ds_list_create();
hittable_types = ["normal", "air", "invisible"];
max_life = 300;
life = 0;
