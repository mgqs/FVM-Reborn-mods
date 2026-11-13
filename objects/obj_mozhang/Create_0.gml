event_inherited();
plant_id = "mozhang";
event_user(0);

if (shape == 0)
    sprite_index = spr_mozhang;
else if (shape == 1)
    sprite_index = spr_mozhang_1;
else if (shape == 2)
    sprite_index = spr_mozhang_2;

attack_anim = 0;
idle_anim = 12;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;

// ── 增幅：三条通道（2026-11-14 官方 4.增幅 r112）──────────────────────
//   旋喷档 sprayer        ：旋转喷壶类 + 金刚马/红柳/护法神，5×5（3 转 5×5，0 转 3×3）
//   附加档 sprayer_attach ：附加类（目前只有弹珠汽水），同一份 5×5
//   咖啡档 sprayer_coffee ：咖啡喷壶类，本行整行
buff_value = atk / 100;
var _radius = (shape >= 1) ? 2 : 1;
buff_outputs = [
    { type: "sprayer",        cells: cells_square(grid_col, grid_row, _radius, buff_value) },
    { type: "sprayer_attach", cells: cells_square(grid_col, grid_row, _radius, buff_value) },
    { type: "sprayer_coffee", cells: cells_row(grid_row, buff_value) }
];
buff_cells_refreshed = false;

ds_list_add(global.buff_sources, id);
global.buff_dirty = true;
