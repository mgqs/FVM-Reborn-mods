if (!instance_exists(obj_battle))
{
    instance_destroy();
    exit;
}

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

                // 增幅：该卡所有可吃通道取最大（目标表见 scripts/buff_target）
                var buff_multiplier = buff_channels_multiplier(self.plant_id, self.grid_col, self.grid_row);

                // 海洋女神与榨汁机、魔杖蛇的喷壶增幅不叠加，取较高倍率。
                var ocean_mult = 1;
                if (variable_instance_exists(self.id, "ocean_buff_multiplier"))
                    ocean_mult = self.ocean_buff_multiplier;

                var zhanqima_mult = get_zhanqima_buff_multiplier(self.id);

                // 喷壶三档（旋喷 / 咖啡 / 附加）任意一档 → 与海洋女神取高不叠乘
                var has_sprayer_buff = buff_channels_has_any(self.plant_id,
                    ["sprayer", "sprayer_coffee", "sprayer_attach"]);
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

                // 星轨神·阿斯特：同为「固定轨迹增幅」，与音盒马 / 浮生茶并列为同一乘区，取最高、不叠乘。
                //   四转起的「每多 1 张 +0.7」与终转全屏判定都在 obj_xinggui_god/Other_10 里算完再交上来。
                global.xinggui_mult = 1;
                global.xinggui_query_card = self.id;
                with (obj_xinggui_god) event_user(0);
                var xinggui_mult = global.xinggui_mult;

                var track_buff_mult = max(zodiac_mult, max(fushengcha_mult, xinggui_mult));
                self.atk = self.base_atk * combined_buff_multiplier * zhanqima_mult * _shield_gem_mult * track_buff_mult;

                // ══ 海克斯：乘在全部既有乘区之后（增幅/星级/地形/技能都不改） ══
                // hex_* 系列在非海克斯模式恒返回 1.0，所以这里不需要 if 包住 atk
                self.atk *= hex_atk_mult_for_card(self.plant_id);

                if (hex_enabled())
                {
                    // 「双灶并行」：每行最左侧卡片额外攻击（需要坐标，不能放进 hex_dyn_atk_bonus）
                    if (global.hex_state.first_col_atk > 0 && self.grid_col == 0)
                        self.atk *= (1 + global.hex_state.first_col_atk);

                    // 二期：需要实例上下文的攻击倍率（知识收集蓄力 / 小指相邻 / 婚介所点名 /
                    // 站在熔岩上 / 中指的义理叠层 / 海洋婚礼双倍）
                    self.atk *= hex_b3_inst_atk(self);

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
                    // 二期：全属性 / 岩浆 / 海洋婚礼 等实例侧攻速
                    _hex_cyc *= hex_b3_inst_cycle(self);
                    // 减速（冰冻/泥浆）：间隔翻倍。放在这里算，避免 obj_card_parent 的
                    // Step 每帧硬写 cycle 把词条结果冲掉
                    if (variable_instance_exists(self.id, "is_slowdown") && self.is_slowdown) _hex_cyc *= 2.0;
                    // 攻击间隔必须是整数帧：披萨炉 / 红柳烤串机这一类卡片靠
                    // `attack_timer == cycle - N*frame` 的**精确等号**触发出弹，
                    // 词条乘出来的 224.4 这种小数会让等号永远不成立 ——
                    // 表现就是「攻击间隔一高就完全不攻击」，一滴伤害都打不出来
                    // 攻速上限（= 攻击间隔下限）：大量卡片用「attack_timer == cycle - N*flash_speed」
                    // 或 `attack_timer <= cycle - attack_anim*flash_speed` 的分段判定来触发出弹。
                    // cycle 被词条压到比攻击动画还短时，这些判定右侧变成 0 / 负数、永远不成立 ——
                    // 大炮、巨神这类就只剩抬手动作、一发子弹都出不来。
                    // 下限取「这套攻击动画放完所需的帧数」，等于给攻速立了个上限。
                    var _fs = 1;
                    if (variable_instance_exists(self.id, "flash_speed") && self.flash_speed > 0) {
                        _fs = self.flash_speed;
                    }
                    var _anim = 0;
                    if (variable_instance_exists(self.id, "attack_anim")) _anim = max(0, self.attack_anim);
                    var _min_cycle = max(8, ceil((_anim + 2) * _fs));
                    self.cycle = clamp(round(self.base_cycle * clamp(_hex_cyc, 0.05, 4.0)),
                                       _min_cycle, 999999);

                    if (!variable_instance_exists(self.id, "base_max_hp")) self.base_max_hp = self.max_hp;

                    // ══ 生命上限：先算「纯上限」（卡面基准 × 生命词条，或被词条固定）══
                    // 这个值必须是「不含取长补短」的干净上限，否则下一次重算会拿被抬高的值当基准，
                    // 按比例把当前血量削掉 —— 就是「莫名掉血」的来源。
                    var _hex_hp   = hex_hp_mult_for_card(self.plant_id);
                    var _hp_fix   = hex_batch2_id_hp_fix(self.plant_id);   // 「熊熊烈火」：火盆类固定 10 点
                    var _eq_on    = hex_batch2_equalize_on();              // 「取长补短」
                    // 增幅类卡不参与取长补短：它们的攻击/生命本身就是被增幅拉高的，
                    // 取大值会把另一项一起顶到同一个离谱数字，倍率直接失控
                    if (_eq_on && card_get_major(self.plant_id) == "增幅类") _eq_on = false;
                    var _pure_max = self.base_max_hp * _hex_hp;
                    // 「山脉龙魂」每秒叠生命上限，公式必须和 hex_batch2 的 tick 段完全一致，
                    // 否则两边各自重设 max_hp 会互相抹掉对方那一截
                    if (variable_instance_exists(self.id, "b2_hp_stack"))
                        _pure_max *= (1 + self.b2_hp_stack);
                    if (_hp_fix > 0) _pure_max = _hp_fix;
                    // 二期：全属性 / 血魔的渴血上限 / 海洋婚礼双倍
                    _pure_max *= hex_b3_inst_hp(self);
                    // 生存下去的勇气：受伤流失掉的生命上限（绝对值，最少保留 10%）
                    var _b3_loss = hex_b3_hp_loss(self);
                    if (_b3_loss > 0) _pure_max = max(_pure_max * 0.1, _pure_max - _b3_loss);

                    // 「取长补短」：上限与攻击一起取「纯上限 / 攻击力」中较高者
                    var _new_max = _pure_max;
                    if (_eq_on)
                    {
                        _new_max = max(self.atk, _pure_max);
                        self.atk = _new_max;
                    }

                    // 只有这三类词条会动上限时才重设，别把别的系统临时改过的 max_hp 拉回基准
                    // 「山脉龙魂」必须算进这个条件：它每秒只加层数、不复算 max_hp，
                    // 不带上它的话层数涨了血条却一直不动
                    var _b2_stack_on = (variable_instance_exists(self.id, "b2_hp_stack") && self.b2_hp_stack > 0);
                    if (_hex_hp != 1.0 || _hp_fix > 0 || _eq_on || _b2_stack_on || hex_b3_hp_active(self))
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
