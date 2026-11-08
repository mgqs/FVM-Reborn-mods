// obj_fashishe（法师蛇 / 幽冥法师蛇 / 奥术法师蛇）Create 事件
// 直射类·过火穿透类（2026-11-07 新卡，2026-11-08 按 米苏.jpg 校正能力）
//   0 转：每轮 2 发蛇形魔法弹，轨迹固定 1 整行，全程穿透（同一只只吃一次）。
//   1 转：**子弹 +1（每轮 3 发）**，毒雾从「行末 1 格」扩到「行末 3 格」（原来写的「伤害提高」作废）。
//   2 转：范围扩到前方 3 行（每行 3 发），毒雾仍行末 3 格。
//   出弹口径照 bbq / 后羿：子弹**不跟卡片位置走**，统一从地图最左沿出生、沿本行往右飞。
//   一轮多发**一发一发出膛**（后面的晚 fashishe_shot_delay 帧，同 bbq），不是同帧一起冒。
//   毒雾按「发」计数，**每 3 发**那一发负责铺（同 bbq 的「每 4 发一颗烤串」）：
//     0 转一拍 2 发 → 第 1 轮不出，第 2 轮第 1 发（= 第 3 发）出，第 3 轮第 2 发（= 第 6 发）出 …
//     1 转一拍 3 发 → 正好每轮第 3 发出。
event_inherited();

plant_id = "fashishe";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_fashishe;
else if (shape == 1) sprite_index = spr_fashishe_1;
else                 sprite_index = spr_fashishe_2;

plant_type   = "normal";
feature_type = "normal";
target_type  = "normal";
is_slowdown  = false;
image_speed  = 0;      // 🔴 必须 0：帧由父对象 timer 推（image_speed = 1 会每步再推一帧，动画翻倍）
flash_speed  = 5;      // 待机段每帧停留几 tick（越大越慢）

attack_timer = 0;
state = CARD_STATE.IDLE;

idle_anim   = 11;   // 待机 1~12
attack_anim = 16;   // 攻击 13~28
fire_frame  = 24;   // 攻击段播到第 25 帧才出弹（改这里就换出弹时机）
anim_t      = 0;
fashishe_fired = false;

// ── 可调参数（要微调只改这几行）──
fashishe_per_row      = (shape >= 1) ? 3 : 2;   // 每轮子弹数：0 转 2 发 / 1·2 转 3 发
fashishe_shot_delay   = 14;                     // 一轮内后几发比上一发晚几帧出膛（同 bbq）
fashishe_poison_every = 3;                      // 每几「发」铺一次毒雾（3 = 第 3/6/9… 发）
fashishe_art_up       = 36;                     // 贴图格线比逻辑网格高 36px（同 bbq_art_up），正 = 往上抬
fashishe_poison_cells = (shape >= 1) ? 3 : 1;   // 毒雾覆盖行末几格：0 转 1 格 / 1·2 转 3 格
fashishe_end_cells    = 1;                      // 飞出地图右沿几格开始消散（原来 2 格太远，特效看不见）
fashishe_poison_extra_col = 1;                  // 毒雾能烧到场外几格（1 = 第 10 格 / BOSS 出生位，同 bbq；特效不跟着外扩）
fashishe_shot_count   = 0;                      // 跨轮累加的「发」序号
fashishe_burst_rows   = [grid_row];             // 本轮要出的行（二转 = 3 行）
fashishe_burst_left   = 0;                      // 本轮还剩几发没出膛
fashishe_burst_timer  = 0;                      // 距下一发还有几帧

