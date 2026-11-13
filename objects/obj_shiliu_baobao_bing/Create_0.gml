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
// 播放顺序 = 生长 → 成熟待机 → 爆炸（素材导出时爆炸夹在生长和成熟之间，顺序本身是错的）。
// `tools/fix_shiliu_sprite_order.py` 已把每帧 PNG 原地重排成：
//   [生长 idx0..8][成熟 idx9..21][爆炸 idx22..24/31/32]
// 宽度曲线可验：生长段 62→74 单调增，成熟段 80~88 稳定，爆炸段 165~331。
// 帧表最后一段一定是爆炸 —— 不会出现「最后一帧是一颗完好的果实」。
sprite_index = spr_shiliu_0;
idle_anim = 21;     // 待机 = 生长 9 + 成熟 13（idx 0..21 共 22 帧）
attack_anim = 3;    // 爆炸 idx 22..24
if (shape == 1) {
    sprite_index = spr_shiliu_1;
    attack_anim = 10;  // idx 22..31
}
else if (shape == 2) {
    sprite_index = spr_shiliu_2;
    attack_anim = 11;  // idx 22..32
}

// 生长段只播一次（见 Step）：播到成熟段之后就锁在成熟段里呼吸，不再回卷到幼苗
shiliu_mature_start  = 9;      // 成熟段首帧 idx
shiliu_mature_locked = false;
shiliu_armed         = false;  // 作用范围内出现老鼠后才置 true（没老鼠不生长、不引爆）

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
