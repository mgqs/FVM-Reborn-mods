if (!instance_exists(obj_battle))
    instance_destroy();

if (global.buff_dirty)
{
    reset_aurora_grid();
    rebuild_buff_grid();
    global.buff_apply_id++;
    global.buff_dirty = false;
    show_debug_message("buff地图更新");
}

// 海洋女神增幅系统
if (variable_global_exists("ocean_buff_dirty") && global.ocean_buff_dirty)
{
    rebuild_ocean_buff();
    show_debug_message("海洋女神增幅更新");
}

shield_replaced = true;

if (buff_timer > 0)
{
    buff_timer--;
}
else
{
    with (obj_card_parent)
    {
        if (self.plant_id != "player")
        {
            var just_initialized = false;
            
            if (!variable_instance_exists(self.id, "base_atk"))
            {
                var upgrade_data = get_plant_data_with_skill(self.plant_id, self.shape, self.current_level, self.skill);
                self.base_atk = (upgrade_data != undefined) ? ds_map_find_value(upgrade_data, "atk") : self.atk;
                just_initialized = true;
            }
            
            if (!variable_instance_exists(self.id, "base_cycle"))
            {
                var upgrade_data = get_plant_data_with_skill(self.plant_id, self.shape, self.current_level, self.skill);
                self.base_cycle = (upgrade_data != undefined) ? ds_map_find_value(upgrade_data, "cycle") : self.cycle;
                just_initialized = true;
            }
            
            if (!variable_instance_exists(self.id, "buff_type"))
            {
                self.buff_type = mod_get_buff_type(self.plant_id);
                just_initialized = true;
            }
            
            if (!variable_instance_exists(self.id, "buff_applied_id"))
            {
                self.buff_applied_id = -1;
                just_initialized = true;
            }

            if (!variable_instance_exists(self.id, "ocean_buff_multiplier"))
            {
                self.ocean_buff_multiplier = 1;
                just_initialized = true;
            }
            
            if (!variable_instance_exists(self.id, "buffer_type"))
            {
                if (!variable_instance_exists(self.id, "shield_buffed"))
                {
                    if (self.grid_col >= 0 && self.grid_col < global.grid_cols && self.grid_row >= 0 && self.grid_row < global.grid_rows)
                    {
                        var shield_buff = global.shield_grid[self.grid_col][self.grid_row] + 1;
                        self.base_atk *= shield_buff;
                    }
                    self.shield_buffed = true;
                    just_initialized = true;
                }
                else if (!self.shield_buffed)
                {
                    if (self.grid_col >= 0 && self.grid_col < global.grid_cols && self.grid_row >= 0 && self.grid_row < global.grid_rows)
                    {
                        var shield_buff = global.shield_grid[self.grid_col][self.grid_row] + 1;
                        self.base_atk *= shield_buff;
                    }
                    self.shield_buffed = true;
                    just_initialized = true;
                }
            }
            
            // 放置、复活或移动后的目标都按当前坐标重新判定。
            var current_ocean_mult = get_ocean_buff_multiplier(self.id);
            if (current_ocean_mult != self.ocean_buff_multiplier)
            {
                self.ocean_buff_multiplier = current_ocean_mult;
                just_initialized = true;
            }

            if (just_initialized || self.buff_applied_id != global.buff_apply_id)
            {
                if (self.grid_col < 0 || self.grid_col >= global.grid_cols || self.grid_row < 0 || self.grid_row >= global.grid_rows)
                {
                    self.atk = self.base_atk;
                    self.buff_applied_id = global.buff_apply_id;
                    continue;
                }

                var buff_multiplier = 1;

                if (!is_undefined(self.buff_type))
                {
                    switch (self.buff_type)
                    {
                        case "thrower":
                            var grid_thrower = ds_map_find_value(global.buff_grid, "thrower");
                            var buff_au = get_aurora_buff(self.grid_col, self.grid_row);
                            buff_multiplier = max(grid_thrower[self.grid_col][self.grid_row], buff_au);
                            break;

                        case "tracker":
                            var grid_tracker = ds_map_find_value(global.buff_grid, "tracker");
                            var stack_tracker = ds_map_find_value(global.buff_stack_grid, "tracker");
                            var tr_normal = grid_tracker[self.grid_col][self.grid_row];
                            var tr_stack = stack_tracker[self.grid_col][self.grid_row];
                            buff_multiplier = max(tr_normal, tr_stack);
                            break;

                        case "tracker_advanced":
                            var grid_tracker_advanced = ds_map_find_value(global.buff_grid, "tracker_advanced");
                            var stack_tracker_advanced = ds_map_find_value(global.buff_stack_grid, "tracker_advanced");
                            buff_multiplier = max(grid_tracker_advanced[self.grid_col][self.grid_row], stack_tracker_advanced[self.grid_col][self.grid_row]);
                            break;

                        case "tracker_berry":
                            var grid_tracker_berry = ds_map_find_value(global.buff_grid, "tracker_berry");
                            buff_multiplier = grid_tracker_berry[self.grid_col][self.grid_row];
                            break;

                        case "xiangshui":
                            var grid_xiangshui = ds_map_find_value(global.buff_grid, "xiangshui");
                            var stack_xiangshui = ds_map_find_value(global.buff_stack_grid, "xiangshui");
                            var xs_normal = grid_xiangshui[self.grid_col][self.grid_row];
                            var xs_stack = stack_xiangshui[self.grid_col][self.grid_row];
                            buff_multiplier = max(xs_normal, xs_stack);
                            break;

                        case "sprayer":
                            var grid_sprayer = ds_map_find_value(global.buff_grid,
                                is_row_sprayer_card(self.plant_id) ? "sprayer_row" : "sprayer");
                            buff_multiplier = grid_sprayer[self.grid_col][self.grid_row];
                            break;

                        case "five_dir":
                            // 五向增幅（五行蛇）：只给五向类；鱿鱼不在名单里（它的主类型是 multi_dir）
                            var grid_five_dir = ds_map_find_value(global.buff_grid, "five_dir");
                            var stack_five_dir = ds_map_find_value(global.buff_stack_grid, "five_dir");
                            var fd_normal = grid_five_dir[self.grid_col][self.grid_row];
                            var fd_stack = stack_five_dir[self.grid_col][self.grid_row];
                            buff_multiplier = max(fd_normal, fd_stack);
                            break;

                        case "multi_dir":
                            // 多向增幅（丰饶神）：多向类全体，含鱿鱼神
                            var grid_multi_dir = ds_map_find_value(global.buff_grid, "multi_dir");
                            var stack_multi_dir = ds_map_find_value(global.buff_stack_grid, "multi_dir");
                            var md_normal = grid_multi_dir[self.grid_col][self.grid_row];
                            var md_stack = stack_multi_dir[self.grid_col][self.grid_row];
                            buff_multiplier = max(md_normal, md_stack);
                            break;

                        default:
                            buff_multiplier = 1;
                            break;
                    }
                }

                // 第二buff类型：取与第一buff的较大值（避免同一增幅源重复计算）
                var buff_type_2 = "";
                if (variable_global_exists("plant_buff_map_2") && ds_exists(global.plant_buff_map_2, ds_type_map) && ds_map_exists(global.plant_buff_map_2, self.plant_id))
                    buff_type_2 = ds_map_find_value(global.plant_buff_map_2, self.plant_id);

                if (buff_type_2 != "" && buff_type_2 != self.buff_type)
                {
                    var buff2_multiplier = 1;
                    switch (buff_type_2)
                    {
                        case "thrower":
                            var grid_thrower2 = ds_map_find_value(global.buff_grid, "thrower");
                            var buff_au2 = get_aurora_buff(self.grid_col, self.grid_row);
                            buff2_multiplier = max(grid_thrower2[self.grid_col][self.grid_row], buff_au2);
                            break;

                        case "tracker":
                            var grid_tracker2 = ds_map_find_value(global.buff_grid, "tracker");
                            var stack_tracker2 = ds_map_find_value(global.buff_stack_grid, "tracker");
                            var tr2_normal = grid_tracker2[self.grid_col][self.grid_row];
                            var tr2_stack = stack_tracker2[self.grid_col][self.grid_row];
                            buff2_multiplier = max(tr2_normal, tr2_stack);
                            break;

                        case "tracker_advanced":
                            var grid_tracker_advanced2 = ds_map_find_value(global.buff_grid, "tracker_advanced");
                            var stack_tracker_advanced2 = ds_map_find_value(global.buff_stack_grid, "tracker_advanced");
                            buff2_multiplier = max(grid_tracker_advanced2[self.grid_col][self.grid_row], stack_tracker_advanced2[self.grid_col][self.grid_row]);
                            break;

                        case "tracker_berry":
                            var grid_tracker_berry2 = ds_map_find_value(global.buff_grid, "tracker_berry");
                            buff2_multiplier = grid_tracker_berry2[self.grid_col][self.grid_row];
                            break;

                        case "xiangshui":
                            var grid_xiangshui2 = ds_map_find_value(global.buff_grid, "xiangshui");
                            var stack_xiangshui2 = ds_map_find_value(global.buff_stack_grid, "xiangshui");
                            var xs2_normal = grid_xiangshui2[self.grid_col][self.grid_row];
                            var xs2_stack = stack_xiangshui2[self.grid_col][self.grid_row];
                            buff2_multiplier = max(xs2_normal, xs2_stack);
                            break;

                        case "sprayer":
                            var grid_sprayer2 = ds_map_find_value(global.buff_grid,
                                is_row_sprayer_card(self.plant_id) ? "sprayer_row" : "sprayer");
                            buff2_multiplier = grid_sprayer2[self.grid_col][self.grid_row];
                            break;

                        case "five_dir":
                            // 第二类型分支：五向卡的主类型是 five_dir、副类型是 multi_dir（丰饶神），两边取较高值
                            var grid_five_dir2 = ds_map_find_value(global.buff_grid, "five_dir");
                            var stack_five_dir2 = ds_map_find_value(global.buff_stack_grid, "five_dir");
                            var fd2_normal = grid_five_dir2[self.grid_col][self.grid_row];
                            var fd2_stack = stack_five_dir2[self.grid_col][self.grid_row];
                            buff2_multiplier = max(fd2_normal, fd2_stack);
                            break;

                        case "multi_dir":
                            var grid_multi_dir2 = ds_map_find_value(global.buff_grid, "multi_dir");
                            var stack_multi_dir2 = ds_map_find_value(global.buff_stack_grid, "multi_dir");
                            var md2_normal = grid_multi_dir2[self.grid_col][self.grid_row];
                            var md2_stack = stack_multi_dir2[self.grid_col][self.grid_row];
                            buff2_multiplier = max(md2_normal, md2_stack);
                            break;
                    }

                    buff_multiplier = max(buff_multiplier, buff2_multiplier);
                }

                // 海洋女神与榨汁机、魔杖蛇的喷壶增幅不叠加，取较高倍率。
                var ocean_mult = 1;
                if (variable_instance_exists(self.id, "ocean_buff_multiplier"))
                    ocean_mult = self.ocean_buff_multiplier;

                var zhanqima_mult = get_zhanqima_buff_multiplier(self.id);

                var has_sprayer_buff = (self.buff_type == "sprayer" || buff_type_2 == "sprayer");
                var combined_buff_multiplier = has_sprayer_buff
                    ? max(buff_multiplier, ocean_mult)
                    : buff_multiplier * ocean_mult;

                // 海克斯「增幅类卡片倍率」：只放大「增幅给出的那一部分」，本体 1.0 不放大
                if (hex_enabled()) {
                    var _bg = hex_buff_grant_mult();
                    if (_bg != 1.0 && combined_buff_multiplier > 1)
                        combined_buff_multiplier = 1 + (combined_buff_multiplier - 1) * _bg;
                }

                var _shield_gem_mult = get_shield_gem_atk_mult(self.grid_col, self.grid_row, self.plant_id);
                global.zodiac_music_mult = 1;
                global.zodiac_query_card = self.id;
                with (obj_yinhema) event_user(0);
                var zodiac_mult = global.zodiac_music_mult;

                // 浮生茶：固定轨迹类范围增幅。与音盒马同属「固定轨迹增幅」，同类取最高、不叠乘。
                global.fushengcha_mult = 1;
                global.fushengcha_query_card = self.id;
                with (obj_fushengcha) event_user(0);
                var fushengcha_mult = global.fushengcha_mult;

                var track_buff_mult = max(zodiac_mult, fushengcha_mult);
                self.atk = self.base_atk * combined_buff_multiplier * zhanqima_mult * _shield_gem_mult * track_buff_mult;

                // ══ 海克斯：乘在全部既有乘区之后（增幅/星级/地形/技能都不改） ══
                // hex_* 系列在非海克斯模式恒返回 1.0，所以这里不需要 if 包住 atk
                self.atk *= hex_atk_mult_for_card(self.plant_id);

                if (hex_enabled())
                {
                    // 「双灶并行」：每行最左侧卡片额外攻击（需要坐标，不能放进 hex_dyn_atk_bonus）
                    if (global.hex_state.first_col_atk > 0 && self.grid_col == 0)
                        self.atk *= (1 + global.hex_state.first_col_atk);

                    // 「稳住锅气」：攻击力不低于基础值的 X%
                    var _fl = hex_card_atk_floor(self.base_atk);
                    if (_fl > 0) self.atk = max(self.atk, _fl);
                }

                if (hex_enabled())
                {
                    // 恒以 base_cycle 为底重算，避免多次刷新之间互相叠乘
                    var _hex_cyc = hex_cycle_mult_for_card(self.plant_id);
                    // 「逆火」：敌人逼近到前方 N 格内时该行卡片加速
                    if (global.hex_state.near_cycle_on
                        && hex_near_cycle_hit(self.grid_col, self.grid_row, global.hex_state.near_cycle_range))
                        _hex_cyc *= (1 + global.hex_state.near_cycle_add);
                    self.cycle = self.base_cycle * clamp(_hex_cyc, 0.05, 4.0);

                    if (!variable_instance_exists(self.id, "base_max_hp")) self.base_max_hp = self.max_hp;

                    // ══ 生命上限：先算「纯上限」（卡面基准 × 生命词条，或被词条固定）══
                    // 这个值必须是「不含取长补短」的干净上限，否则下一次重算会拿被抬高的值当基准，
                    // 按比例把当前血量削掉 —— 就是「莫名掉血」的来源。
                    var _hex_hp   = hex_hp_mult_for_card(self.plant_id);
                    var _hp_fix   = hex_batch2_id_hp_fix(self.plant_id);   // 「熊熊烈火」：火盆类固定 10 点
                    var _eq_on    = hex_batch2_equalize_on();              // 「取长补短」
                    var _pure_max = self.base_max_hp * _hex_hp;
                    // 「山脉龙魂」每秒叠生命上限，公式必须和 hex_batch2 的 tick 段完全一致，
                    // 否则两边各自重设 max_hp 会互相抹掉对方那一截
                    if (variable_instance_exists(self.id, "b2_hp_stack"))
                        _pure_max *= (1 + self.b2_hp_stack);
                    if (_hp_fix > 0) _pure_max = _hp_fix;

                    // 「取长补短」：上限与攻击一起取「纯上限 / 攻击力」中较高者
                    var _new_max = _pure_max;
                    if (_eq_on)
                    {
                        _new_max = max(self.atk, _pure_max);
                        self.atk = _new_max;
                    }

                    // 只有这三类词条会动上限时才重设，别把别的系统临时改过的 max_hp 拉回基准
                    if (_hex_hp != 1.0 || _hp_fix > 0 || _eq_on)
                    {
                        // 一次算到底：从「当帧旧上限」直接换算到「新上限」。
                        // 上限涨多少当前血涨多少、跌多少血跌多少。
                        // 之前「只改上限不改血」会让涨的时候血不动，等增幅消失上限回落时血才跟着掉，一来一回净亏一截。
                        if (abs(_new_max - self.max_hp) > 0.001 && self.max_hp > 0 && self.hp > 0)
                            self.hp = self.hp * (_new_max / self.max_hp);
                        self.max_hp = _new_max;
                        if (self.hp > self.max_hp) self.hp = self.max_hp;
                        if (self.hp > 0 && self.hp < 1) self.hp = 1;   // 别把还活着的卡按比例缩成 0
                    }
                }

                self.buff_applied_id = global.buff_apply_id;
            }
        }
    }
    
    buff_timer = 5;
}

