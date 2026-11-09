/// =====================================================================
/// 子弹 × 环境交互参数表（火盆类 / 反弹类）—— 批量调参的唯一入口
///
///   fire = 过火（火盆 / 火神 / 金牛 / 能量喵 / 融合火盆）
///   reb  = 反弹（樱桃布丁 / 布丁汪 / 水神）
///
///   🔴 两种开法，二选一即可：
///      ① 表里写一行（本文件）—— 适合批量调整、给某张卡特殊参数
///      ② 子弹自己的 Create 里写 `hazard_fire = true;` / `hazard_rebound = true;`
///         —— 走默认参数（放大 1.8、按行、move_speed），日常加新卡用这个最省事
///      表里显式写了就以表为准（可以只写要改的字段）。
///   🔴 不要再给子弹写任何 Collision 事件 —— 父类 obj_bullet_parent 已经挂好 8 个。
///
///   fire 字段：
///     on       是否吃火（默认 false）
///     ice      是否冰弹（默认 = 对象名含 "ice"；霜蛊 / 融霜蛊因此不算）
///     step2    冰弹是否两步（默认 true：0→1 融化、1→2 点燃）
///     scale    点燃后放大几倍（默认 1.8；0 = 不放大，子弹自己在 Step 里处理）
///     srcs     入口白名单（默认 "*"；数组时只认这些对象名）
///     src_gate 要求 source_card_id 等于它（默认 ""，冰冻长枪那颗用）
///   reb 字段：
///     on        是否反弹（默认 false）
///     axis      反哪个位移量：move_speed / move_dir / move_x / move_speed_x / vx / travel_dir
///     judge     同排判定：row（默认）/ col / none
///     flip_y    同时翻 y_move_speed（海星类斜弹）
///     angle180  反弹后 image_angle += 180（默认 true）
///     kind_gate 只有 kind == fire/star 才反弹（星弹）
///     dir_guard 水平/垂直弹只看行（玫瑰盾）
///     reset_hits 反弹时清空命中记录（穿透弹回程能再打一次，**默认 true**；个别不想刷新的写 false）
/// =====================================================================

