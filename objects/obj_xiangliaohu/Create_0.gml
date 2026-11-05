// obj_xiangliaohu（香料虎 / 海洋香料虎 / 魔力香料虎）Create 事件
// 增幅类·名单类增幅·追踪增幅（照浆果甜点）：给范围内**陆地追踪卡**加攻，倍率 = atk/100，同类不叠加取最高
//   名单由 card_buff_category 的 "追踪类" 决定（含盖亚神使），引擎按 buffer_type 找卡
//   2026-11-06：名单与莓果点心**完全同步** —— apply_buff 里 tracker_berry 那一格现在两张卡都写
//   （只认 tracker_berry 的冰块冷萃机以前吃不到香料虎的增幅）
// 素材 13 帧纯待机（0~12）
// 数值：atk = 倍率 × 100（2 转用 mod_cards_init 的第二张表）
event_inherited();
plant_id = "xiangliaohu";
event_user(0);

if (shape == 0)      sprite_index = spr_xiangliaohu;
else if (shape == 1) sprite_index = spr_xiangliaohu_1;
else                 sprite_index = spr_xiangliaohu_2;

plant_type = "normal";
feature_type = "normal";
is_slowdown = false;
image_speed = 0;

idle_anim   = 12;
attack_anim = 0;
flash_speed = 5;

buffer_type = "tracker";
buffer_type_2 = undefined;
buff_value = atk / 100;
buff_shape = (shape >= 1) ? "5x5" : "3x3";
buff_cells = build_buff_cells(grid_col, grid_row, buff_shape, buff_value);
buff_cells_refreshed = false;
