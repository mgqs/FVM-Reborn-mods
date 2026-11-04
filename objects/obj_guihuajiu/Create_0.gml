// obj_guihuajiu（桂花酒）Create 事件
// 形态：0 桂花酒 / 1 陈年桂花酒 / 2 仙酿桂花酒
// 素材：spr_guihuajiu / _1 / _2 各 20 帧（酒坛只占画布中间，爆开帧才铺到 3×3）
//       spr_guihuajiu_burn 18 帧 = 残留燃烧的酒精；spr_guihuajiu_drunk 20 帧 = 二转醉酒标记
// 帧段（共 20 帧）：帧 1~7（index 0~6）待机；帧 8~10（index 7~9）前摇膨胀；
//       帧 11（index 10）起爆，帧 11~20（index 10~19）爆开扩散
// 数值：素材包「数据.xlsx」——体力 500→1740，耗能 125，冷却 50/48/45/42/38/34/30/25/20 秒
event_inherited();
plant_id = "guihuajiu";
obj_type = object_index;
event_user(0);

plant_type = "normal";
feature_type = "normal";

if (shape <= 0)      sprite_index = spr_guihuajiu;
else if (shape == 1) sprite_index = spr_guihuajiu_1;
else                 sprite_index = spr_guihuajiu_2;

image_speed = 0;
flash_speed = 6;

IDLE_FIRST   = 0;
IDLE_LAST    = 6;
WINDUP_FIRST = 7;
WINDUP_LAST  = 9;
BOOM_FIRST   = 10;
BOOM_LAST    = 19;

idle_anim = IDLE_LAST;
attack_anim = BOOM_LAST - IDLE_LAST;

// 数值全部走注册表（mod_cards_init 里三形态各一份），方便在卡片面板直接看 / 直接改：
//   爆炸伤害   → atk（0 转 500 / 1·2 转 900）
//   燃烧伤害   → flame_produce（0 转 50 / 1·2 转 100，每格总伤）
//   每秒限伤   → cycle（0 转 200 / 1 转 150 / 2 转 100，所有来源合计）
//   🔴 cycle 是「攻击间隔」，面板（情报岛 obj_info_island_bg/Draw_0）显示时会 ÷60，
//      所以注册表里存的是 数值 ×60（12000 / 9000 / 6000），这里必须 ÷60 还原成真实数值。
boom_damage = atk;
boom_cross  = (shape >= 1);
boom_type   = "ash";

burn_total  = variable_instance_exists(id, "flame_produce") ? flame_produce : 50;
burn_cross  = (shape >= 1);
burn_type   = "physical";

cap_per_sec = (origin_cycle > 0) ? (origin_cycle / 60) : 200;   // origin_cycle：减速时 cycle 会被 ×2
cap_used    = 0;
cap_timer   = 60;
last_hp     = hp;

// 二转醉酒：命中后 25 秒内受伤 ×1.5（BOSS 除外）
drunk_time  = (shape >= 2) ? 25 * 60 : 0;
drunk_mult  = 1.5;
