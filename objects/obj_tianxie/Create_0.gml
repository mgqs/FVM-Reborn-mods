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
// 二转（shape >= 2）：随机发射「其他卡种的一次攻击」
//   方案：桌面\fvm的ai\方案_天蝎座二转.md（2026-11-09 用户已锁定全部口径）
//   · 加权随机、不轮换、不与上一发重复（重抽一次）
//   · 每一发 = 那张卡「进行了一次攻击」（2026-11-09 扩到 **24 种**）：
//     小笼包 6 连发 / 融合煮蛋器 3 行×2 / 法师蛇 3 发+毒雾 / 勺勺兔 3 行 /
//     三线酒架 4 发 / 炭烧海星 5 向 / 星星兔 5 向 / 章鱼烧 2 发 / 咖喱龙虾炮 2 发 /
//     糖葫芦·护法神·栗子·披萨·可乐炸弹·焦油·肥牛·关东煮·巧克力·生煎·香肠·煮蛋器 各 1~3 发 /
//     白羊 1 辆冲撞车 / 逆转牛 & 桂花酒 各飞一张卡面（obj_tianxie_alt）
//   · 威力 = 天蝎座自己的 atk（可乐炸弹例外：固定 900，与星级无关）
//   · 对空 / 对地照抄原卡（糖葫芦只打空军、护法神含地鼠 / 幽灵、披萨走 pierce）
// ══════════════════════════════════════════════════════════════════════════
tx_cards = [
    "gatlin_ice_long_bao",   // 机枪冰冻小笼包：6 连发（间隔 5 帧）
    "baiyang",               // 白羊座：1 辆冲撞车清本行
    "nizhuanniu",            // 逆转牛：飞卡面 → 5×5 送回、0 伤害
    "fashishe",              // 法师蛇：3 发 + 第 3 发铺毒雾
    "hufa_god",              // 护法神：1 发全屏追踪（满转 shape 3 口径）
    "tang_hu_lu",            // 糖葫芦炮弹：1 发（只打空军）
    "spoon_rabbit",          // 勺勺兔：3 行各 1 发
    "guihuajiu",             // 桂花酒：飞卡面 → 十字火焰格 + 醉酒
    "tangchaolizi",          // 糖炒栗子：1 发抛物线，落地 3×3
    "eightcake",             // 8 周年蛋糕：可乐炸弹投掷（固定 900 灰烬）
    "pizza_oven",            // 披萨炉：1 发三角路径，飞一圈回卡上
    "starrabbit",            // 星星兔：5 方向各 1 发星弹
    "egg_boiler_pult",       // 煮蛋器（普通）：1 发抛物线投蛋
    "ronghedan_god",         // 融合煮蛋器：三行各 2 枚 + 定身 + 毒气
    "sheshou",               // 射手座精灵：三行各 1 发 + 中路补 1 发
    "gaia",                  // 盖亚神使：双连发 3×3 爆炸音波
    "coal_starfish",         // 炭烧海星：五方向各 1 发
    "ronghehaixing",         // 融合海星：五方向共 11 发
    "fenjima",               // 焚寂马：1 发穿透火焰弹
    "yufengma",              // 御风马：龙卷风贯穿本行
    "chocolate_cannon",      // 巧克力炮：落本行第 9 列 3×3 爆炸
    "hongliukaochuan",       // 红柳烤串机：1 发全屏追踪穿透肉串
    "donut",                 // 多拿滋：连续攻击本行，优先空军
    "takoyaki",              // 章鱼烧：2 发追踪飞镖
    "gongjiang_god"          // 工匠神·鲁班：河豚弹沿固定轨迹往返（终转 2 横 + 4 竖）
];
// 权重一一对应（2026-11-09 用户三次分档，**24 张**，合计 **100**）
//   高：糖葫芦 8 · 逆转牛 8（用户要求提高）
//   中：小笼包 6 · 勺勺兔 6 · 栗子 5 · 披萨炉 5 · 8周年蛋糕 5 · 炭烧海星 5
//   低：法师蛇 4 · 焦油 4 · 肥牛 4 · 关东煮 3→ 见数组 · 香肠 4 · 星星兔 4 · 两种煮蛋器各 4
//   最低：桂花酒 3 · 护法神 2 · 白羊座 1（用户要求降低）
// 权重一一对应（2026-11-09 用户五档，**25 张**，合计 151）
//   🔴 只有「相对比例」影响概率，总和是多少都一样（irandom(总和-1) 后逐项累减），
//      改总和不会改变任何一张的占比，除非同时改了比例。
//   一档 10（各 6.6%）：糖葫芦 / 小笼包 / 勺勺兔 / 炭烧海星 / 披萨炉 / 煮蛋器 / 射手座 / 章鱼烧
//   二档  6（各 4.0%）：融合海星 / 融合煮蛋器 / 星星兔 / 巧克力炮 / 多拿滋
//   三档  4（各 2.6%）：逆转牛 / 法师蛇 / 桂花酒 / 糖炒栗子 / 可乐炸弹 / 盖亚 / 焚寂马 / 御风马 / 红柳
//   四档  2（各 1.3%）：护法神 / 工匠神·鲁班（= 白羊座 + 1）
//   五档  1（0.66%）：白羊座
//   比例 10 : 6 : 4 : 2 : 1
tx_weight    = [10, 1, 4, 4, 2, 10, 10, 4, 4, 4, 10,
                6, 10, 6, 10, 4, 10, 6, 4, 4, 6, 4, 6, 10, 2];   // 合计 151
tx_last_card = "";       // 上一发出的卡 id（抽到同一张就重抽一次）
tx_shot_col  = -1;       // 这一轮的目标列（tx_shoot 取一次，多发卡共用）
tx_pending   = [];       // 待补发队列：[{card:"...", seq:n, t:剩余帧}]

/// 加权抽一张，返回卡 id
tx_roll_card = function()
{
    var _total = 0;
    for (var _a = 0; _a < array_length(tx_weight); _a++) _total += tx_weight[_a];

    var _pick = irandom(_total - 1);
    for (var _b = 0; _b < array_length(tx_cards); _b++)
    {
        if (_pick < tx_weight[_b]) return tx_cards[_b];
        _pick -= tx_weight[_b];
    }
    return tx_cards[0];
};

