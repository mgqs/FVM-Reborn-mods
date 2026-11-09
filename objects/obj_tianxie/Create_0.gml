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
    _fx.fx_ground_y   = _cell0.y + 40 - 34 * tianxie_needle_scale - tianxie_art_up;

    audio_play_sound(snd_shot, 0, 0);
};
