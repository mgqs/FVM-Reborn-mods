// obj_fushengcha（浮生茶）Create 事件
// 三形态：0转 浮生茶 / 1转 清心浮生茶 / 2转 忘忧浮生茶
// 机制：常驻光环增幅范围内的「直射类-固定轨迹类」卡片攻击力；
//       0转 3*3，1/2转 5*5；同类增幅（含音盒马）取最高倍率、不叠乘。
//       本体无攻击行为，1-13 帧闲置循环。
// 数值取自用户表格「浮生茶」：增幅倍率 17 档（0-16 星）、冷却 50~18 秒、耗能 265。
event_inherited();
plant_id = "fushengcha";
obj_type = object_index;
fushengcha_initializing = true;
event_user(0);
fushengcha_initializing = false;

plant_type = "normal";
feature_type = "normal";

if (shape == 0) sprite_index = spr_fushengcha;
else if (shape == 1) sprite_index = spr_fushengcha_1;
else sprite_index = spr_fushengcha_2;

// 1-13 帧闲置（0-based 0-12），本体无攻击动画，一直保持闲置循环
idle_anim = 12;
attack_anim = 0;
flash_speed = 5;
state = CARD_STATE.IDLE;

// 常驻跟随光环特效：0转 3*3，1/2转 5*5
// 缩放按「格数 × 格子尺寸 / 精灵原始尺寸」计算，保证动画实际覆盖 3*3 / 5*5
fushengcha_age = 0;
fushengcha_effects = [];
var _e = instance_create_depth(x, y, -3000, obj_zodiac_effect);
_e.sprite_index = spr_fushengcha_effect;
if (shape == 1) _e.sprite_index = spr_fushengcha_effect_1;
else if (shape >= 2) _e.sprite_index = spr_fushengcha_effect_2;
_e.life = 2147483647;
_e.image_index = 0;
_e.image_speed = 0.5;
var _halo_range = (shape == 0) ? 3 : 5;
_e.image_xscale = _halo_range * global.grid_cell_size_x / sprite_get_width(_e.sprite_index);
_e.image_yscale = _halo_range * global.grid_cell_size_y / sprite_get_height(_e.sprite_index);
array_push(fushengcha_effects, _e);

if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
