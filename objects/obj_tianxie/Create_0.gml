// obj_tianxie（天蝎座精灵 / 天蝎座战将 / 天蝎座主宰）Create 事件
// 直射类·直线穿透类（2026-11-08 新卡，素材 = 美食大战老鼠资源\spr-tianxie）
//   官方口径（米苏.jpg + 数据信息.xlsx）：猩红毒针 —— 对一行连续 4 格造成 100% 伤害，无视障碍。
//   耗能 200 / 范围 1 行 / 全天。
//
// ── 2026-11-09 修补（用户定稿，交接 §5.53 C / 待办 #42）────────────────
//   ① 帧段：待机 1~13（idx 0~12）/ 攻击 14~23（idx 13~22），**第 20 帧（idx 19）出弹**
//   ② 取消盲区：不再「自身格 + 前方 1 格打不到」，索敌等于 bbq 的**整行**（含身后 / 场外）
//   ③ 不再是「到点即结算」：出弹后由演出对象 obj_tianxie_needle 从出弹口飞到目标格，
//      再按「四根针依次落下」的帧序**逐格结算**（atk，平射）—— 见那个对象的注释
//   ④ 4 格口径（用户 2026-11-09 情报岛文案定的）：**最左老鼠所在格起连续 4 格**，
//      空格也算一格（伤害只看格里有谁，没鼠的格自然不掉血）
//
// ── 数值 / 售卖口径（注册文件里不写注释，全记在这里）──────────────────
//   攻击力：xlsx 第 51~58 行 17 档直接抄表 40/50/…/340
//   攻击间隔：注册表 cycle = array_create(17, 90)（1.5s，**17 档同一个值**，不按星级递减）
//     —— 官方「星级影响[攻击力]，技能影响[攻击间隔]」，递减只在 mod_skill_init 的 9 档技能表
//        [90,87,84,81,78,75,72,66,60]（技能 0~8 级：1.5s → 1.0s）
//   耗能 200 / hp 50 / 范围 1 行 / cooldown 420（重放 7s）
//   商店：本体 100000 金币（普通商店，不进跨服）
//   凭证：**照焦油喷壶** —— 一转 3400 威望 / 塔 6-1（已上架）；
//         二转 16800 威望 / 塔 20-2 **代码写好但整段注释掉，暂不售卖**（要开卖去掉 credit_shop_init 末尾那段注释）
//   分类：直射类·直线穿透类（card_buff_category 末尾一条）
event_inherited();

plant_id = "tianxie";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_tianxie;
else if (shape == 1) sprite_index = spr_tianxie_1;
else                 sprite_index = spr_tianxie_2;

plant_type   = "normal";
feature_type = "normal";
// 攻击类型 = 穿透（`pierce`，2026-11-09 用户口径：分类是「直射类·直线穿透类」，
//   与双刃蛇同口径 —— 它的 target_type / damage_type 两个都是 pierce）。
//   能打 普通 + 非主流(舞步) + 障碍 + 未显形幽灵；不打空军 / 潜水 / 钻地。
//   🔴 三个字段别混：`target_type` 决定「能打谁」，`damage_type` 决定「怎么扣血」，
//      「子弹打穿一排」是子弹 Step 里的循环，跟这两个字段都无关。
target_type  = "pierce";
is_slowdown  = false;
image_speed  = 0;            // 🔴 必须 0：帧由父对象 timer 推（同法师蛇）
flash_speed  = 5;

// 素材 23 帧 = 待机 1~13 + 攻击 14~23（第 20 帧刺出最远，在这帧出弹）
idle_anim     = 12;          // 待机 0~12（帧 1~13）
attack_anim   = 10;          // 攻击 13~22（帧 14~23）
state         = CARD_STATE.IDLE;
attack_timer  = 0;
tianxie_fired = false;       // 本轮是否已经出过弹（Step 按 image_index 判，一轮只发一次）

// ── 可调参数（要改能力只动这几行）────────────────────────────────
//   改完在情报岛文案里对照着说，别再另开一套 custom 数值
tianxie_needle_cells = 4;     // 一击覆盖几格（官方：连续 4 格，空格也算一格）
tianxie_needle_scale = 1.685; // 演出缩放：把素材里「针距 ~63.5px」拉到一格宽 107px
                              //   （2026-11-09 量：四针中心 x=105.5/171/231.5/296，均值间隔 63.5）
tianxie_art_up       = 0;     // 演出纵向微调（正 = 往上抬）；基础对齐由演出对象按素材自己算
tianxie_muzzle_up    = 92;    // **出弹口抬高**：针从卡片顶部那根红刺的高度出来，飞行段再轻微下压到落点
                              //   2026-11-09 用户二次反馈「还是低了，至少和尖刺平行」→ 按尖刺量：
                              //     尖刺 sprite y≈37（sprite 高 85、原点在底边）→ 距卡底 (85-37)×**1.8 卡片缩放** ≈ 86px
                              //     飞针可见中心比实例原点低 (66.3-62)×1.685 ≈ 7px → 实例 y 取 92 才让针心落在 86
                              //   🔴 卡片是 1.8 倍画的（obj_card_parent/Draw_0），算高度必须乘 1.8，别直接拿 sprite 像素
tianxie_damage_type  = "pierce"; // 伤害类型 = 穿透（护罩本体一起扣，与双刃蛇同分类同口径）
tx_min_col           = -1;    // tianxie_left_enemy() 的扫描结果（实例变量，勿删）

