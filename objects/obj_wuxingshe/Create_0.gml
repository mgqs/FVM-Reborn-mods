// obj_wuxingshe（五行蛇）Create 事件
// 三形态：0转 五行蛇 / 1转 通灵五行蛇 / 2转 泰斗五行蛇
// 机制：常驻法阵，为范围内的「多向类」卡片增加攻击力（五向增幅）；
//       0/1 转 3*3，2 转 5*5；**不增幅鱿鱼（youyu_god）与牛油果（niuyouguo）**。
//       本体无攻击行为，28 帧全是闲置循环。
// 数值取自「龙渊期新增卡组\数据与建议.xlsx」五行蛇那一段（倍率 17 档 / 耗能 280 / 冷却 40~15 秒）；
// atk 存的是「倍率 × 100」（与丰饶神同口径：buff_value = atk / 100），所以是 104.5 这种小数。
event_inherited();
plant_id = "wuxingshe";
obj_type = object_index;
event_user(0);

if (shape == 0) sprite_index = spr_wuxingshe;
else if (shape == 1) sprite_index = spr_wuxingshe_1;
else sprite_index = spr_wuxingshe_2;

// 28 帧全部是闲置摆动，没有攻击动作
idle_anim = 27;
attack_anim = 0;
flash_speed = 5;
plant_type = "normal";
feature_type = "normal";
is_slowdown = false;
state = CARD_STATE.IDLE;

// 五向增幅（five_dir）：只给五向类 —— 鱿鱼归多向增幅（multi_dir）、牛油果归三向，两者都不在名单里
buffer_type = "five_dir";
buff_stacking = false;
buff_max_stacks = 1;

buff_value = atk / 100;
buff_shape = (shape >= 2) ? "5x5" : "3x3";
buff_cells = build_buff_cells(grid_col, grid_row, buff_shape, buff_value);
buff_cells_refreshed = false;

global.buff_dirty = true;

// 常驻法阵光环：0/1 转八角框按 3*3 精确铺满，2 转太极圆环按 1.65× 放大到 5*5
wuxingshe_age = 0;
wuxingshe_effects = [];
// 光环画在卡片**下层**（depth 比卡片大 = 更靠后），别盖住蛇本体
var _e = instance_create_depth(x, y, depth + 10, obj_zodiac_effect);
_e.sprite_index = spr_wuxingshe_effect;
if (shape == 1) _e.sprite_index = spr_wuxingshe_effect_1;
else if (shape >= 2) _e.sprite_index = spr_wuxingshe_effect_2;
_e.life = 2147483647;          // 常驻，不自然消失
_e.image_index = 0;
_e.image_speed = 0.5;
if (shape >= 2) {
    _e.image_xscale = 1.65;
    _e.image_yscale = 1.65;
} else {
    _e.image_xscale = 3 * global.grid_cell_size_x / sprite_get_width(_e.sprite_index);
    _e.image_yscale = 3 * global.grid_cell_size_y / sprite_get_height(_e.sprite_index);
}
array_push(wuxingshe_effects, _e);