if (record_timer > 0)
{
    record_timer--;
}
else
{
    with (obj_card_parent)
    {
        if (plant_id != "player")
        {
            if (!variable_instance_exists(id, "transform_recorded"))
            {
                mod_on_card_placed(self.plant_id, self.shape);
                self.transform_recorded = true;
            }
        }
    }
    
    record_timer = 5;
}

if (global.debug)
{
    if (keyboard_check_pressed(vk_numpad1))
    {
        var grid_pos = get_grid_position_from_world(mouse_x, mouse_y);
        var inst = instance_create_depth(grid_pos.x, grid_pos.y + 38, 0, obj_infected_frog_prince_mouse);
        inst.grid_row = grid_pos.row;
        inst.grid_col = grid_pos.col;
        inst.frozen_timer = 0;
    }
    
    if (keyboard_check_pressed(vk_numpad2))
    {
        var grid_pos = get_grid_position_from_world(mouse_x, mouse_y);
        var inst = instance_create_depth(grid_pos.x, grid_pos.y + 38, 0, obj_infected_duck_mouse);
        inst.grid_row = grid_pos.row;
        inst.grid_col = grid_pos.col;
        inst.frozen_timer = 0;
    }
    
    if (keyboard_check_pressed(vk_numpad3))
    {
        var grid_pos = get_grid_position_from_world(mouse_x, mouse_y);
        var inst = instance_create_depth(grid_pos.x, grid_pos.y + 38, 0, obj_infected_submarine_mouse);
        inst.grid_row = grid_pos.row;
        inst.grid_col = grid_pos.col;
        inst.frozen_timer = 0;
    }
    
    if (keyboard_check_pressed(vk_numpad4))
    {
        var grid_pos = get_grid_position_from_world(mouse_x, mouse_y);
        var inst = instance_create_depth(grid_pos.x, grid_pos.y + 38, 0, obj_infected_normal_mouse);
        inst.grid_row = grid_pos.row;
        inst.grid_col = grid_pos.col;
        inst.frozen_timer = 0;
    }
    
    if (keyboard_check_pressed(vk_numpad5))
    {
        var grid_pos = get_grid_position_from_world(mouse_x, mouse_y);
        var inst = instance_create_depth(grid_pos.x, grid_pos.y + 38, 0, obj_infected_football_fan_mouse);
        inst.grid_row = grid_pos.row;
        inst.grid_col = grid_pos.col;
        inst.frozen_timer = 0;
    }
    
    if (keyboard_check_pressed(vk_numpad6))
    {
        var grid_pos = get_grid_position_from_world(mouse_x, mouse_y);
        var inst = instance_create_depth(grid_pos.x, grid_pos.y + 38, 0, obj_infected_iron_pan_mouse);
        inst.grid_row = grid_pos.row;
        inst.grid_col = grid_pos.col;
        inst.frozen_timer = 0;
    }
    
    if (keyboard_check_pressed(vk_numpad7))
    {
        var grid_pos = get_grid_position_from_world(mouse_x, mouse_y);
        var inst = instance_create_depth(grid_pos.x, grid_pos.y + 38, 0, obj_infected_mario_mouse);
        inst.grid_row = grid_pos.row;
        inst.grid_col = grid_pos.col;
        inst.frozen_timer = 0;
        obj_battle.boss_count += 1;
    }
}