/// 本行**整行**最靠左的可打敌人列（含自身格 / 场外 1 格，2026-11-09 取消盲区）；没有返回 -1
///   🔴 扫描结果存**实例变量** tx_min_col，不用 var：with 里改 var 在 GM 里虽能跑，
///      但同工程一贯口径是「跨 with 的结果走实例变量」（见旋转喷壶 damage_value）
tianxie_left_enemy = function()
{
    tx_min_col = -1;
    with (obj_enemy_parent)
    {
        if (hp > 0
            && grid_row == other.grid_row
            && grid_col >= other.grid_col
            && grid_col <= global.grid_cols + 1
            && can_target_on(other.target_type, target_type))
        {
            if (other.tx_min_col < 0 || grid_col < other.tx_min_col) other.tx_min_col = grid_col;
        }
    }
    return tx_min_col;
};

/// 出弹：_col0 = 最左敌人所在列（覆盖 _col0 ~ _col0 + cells - 1，空格也算一格）
///   伤害**不在这里结算**：演出对象飞到目标格后按「四根针落下」逐格打 atk（见 obj_tianxie_needle）
///   无视障碍：本函数不查任何屏障
tianxie_fire = function(_col0)
{
    var _row   = grid_row;
    var _cell0 = get_world_position_from_grid(_col0, _row);

    // 演出对象自己按素材算落点（针 1 中心对齐 _cell0 中心），这里只给「从哪一格开始打」
    var _fx = instance_create_depth(x + 50, y - tianxie_art_up, depth - 500, obj_tianxie_needle);
    _fx.image_xscale  = tianxie_needle_scale;
    _fx.image_yscale  = tianxie_needle_scale;
    _fx.fx_row        = _row;
    _fx.fx_col0       = _col0;
    _fx.fx_cells      = tianxie_needle_cells;
    _fx.fx_dmg        = atk;
    _fx.fx_dmg_type   = tianxie_damage_type;
    // 出弹口 = 卡右侧 x+50。素材第 1 帧的针中心在原点右侧约 37.5px（×缩放），
    //   所以实例起点要往回退这么多，画面上的针才正好从卡口扎出来
    _fx.fx_from_x     = x + 50 - 37.5 * tianxie_needle_scale;
    _fx.fx_land_x     = _cell0.x - 85.5 * tianxie_needle_scale;    // 针 1 中心 = 目标格中心
    // 出弹口高度 = 卡片顶部尖刺的高度（底边往上 tianxie_muzzle_up，卡片按 1.8 倍画）
    _fx.fx_from_y     = y - tianxie_muzzle_up;
    // 🔴 落点高度 = 出弹口高度 → **全程一条水平线飞**（2026-11-09 用户：到老鼠脸前突然往下沉不行）
    //   贴图里「立住的针」比「飞行的针」低约 17px，所以针落地时会略高于老鼠脚底；
    //   真要压到地面，把下面这行换回  _cell0.y + 40 - 34 * tianxie_needle_scale - tianxie_art_up
    //   但那样飞行段就必须做纵向插值（又会下沉），两件事只能选一个。
    _fx.fx_ground_y   = _fx.fx_from_y;

    audio_play_sound(snd_shot, 0, 0);
};

// ══════════════════════════════════════════════════════════════════════════
// 二转（shape >= 2）：每轮打 **1 次随机抽取**
//   每次 = 10% 特殊池 / 90% 普通池，池内按权重抽；打那一张卡的**一轮攻击**
//   数据表：scripts/mod_tianxie_pool（特殊池 / 普通池两份拍平列表）
//   伤害一律 = 天蝎座 atk；对空 / 对地 / 附加效果都跟那颗子弹原样走
// ══════════════════════════════════════════════════════════════════════════
/// 二转随机：**先掷特殊/普通 → 池内等概率抽卡 → 打这张卡最高形态的子弹**
///   数据全部在 scripts/mod_tianxie_pool（每张卡一行），这里只有选取和发射
///   加卡 / 换子弹 / 调特殊池比例都只改那个数据文件或 tx_special_rate，不用动本文件
/// ══════════════════════════════════════════════════════════════════════════
tx_pool     = tx_pool_data();
tx_shot_col = -1;        // 这一轮的目标列（投掷 / 追踪弹落点用）
tx_pending  = [];        // 延迟出膛队列（tx_spawn 内部「逐发延迟」用）
tx_tick     = function() { };

/// 特殊池比例（2026-11-11 用户定稿：每次抽取 10% 进特殊池）
tx_special_rate = 10;

/// 街头烤肉大师的「第几发」计数器（原卡 bbq_shot_count 的移植）
///   原卡跨轮累加、每第 4 发爆辣 + 铺火格；这里同样跨轮累计，不随每轮清零
tx_bbq_no = 0;

/// 全屏最靠左的可打敌人（追踪 / 防空弹锁敌用）—— 实现在 mod_tianxie_pool
tx_pick_any = function(_type) { return tx_enemy_leftmost(_type); };

