// obj_budingwang（布丁汪 / 双拼布丁汪 / 什锦布丁汪）Create 事件
// 辅助类·反弹类：继承 obj_cherry_pudding —— 所有直射子弹自带的 Collision_obj_cherry_pudding
//   对「它的子对象」一样生效，所以**不用去改那 45 个子弹**，穿过来就会被弹回去。
// 反弹附伤走子弹事件里的 `damage += other.atk` → 本卡 atk 就是「附加伤害」（0 转 6→100、二转 12→190）。
// 素材 10 帧纯待机（0~9），没有攻击段。
event_inherited();

plant_id = "budingwang";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_budingwang;
else if (shape == 1) sprite_index = spr_budingwang_1;
else                 sprite_index = spr_budingwang_2;

plant_type = "normal";
feature_type = "normal";
is_slowdown = false;
image_speed = 0;

idle_anim   = 9;     // 0~9 全循环
attack_anim = 0;     // 没有攻击动作
flash_speed = 6;