/// @function bullet_hazard_table()
/// @desc 表体。只写「与默认不同」的字段（2026-11-10 从原来 273 份 Collision 文件逐条提取）。
function bullet_hazard_table() {
    static _t = {
        // ── 过火 + 反弹 都吃的（多数直射弹）──
        "obj_corn_shooter_bullet":         { fire:{ on:true },                        reb:{ on:true } },
        "obj_corn_shooter_bullet_1":       { fire:{ on:true },                        reb:{ on:true } },
        "obj_corn_shooter_bullet_2":       { fire:{ on:true },                        reb:{ on:true } },
        "obj_houyi_god_bullet":            { fire:{ on:true },                        reb:{ on:true } },
        "obj_infected_zhanshen_bullet":    { fire:{ on:true },                        reb:{ on:true } },
        "obj_infected_zhanshen_bullet_super":{ fire:{ on:true },                      reb:{ on:true } },
        "obj_love_god_bullet":             { fire:{ on:true },                        reb:{ on:true } },
        "obj_love_god_bullet_1":           { fire:{ on:true },                        reb:{ on:true } },
        "obj_love_god_bullet_2":           { fire:{ on:true },                        reb:{ on:true } },
        "obj_love_god_bullet_3":           { fire:{ on:true },                        reb:{ on:true } },
        "obj_mianbao_bullet":              { fire:{ on:true },                        reb:{ on:true } },
        "obj_mightygun_bullet":            { fire:{ on:true },                        reb:{ on:true } },
        "obj_odin_bullet":                 { fire:{ on:true },                        reb:{ on:true } },
        "obj_sheshou_bullet":              { fire:{ on:true },                        reb:{ on:true } },
        "obj_shuanggu_bullet":             { fire:{ on:true },                        reb:{ on:true } },
        "obj_tiancheng_bullet":            { fire:{ on:true },                        reb:{ on:true } },
        "obj_triplewinerack_bullet":       { fire:{ on:true },                        reb:{ on:true } },
        "obj_war_god_bullet":              { fire:{ on:true },                        reb:{ on:true } },
        "obj_war_god_bullet_super":        { fire:{ on:true },                        reb:{ on:true } },
        "obj_waterpipe_bullet":            { fire:{ on:true },                        reb:{ on:true } },
        "obj_xiaolongbao_bullet":          { fire:{ on:true },                        reb:{ on:true } },
        "obj_caihongshe_bullet":           { fire:{ on:false },                       reb:{ on:true } },
        "obj_ghost_god_bullet_ping":       { fire:{ on:false },                       reb:{ on:true } },
        "obj_ghost_god_bullet_ping_m":     { fire:{ on:false },                       reb:{ on:true } },

        // ── 过火但不放大（贴图自己在 Step 里处理）──
        "obj_bbq_bullet":                  { fire:{ on:true, scale:0 },               reb:{ on:true, axis:"move_dir", judge:"none", reset_hits:true } },
        "obj_fashishe_bullet":             { fire:{ on:true, scale:0 },               reb:{ on:true, axis:"move_dir", judge:"none", reset_hits:true } },
        "obj_nutfrier_bullet":             { fire:{ on:true, scale:0 },               reb:{ on:true, flip_y:true, judge:"none" } },
        "obj_ronghesanxian_bullet":        { fire:{ on:true, scale:0 },               reb:{ on:true, reset_hits:true } },
        "obj_rongheshuanggu_bullet":       { fire:{ on:true, scale:0 },               reb:{ on:true } },
        "obj_youyu_god_bullet":            { fire:{ on:true, scale:0 },               reb:{ on:true, axis:"move_x" } },
        "obj_zodiac_projectile":           { fire:{ on:true, scale:0 },               reb:{ on:true, axis:"move_x", judge:"none", kind_gate:true } },

        // ── 冰弹（两步：先融化、再过一次才点燃）──
        "obj_icegun_bullet":               { fire:{ on:true, ice:true, step2:true },  reb:{ on:true } },
        "obj_icelongbao_bullet":           { fire:{ on:true, ice:true, step2:true, src_gate:"gatlin_ice_long_bao" }, reb:{ on:true } },
        "obj_icelongbao_bullet_vertical":  { fire:{ on:true, ice:true, step2:true },  reb:{ on:true, judge:"col" } },
        "obj_xiaolongbao_bullet_vertical": { fire:{ on:true },                        reb:{ on:true, judge:"col" } },

        // ── 按列反弹（三向 / 竖排）──
        "obj_ghost_god_bullet_xie":        { fire:{ on:false },                       reb:{ on:true, judge:"col" } },
        "obj_ghost_god_bullet_xie_m":      { fire:{ on:false },                       reb:{ on:true, judge:"col" } },
        "obj_ghost_god_bullet_zhi":        { fire:{ on:false },                       reb:{ on:true, judge:"col" } },
        "obj_ghost_god_bullet_zhi_m":      { fire:{ on:false },                       reb:{ on:true, judge:"col" } },

        // ── 不过火、只反弹 ──
        "obj_coalstarfish_bullet":         { fire:{ on:false },                       reb:{ on:true, flip_y:true, judge:"none" } },
        "obj_niuyouguo_bullet":            { fire:{ on:false },                       reb:{ on:true, axis:"travel_dir", angle180:false } },
        "obj_rig_bullet":                  { fire:{ on:false },                       reb:{ on:true, axis:"move_speed_x", judge:"none" } },
        "obj_rig_bullet_oblique":          { fire:{ on:false },                       reb:{ on:true, axis:"move_speed_x", judge:"none" } },   // 斜弹只翻水平分量（原手动写法）
        "obj_ronghehaixing_bullet":        { fire:{ on:false },                       reb:{ on:true, flip_y:true, judge:"none" } },
        "obj_rose_shield_bullet":          { fire:{ on:false },                       reb:{ on:true, dir_guard:true, reset_hits:true } },

        // ── 特例 ──
        "obj_shuanggu_bullet_air":         { fire:{ on:false },                       reb:{ on:true } },   // 空中弹完全不过火（2026-11-10 用户口径）
        "obj_rongheshuanggu_bullet_air":   { fire:{ on:false },                       reb:{ on:true } },
        "obj_tarsprayer_bullet":           { fire:{ on:true },                        reb:{ on:false } },  // 焦油喷壶：吃火但不反弹
        "obj_zhuzhuliaoliji_bullet":       { fire:{ on:true },                        reb:{ on:true, axis:"vx" } },
        "obj_love_god_bullet_super":       { fire:{ on:true },                        reb:{ on:false } },  // 原事件是空文件
    };
    return _t;
}

/// @function bullet_hazard_cfg(_obj_index)
/// @desc 取某子弹对象的合并配置，带缓存（用 object_index 当 key，避免每帧拼字符串）
/// @return struct { fire:{...}, reb:{...} }
function bullet_hazard_cfg(_obj_index) {
    static _by_index = {};
    if (variable_struct_exists(_by_index, _obj_index)) return _by_index[$ _obj_index];

    var _cf = { on:false, ice:undefined, step2:true, scale:1.8, srcs:"*", src_gate:"" };
    var _cr = { on:false, axis:"move_speed", judge:"row", flip_y:false, angle180:true,
                kind_gate:false, dir_guard:false, reset_hits:true };

    var _nm = object_get_name(_obj_index);          // 只在第一次进来时取一次
    var _t  = bullet_hazard_table();
    if (variable_struct_exists(_t, _nm)) {
        var _e = _t[$ _nm];
        if (variable_struct_exists(_e, "fire")) {
            var _f  = _e.fire;
            var _kf = variable_struct_get_names(_f);
            for (var i = 0; i < array_length(_kf); i++) _cf[$ _kf[i]] = _f[$ _kf[i]];
        }
        if (variable_struct_exists(_e, "reb")) {
            var _r  = _e.reb;
            var _kr = variable_struct_get_names(_r);
            for (var j = 0; j < array_length(_kr); j++) _cr[$ _kr[j]] = _r[$ _kr[j]];
        }
    }

    // ice 缺省 = 对象名含 "ice"（与 2026-11-10 之前的判定口径一致）
    if (is_undefined(_cf.ice)) _cf.ice = (string_count("ice", _nm) != 0);

    var _out = { fire:_cf, reb:_cr };
    _by_index[$ _obj_index] = _out;
    return _out;
}
