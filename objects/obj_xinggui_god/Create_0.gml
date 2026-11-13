// obj_xinggui_god（星轨神·阿斯特 家族）Create 事件
// 增幅类・固定轨迹增幅（2026-11-13 新卡，素材 = 桌面\皮特\11月份做卡11.12\spr-xinggui-god）
//   官方口径（米苏.jpg + 数据信息.xlsx 第 76~100 行）：
//     耗能 345 / 范围 5*5 / 全天 / 金卡；星级强化 = 增幅倍率，技能强化 = 冷却时间。
//     基础能力：为范围内固定轨迹类卡片提高攻击力，同类卡片效果不叠加。
//     三转：无需格子就可以放置卡片（→ plant_type = "gridless"）
//     四转：每多放置 1 张卡攻击力提升 1 次，提升上限 3 次（每张 +0.7，最多 +2.1）
//     终转：场上任意放置 4 张卡后即可全屏增幅，攻击力再次提升（换用终转倍率表）
//
//   形态：0 阿斯特神使 / 1 阿斯特圣神（三转）/ 2 星轨神·阿斯特（四转）/ 3 至尊星轨神（终转）
//   倍率直接写在注册表的 atk 里（1.7 → 9），读法与音盒马 / 浮生茶完全一致：
//     get_plant_data_with_skill(plant_id, shape, current_level, skill)[? "atk"]
//   之所以不用实例 atk：这个实例的 atk 本身由 obj_mod_battle_manager 重算，拿它当倍率会自我叠乘。
event_inherited();

plant_id = "xinggui_god";
obj_type = object_index;
xinggui_initializing = true;
event_user(0);            // 父类属性初始化（Other_10 里 xinggui_initializing 为真时委托给父类）
xinggui_initializing = false;

if (shape == 0)      sprite_index = spr_xinggui_god;
else if (shape == 1) sprite_index = spr_xinggui_god_1;
else if (shape == 2) sprite_index = spr_xinggui_god_2;
else                 sprite_index = spr_xinggui_god_3;

// 三转（shape 1）起变为悬浮卡，不占格；放置判定见 can_place_at_position 的 gridless 分支
plant_type   = (shape >= 1) ? "gridless" : "normal";
feature_type = "normal";
is_slowdown  = false;
image_speed  = 0;      // 帧由父对象 timer 按 flash_speed 推，自己再自动播会双倍速
flash_speed  = 4;

// 素材 15 帧全是上下浮动循环（无攻击帧）：idle 0..14
idle_anim   = 14;
attack_anim = 0;
state       = CARD_STATE.IDLE;

// ── 增幅参数（要调能力只动这几行）────────────────────────────────────
xg_range            = 2;     // 5*5 = 中心 ±2 格
xg_stack_step       = 0.7;   // 四转起：每多 1 张星轨神倍率 +0.7
xg_stack_cap        = 2.1;   // 上限 +2.1（= 3 次）
xg_fullscreen_need  = 4;     // 终转：场上 4 张星轨神起全屏

xg_age        = 0;
xg_fullscreen = false;
xg_corner_effects = [];

// 常驻光环（射程框）：0 转也画 5*5，形态只换配色
xg_halo = noone;
var _halo_spr = spr_xinggui_god_effect;
if (shape == 1)      _halo_spr = spr_xinggui_god_effect_1;
else if (shape == 2) _halo_spr = spr_xinggui_god_effect_2;
else if (shape >= 3) _halo_spr = spr_xinggui_god_effect_3;

// 常驻光环图层：与海洋女神 / 丰饶神 / 时间神 的光环**同层 = depth 0**。
// 深度越小越靠前：手牌卡槽 obj_card_slot 是 depth = -slot_index - 1000（-1000 起），
// 卡片本体 calculate_plant_depth 在 -10 ~ -330。
// 原来写 -2500 会压在卡槽和整个 HUD 之上（底行卡片的 5*5 框一直盖住手牌），
// 2026-11-13 用户反馈改为与其它神卡一致的地面层，落在卡槽之下、卡片之下。
xg_halo = instance_create_depth(x, y, 0, obj_xinggui_god_effect);
xg_halo.sprite_index = _halo_spr;
xg_halo.image_index  = 0;
xg_halo.image_speed  = 0.5;
// 光环精灵是「淡入 0~2 → 常亮 3~13 → 淡出 14~16 → 17 全透明」的一次性脉冲，
// 循环播会变成一闪一闪；播到第 10 帧（常亮段中部）就锁死，特效此后一直亮着。
xg_halo.xg_hold_frame = 10;
// 光环是「四角括号框」（中间空），要让它正好框住 5*5 格区。
//
// 🔴 缩放基准必须是「括号视觉框」，不能用 bbox：
//   bbox 会被四角星芒 / 光晕撑大，而且**形态越高撑得越多**（shape0 只多 15%，shape2 多 42%），
//   按 bbox 算的结果就是「形态越高、框越小」——用户 2026-11-13 22:00 三张截图：
//   shape2 只有 4.2 格、shape1 5.0 格、shape0 5.2 格，所以单看 shape2 的框明显比红色边框小一圈。
//
// 视觉框的取法：把常亮帧（xg_hold_frame = 10）摊成 alpha 掩码，统计每一行 / 每一列的不透明像素数，
// **像素最多的那一行 / 那一列就是四角括号的臂**，臂的跨度就是玩家眼里的「框」。
// 量测脚本：tools/measure_xinggui_halo.py（换素材后重跑一次，把下表更新掉）
//   shape0    x  9..303 / y  8..320  → 295 x 313   （bbox 311x327，星芒各多出 5%）
//   shape1    x 13..319 / y  9..332  → 307 x 324   （bbox 325x334，多 6%）
//   shape2/3  x 51..356 / y 57..375  → 306 x 319   （bbox 392x370，多 28% / 16%）
// 三个形态的臂跨度几乎一样（295~307 x 313~324）＝ 美术本来就画成同一尺寸，
// 所以按视觉框缩放之后三者视觉大小完全一致。
// 视觉框中心与精灵原点（画布中心）重合，直接按原点缩放即可，位置不用补偿。
var _vis_w = 295, _vis_h = 313;
if (shape == 1)      { _vis_w = 307; _vis_h = 324; }
else if (shape >= 2) { _vis_w = 306; _vis_h = 319; }
// 严格 5*5（情报范围），不额外外扩 —— 臂外沿正好压在 5*5 的格线上
var _span_x = (xg_range * 2 + 1) * global.grid_cell_size_x;
var _span_y = (xg_range * 2 + 1) * global.grid_cell_size_y;
xg_halo.image_xscale = _span_x / _vis_w;
xg_halo.image_yscale = _span_y / _vis_h;

if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