/// 把一发延后 _t 帧补发（小笼包 / 法师蛇 这类多发的卡用）
tx_queue = function(_id, _seq, _t)
{
    array_push(tx_pending, { card: _id, seq: _seq, t: _t });
};

/// 二转开火入口：抽一张 → 立刻发第 1 发，多发卡的后续几发由 tx_tick 按帧补
tx_shoot = function()
{
    tx_shot_col = tianxie_left_enemy();
    if (tx_shot_col < 0) tx_shot_col = grid_col + 4;   // 海克斯空放：往前方 4 格打

    var _id = tx_roll_card();
    if (_id == tx_last_card) _id = tx_roll_card();     // 不与上一发重复（只重抽一次，不会死循环）
    tx_last_card = _id;

    tx_fire(_id, 0);
};

/// 每帧推进补发队列（Step 里调）
tx_tick = function()
{
    var _n = array_length(tx_pending);
    for (var _i = _n - 1; _i >= 0; _i--)
    {
        if (_i >= array_length(tx_pending)) continue;
        var _e = tx_pending[_i];
        _e.t = _e.t - 1;
        if (_e.t <= 0)
        {
            tx_fire(_e.card, _e.seq);
            array_delete(tx_pending, _i, 1);
        }
    }
};

/// 本行最靠左的可打敌人（_type = 攻击类型口径，跟原卡一致）；没有返回 noone
///   🔴 with 里改实例变量必须走 other.（同 tianxie_left_enemy 的写法），否则写到老鼠身上
tx_pick_row = function(_row, _type)
{
    tx_pick_id = noone;
    tx_pick_x  = 999999;
    with (obj_enemy_parent)
    {
        if (hp <= 0) continue;
        if (grid_row != _row) continue;
        if (!can_target_on(_type, target_type)) continue;
        if (x < other.tx_pick_x)
        {
            other.tx_pick_x  = x;
            other.tx_pick_id = id;
        }
    }
    return tx_pick_id;
};

/// 全屏最靠左的可打敌人（香肠判「有没有空军」用）
tx_pick_any = function(_type)
{
    tx_pick_id = noone;
    tx_pick_x  = 999999;
    with (obj_enemy_parent)
    {
        if (hp <= 0) continue;
        if (!can_target_on(_type, target_type)) continue;
        if (x < other.tx_pick_x)
        {
            other.tx_pick_x  = x;
            other.tx_pick_id = id;
        }
    }
    return tx_pick_id;
};

