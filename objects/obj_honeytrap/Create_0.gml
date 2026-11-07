// obj_honeytrap（蜜糖陷阱 / 香浓蜜糖陷阱 / 王冠蜜糖陷阱）Create 事件
// 追踪类·集火追踪 · 普卡（2026-11-07 新卡，照仙笛马口径）
//   不占格；每 cycle/3 秒攒 1 只蜜蜂，攒满 3 只（二转 6 只）后一起飞出，先打 BOSS 再打当前血量最高的。
//   一转起对 BOSS 造成 2 倍基础伤害。
event_inherited();

plant_id = "honeytrap";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_honeytrap;
else if (shape == 1) sprite_index = spr_honeytrap_1;
else                 sprite_index = spr_honeytrap_2;

plant_type   = "gridless";
feature_type = "normal";
target_type  = "track";
is_slowdown  = false;
image_speed  = 0;
flash_speed  = 5;

attack_timer = 0;
state        = CARD_STATE.IDLE;
remove_timer = 0;   // 同格去重（照麦芽糖）：第 1 帧把同格其它蜜糖陷阱清掉

// 动画：全待机，没有攻击段（同仙笛马）
attack_anim = 0;
idle_anim   = sprite_get_number(sprite_index)-1;

max_bees  = 3;                      // 固定 3 只（2026-11-08 用户口径：二转不再 +3，改成攻击力翻倍）
boss_mult = (shape >= 1) ? 2 : 1;   // 一转起对 BOSS 2 倍

bees = [];
