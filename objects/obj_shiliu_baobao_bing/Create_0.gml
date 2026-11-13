// 石榴爆爆冰 —— 灰烬类 / 瞬发类 / 爆炸类
// 数据表口径：
//   耗能 216、体力 1000，星级强化 = 攻击力，技能训练 = 冷却速度
//   作用范围 = 爆炸范围 + 碾压索敌范围：3*3+5*5 / 3*3+7*7 / 5*5+7*7
//   3*3 | 3*3 | 5*5 灰烬爆炸，死亡碎冰效果；未死亡附加冰冻 4s、减速 20s
//   对 5*5 | 7*7 | 7*7 范围最近 2 / 2 / 4 个陆、地目标造成攻击力伤害碾压
event_inherited();
plant_id = "shiliu_baobao_bing";
obj_type = object_index;
current_level = 1;
event_user(0);

// ========== 形态精灵 ==========
// 三个形态的帧结构一致：0..8 待机（果实微动），9 起为爆炸段，之后回落。
sprite_index = spr_shiliu_0;
attack_anim = 3;   // 爆炸段帧数：idx 9..11
if (shape == 1) {
    sprite_index = spr_shiliu_1;
    attack_anim = 9;   // idx 9..17
}
else if (shape == 2) {
    sprite_index = spr_shiliu_2;
    attack_anim = 10;  // idx 9..18
}
idle_anim = 8;

flash_speed = 5;
plant_type = "normal";
feature_type = "normal";
target_type = "all";
is_slowdown = false;
invincible = false;
triggered = false;

// 爆炸段自己推进（不依赖父对象的 image_index 夹逼）
anim_frame = 0;
anim_timer = 0;

// ========== 引爆延迟（准备时间，tick）==========
explode_timer = 90;
if (shape == 1) explode_timer = 75;
else if (shape == 2) explode_timer = 60;

// ========== 爆炸 / 碾压参数 ==========
// explode_radius：切比雪夫半径，1 = 3*3，2 = 5*5
// crush_radius：碾压索敌半径，2 = 5*5，3 = 7*7
// crush_count：碾压目标数
explode_radius = 1;
crush_radius = 2;
crush_count = 2;
if (shape == 1) {
    explode_radius = 1;
    crush_radius = 3;
    crush_count = 2;
}
else if (shape == 2) {
    explode_radius = 2;
    crush_radius = 3;
    crush_count = 4;
}

// ========== 冰冻 / 减速（tick）==========
freeze_ticks = 4 * 60;
slow_ticks = 20 * 60;

can_mouse_list = ["can_mouse"];