/// 抽一张卡（2026-11-11 第二轮）：先掷 10% 判特殊池 / 普通池，再**池内抽**
///   · 特殊池 9 张：大炮 / 盖亚 / 护法 / 逆转牛 / 桂花酒 / 宙斯（走原卡 mode 口径）
///   · 普通池 68 条：平射 / 投手 / 追踪 / 纯防空 / 金卡 / 法师蛇 / bbq，一律等权（金卡不另降权）
///     普通池带同长权重表 nw：没写 wt 的一律 10，八周年拆出来的 3 条 6/3/1（合起来 = 一张卡）
///   档位 w 与类别已取消，只作分组标签
tx_roll = function()
{
    if (irandom(99) < tx_special_rate) return tx_pool.special[irandom(array_length(tx_pool.special) - 1)];

    // 普通池：按 nw 加权抽（累加总权重 → 掷一个数 → 逐个减）
    var _fw = tx_pool.nw;
    var _tot = 0;
    for (var _i = 0; _i < array_length(_fw); _i++) _tot += _fw[_i];
    var _pick = irandom(max(0, _tot - 1));
    for (var _j = 0; _j < array_length(_fw); _j++)
    {
        _pick -= _fw[_j];
        if (_pick < 0) return tx_pool.normal[_j];
    }
    return tx_pool.normal[array_length(tx_pool.normal) - 1];
};

/// 复刻「街头烤肉」的灼烧火格（原卡 bbq_spawn_burn_cell 的移植）
///   · 固定铺在**行末格**（第 9 列），能烧到场外 1 格（第 10 列 / BOSS 出生位）
///   · 每跳伤害 = 天蝎座 atk；持续 / 跳数读 bbq 注册表的 custom
tx_burn_cell = function(_row)
{
    var _dur = 2, _ticks = 4;
    var _bi = get_plant_data_with_skill("bbq", 2, 16, 0);
    if (_bi != undefined && ds_map_exists(_bi, "灼烧持续")) _dur   = _bi[? "灼烧持续"];
    if (_bi != undefined && ds_map_exists(_bi, "灼烧跳数")) _ticks = _bi[? "灼烧跳数"];

    var _bc   = global.grid_cols - 1;
    var _cell = get_world_position_from_grid(_bc, _row);
    var _fw = 56, _fh = 66, _fcx = 56, _fcy = 81;     // 实心火的内容框（同 bbq）
    var _fire_dx = 9, _fire_dy = -10;
    var _sx = global.grid_cell_size_x / _fw;
    var _sy = global.grid_cell_size_y / _fh;
    var _bx = (_cell.x + _fire_dx) - (_fcx - sprite_get_xoffset(spr_bbq_burn_ground)) * _sx;
    var _by = (_cell.y - 36 + _fire_dy) - (_fcy - sprite_get_yoffset(spr_bbq_burn_ground)) * _sy;

    var _b = instance_create_depth(_bx, _by, -10 - _row * 45, obj_burn_cell);
    _b.sprite_index = spr_bbq_burn_ground;
    _b.frame_start = 3;
    _b.frame_end = 16;
    _b.anim_loop_frames = 42;
    _b.damage = atk;
    _b.life = max(1, round(_dur * 60));
    _b.tick_interval = max(1, round(_b.life / max(1, _ticks)));
    _b.extra_col_right = 1;
    _b.lock_grid = true;
    _b.grid_col = _bc;
    _b.grid_row = _row;
    _b.hittable_types = ["normal", "dance", "invisible", "diver", "obstacle", "underground"];
    _b.mouse_fx_spr = spr_bbq_burn_mouse;
    _b.image_xscale = _sx;
    _b.image_yscale = _sy;
};

/// 复刻「法师蛇」的毒雾（原卡 fashishe_poison_at 的移植）
///   · 行末 3 格（第 7~9 列），最右一格能烧到场外 1 格
///   · 每跳伤害 = 天蝎座 atk；持续 / 跳数读 fashishe 注册表的 custom
tx_poison_cells = function(_row)
{
    tx_poison_at(id, _row);      // 实现在 scripts/mod_tianxie_pool（tx_special_shot 也要用，见法师蛇那条）
};

/// 抛物线投掷（八周年可乐炸弹这类自己 lerp 飞行的弹体）：补起点 / 落点 / 飞行帧 / 拱高
tx_arc_init = function(_b, _col)
{
    var _cell = get_world_position_from_grid(_col, grid_row);
    var _tx = _cell.x;
    var _ty = _cell.y - 36;                       // 贴图格线比逻辑网格高 36px（同原卡）
    var _d  = point_distance(_b.x, _b.y, _tx, _ty);

    _b.sx = _b.x;  _b.sy = _b.y;
    _b.tx = _tx;   _b.ty = _ty;
    _b.T   = clamp(round(_d / 20), 20, 46);
    _b.arc = clamp(_d * 0.42, 80, 300);
    _b.col = _col;
};

