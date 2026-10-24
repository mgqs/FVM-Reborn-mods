event_inherited();
plant_id = "zhuzhujiaqiang";
event_user(0);
sprite_index = spr_zhuzhujiaqiang;

// 0 = 猪猪加强器 / 1 = 猪猪信号塔（一转，体力翻倍）/ 2 = 猪猪发射站（二转，增幅大幅提升）
if (shape == 1)
    sprite_index = spr_zhuzhujiaqiang_1;
else if (shape == 2)
    sprite_index = spr_zhuzhujiaqiang_2;

attack_anim = 0;
// 纯增幅卡没有攻击动作，整张精灵都当作待机动画播放
idle_anim = sprite_get_number(sprite_index);
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
// 为本行投掷类卡片增伤，倍率 = 攻击力 / 100
buffer_type = "thrower";
buff_value = atk / 100;
buff_shape = "row";
buff_cells = build_buff_cells(grid_col, grid_row, buff_shape, buff_value);
buff_cells_refreshed = false;
