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

xg_halo = instance_create_depth(x, y, -3000, obj_xinggui_god_effect);
xg_halo.sprite_index = _halo_spr;
xg_halo.image_index  = 0;
xg_halo.image_speed  = 0.5;
// 光环比精灵原始尺寸放大到正好铺满 5*5（格心为中心，所以按格数换算即可）
xg_halo.image_xscale = (xg_range * 2 + 1) * global.grid_cell_size_x / sprite_get_width(_halo_spr);
xg_halo.image_yscale = (xg_range * 2 + 1) * global.grid_cell_size_y / sprite_get_height(_halo_spr);

if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