/// 打出一张卡的**一轮攻击**：n = 这一轮几发，sp = 怎么铺开
///   "rows" 多行（三线 / 投手 / 陆空）· "ang" 扇面角度（海星类）· "fan" 同排小偏移
///   "pair" 左右各一发 · "rows2" 3 行×每行 2 枚
///   可选字段：dmg 固定伤害 · arc 抛物线 · burn 末发爆辣+火格 · poison 末发毒雾 · alt 卡面飞行物
///             ang 角度表（按发序取）· mix 多弹体表（哈迪斯 / 里格）· k 星弹 kind
///             o2 + dy2 第二种弹体（双菇类一次打地面弹 + 空中弹）
///   伤害一律 = 天蝎座 atk，行 = 天蝎座所在行
tx_spawn_at = function(_card, _si)
{
    // ── 特殊子弹（宙斯 / 盖亚 / 大炮 / 火箭猪）：按**原卡口径**另走一套 ──
    //   出生点 / 索敌 / 落点 / 形态参数都是原卡自己算的，通用逻辑猜不准，
    //   具体见 scripts/mod_tianxie_pool 末尾的 tx_special_shot
    if (variable_struct_exists(_card, "mode"))
    {
        tx_special_shot(id, _card, _si);
        return;
    }

    var _dx = variable_struct_exists(_card, "dx") ? _card.dx : 40;
    var _dy = variable_struct_exists(_card, "dy") ? _card.dy : -80;
    var _n  = variable_struct_exists(_card, "n") ? _card.n : 1;
    var _sp = variable_struct_exists(_card, "sp") ? _card.sp : "fan";
    var _angs = variable_struct_exists(_card, "ang") ? _card.ang : undefined;
    var _mix  = variable_struct_exists(_card, "mix") ? _card.mix : undefined;

    // ── 按发序换出膛点（机枪咖啡杯 3 个炮口 / 双鱼 2 个口 / 章鱼烧 x 与 x+40 / 左右对射）──
    //   dxs / dys 与发序一一对应，长度不够就回落到统一 dx / dy
    if (variable_struct_exists(_card, "dxs"))
    {
        var _dxs = _card.dxs;
        if (array_length(_dxs) > 0) _dx = _dxs[_si mod array_length(_dxs)];
    }
    if (variable_struct_exists(_card, "dys"))
    {
        var _dys = _card.dys;
        if (array_length(_dys) > 0) _dy = _dys[_si mod array_length(_dys)];
    }

    {
        var _k  = _si - (_n - 1) / 2;                 // -n/2 … +n/2
        var _px = x + _dx;
        var _py = y + _dy;
        var _row_off = 0;                             // 这一发打**第几行**（相对天蝎座所在行）
        if (_sp == "fan")       _py += _k * 24;        // 同排轻微散开
        else if (_sp == "pair") _px += _k * 40;        // 左右各一发（双向水管 / 天秤 / 章鱼烧）
        else if (_sp == "none") { }                    // 原地连发：出膛点全交给 dxs / dys
        else if (_sp == "rows2")
        {
            // 3 行 × 每行 2 枚（融合煮蛋这类：原卡 for 3 行 × for 2 枚）
            _row_off = floor(_si / 2) - 1;
            _px += (_si mod 2) * 20 - 10;
        }
        else if (_sp == "rows3") _row_off = (_si mod 3) - 1;   // 每 3 发一轮：上 / 中 / 下三行
        else if (_sp == "rows")
        {
            // 多行铺开：rows_off 给了就按表取（幻影蛇 5 行 6 发，最后一发补最前路），否则按 k 均分
            if (variable_struct_exists(_card, "rows_off"))
            {
                var _ro = _card.rows_off;
                _row_off = _ro[_si mod array_length(_ro)];
            }
            else _row_off = _k;
        }

        // 多弹体（哈迪斯 ping/zhi/xie、里格 平射/斜射）：按发序轮流取
        var _obj = _card.o;
        if (!is_undefined(_mix)) _obj = _mix[_si mod array_length(_mix)];

        var _b = instance_create_depth(_px, _py, depth - 500, _obj);
        if (!instance_exists(_b)) return;

        // ── 多行铺开（2026-11-11 修）──
        //   靠 target_row 拐行的（三线 / 射手 / 子母三线）：三发都从**同一高度**出发，由子弹自己飞到目标行，
        //     所以只设 target_row + start_y，绝不挪 y；**中间那一发也必须设**（Create 默认 target_row=0，
        //     不设的话中间发飞去第 1 行 → 整组看着歪掉，酒架 / 子母三线 / 射手全中招）
        //   其余多行弹：按格高错开 y，**同时把 row / grid_row 一起改**（只挪 y 不改 row = 画在下一行、判定在本行）
        if (_sp == "rows" || _sp == "rows2" || _sp == "rows3")
        {
            // 行号取整（双鱼那种 n=2 的 rows，k=±0.5：视觉上半行，判定上分别算上/下一行）
            var _trow = clamp(grid_row + round(_row_off), 0, global.grid_rows - 1);
            if (variable_instance_exists(_b, "target_row"))
            {
                _b.target_row = _trow;
                if (variable_instance_exists(_b, "start_y")) _b.start_y = _py;
            }
            else
            {
                if (_row_off != 0)
                {
                    _py += _row_off * global.grid_cell_size_y;
                    _b.y  = _py;
                }
                if (variable_instance_exists(_b, "row"))      _b.row      = _trow;
                if (variable_instance_exists(_b, "grid_row")) _b.grid_row = _trow;
            }
        }

        // 属主引用：有些子弹靠 `owner_card` / `owner_id` 判活（赖皮蛇、灯影花糕），
        //   不设的话它们第一帧就 instance_destroy() → 看起来「放了个空」
        if (variable_instance_exists(_b, "owner_card")) _b.owner_card = id;
        if (variable_instance_exists(_b, "owner_id"))   _b.owner_id   = id;

        // 伤害：默认 = 天蝎座 atk；数据里写了 dmg 就用固定值（如八周年可乐炸弹 = 900）
        var _dmg = variable_struct_exists(_card, "dmg") ? _card.dmg : atk;
        variable_instance_set(_b, "damage", _dmg);
        if (variable_instance_exists(_b, "base_damage")) variable_instance_set(_b, "base_damage", _dmg);
        variable_instance_set(_b, "row", grid_row);
        if (variable_instance_exists(_b, "grid_row")) _b.grid_row = grid_row;
        // 速度：spds 是「按发序的速度表」（哈迪斯那种正负号决定上/下的），spd 是统一速度
        if (variable_instance_exists(_b, "move_speed"))
        {
            if (variable_struct_exists(_card, "spds"))
                _b.move_speed = _card.spds[_si mod array_length(_card.spds)];
            else if (variable_struct_exists(_card, "spd"))
                _b.move_speed = _card.spd;
        }

        // 数据里写死的形态 / 贴图（取最高转职形态用）：只有数据写了才覆盖，没写就按子弹 Create 的
        if (variable_struct_exists(_card, "shape")) variable_instance_set(_b, "shape", _card.shape);
        if (variable_struct_exists(_card, "spr"))   _b.sprite_index = _card.spr;

        // ── fx：效果透传表（2026-11-11 新增）────────────────────────────────
        //   原卡的效果很多是「开火事件写进子弹实例变量」的（减速 / 穿透 / 燃烧伤害 / 三昧真火…），
        //   子弹自己不会按 shape 补；池里写 fx: { 变量名: 值 } 就逐项写进这颗子弹。
        //   只写子弹**本来就有的**变量，避免给别的弹体凭空塞字段。
        if (variable_struct_exists(_card, "fx"))
        {
            var _fxn = variable_struct_get_names(_card.fx);
            for (var _fi2 = 0; _fi2 < array_length(_fxn); _fi2++)
            {
                var _fv = _card.fx[$ _fxn[_fi2]];
                if (variable_instance_exists(_b, _fxn[_fi2])) variable_instance_set(_b, _fxn[_fi2], _fv);
            }
        }

        // ── delays：按发序错帧（海星 11 发 / 鱿鱼 22 发）────────────────────
        //   这两类子弹自己 Step 首行就是 `if (delay > 0) { delay--; visible = false; exit; }`
        if (variable_struct_exists(_card, "delays") && variable_instance_exists(_b, "delay"))
        {
            var _ds = _card.delays;
            _b.delay = _ds[_si mod array_length(_ds)];
        }

        // 「有概率出毒」的投手（臭豆腐 50%）：照原卡掷一次，出毒就换毒弹贴图（2026-11-11 用户提醒）
        if (variable_struct_exists(_card, "poison_chance")
            && variable_struct_exists(_card, "poison_spr")
            && irandom(99) < _card.poison_chance)
        {
            _b.sprite_index = _card.poison_spr;
        }

        // ── 自己 lerp 的投掷（糖炒栗子 / 铛铛虎）：sx·sy → tx·ty + T 帧 + arc 拱高 ──
        //   这两张卡的弹道写在子弹自己的 Step 里（x = lerp(sx, tx, _p)…），数值由**原卡开火事件**给：
        //   栗子 Create 里 sx=sy=tx=ty=自己坐标、铛铛虎 Create 里干脆全是 0
        //   → 不补的话栗子原地落下、铛铛虎直接在屏幕左上角 (0,0) 飞。
        //   口径照原卡：起点 = 出膛口（这里就是生成点）· 落点 = 目标格中心 · 栗子纵向再上抬 36（贴图格线）
        if (variable_instance_exists(_b, "sx") && variable_instance_exists(_b, "tx")
            && !variable_instance_exists(_b, "land_x")                 // land_x 是幻影蛇那套，另有处理
            && !variable_struct_exists(_card, "arc"))                  // 八周年走 tx_arc_init，别在这里抢
        {
            var _lcol  = clamp(tx_shot_col, 0, global.grid_cols);
            var _lcell = get_world_position_from_grid(_lcol, grid_row);
            var _artup = variable_struct_exists(_card, "art_up") ? _card.art_up : 0;

            _b.sx  = _px;
            _b.sy  = _py;
            _b.tx  = _lcell.x;
            _b.ty  = _lcell.y - _artup;
            if (variable_instance_exists(_b, "row")) _b.row = grid_row;
            if (variable_instance_exists(_b, "col")) _b.col = _lcol;
            // 飞行帧数照投手口径（距离越远飞越久），拱高用子弹 Create 里自带的（栗子 100 / 铛铛虎 110）
            _b.T   = clamp(round(30 + ((_lcell.x - _px) / 1000) * 45), 30, 75);
            // 最高形态：栗子 / 铛铛虎的 shape 决定落地是十字还是 3×3 方块
            if (variable_instance_exists(_b, "shape"))         _b.shape = 2;
            if (variable_instance_exists(_b, "damage_corner")) _b.damage_corner = _dmg;
            if (variable_struct_exists(_card, "spr"))          _b.sprite_index = _card.spr;
        }

        // 左右成对（天秤 / 双向水管 / 阿瑞斯）：左发速度取负、贴图翻转，原卡就是这么打的
        //   2026-11-11：这批卡改用 sp:"none" + dxs 表（左右交替），所以判据改成「这一发出膛点在左边」
        if (variable_struct_exists(_card, "mir") && _dx < 0 && variable_instance_exists(_b, "move_speed"))
        {
            _b.move_speed = -abs(_b.move_speed);
            _b.image_angle = 180;
        }

        // 卡面飞行物（逆转牛 / 桂花酒）：走 obj_tianxie_alt 自己的那套
        if (variable_struct_exists(_card, "alt") && variable_instance_exists(_b, "alt_mode"))
        {
            _b.alt_mode = _card.alt;
            _b.alt_row  = grid_row;
            _b.alt_dmg  = atk;
        }

        // 星弹 kind：star（星星兔）/ fire（焚寂马）/ wind（御风马）/ return（归元马）/ phoenix（炎凰马）
        //   不设的话默认 "wave" 会走 Step 的 default 分支，只剩普通穿透伤害
        if (variable_struct_exists(_card, "k") && variable_instance_exists(_b, "kind"))
        {
            _b.kind = _card.k;
            if (variable_instance_exists(_b, "center_row")) _b.center_row = grid_row;
            if (variable_instance_exists(_b, "damage_type") && _card.k == "star") _b.damage_type = "normal";
        }

        // ── 投掷抛物线：双鱼 / 巧克力投手 / 煮蛋器 / 勺勺兔 / 索尔 / 尤弥尔 / 祝融 / 雪芭… ──
        //   这些子弹 Create 里 move_speed / cvspeed / cgravity **全是 0**，弹道必须由卡自己算；
        //   只给 move_speed 的话它们会一直水平飞（y 不动）= 平射。公式照抄投手类原卡。
        if (variable_instance_exists(_b, "cvspeed") && variable_instance_exists(_b, "cgravity"))
        {
            var _btt0 = variable_instance_exists(_b, "target_type") ? _b.target_type : "throw";
            var _tt = tx_pick_any(_btt0);
            if (instance_exists(_tt))
            {
                var _ft   = clamp(30 + ((_tt.x - _b.x) / 1000) * 45, 30, 75);   // 飞行帧数随距离
                var _es   = variable_instance_exists(_tt, "move_speed") ? _tt.move_speed : 0;
                var _pred = _tt.x - _es * _ft - 60;                              // 提前量
                if (_pred < x) _pred = x;
                var _tdy  = 600;                                                 // 固定落差（原卡口径）
                _b.move_speed = (_pred - _b.x) / _ft;
                _b.cgravity   = (2 * _tdy) / (_ft * _ft);
                _b.cvspeed    = _tdy / _ft;
                if (variable_instance_exists(_b, "target_enemy")) _b.target_enemy = _tt;
            }
            else
            {
                _b.move_speed = 8;      // 空放兜底：往前抛一条短弧
                _b.cvspeed    = 6;
                _b.cgravity    = 0.2;
            }
        }

        // 方向速度表：海星类靠 **move_speed / y_move_speed 的正负**决定方向（不是角度）
        //   融合海星 mvs [-8,-8,-8,0,0,0,0,5,5,5,5] / mvys [0,0,0,8,8,-8,-8,-3,-3,3,3]
        if (variable_struct_exists(_card, "mvs"))
            variable_instance_set(_b, "move_speed", _card.mvs[_si mod array_length(_card.mvs)]);
        if (variable_struct_exists(_card, "mvys"))
            variable_instance_set(_b, "y_move_speed", _card.mvys[_si mod array_length(_card.mvys)]);

        // 猪猪料理机：方向走 vx / vy（Step 是 x += vx / y += vy）
        if (variable_struct_exists(_card, "vxs"))
            variable_instance_set(_b, "vx", _card.vxs[_si mod array_length(_card.vxs)]);
        if (variable_struct_exists(_card, "vys"))
            variable_instance_set(_b, "vy", _card.vys[_si mod array_length(_card.vys)]);

        // 牛油果飞镖：方向走 travel_dir（Step 里 lengthdir_x(move_speed, travel_dir)）
        if (variable_struct_exists(_card, "tdirs"))
            variable_instance_set(_b, "travel_dir", _card.tdirs[_si mod array_length(_card.tdirs)]);

        // 扇面：数据里给了 ang 数组就用原卡角度，否则按 ±22.5° 均分（海星类那种多向弹）
        if (_sp == "ang" || !is_undefined(_angs))
        {
            var _ang = is_undefined(_angs) ? _k * 22.5 : _angs[_si mod array_length(_angs)];
            if (variable_instance_exists(_b, "move_x") && variable_instance_exists(_b, "move_y"))
            {
                var _v = variable_instance_exists(_b, "move_speed") ? _b.move_speed : 8;
                _b.move_x = lengthdir_x(_v, _ang);
                _b.move_y = lengthdir_y(_v, _ang);
            }
            _b.image_angle = _ang;
        }

        // 投掷 / 追踪 / 大炮：落点交给弹体自己算
        if (variable_struct_exists(_card, "a"))
        {
            // ① 格子落点（大炮类：巧克力大炮 / 脆心死神大炮 / 咖喱龙虾炮）—— 固定格子，原卡口径
            if (variable_instance_exists(_b, "target_col")) _b.target_col = tx_shot_col;
            if (variable_instance_exists(_b, "target_row")) _b.target_row = grid_row;

            // ② 点位落点（雅典娜 / 盖亚这类「飞到某点再炸」）—— 原卡给的是**敌人身上**（y-50），不是格子中心
            if (variable_instance_exists(_b, "target_x") || variable_instance_exists(_b, "target_y"))
            {
                var _wx, _wy;
                // 投手类（带 has_target 的：酱香锅 / 祝融）原卡落点一律是**格子中心**
                //   （obj_lizi_god / obj_zhurong 的 Other_11 都是 get_world_position_from_grid）
                if (variable_instance_exists(_b, "has_target"))
                {
                    var _pc = get_world_position_from_grid(tx_shot_col, grid_row);
                    _wx = _pc.x;
                    _wy = _pc.y;
                    if (_wx < x + 40) _wx = x + 260;            // 目标在身后：往前放一段，别原地落
                    // 速度按「生成点 → 格子中心」重算，保证最后一帧正好落在 target_x 上：
                    //   祝融那类子弹的落地判定是 `abs(x - target_x) < 5`，步长一大就整帧跨过去 → 永远不落地、飞出场外
                    if (variable_instance_exists(_b, "move_speed") && variable_instance_exists(_b, "cvspeed"))
                    {
                        var _ft2 = clamp(round(30 + ((_wx - _b.x) / 1000) * 45), 30, 75);
                        _b.move_speed = (_wx - _b.x) / _ft2;
                        _b.cvspeed    = 600 / _ft2;                 // 先升后落，同一套拱高口径
                        _b.cgravity   = 1200 / (_ft2 * _ft2);
                    }
                }
                else
                {
                    var _btt2 = variable_instance_exists(_b, "target_type") ? _b.target_type : "normal";
                    var _te2  = tx_pick_any(_btt2);
                    if (instance_exists(_te2))
                    {
                        var _es2 = variable_instance_exists(_te2, "move_speed") ? _te2.move_speed : 0;
                        _wx = _te2.x - _es2 * 30;     // 提前量（雅典娜口径）
                        _wy = _te2.y - 50;            // 打身体中心
                    }
                    else
                    {
                        var _wp = get_world_position_from_grid(tx_shot_col, grid_row);
                        _wx = _wp.x;
                        _wy = _wp.y - 36;
                    }
                }
                // 目标在身后 / 就在脚下时，落点会落在出生点左边 → 落地判定第一帧就成立（栗子「丢原地」）
                if (_wx < x + 40) _wx = x + 260;
                if (variable_instance_exists(_b, "target_x")) _b.target_x = _wx;
                if (variable_instance_exists(_b, "target_y")) _b.target_y = _wy;
            }
        }

        // 追踪 / 防空 / 落点：锁最靠前的敌人
        if (variable_instance_exists(_b, "target_enemy") || variable_instance_exists(_b, "target_id")
            || variable_instance_exists(_b, "target_instance"))
        {
            // 按子弹自己的 target_type 索敌：防空弹（air_only）不能锁地面鼠
            var _btt = variable_instance_exists(_b, "target_type") ? _b.target_type : "normal";
            var _te = tx_pick_any(_btt);
            if (instance_exists(_te))
            {
                if (variable_instance_exists(_b, "target_enemy"))    _b.target_enemy    = _te;
                if (variable_instance_exists(_b, "target_id"))       _b.target_id       = _te.id;
                if (variable_instance_exists(_b, "target_instance")) _b.target_instance = _te;
            }
        }

        // 抛物线投掷（八周年可乐炸弹）：补起点 / 落点 / 飞行帧 / 拱高
        if (variable_struct_exists(_card, "arc") && variable_instance_exists(_b, "sx"))
            tx_arc_init(_b, tx_shot_col);

        // ── 公共兜底：子弹 Step **无条件读**、但 Create 里没默认值的字段 ──
        //   thrower_y（全部投手类）/ atk（雅典娜、宙斯）/ target_y·shape·target_instance（典伊）
        //   少一个就是 not set 崩溃，所以一律用 variable_instance_set 补上
        var _tc = get_world_position_from_grid(tx_shot_col, grid_row);
        if (!variable_instance_exists(_b, "thrower_y"))       variable_instance_set(_b, "thrower_y", y);
        if (!variable_instance_exists(_b, "atk"))             variable_instance_set(_b, "atk", _dmg);
        if (!variable_instance_exists(_b, "target_y"))        variable_instance_set(_b, "target_y", _tc.y);
        if (!variable_instance_exists(_b, "target_instance")) variable_instance_set(_b, "target_instance", noone);
        // 🔴 has_target 是投手类「瞄准就绪、到点就炸」的开关（obj_lizi_god / obj_zhurong 的 Create 默认 false），
        //    只补缺不管已有值的话它们会一路飞出场外自然消失 —— 天蝎座这边永远有落点，一律置 true
        if (variable_instance_exists(_b, "has_target"))       _b.has_target = true;
        else                                                  variable_instance_set(_b, "has_target", true);
        if (!variable_instance_exists(_b, "original_damage")) variable_instance_set(_b, "original_damage", _dmg);
        if (!variable_instance_exists(_b, "shape"))           variable_instance_set(_b, "shape", 2);

        // ── 自己插值的抛物线投掷（幻影蛇）：起点 → 目标格。缺省时 start=land=出生点，会原地落下 ──
        if (variable_instance_exists(_b, "land_x"))
        {
            _b.start_x = _px;
            _b.start_y = _py;
            _b.land_x  = _tc.x;
            _b.land_y  = _tc.y;
            if (variable_instance_exists(_b, "grid_target_col")) _b.grid_target_col = tx_shot_col;
            if (variable_instance_exists(_b, "grid_target_row")) _b.grid_target_row = grid_row;
        }

        // ── 三段折返（赖皮蛇）：起点 → 右下角 → 右上角。缺省时从 (0,0) 出发，弹道全错 ──
        if (variable_instance_exists(_b, "wp1_x"))
        {
            var _rc = combat_max_col();
            var _w1 = get_world_position_from_grid(_rc, global.grid_rows - 1);
            var _w2 = get_world_position_from_grid(_rc, 0);
            _b.start_x = _px;
            _b.start_y = _py;
            _b.wp1_x = _w1.x;
            _b.wp1_y = _w1.y + global.grid_cell_size_y / 2 - sprite_get_height(_b.sprite_index) * _b.image_yscale / 2;
            _b.wp2_x = _w2.x;
            _b.wp2_y = _w2.y - global.grid_cell_size_y / 2;
        }

        // ── 三角形穿透轨迹（迷你披萨炉）：卡位 → 右沿上 → 右沿下 → 回起点 ──
        if (variable_instance_exists(_b, "point0_x"))
        {
            var _re = global.grid_offset_x + global.grid_cols * global.grid_cell_size_x;
            _b.point0_x = _px;
            _b.point0_y = _py;
            _b.point1_x = _re;
            _b.point1_y = global.grid_offset_y;
            _b.point2_x = _re;
            _b.point2_y = global.grid_offset_y + global.grid_rows * global.grid_cell_size_y;
            _b.target_point = 1;
        }

        // 双菇类：一次攻击 = 地面弹 + 空中弹（原卡两种对象各一发，各打各的目标类型）
        if (variable_struct_exists(_card, "o2"))
        {
            var _dy2 = variable_struct_exists(_card, "dy2") ? _card.dy2 : -128;
            var _b2 = instance_create_depth(x + _dx, y + _dy2, depth - 500, _card.o2);
            if (instance_exists(_b2))
            {
                variable_instance_set(_b2, "damage", _dmg);
                if (variable_instance_exists(_b2, "base_damage")) variable_instance_set(_b2, "base_damage", _dmg);
                variable_instance_set(_b2, "row", grid_row);
                if (variable_instance_exists(_b2, "grid_row")) _b2.grid_row = grid_row;
                if (!variable_instance_exists(_b2, "thrower_y")) variable_instance_set(_b2, "thrower_y", y);
                if (!variable_instance_exists(_b2, "atk"))       variable_instance_set(_b2, "atk", _dmg);
                if (variable_instance_exists(_b2, "move_speed") && variable_struct_exists(_card, "spd"))
                    _b2.move_speed = _card.spd;
            }
        }

        // ── 街头烤肉大师（bbq）：**每第 4 发**爆辣 + 铺火格（2026-11-11 改）─────────
        //   原卡 obj_bbq/Other_11：`bbq_shot_count` 跨轮累加，`_burn = ((_shot_base + _j + 1) mod 4 == 0)`
        //   → 命中第 4 / 8 / 12… 发换爆辣贴图并铺该行末格火。
        //   以前这里写的是「每轮末发」，一轮只有 6 发，跟原卡节奏对不上（会每轮都烧、位置还固定）。
        //   现在用实例计数器 tx_bbq_no 累计，跟原卡一样跨轮走。
        if (variable_struct_exists(_card, "burn"))
        {
            tx_bbq_no++;
            if (tx_bbq_no mod 4 == 0 && variable_instance_exists(_b, "burn_shot"))
            {
                _b.burn_shot = true;
                _b.sprite_index = spr_bbq_bullet_burn;
                tx_burn_cell(clamp(grid_row + round(_row_off), 0, global.grid_rows - 1));
            }
        }

        // 法师蛇（普通池版）之外的毒：数据写 poison: true 才铺（现在只有法师蛇走 mode 分支自己铺）
        if (variable_struct_exists(_card, "poison") && (_si + 1) mod 3 == 0)
        {
            if (_sp == "rows3")
            {
                for (var _pr = -1; _pr <= 1; _pr++)
                {
                    var _prr = grid_row + _pr;
                    if (_prr >= 0 && _prr < global.grid_rows) tx_poison_cells(_prr);
                }
            }
            else tx_poison_cells(grid_row);
        }
    }
};