// 铺毒雾：本行最右 fashishe_poison_cells 格（同 bbq 的火格，出弹当帧就铺）
fashishe_poison_at = function(_row)
{
    var _c0 = global.grid_cols - 1;
    for (var _i = 0; _i < fashishe_poison_cells; _i++)
    {
        var _c = _c0 - _i;
        if (_c < 0) continue;
        var _cell = get_world_position_from_grid(_c, _row);

        // 贴图 88×91 的画布里只有中间一块是雾：按实心内容框放大到整格
        var _fw = 69, _fh = 58, _fcx = 44.5, _fcy = 53;
        var _sx = global.grid_cell_size_x / _fw;
        var _sy = global.grid_cell_size_y / _fh;
        var _bx = _cell.x - (_fcx - sprite_get_xoffset(spr_fashishe_burn_ground)) * _sx;
        var _by = (_cell.y - fashishe_art_up) - (_fcy - sprite_get_yoffset(spr_fashishe_burn_ground)) * _sy;

        // 毒雾格用**法师蛇自己的对象** obj_fashishe_poison_cell（2026-11-08 从 obj_burn_cell 拆出来）：
        //   数值 / 鼠身紫雾外观都写在那个对象里，调 bbq 的火格不会牵到这里，反之亦然。
        var _p = instance_create_depth(_bx, _by, -10 - _row * 45, obj_fashishe_poison_cell);
        _p.sprite_index = spr_fashishe_burn_ground;
        _p.frame_start  = 0;
        _p.frame_end    = sprite_get_number(spr_fashishe_burn_ground) - 1;
        _p.anim_loop_frames = 30;
        _p.damage        = poison_damage;
        _p.damage_type   = "normal";
        _p.life          = poison_frames;
        _p.tick_interval = poison_interval;
        _p.lock_grid     = true;
        _p.grid_col      = _c;
        _p.grid_row      = _row;
        _p.hittable_types = get_hittable_enemy_types("all");
        // 只有最右一格放宽到「场外 1 格」（第 10 格 / BOSS 出生位）；
        //   中间几格放宽的话会互相覆盖，同一条老鼠会被相邻格重复烧。
        _p.extra_col_right = (_i == 0) ? fashishe_poison_extra_col : 0;
        _p.image_xscale = _sx;
        _p.image_yscale = _sy;
    }
};

// 出一发（本轮每行各一颗，同一帧一起出；带毒的那一发当帧就把毒雾铺上）
fashishe_fire_one = function()
{
    fashishe_shot_count++;
    var _poison = (fashishe_shot_count mod fashishe_poison_every == 0);
    var _end_x  = global.grid_offset_x + (global.grid_cols + fashishe_end_cells) * global.grid_cell_size_x;

    for (var _r = 0; _r < array_length(fashishe_burst_rows); _r++)
    {
        var _row    = fashishe_burst_rows[_r];
        var _lane_y = global.grid_offset_y + _row * global.grid_cell_size_y
                    + global.grid_cell_size_y * 0.5 - fashishe_art_up;

        var _b = instance_create_depth(global.grid_offset_x, _lane_y, depth - 500, obj_fashishe_bullet);
        _b.row            = _row;
        _b.base_y         = _lane_y;
        _b.phase          = 0;
        _b.damage         = atk;
        _b.end_x          = _end_x;
        _b.damage_type    = "normal";
        _b.target_type    = "normal";
        _b.hittable_types = get_hittable_enemy_types("normal");

        // 毒雾跟子弹同一帧铺（同 bbq 的烤串 + 火格）
        if (_poison) fashishe_poison_at(_row);

        if (shape == 1)      _b.sprite_index = spr_fashishe_bullet_1;
        else if (shape == 2) _b.sprite_index = spr_fashishe_bullet_2;
    }
    audio_play_sound(snd_shot, 0, 0);
};

// ── 毒雾数值：全部走注册表 custom ──
//   情报岛里的 {毒雾持续} / {毒雾伤害} / {毒雾次数} 读的就是这三个 key，改表即生效。
//   持续时间（秒）× 60 = 总帧数；总帧数 ÷ 跳数 = 每跳间隔（1s / 5 跳 → 12 帧 = 0.2s 一跳）。
var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("fashishe", shape, clamp(current_level, 0, 16), _sk);

poison_damage = 400;    // 每跳伤害（伤害类型 = 平射）
poison_time   = 1;      // 持续秒数（custom["毒雾持续"]）
poison_ticks  = 5;      // 跳数 / 次数（custom["毒雾次数"]）
if (_info != undefined && ds_map_exists(_info, "毒雾伤害")) poison_damage = _info[? "毒雾伤害"];
if (_info != undefined && ds_map_exists(_info, "毒雾持续")) poison_time   = _info[? "毒雾持续"];
if (_info != undefined && ds_map_exists(_info, "毒雾次数")) poison_ticks  = _info[? "毒雾次数"];

poison_frames   = max(1, round(poison_time * 60));
poison_interval = max(1, round(poison_frames / max(1, poison_ticks)));