if (global.level_id == "ancient_castle_1" && !event_created)
{
    var obstacle_pos_list = [[0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0]];
    
    for (var i = 0; i < array_length(obstacle_pos_list); i++)
    {
        for (var j = 0; j < array_length(obstacle_pos_list[i]); j++)
        {
            if (obstacle_pos_list[i][j] == 1)
            {
                var obs_pos = get_world_position_from_grid(j, i);
                var inst = instance_create_depth(obs_pos.x, obs_pos.y - 35, -1200, obj_obstacle);
                inst.row = i;
            }
        }
    }
    
    event_created = true;
}

if (global.level_id == "ancient_castle_2" && !event_created)
{
    var obstacle_pos_list = [[0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0]];
    
    for (var i = 0; i < array_length(obstacle_pos_list); i++)
    {
        for (var j = 0; j < array_length(obstacle_pos_list[i]); j++)
        {
            if (obstacle_pos_list[i][j] == 1)
            {
                var obs_pos = get_world_position_from_grid(j, i);
                var inst = instance_create_depth(obs_pos.x, obs_pos.y - 35, -1200, obj_obstacle);
                inst.row = i;
            }
        }
    }
    
    event_created = true;
}

if (global.level_id == "ancient_castle_3" && !event_created)
{
    var obstacle_pos_list = [[0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0]];
    
    for (var i = 0; i < array_length(obstacle_pos_list); i++)
    {
        for (var j = 0; j < array_length(obstacle_pos_list[i]); j++)
        {
            if (obstacle_pos_list[i][j] == 1)
            {
                var obs_pos = get_world_position_from_grid(j, i);
                var inst = instance_create_depth(obs_pos.x, obs_pos.y - 35, -1200, obj_obstacle);
                inst.row = i;
            }
        }
    }
    
    event_created = true;
}