/// 打一轮攻击：n = 这一轮几发；gap > 0 时改成「逐发延迟出膛」（法师蛇 / bbq 原卡口径）
tx_spawn = function(_card)
{
    // 整轮一次生成的口径（灯影花糕 / 炎凰马 / 冰块冷萃机 / 鲁班 / 典伊）：
    //   这几张原卡就是一个开火事件里把整轮铺完，n 只是表里的「描述发数」，不能拿来循环，
    //   否则会按 n 倍重复生成（灯影花糕会变 64 只）。交给 tx_special_shot 一次出完。
    if (tx_is_whole_mode(_card))
    {
        tx_special_shot(id, _card, 0);
        audio_play_sound(snd_shot, 0, 0);
        return;
    }

    var _n   = variable_struct_exists(_card, "n") ? _card.n : 1;
    var _gap = variable_struct_exists(_card, "gap") ? _card.gap : 0;

    var _per = variable_struct_exists(_card, "per") ? _card.per : 1;

    if (_gap > 0 && _n > _per)
    {
        for (var _bi = 0; _bi < _per; _bi++) tx_spawn_at(_card, _bi);      // 第一批当帧全出
        for (var _qi = _per; _qi < _n; _qi++)
            array_push(tx_pending, { c: _card, si: _qi, t: _gap * floor(_qi / _per) });
    }
    else
    {
        for (var _qi = 0; _qi < _n; _qi++) tx_spawn_at(_card, _qi);
    }

    audio_play_sound(snd_shot, 0, 0);
};

/// 延迟出膛队列（Step 里 array_length(tx_pending) > 0 时调用）
///   tx_spawn 内部「逐发延迟」的条目：到点只出那一发
tx_tick = function()
{
    for (var _ti = array_length(tx_pending) - 1; _ti >= 0; _ti--)
    {
        var _pend = tx_pending[_ti];
        _pend.t--;
        if (_pend.t <= 0)
        {
            array_delete(tx_pending, _ti, 1);
            tx_spawn_at(_pend.c, _pend.si);
        }
    }
};

/// 二转开火入口（Other_11 调用）
///   2026-11-11 用户定稿：一轮 = **1 次抽取**，打那张卡的一轮攻击
tx_shoot = function()
{
    tx_shot_col = tianxie_left_enemy();
    if (tx_shot_col < 0) tx_shot_col = grid_col + 4;   // 空放：往前方 4 格打

    tx_spawn(tx_roll());                               // 抽一张，本帧出
};
