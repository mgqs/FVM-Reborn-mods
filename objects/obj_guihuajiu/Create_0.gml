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
//   爆炸伤害   → custom["爆炸伤害"]（0 转 500 / 1 转 900 / 2 转 1800）
//   燃烧伤害   → custom["燃烧伤害"]（0 转 50 / 1·2 转 100，每格总伤）
//   每秒限伤   → custom["每秒限伤"]（0 转 200 / 1 转 150 / 2 转 100，所有来源合计）
boom_cross  = (shape >= 1);
boom_type   = "ash";

burn_cross  = (shape >= 1);
burn_type   = "physical";

// 三个数值都从注册表 custom 取（2026-11-05 从 cycle 搬出、2026-11-06 从 atk / flame_produce 搬出）
var _gj_skill = variable_instance_exists(id, "skill") ? skill : 0;
var _gj_info  = get_plant_data_with_skill("guihuajiu", shape, clamp(current_level, 0, 16), _gj_skill);
cap_per_sec = (_gj_info != undefined) ? _gj_info[? "每秒限伤"] : 200;
// 爆炸伤害：固定值（原先存在 atk 表里，17 档全一样，没必要；本卡 atk 已归 0）
boom_damage = (_gj_info != undefined && ds_map_exists(_gj_info, "爆炸伤害")) ? _gj_info[? "爆炸伤害"] : 500;
// 燃烧伤害：每格总伤（原先借 flame_produce 占位，现已归还，本卡不再产火苗）
burn_total  = (_gj_info != undefined && ds_map_exists(_gj_info, "燃烧伤害")) ? _gj_info[? "燃烧伤害"] : 50;
cap_used    = 0;
cap_timer   = 60;
last_hp     = hp;

// 二转醉酒：命中后 25 秒内受伤 ×1.5（BOSS 除外）
drunk_time  = (shape >= 2) ? 25 * 60 : 0;
drunk_mult  = 1.5;