if (global.level_id == "ancient_castle_4" && !event_created)
{
    var obstacle_pos_list = [[0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0]];
    
    for (var i = 0; i < array_length(obstacle_pos_list); i++)
    {
        for (var j = 0; j < array_length(obstacle_pos_list[i]); j++)
        {
            if (obstacle_pos_list[i][j] == 1)
            {
                var obs_pos = get_world_position_from_grid(j, i);
                var inst = instance_create_depth(obs_pos.x, obs_pos.y - 35, -1200, obj_obstacle);
                inst.row = i;
            }
        }
    }
    
    event_created = true;
}

if (global.level_id == "ancient_castle_5" && !event_created)
{
    var obstacle_pos_list = [[0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0]];
    
    for (var i = 0; i < array_length(obstacle_pos_list); i++)
    {
        for (var j = 0; j < array_length(obstacle_pos_list[i]); j++)
        {
            if (obstacle_pos_list[i][j] == 1)
            {
                var obs_pos = get_world_position_from_grid(j, i);
                var inst = instance_create_depth(obs_pos.x, obs_pos.y - 35, -1200, obj_obstacle);
                inst.row = i;
            }
        }
    }
    
    event_created = true;
}

if (global.level_id == "ancient_castle_6" && !event_created)
{
    var obstacle_pos_list = [[0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0]];
    
    for (var i = 0; i < array_length(obstacle_pos_list); i++)
    {
        for (var j = 0; j < array_length(obstacle_pos_list[i]); j++)
        {
            if (obstacle_pos_list[i][j] == 1)
            {
                var obs_pos = get_world_position_from_grid(j, i);
                var inst = instance_create_depth(obs_pos.x, obs_pos.y - 35, -1200, obj_obstacle);
                inst.row = i;
            }
        }
    }
    
    event_created = true;
}

if (global.level_id == "ancient_castle_7" && !event_created)
{
    var obstacle_pos_list = [[1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 0, 0, 0, 0, 0, 0, 0, 0]];
    
    for (var i = 0; i < array_length(obstacle_pos_list); i++)
    {
        for (var j = 0; j < array_length(obstacle_pos_list[i]); j++)
        {
            if (obstacle_pos_list[i][j] == 1)
            {
                var obs_pos = get_world_position_from_grid(j, i);
                var inst = instance_create_depth(obs_pos.x, obs_pos.y - 35, -1200, obj_obstacle);
                inst.row = i;
            }
        }
    }
    
    event_created = true;
}