/// 出一发：_id = 卡 id，_seq = 这张卡的第几发（0 起）
///   🔴 每个 case 的临时变量都用了不同的名字：GML 2.3 的 var 作用域按函数算，
///      同名 var 在同一函数里重复声明会告警（严格模式可能直接报错），别写成统一 _b。
tx_fire = function(_id, _seq)
{
    var _row = grid_row;
    var _dmg = atk;

    switch (_id)
    {
        // ── 机枪冰冻小笼包：6 连发，每发间隔 5 帧 ──
        //   🔴 source_card_id 必须传原卡 id：obj_icelongbao_bullet 的过火门禁认的是 "gatlin_ice_long_bao"
        case "gatlin_ice_long_bao":
        {
            var _bg = instance_create_depth(x + 45, y - 60, depth - 500, obj_icelongbao_bullet);
            _bg.damage         = _dmg;
            _bg.source_card_id = "gatlin_ice_long_bao";
            _bg.move_speed     = 8;
            _bg.row            = _row;
            audio_play_sound(snd_shot, 0, 0);
            if (_seq < 5) tx_queue(_id, _seq + 1, 5);
            break;
        }

        // ── 白羊座：只 1 辆冲撞车，清本行 ──
        //   🔴 直接生成 obj_baiyang_effect，**不创建白羊座卡片** →
        //      不会触发百变蛇复制 / 放置类钩子，就是纯发射
        case "baiyang":
        {
            var _car = instance_create_depth(x, y, depth - 500, obj_baiyang_effect);
            _car.atk      = _dmg;
            _car.grid_row = _row;
            audio_play_sound(snd_shot, 0, 0);
            break;
        }

        // ── 逆转牛：飞一张卡面过去，碰第一只可打老鼠 → 5×5 送回、0 伤害 ──
        case "nizhuanniu":
        {
            tx_alt_spawn("cow", _row, _dmg);
            break;
        }

        // ── 法师蛇：本行 3 发（间隔 14 帧），第 3 发那一帧铺毒雾（行末 3 格）──
        // ── 法师蛇：二转一轮 = **3 行 × 3 发**（每「发」三行各出 1 颗，共 3 次、间隔 14 帧）
        //   毒雾：每 3 发铺一次 → 第 3 次那轮**三行各铺 3 格**（原卡 fashishe_fire_one + per_row=3）
        //   🔴 2026-11-09：原来只发本行 3 发，少了上下两行与两次毒雾
        case "fashishe":
        {
            var _fas_rows = [];
            if (_row > 0)                      array_push(_fas_rows, _row - 1);
            array_push(_fas_rows, _row);
            if (_row < global.grid_rows - 1)   array_push(_fas_rows, _row + 1);

            for (var _fas_i = 0; _fas_i < array_length(_fas_rows); _fas_i++)
            {
                var _fas_r = _fas_rows[_fas_i];
                // 贴图格线比逻辑格心高 36px（同 bbq 的 art_up），子弹中心线按贴图走
                var _fas_lane_y = get_world_position_from_grid(grid_col, _fas_r).y - 36;
                var _bf = instance_create_depth(x + 45, _fas_lane_y, depth - 500, obj_fashishe_bullet);
                _bf.row            = _fas_r;
                _bf.base_y         = _fas_lane_y;
                _bf.phase          = 0;
                _bf.damage         = _dmg;
                _bf.end_x          = global.grid_offset_x + (global.grid_cols + 1) * global.grid_cell_size_x;
                _bf.damage_type    = "pierce";   // 2026-11-10：与法师蛇原卡一致（毒针全程穿透 → 也要穿地形障碍）
                _bf.target_type    = "normal";
                _bf.hittable_types = get_hittable_enemy_types("normal");
                _bf.sprite_index   = spr_fashishe_bullet_2;

                if (_seq == 2) tx_poison_at(_fas_r, 3, _dmg);    // 第 3 次：三行各铺毒
            }
            audio_play_sound(snd_shot, 0, 0);

            if (_seq < 2) tx_queue(_id, _seq + 1, 14);
            break;
        }

        // ── 护法神：1 发全屏追踪穿透弹（满转 shape 3：可打地鼠 / 幽灵 / 空军）──
        case "hufa_god":
        {
            var _hf_hittable = ["normal", "air", "underground", "invisible"];
            var _hf_tgt  = noone;
            var _hf_best = -infinity;
            if (variable_global_exists("enemy_by_type"))
            {
                for (var _hf_t = 0; _hf_t < array_length(_hf_hittable); _hf_t++)
                {
                    var _hf_key = _hf_hittable[_hf_t];
                    if (!variable_struct_exists(global.enemy_by_type, _hf_key)) continue;
                    var _hf_list = global.enemy_by_type[$ _hf_key];
                    for (var _hf_i = 0; _hf_i < array_length(_hf_list); _hf_i++)
                    {
                        var _hf_e = _hf_list[_hf_i];
                        if (!instance_exists(_hf_e) || _hf_e.hp <= 0) continue;
                        var _hf_score = -point_distance(x, y, _hf_e.x, _hf_e.y);
                        if (_hf_e.is_boss) _hf_score += 1000000;
                        if (_hf_score > _hf_best)
                        {
                            _hf_best = _hf_score;
                            _hf_tgt  = _hf_e;
                        }
                    }
                }
            }
            if (instance_exists(_hf_tgt))
            {
                var _bh = instance_create_depth(x, y - 75, depth - 500, obj_hufa_god_bullet);
                _bh.damage         = _dmg;
                _bh.base_atk       = _dmg;
                _bh.shape          = 3;
                _bh.target_id      = _hf_tgt.id;
                _bh.hittable_types = _hf_hittable;
                _bh.sprite_index   = spr_hufa_god_bullet_3;

                var _hf_dx = _hf_tgt.x - x;
                var _hf_dy = _hf_tgt.y - (y - 75);
                var _hf_len = point_distance(0, 0, _hf_dx, _hf_dy);
                if (_hf_len > 0)
                {
                    _bh.move_x = (_hf_dx / _hf_len) * _bh.move_speed;
                    _bh.move_y = (_hf_dy / _hf_len) * _bh.move_speed;
                }
                _bh.image_angle = point_direction(0, 0, _bh.move_x, _bh.move_y);
                audio_play_sound(snd_shot, 0, 0);
            }
            break;
        }

        // ── 糖葫芦炮弹：1 发，只打空军（照抄 0 转的一次攻击）──
        case "tang_hu_lu":
        {
            var _th_tgt  = noone;
            var _th_minx = 999999;
            with (obj_enemy_parent)
            {
                if (hp > 0 && can_target_on("air_only", target_type) && x < _th_minx)
                {
                    _th_minx = x;
                    _th_tgt  = id;
                }
            }

            var _bt = instance_create_depth(x, y - 95, depth - 500, obj_tanghulu_bullet);
            _bt.damage          = _dmg;
            _bt.move_speed      = 10;
            _bt.target_enemy    = _th_tgt;      // 没有空军时是 noone，子弹照原卡逻辑直飞
            _bt.banding_card_obj = id;
            _bt.row             = _row;
            _bt.bullet_shape    = 2;
            audio_play_sound(snd_shot, 0, 0);
            if (_seq == 0) tx_queue(_id, 1, 8);   // 二转是 2 发，第二发隔 8 帧
            break;
        }

        // ── 勺勺兔：3 行各 1 发抛物线（哪行没目标就不丢那行，同原卡）──
        case "spoon_rabbit":
        {
            var _sp_lane_h = global.grid_cell_size_y;
            for (var _sp_k = 0; _sp_k < 3; _sp_k++)
            {
                var _sp_row = _row + (_sp_k - 1);
                if (_sp_row < 0 || _sp_row >= global.grid_rows) continue;

                var _sp_tgt  = noone;
                var _sp_minx = 999999;
                with (obj_enemy_parent)
                {
                    if (hp > 0 && grid_row == _sp_row && x < _sp_minx && can_target_on("throw", target_type))
                    {
                        _sp_minx = x;
                        _sp_tgt  = id;
                    }
                }
                if (!instance_exists(_sp_tgt)) continue;

                var _sp_ex  = _sp_tgt.x;
                var _sp_esp = variable_instance_exists(_sp_tgt, "move_speed") ? _sp_tgt.move_speed : 0;
                var _sp_ft  = clamp(30 + (((_sp_ex - x) / 1000) * 45), 30, 75);   // 飞行帧数（同原卡）
                var _sp_px  = _sp_ex - (_sp_esp * _sp_ft) - 70;
                if (_sp_px < x) _sp_px = x;

                var _sp_tdx = _sp_px - x;
                var _sp_tdy = 400;

                var _bs = instance_create_depth(x, y - 160 - (_sp_k - 1) * _sp_lane_h, depth - 500, obj_spoon_rabbit_bullet);
                _bs.damage       = _dmg;
                _bs.row          = _sp_row;
                _bs.thrower_y    = y - (_sp_k - 1) * _sp_lane_h;
                _bs.sprite_index = spr_spoon_rabbit_bullet_2;
                _bs.move_speed   = _sp_tdx / _sp_ft;
                _bs.cgravity     = (2 * _sp_tdy) / (_sp_ft * _sp_ft);
                _bs.cvspeed      = _sp_tdy / _sp_ft;
                _bs.hit_enemy    = false;
            }
            audio_play_sound(snd_shot, 0, 0);
            break;
        }

        // ── 桂花酒：飞一张卡面过去，碰第一只 → 十字火焰格 + 醉酒 25 秒 ──
        case "guihuajiu":
        {
            tx_alt_spawn("wine", _row, _dmg);
            break;
        }

        // ── 糖炒栗子：1 发抛物线，落地 3×3（十字 5 格吃满）──
        case "tangchaolizi":
        {
            // 目标列可以落到场外（老鼠排到第 10/11 列也砸得到），不夹地图列（同原卡 tc_tcol）
            var _lz_col = tx_shot_col;
            if (_lz_col < 0) _lz_col = min(grid_col + 4, global.grid_cols);
            _lz_col = clamp(_lz_col, 0, global.grid_cols + 1);

            var _lz_sx = x + 4;
            var _lz_sy = y - 74;

            // 提前量（同原卡 / 生煎锅）：老鼠朝左推进，飞行 T 帧会走过 move_speed × T 像素，
            //   按格 round 扣掉 → 不足半格不提前，半格以上提前 1 格
            var _lz_t = tx_pick_row(_row, "throw");
            if (instance_exists(_lz_t)
                && variable_instance_exists(_lz_t, "move_speed") && _lz_t.move_speed > 0)
            {
                var _lz_t0 = clamp(round(30 + ((get_world_position_from_grid(_lz_col, _row).x - _lz_sx) / 1000) * 45), 30, 75);
                _lz_col = max(0, _lz_col - round(_lz_t.move_speed * _lz_t0 / global.grid_cell_size_x));
            }

            var _lz_cell = get_world_position_from_grid(_lz_col, _row);
            var _lz_ty = _lz_cell.y - 36;               // 视觉落点 = 贴图格线（同原卡）
            var _bl = instance_create_depth(_lz_sx, _lz_sy, depth - 500, obj_tangchaolizi_bullet);
            _bl.sprite_index  = spr_tangchaolizi_bullet_2;
            _bl.shape         = 2;
            _bl.damage        = _dmg;
            _bl.damage_corner = _dmg;                   // 四角格也给 atk（原卡是 0 转 atk，这里统一按天蝎座 atk）
            _bl.row           = _row;
            _bl.col           = _lz_col;
            _bl.sx = _lz_sx;
            _bl.sy = _lz_sy;
            _bl.tx = _lz_cell.x;
            _bl.ty = _lz_ty;
            _bl.T   = clamp(round(30 + ((_lz_cell.x - _lz_sx) / 1000) * 45), 30, 75);
            _bl.arc = 120;
            audio_play_sound(snd_throw, 0, 0);
            break;
        }

        // ── 8 周年蛋糕：投一颗可乐炸弹（固定 900 灰烬伤害，不读天蝎座 atk）──
        case "eightcake":
        {
            // 炸弹是 3×3 按格结算，落点必须在地图内，场外那只靠 ±1 列捎带
            var _ec_col = tx_shot_col;
            if (_ec_col < 0 || _ec_col >= global.grid_cols) _ec_col = min(grid_col + 4, global.grid_cols - 1);
            _ec_col = clamp(_ec_col, 0, global.grid_cols - 1);
            var _ec_cell = get_world_position_from_grid(_ec_col, _row);

            var _ec_sx = x - 20;
            var _ec_sy = y - 100;
            var _ec_ty = _ec_cell.y - 36;
            var _ec_bd = point_distance(_ec_sx, _ec_sy, _ec_cell.x, _ec_ty);

            var _bb = instance_create_depth(_ec_sx, _ec_sy, depth - 500, obj_eightcake_bomb);
            _bb.damage = 900;                           // 固定值：与天蝎座星级 / buff 无关
            _bb.row    = _row;
            _bb.col    = _ec_col;
            _bb.sx = _ec_sx;
            _bb.sy = _ec_sy;
            _bb.tx = _ec_cell.x;
            _bb.ty = _ec_ty;
            _bb.T   = clamp(round(_ec_bd / 20), 20, 46);
            _bb.arc = clamp(_ec_bd * 0.42, 80, 300);
            audio_play_sound(snd_throw, 0, 0);
            break;
        }

        // ── 披萨炉：1 发三角路径穿透弹，绕一圈回到卡上（原卡逻辑：回到 point0 即销毁）──
        case "pizza_oven":
        {
            var _pz_pos    = get_world_position_from_grid(grid_col, _row);
            var _pz_right  = global.grid_offset_x + global.grid_cols * global.grid_cell_size_x;
            var _pz_top    = global.grid_offset_y;
            var _pz_bottom = global.grid_offset_y + global.grid_rows * global.grid_cell_size_y;

            var _bp = instance_create_depth(x + 40, y - 70, depth - 500, obj_pizzaoven_bullet);
            _bp.damage       = _dmg;
            _bp.move_speed   = 8;
            _bp.sprite_index = spr_pizza_oven_bullet_2;
            _bp.point0_x = _pz_pos.x;
            _bp.point0_y = _pz_pos.y - 70;
            _bp.point1_x = _pz_right;
            _bp.point1_y = _pz_top;
            _bp.point2_x = _pz_right;
            _bp.point2_y = _pz_bottom;
            _bp.target_point = 1;
            audio_play_sound(snd_shot, 0, 0);
            break;
        }

        // ── 星星兔：5 方向各 1 发星弹 ──
        case "starrabbit":
        {
            var _sr_ang = [0, 22.5, -22.5, 45, -45];
            for (var _sr_i = 0; _sr_i < array_length(_sr_ang); _sr_i++)
            {
                var _sr = instance_create_depth(x, y - 30, -2500, obj_zodiac_projectile);
                _sr.kind              = "star";
                _sr.damage            = _dmg * 3;   // 原卡二转「伤害提升至 3 倍」
                _sr.base_damage       = _dmg * 3;
                _sr.shape             = 2;
                _sr.target_id         = noone;
                _sr.move_x            = lengthdir_x(8, _sr_ang[_sr_i]);
                _sr.move_y            = lengthdir_y(8, _sr_ang[_sr_i]);
                _sr.image_angle       = _sr_ang[_sr_i];
                _sr.sprite_index      = spr_starrabbit_bullet_2;
                _sr.image_xscale      = 1;
                _sr.image_yscale      = 1;
                _sr.can_dandantu_store = false;
                _sr.damage_type       = "normal";   // 星弹不穿透、不穿盾（原卡口径）
                _sr.center_row        = _row;
            }
            audio_play_sound(snd_shot, 0, 0);
            break;
        }

        // ── 煮蛋器（普通）：1 发抛物线投蛋（落点按目标提前量，照原卡公式）──
        case "egg_boiler_pult":
        {
            var _eb = instance_create_depth(x + 20, y - 115, depth - 500, obj_eggboilerpult_bullet);
            _eb.sprite_index    = spr_eggboilerpult_bullet_2;
            _eb.damage          = _dmg;
            _eb.original_damage = _dmg;
            _eb.row             = _row;
            _eb.thrower_y       = y;
            _eb.shape           = 2;
            _eb.hit_enemy       = false;
            _eb.splashed        = false;

            var _eb_t = tx_pick_row(_row, "throw");
            if (instance_exists(_eb_t))
            {
                var _eb_spd = variable_instance_exists(_eb_t, "move_speed") ? _eb_t.move_speed : 0;
                var _eb_ft  = clamp(30 + ((_eb_t.x - _eb.x) / 1000) * 45, 30, 75);
                var _eb_aim = max(x, _eb_t.x - _eb_spd * _eb_ft - 50);
                _eb.move_speed   = (_eb_aim - _eb.x) / _eb_ft;
                _eb.cgravity     = 1200 / (_eb_ft * _eb_ft);
                _eb.cvspeed      = 600 / _eb_ft;
                _eb.target_enemy = _eb_t;
                _eb.has_target   = true;
            }
            else
            {
                _eb.move_speed   = 8;
                _eb.cvspeed      = 6;
                _eb.cgravity     = 0.2;
                _eb.target_enemy = noone;
                _eb.has_target   = false;
            }
            audio_play_sound(snd_throw, 0, 0);
            break;
        }

        // ── 融合煮蛋器：三行各 2 枚 + 几率定身 + 深度毒气（照原卡 shape 2）──
        case "ronghedan_god":
        {
            var _rd_last_col = global.grid_cols - 1;
            var _rd_tgt = [noone, noone, noone];
            var _rd_mx  = [999999, 999999, 999999];
            with (obj_enemy_parent)
            {
                if (hp <= 0) continue;
                if (target_type == "obstacle") continue;
                if (!can_target_on("throw", target_type)) continue;
                if (grid_col < other.grid_col) continue;
                if (grid_col > global.grid_cols + 1) continue;
                var _rd_lane = (grid_row - other.grid_row) + 1;
                if (_rd_lane < 0 || _rd_lane > 2) continue;
                if (x < _rd_mx[_rd_lane])
                {
                    _rd_mx[_rd_lane]  = x;
                    _rd_tgt[_rd_lane] = id;
                }
            }

            var _rd_stun_frames = round(3.6 * 60);   // 满星 3.6 秒
            var _rd_poison      = 243;               // 深度毒气：**固定按星级表**（17 星 243），不跟 atk
            var _rd_lane_h      = global.grid_cell_size_y;

            for (var _rd_i = 0; _rd_i < 3; _rd_i++)
            {
                var _rd_row = clamp(_row + _rd_i - 1, 0, global.grid_rows - 1);
                var _rd_t   = _rd_tgt[_rd_i];
                var _rd_col = instance_exists(_rd_t) ? _rd_t.grid_col : _rd_last_col;
                var _rd_sy  = y - 125 + (_rd_row - _row) * _rd_lane_h;

                for (var _rd_n = 0; _rd_n < 2; _rd_n++)
                {
                    var _rd = instance_create_depth(x - 40 + (_rd_n * 20 - 10), _rd_sy, depth - 500, obj_ronghedan_god_bullet);
                    _rd.sprite_index    = spr_ronghedan_god_bullet_2;
                    _rd.image_speed     = 0;
                    _rd.image_index     = 0;
                    _rd.damage          = _dmg;
                    _rd.original_damage = _dmg;
                    _rd.row             = _rd_row;
                    _rd.thrower_y       = y + (_rd_row - _row) * _rd_lane_h;
                    _rd.shape           = 2;
                    _rd.stun_chance     = 20;          // 满级兜底（原卡 17 级 20%）
                    _rd.stun_frames     = _rd_stun_frames;
                    _rd.poison_damage   = _rd_poison;
                    _rd.splash_ratio    = 0.35;
                    _rd.hit_enemy       = false;
                    _rd.has_splashed    = false;

                    var _rd_spread = (_rd_n == 0) ? -30 : 30;
                    var _rd_ft  = 30;
                    var _rd_aim = 0;
                    if (instance_exists(_rd_t))
                    {
                        var _rd_spd = variable_instance_exists(_rd_t, "move_speed") ? _rd_t.move_speed : 0;
                        _rd_ft  = clamp(30 + ((_rd_t.x - _rd.x) / 1000) * 45, 30, 75);
                        _rd_aim = max(x, _rd_t.x - _rd_spd * _rd_ft - 50 + _rd_spread);
                        _rd.target_enemy = _rd_t;
                    }
                    else
                    {
                        var _rd_cell = get_world_position_from_grid(_rd_col, _rd_row);
                        _rd_aim = _rd_cell.x;
                        _rd_ft  = clamp(30 + ((_rd_aim - _rd.x) / 1000) * 45, 30, 75);
                        _rd.target_enemy = noone;
                    }
                    _rd.move_speed = (_rd_aim - _rd.x) / _rd_ft;
                    _rd.cgravity   = 1200 / (_rd_ft * _rd_ft);
                    _rd.cvspeed    = 600 / _rd_ft;
                    _rd.has_target = true;
                }
            }
            audio_play_sound(snd_throw, 0, 0);
            break;
        }

        // ── 射手座精灵：三行各 1 发，中路再补 1 发（原卡「3 行 4 发」）──
        // ── 射手座精灵：一次攻击 = 2 组齐射（原卡 cycle-5×flash / cycle-3×flash，flash=5 → 隔 10 帧）
        //   每组 = 中路 + 上一行 + 下一行 3 发；二转两组都带上/下 → **共 6 发**
        //   🔴 2026-11-09 用户实测「效果没完全」：原来只写 4 发（3 行 + 中路各 1），少了一整组
        case "sheshou":
        {
            var _ss_my = y - 75;
            for (var _ss_g = 0; _ss_g < 3; _ss_g++)          // 0=中 1=上 2=下
            {
                var _ss = instance_create_depth(x + 40, _ss_my, depth - 500, obj_sheshou_bullet);
                _ss.damage     = _dmg;
                _ss.move_speed = 8;
                _ss.row        = _row;

                if (_ss_g == 0)
                {
                    _ss.target_row = _row;                    // 中路不发 start_y（照原卡）
                }
                else if (_ss_g == 1)
                {
                    if (_row - 1 >= 0) _ss.target_row = _row - 1;
                    else { _ss.target_row = _row; _ss.x -= 20; }   // 边行补偿（同原卡）
                    _ss.start_y = _ss_my;
                }
                else
                {
                    if (_row + 1 < global.grid_rows) _ss.target_row = _row + 1;
                    else { _ss.target_row = _row; _ss.x -= 20; }
                    _ss.start_y = _ss_my;
                }
            }
            audio_play_sound(snd_shot, 0, 0);
            if (_seq == 0) tx_queue(_id, 1, 10);              // 第二组齐射
            break;
        }

        // ── 盖亚神使：**3 连发** 3×3 爆炸音波（原卡 attack_anim-10/-8/-6 各调一次 event_user(1)）
        //   子弹从天而降，照原卡 y-330 起手；三发落点各偏 -20/0/+20，避免完全重叠看不出
        case "gaia":
        {
            var _ga_t = tx_pick_row(_row, "normal");
            for (var _ga_i = 0; _ga_i < 3; _ga_i++)
            {
                var _ga = instance_create_depth(x, y - 330, depth - 45, obj_gaia_bullet);
                _ga.damage       = _dmg;
                _ga.shape_bullet = 2;
                _ga.sprite_index = spr_gaia_bullet_2;
                if (instance_exists(_ga_t))
                {
                    _ga.target_x = _ga_t.x + (_ga_i - 1) * 20;   // -20 / 0 / +20
                    _ga.target_y = _ga_t.y;
                    _ga.row      = _ga_t.grid_row;
                }
                else
                {
                    _ga.target_x = get_world_position_from_grid(global.grid_cols - 1, _row).x;
                    _ga.target_y = y;
                    _ga.row      = _row;
                }
            }
            audio_play_sound(snd_shot, 0, 0);
            break;
        }

        // ── 炭烧海星：五方向各 1 发（左 / 下 / 上 / 右上 / 右下，照原卡 5 段）──
        //   🔴 这里用**一维平行数组**，不要写成 [[x,y,...],...] 这种二维字面量：
        //      工程里能跑通的多发实现（obj_ronghehaixing/Other_11、obj_aladdin_lamp/Other_11）
        //      都是「每个字段一个一维数组 + 一维下标」。2026-11-09 用户实测：二维写法只出 1 发。
        case "coal_starfish":
        {
            var _cs_x   = [x - 40, x,      x,      x + 40, x + 40];
            var _cs_y   = [y - 45, y - 45, y - 95, y - 45, y - 45];
            var _cs_mvx = [    -8,      0,      0,      5,      5];
            var _cs_mvy = [     0,      8,     -8,     -3,      3];
            var _cs_ang = [     0,     90,    -90,   -145,    145];
            for (var _cs_i = 0; _cs_i < 5; _cs_i++)
            {
                var _cs = instance_create_depth(_cs_x[_cs_i], _cs_y[_cs_i], depth - 500, obj_coalstarfish_bullet);
                _cs.damage       = _dmg;
                _cs.move_speed   = _cs_mvx[_cs_i];
                _cs.y_move_speed = _cs_mvy[_cs_i];
                _cs.image_angle  = _cs_ang[_cs_i];
                _cs.row          = _row;
                _cs.b_type       = 1;
                _cs.sprite_index = spr_coalstarfish_bullet_2;
            }
            audio_play_sound(snd_shot, 0, 0);
            break;
        }

        // ── 融合海星：五方向共 11 发（后 3 + 其余各 2，含错帧），照原卡 ──
        case "ronghehaixing":
        {
            var _rh_x     = [-40,  0,   0,  40,  40];
            var _rh_y     = [-45, -45, -95, -45, -45];
            var _rh_mvx   = [ -8,   0,   0,   5,   5];
            var _rh_mvy   = [  0,   8,  -8,  -3,   3];
            var _rh_ang   = [  0,  90, -90, -145, 145];
            var _rh_btype = [  1,   0,   0,   0,   0];
            var _rh_n     = [  3,   2,   2,   2,   2];

            for (var _rh_d = 0; _rh_d < 5; _rh_d++)
            {
                for (var _rh_k = 0; _rh_k < _rh_n[_rh_d]; _rh_k++)
                {
                    var _rh = instance_create_depth(x + _rh_x[_rh_d], y + _rh_y[_rh_d], depth - 500, obj_ronghehaixing_bullet);
                    _rh.damage       = _dmg;
                    _rh.move_speed   = _rh_mvx[_rh_d];
                    _rh.y_move_speed = _rh_mvy[_rh_d];
                    _rh.image_angle  = _rh_ang[_rh_d];
                    _rh.b_type       = _rh_btype[_rh_d];
                    _rh.shape        = 2;
                    _rh.sprite_index = spr_ronghehaixing_bullet_2;
                    _rh.delay        = _rh_k * 5;
                    _rh.dir_index    = _rh_d;
                    _rh.splash_ratio = 0.50;   // 17 星满档（原卡 _splash_by_star 末位 0.50）
                    if (_rh_btype[_rh_d] == 1) _rh.row = _row;
                }
            }
            audio_play_sound(snd_shot, 0, 0);
            break;
        }

        // ── 焚寂马：1 发穿透火焰弹（原卡 kind = "fire"，穿透伤害）──
        case "fenjima":
        {
            var _fj = instance_create_depth(x, y - 30, -2500, obj_zodiac_projectile);
            _fj.kind         = "fire";
            _fj.damage       = _dmg;
            _fj.base_damage  = _dmg;
            _fj.shape        = 2;
            _fj.target_id    = noone;
            _fj.move_x       = 8;
            _fj.move_y       = 0;
            _fj.image_angle  = 0;
            _fj.sprite_index = spr_fenjima_bullet_2;
            _fj.can_dandantu_store = true;
            _fj.damage_type  = "pierce";     // 原卡：穿透
            _fj.row          = _row;
            _fj.center_row   = _row;
            audio_play_sound(snd_shot, 0, 0);
            break;
        }

        // ── 御风马：1 道龙卷风贯穿本行（目标在左就往左吹，同原卡）──
        case "yufengma":
        {
            var _yf_t   = tx_pick_row(_row, "normal");
            var _yf_dir = 1;
            if (instance_exists(_yf_t) && _yf_t.x < x) _yf_dir = -1;

            var _yf = instance_create_depth(x, y - 30, -2500, obj_zodiac_projectile);
            _yf.kind         = "wind";
            _yf.damage       = _dmg;
            _yf.base_damage  = _dmg;
            _yf.shape        = 2;
            _yf.target_id    = noone;
            _yf.move_x       = _yf_dir * 8;
            _yf.move_y       = 0;
            _yf.image_angle  = 0;
            if (_yf_dir < 0) _yf.image_xscale = -1;
            _yf.sprite_index = spr_yufengma_bullet_2;
            _yf.can_dandantu_store = false;
            _yf.rows         = 0;            // 0 = 只打本行（有风扇的「大风」才拉 3 行）
            _yf.center_row   = _row;
            audio_play_sound(snd_shot, 0, 0);
            break;
        }

        // ── 巧克力炮：1 发，固定落本行第 9 列，3×3 爆炸（秒杀不防爆，原卡口径）──
        case "chocolate_cannon":
        {
            var _cc = instance_create_depth(x, y - 60, depth - 1, obj_chocolatecannon_bullet);
            _cc.target_col = min(8, global.grid_cols - 1);
            _cc.target_row = _row;
            _cc.damage     = _dmg;
            audio_play_sound(snd_throw, 0, 0);
            break;
        }

        // ── 红柳烤串机：1 发全屏追踪穿透肉串（陆 / 空 / 幽灵，BOSS 优先）──
        case "hongliukaochuan":
        {
            var _hl_hit = ["normal", "air", "invisible"];
            var _hl_t   = noone;
            var _hl_best = -infinity;
            if (variable_global_exists("enemy_by_type"))
            {
                for (var _hl_a = 0; _hl_a < array_length(_hl_hit); _hl_a++)
                {
                    var _hl_key = _hl_hit[_hl_a];
                    if (!variable_struct_exists(global.enemy_by_type, _hl_key)) continue;
                    var _hl_list = global.enemy_by_type[$ _hl_key];
                    for (var _hl_i = 0; _hl_i < array_length(_hl_list); _hl_i++)
                    {
                        var _hl_e = _hl_list[_hl_i];
                        if (!instance_exists(_hl_e) || _hl_e.hp <= 0) continue;
                        var _hl_s = -point_distance(x, y, _hl_e.x, _hl_e.y);
                        if (_hl_e.is_boss) _hl_s += 1000000;
                        if (_hl_s > _hl_best)
                        {
                            _hl_best = _hl_s;
                            _hl_t    = _hl_e;
                        }
                    }
                }
            }
            if (instance_exists(_hl_t))
            {
                var _hl_mx = x + 95;
                var _hl_my = y + 5;
                var _hl = instance_create_depth(_hl_mx, _hl_my, depth - 500, obj_hongliukaochuan_bullet);
                _hl.damage         = _dmg;
                _hl.base_atk       = _dmg;
                _hl.shape          = 2;
                _hl.target_id      = _hl_t.id;
                _hl.hittable_types = _hl_hit;

                var _hl_dx = _hl_t.x - _hl_mx;
                var _hl_dy = (_hl_t.y - 37) - _hl_my;     // 敌人原点在脚底，往身体抬 37
                var _hl_len = point_distance(0, 0, _hl_dx, _hl_dy);
                if (_hl_len > 0)
                {
                    _hl.move_x = (_hl_dx / _hl_len) * _hl.move_speed;
                    _hl.move_y = (_hl_dy / _hl_len) * _hl.move_speed;
                }
                _hl.image_angle = point_direction(0, 0, _hl.move_x, _hl.move_y);
                audio_play_sound(snd_shot, 0, 0);
            }
            break;
        }

        // ── 多拿滋：本行连续攻击，**优先空军**（本行有空军就打空，弹道抬高对齐）
        case "donut":
        {
            var _dn_air = noone;
            with (obj_enemy_parent)
            {
                if (hp <= 0) continue;
                if (target_type != "air") continue;
                if (grid_row != other.grid_row) continue;
                _dn_air = id;
                break;
            }

            var _dn_type = instance_exists(_dn_air) ? "air_only" : "normal";
            var _dn_oy   = -30;
            if (_dn_type == "air_only")
            {
                _dn_oy = -60;                       // 兜底：本行扫不到空军时的半身位
                if (instance_exists(_dn_air))
                    _dn_oy = ((_dn_air.bbox_top + _dn_air.bbox_bottom) * 0.5) - y;
            }

            var _dn = instance_create_depth(x + 20, y + _dn_oy, depth - 45, obj_donut_bullet);
            _dn.damage         = _dmg;
            _dn.move_speed     = 6;
            _dn.row            = _row;
            _dn.target_type    = _dn_type;
            _dn.hittable_types = get_hittable_enemy_types(_dn_type);
            _dn.shape          = 2;
            _dn.sprite_index   = spr_donut_bullet_2;

            audio_play_sound(snd_shot, 0, 0);
            if (_seq < 2) tx_queue(_id, _seq + 1, 6);   // 原卡一轮连射 3 发
            break;
        }

        // ── 章鱼烧：2 发追踪飞镖（第二发延迟 15 帧，照原卡二转）──
        case "takoyaki":
        {
            var _tk_t = tx_pick_row(_row, "track");
            for (var _tk_i = 0; _tk_i < 2; _tk_i++)
            {
                var _tk = instance_create_depth(x + (_tk_i * 40), y - 55, depth - 500, obj_takoyaki_bullet);
                _tk.damage          = _dmg;
                _tk.move_speed      = 10;
                _tk.target_enemy    = _tk_t;
                _tk.banding_card_obj = id;
                _tk.row             = _row;
                if (_tk_i == 1) _tk.timer = -15;
            }
            audio_play_sound(snd_shot, 0, 0);
            break;
        }

        // ── 工匠神·鲁班：河豚弹沿固定轨迹往返（终转口径 = 2 条横向 + 首两列 4 条竖向）──
        //   轨迹照原卡：①卡片→(最右列,1)→(最右列,4)；②卡片→(最右列,7)→(最右列,4)
        //   命中口径 all（陆/空/潜/钻/幽灵全吃），附带 20% 定身 + 30% 河豚毒
        case "gongjiang_god":
        {
            var _gj_right = combat_max_col();
            var _gj_top   = 0;
            var _gj_mid   = clamp(3, 0, global.grid_rows - 1);
            var _gj_bot   = clamp(6, 0, global.grid_rows - 1);

            var _gj_wp_top = get_world_position_from_grid(_gj_right, _gj_top);
            _gj_wp_top.y -= global.grid_cell_size_y / 2;      // 第 1 行取格子上顶点（同原卡）
            var _gj_wp_mid = get_world_position_from_grid(_gj_right, _gj_mid);
            var _gj_wp_bot = get_world_position_from_grid(_gj_right, _gj_bot);

            for (var _gj_d = 0; _gj_d < 2; _gj_d++)
            {
                var _gj = instance_create_depth(x, y, depth - 500, obj_gongjiang_god_bullet_horizontal);
                _gj.damage         = _dmg;
                _gj.move_speed     = 8;
                _gj.damage_type    = "normal";
                _gj.pierce_obstacle = true;   // 2026-11-10：与工匠神原卡一致（固定轨迹弹穿地形障碍）
                _gj.target_type    = "all";
                _gj.hittable_types = get_hittable_enemy_types("all");
                _gj.shape          = 3;
                _gj.origin_card_id = id;
                _gj.start_x        = x;
                _gj.start_y        = y;
                if (_gj_d == 0)
                {
                    _gj.wp1_x = _gj_wp_top.x;
                    _gj.wp1_y = _gj_wp_top.y;
                }
                else
                {
                    _gj.wp1_x = _gj_wp_bot.x;
                    _gj.wp1_y = _gj_wp_bot.y;
                }
                _gj.wp2_x = _gj_wp_mid.x;
                _gj.wp2_y = _gj_wp_mid.y;
                _gj.sprite_index   = spr_gongjiang_god_bullet_3;
                _gj.pin_chance     = 0.20;
                _gj.pin_duration   = 90;
                _gj.poison_chance  = 0.30;
                _gj.poison_spr     = spr_gongjiang_god_effect_3_2;
            }

            // 终转额外：第 1、2 列各上下一条竖弹
            for (var _gj_c = 0; _gj_c <= 1; _gj_c++)
            {
                var _gj_pos = get_world_position_from_grid(_gj_c, _gj_mid);
                for (var _gj_v = 0; _gj_v < 2; _gj_v++)
                {
                    var _gv = instance_create_depth(_gj_pos.x, _gj_pos.y, depth - 500, obj_gongjiang_god_bullet_vertical);
                    _gv.damage         = _dmg;
                    _gv.move_speed     = 8;
                    _gv.vertical_dir   = (_gj_v == 0) ? -1 : 1;
                    _gv.col            = _gj_c;
                    _gv.shape          = 3;
                    _gv.damage_type    = "normal";
                    _gv.pierce_obstacle = true;   // 2026-11-10：与工匠神原卡一致（固定轨迹弹穿地形障碍）
                    _gv.target_type    = "all";
                    _gv.hittable_types = get_hittable_enemy_types("all");
                    _gv.sprite_index   = spr_gongjiang_god_bullet_3;
                    _gv.image_angle    = (_gj_v == 0) ? 90 : 270;
                    _gv.pin_chance     = 0.20;
                    _gv.pin_duration   = 90;
                    _gv.poison_chance  = 0.30;
                    _gv.poison_spr     = spr_gongjiang_god_effect_3_2;
                }
            }

            audio_play_sound(snd_shot, 0, 0);
            break;
        }
    }
};

