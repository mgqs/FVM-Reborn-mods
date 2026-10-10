event_inherited();
plant_id = "time_god";
event_user(0);

if (shape == 0)
    sprite_index = spr_time_god;
else if (shape == 1)
    sprite_index = spr_time_god_1;
else if (shape == 2)
    sprite_index = spr_time_god_2;
else if (shape == 3)
    sprite_index = spr_time_god_3;

attack_anim = 0;
idle_anim = 35;
flash_speed = 5;
plant_type = "coffee";
is_slowdown = false;
current_hp = hp;
image_speed = 0;

exec_count = 0;

if (skill == 0)
    max_exec = 3;
else if (skill == 6)
    max_exec = 4;
else if (skill == 8)
    max_exec = 5;
else
    max_exec = 3;

first_delay = 72;
cycle_interval = 420;

if (skill == 0)
    lifetime = 1020;
else if (skill == 6)
    lifetime = 1440;
else if (skill == 8)
    lifetime = 1860;
else
    lifetime = 1020;
lifetime_timer = lifetime;

reduction_timer = first_delay;

tg_timer = 0;
anim_frame = 0;
image_alpha = 0;

var eff_spr = spr_time_god_effect;
if (shape == 1)
    eff_spr = spr_time_god_effect_1;
else if (shape == 2)
    eff_spr = spr_time_god_effect_2;
else if (shape == 3)
    eff_spr = spr_time_god_effect_3;

tg_corner_effects = [];
time_god_effect_obj = noone;

if (shape == 3)
{
    // 形态3：与海洋女神全屏效果一样，特效出现在地图四角（素材锚定右下角，其余三角镜像翻转）
    var fx_scale = 1.8;
    var fx_width = sprite_get_width(spr_time_god_effect_3);
    var fx_xoffset = sprite_get_xoffset(spr_time_god_effect_3);
    var fx_yoffset = sprite_get_yoffset(spr_time_god_effect_3);
    var grid_left = global.grid_offset_x;
    var grid_top = global.grid_offset_y;
    var grid_right = grid_left + global.grid_cols * global.grid_cell_size_x;
    var grid_bottom = grid_top + global.grid_rows * global.grid_cell_size_y;
    var grid_effect_offset_y = -20;
    var half_cell_x = global.grid_cell_size_x * 0.5;
    var half_cell_y = global.grid_cell_size_y * 0.5;
    var corner_x = [
        grid_left + (fx_width - fx_xoffset) * fx_scale - half_cell_x,
        grid_right - (fx_width - fx_xoffset) * fx_scale + half_cell_x,
        grid_left + (fx_width - fx_xoffset) * fx_scale - half_cell_x,
        grid_right - (fx_width - fx_xoffset) * fx_scale + half_cell_x
    ];
    var corner_y = [
        grid_top + fx_yoffset * fx_scale + grid_effect_offset_y - half_cell_y,
        grid_top + fx_yoffset * fx_scale + grid_effect_offset_y - half_cell_y,
        grid_bottom - fx_yoffset * fx_scale + grid_effect_offset_y + half_cell_y,
        grid_bottom - fx_yoffset * fx_scale + grid_effect_offset_y + half_cell_y
    ];
    // 索引顺序：0左上 1右上 2左下 3右下；右下为素材原始朝向，其余镜像
    var scale_x = [-fx_scale, fx_scale, -fx_scale, fx_scale];
    var scale_y = [-fx_scale, -fx_scale, fx_scale, fx_scale];
    for (var i = 0; i < 4; i++)
    {
        var corner_fx = instance_create_depth(corner_x[i], corner_y[i], -3000, obj_time_god_effect);
        corner_fx.is_corner = true;
        corner_fx.sprite_index = spr_time_god_effect_3;
        corner_fx.image_xscale = scale_x[i];
        corner_fx.image_yscale = scale_y[i];
        corner_fx.image_index = 0;
        corner_fx.image_alpha = 0;
        array_push(tg_corner_effects, corner_fx);
    }
}
else
{
    time_god_effect_obj = instance_create_depth(x, y - 30, 0, obj_time_god_effect);
    time_god_effect_obj.parent_plant = id;
    time_god_effect_obj.sprite_index = eff_spr;
    time_god_effect_obj.is_one_shot = false;
    if (instance_exists(time_god_effect_obj))
        time_god_effect_obj.image_alpha = 0;
}

if (shape >= 1)
{
    var start_spr = spr_time_god_start_1;
    if (shape == 2)
        start_spr = spr_time_god_start_2;
    else if (shape == 3)
        start_spr = spr_time_god_start_3;

    var boom = instance_create_depth(x, y, depth - 100, obj_time_god_effect);
    boom.sprite_index = start_spr;
    boom.is_one_shot = true;
    boom.frame_counter = 0;

    with (obj_enemy_parent)
    {
        if (hp > 0)
        {
            var dx = abs(x - other.x);
            var dy = abs(y - other.y);
            if (dx < 200 && dy < 200)
            {
                damage_amount = other.atk;
                damage_type = "explosion";
                event_user(0);
            }
        }
    }
}
