// obj_yinyangshe（阴阳蛇 / 一转 / 二转）Create 事件
// 直射类·传统直线类（2026-11-18 新卡，素材 = res1118\11月份做卡11.14\spr-yinyangshe）
//   官方口径（数据信息.xlsx Sheet1 第 29~37 行）：
//     耗能 295 / 子弹数 5 / 10 / 10 / 子弹皆可反弹、可过火
//     0 转：只有阴蛇，一次 5 连发，第一发带毒
//     1 转：多一只阳蛇，阳蛇也发 5 连（普通弹）→ 一轮 10 发
//     2 转：阳蛇改成穿透弹，阴蛇的毒伤提到 4.5 倍
//     阴蛇可直接攻击未照明的幽灵鼠
//     毒伤 = 攻击力 × 火盆倍率 × 3 / 3 / 4.5
//   攻击间隔 2.2 / 2.15 / … / 1.5 秒写在 mod_skill_init 的 9 档技能表里，
//     父对象 event_user(0) 会把它写进 cycle，这里直接用 cycle。
event_inherited();

plant_id = "yinyangshe";
obj_type = object_index;
event_user(0);

if (shape == 0)
    sprite_index = spr_yinyangshe;
else if (shape == 1)
    sprite_index = spr_yinyangshe_1;
else
    sprite_index = spr_yinyangshe_2;

// 素材 22 帧（三个形态都是这个结构）—— SWF 的 FrameLabelTag 写得很清楚：
//   frame 1 「待机」… frame 12 待机段结束，frame 13 「攻击」… frame 22 攻击段结束
//   → 待机 idx 0..11（12 帧）、攻击 idx 12..21（10 帧）。
//   父对象 IDLE 段在 0..idle_anim 之间循环、ATTACK 段在 idle_anim+1..idle_anim+attack_anim
//   之间循环（obj_card_parent/Step_0:281-289），所以两个字段必须按「段末下标 / 段长」填：
//   idle_anim = 段末下标 11，attack_anim = 段长 10。
//   🔴 2026-11-18 修正：之前误判成「22 帧全是待机」，把攻击段也当待机播了。
idle_anim    = 11;
attack_anim  = 10;
state        = CARD_STATE.IDLE;
attack_timer = 0;
yy_anim_hold = 0;        // 攻击动画还要保持 ATTACK 态的剩余帧
image_speed  = 0;        // 🔴 必须 0：帧由父对象 timer 推
flash_speed  = 5;
is_slowdown  = false;

// ── 出弹时刻：攻击动画播到「吐出去」那一帧才发弹 ─────────────────────────
//   素材攻击段（第 13~22 帧）逐帧差分 + 头部放大后的结论：
//     16 帧低头蓄力（嘴闭合）→ 17 帧抬头张嘴起手 → **18 帧甩头吐出**（相邻帧差分 2960 像素，
//     是攻击段最大峰值；非透明区域右缘从 77 一下扩到 91）。
//   所以不数固定帧数，直接盯 image_index：父对象在 ATTACK 态下每 flash_speed 帧推一格
//   （obj_card_parent/Step_0:286-289），image_index = 17 就是素材第 18 帧。
yy_fire_frame = 17;      // 素材第 18 帧（0-based）
yy_fire_delay = 90;      // 兜底：动画被卡 / 减速态 60 帧才到 17，等到这个上限也照发，避免整轮空转
yy_charge     = 0;       // > 0 = 已起手，还等着「吐」的那一下

plant_type   = "normal";
feature_type = "normal";
// 卡片侧索敌用穿透口径（= 陆鼠 + 非主流 + 障碍 + 未显形幽灵），
// 「阴蛇能打幽灵」就靠这一行；阳蛇子弹在子弹对象里自己收窄成 normal
target_type  = "pierce";

// ── 弹序 / 伤害口径 ───────────────────────────────────────────────────────
yy_shot_count_yin = 5;                          // 阴蛇每轮 5 发
yy_shot_count_yang = (shape >= 1) ? 5 : 0;      // 1 转起多一只阳蛇
yy_pierce_yang = (shape >= 2);                  // 2 转阳蛇穿透
yy_poison_mult = [3, 3, 4.5][min(shape, 2)];    // 毒伤倍率（0/1 转 3，2 转 4.5）
yy_shot_gap    = 6;                             // 同一轮内每发间隔帧（60 帧/秒下 ≈ 0.1 秒）
yy_bullet_speed = 10;
yy_end_col     = global.grid_cols + 1;

yy_bullet_yin  = spr_yinyangshe_bullet_yin;
yy_bullet_yang = spr_yinyangshe_bullet_yang;

yy_burst      = [];     // 待发队列 [{kind, poison}, ...]
yy_burst_gap  = 0;

/// 本行前方（含自身格）有没有可打目标
yy_has_target = function()
{
    var _hit = false;
    with (obj_enemy_parent)
    {
        if (hp > 0
            && variable_instance_exists(id, "grid_row")
            && variable_instance_exists(id, "grid_col")
            && variable_instance_exists(id, "target_type")
            && grid_row == other.grid_row
            && grid_col >= other.grid_col
            && grid_col <= global.grid_cols + 1
            && can_target_on(other.target_type, target_type))
        {
            _hit = true;
            break;
        }
    }
    return _hit;
};

/// 出一发子弹
/// _kind   0 = 阴蛇（带毒）、1 = 阳蛇
/// _poison 这一发是否附带毒伤
yy_fire = function(_kind, _poison)
{
    // 出膛口按两条蛇的位置错开：阴蛇在左下、阳蛇在右上。
    // 按精灵画布比例算，三个形态（93×70 / 108×84 / 114×95）都能落在嘴边；
    // 写死常数的话二转（114×95）的弹会在蛇脖子以下冒出来。
    var _w = sprite_get_width(sprite_index);
    var _h = sprite_get_height(sprite_index);
    var _dx = (_kind == 0) ? -0.28 * _w : 0.31 * _w;
    var _dy = (_kind == 0) ? -0.74 * _h : -0.76 * _h;

    var _b = instance_create_depth(x + _dx, y + _dy, depth - 500, obj_yinyangshe_bullet);
    _b.sprite_index  = (_kind == 0) ? yy_bullet_yin : yy_bullet_yang;
    _b.row           = grid_row;
    _b.yy_kind       = _kind;
    _b.damage        = atk;
    _b.move_speed    = yy_bullet_speed;
    _b.end_col       = yy_end_col;
    // 阴蛇穿透口径（含未显形幽灵）；阳蛇按官方口径只打常规目标
    _b.target_type   = (_kind == 0) ? "pierce" : "normal";
    _b.yy_pierce     = (_kind == 1 && yy_pierce_yang);
    _b.yy_poison     = _poison;
    _b.yy_poison_mult = yy_poison_mult;
};