/// 铺毒雾：本行最右 _cells 格（照抄 obj_fashishe 的 fashishe_poison_at，1 秒 5 跳、每跳 = _dmg）
tx_poison_at = function(_row, _cells, _dmg)
{
    var _life     = 60;    // 1 秒
    var _interval = 12;    // 5 跳 → 0.2 秒一跳

    for (var _i = 0; _i < _cells; _i++)
    {
        var _c = (global.grid_cols - 1) - _i;
        if (_c < 0) continue;

        var _cell = get_world_position_from_grid(_c, _row);

        // spr_fashishe_burn_ground 画布 88×91，实心雾只有中间 69×58（中心 44.5, 53）→ 放大到整格
        var _fw = 69, _fh = 58, _fcx = 44.5, _fcy = 53;
        var _sx = global.grid_cell_size_x / _fw;
        var _sy = global.grid_cell_size_y / _fh;
        var _bx = _cell.x - (_fcx - sprite_get_xoffset(spr_fashishe_burn_ground)) * _sx;
        var _by = (_cell.y - 36) - (_fcy - sprite_get_yoffset(spr_fashishe_burn_ground)) * _sy;

        var _p = instance_create_depth(_bx, _by, -10 - _row * 45, obj_fashishe_poison_cell);
        _p.sprite_index      = spr_fashishe_burn_ground;
        _p.frame_start       = 0;
        _p.frame_end         = sprite_get_number(spr_fashishe_burn_ground) - 1;
        _p.anim_loop_frames  = 30;
        _p.damage            = _dmg;
        _p.damage_type       = "normal";
        _p.life              = _life;
        _p.tick_interval     = _interval;
        _p.lock_grid         = true;
        _p.grid_col          = _c;
        _p.grid_row          = _row;
        _p.hittable_types    = get_hittable_enemy_types("all");
        _p.extra_col_right   = (_i == 0) ? 1 : 0;    // 只有最右一格放宽到场外 1 格（BOSS 出生位）
        _p.image_xscale      = _sx;
        _p.image_yscale      = _sy;
    }
};

/// 飞一张卡面（桂花酒 wine / 逆转牛 cow）：从卡口沿本行往右飞，碰第一只可打老鼠后再结算
tx_alt_spawn = function(_mode, _row, _dmg)
{
    var _lane_y = get_world_position_from_grid(grid_col, _row).y;
    var _a = instance_create_depth(x + 45, _lane_y, depth - 500, obj_tianxie_alt);
    _a.alt_mode = _mode;
    _a.alt_row  = _row;
    _a.alt_dmg  = _dmg;
    audio_play_sound(snd_throw, 0, 0);
};
