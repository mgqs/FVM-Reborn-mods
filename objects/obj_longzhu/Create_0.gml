/// 龙柱：关卡障碍物（悬浮 = 未封印 / 插地 = 被「桥头米线」封印）
/// 种类由 longzhu_setup() 指定；机制实现见 scripts/longzhu/longzhu.gml
col = -1;
row = -1;

longzhu_kind = longzhu_kind_for_level();
longzhu_anims = longzhu_pillar_anims(spr_longzhu_cheng);
longzhu_action = "";
longzhu_frame = 0;
longzhu_once = false;
longzhu_timer = 0;

longzhu_sealed = false;         // 当前是否处于封印（插地）态
longzhu_force_sealed = false;   // 可被米线/关卡强制封印
longzhu_ready = false;          // 出生动画播完后才开始周期效果
longzhu_effect_timer = 0;

longzhu_bridge_touch = false;   // 本步是否被米线触碰
longzhu_bridge_owner = noone;   // 触碰它的米线拥有者

sprite_index = longzhu_pillar_sprite(longzhu_kind);
image_speed = 0;
image_index = 0;
image_xscale = LONGZHU_SCALE;
image_yscale = LONGZHU_SCALE;
depth = LONGZHU_PILLAR_BASE_DEPTH;

longzhu_setup(id, longzhu_kind);
