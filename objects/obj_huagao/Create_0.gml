// 灯影花糕：固定轨迹类，召唤魂虫向左/右两侧飞出，攻击上中下三行陆军。
event_inherited();
plant_id = "huagao";
obj_type = object_index;
event_user(0);

plant_type = "normal";
feature_type = "lava";   // 可放岩浆（与炎凰马一致）
sprite_index = spr_huagao;
if (shape == 1) sprite_index = spr_huagao_1;
else if (shape >= 2) sprite_index = spr_huagao_2;

// 精灵帧：1-12 闲置（0-based 0-11）、13-21 攻击（0-based 12-20）。
// 父对象按 idle_anim+1 .. idle_anim+attack_anim 推进攻击帧，
// attack_anim 取比实际帧数少 1，才能完整播到第 21 帧。
idle_anim = 11;
attack_anim = 8;
flash_speed = 5;

huagao_timer = 0;
huagao_shot = false;
huagao_vertical_timer = 0;
