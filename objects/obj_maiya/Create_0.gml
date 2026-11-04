// obj_maiya（麦芽糖）Create 事件
// 形态：0 麦芽糖 / 1 莓莓麦芽糖（各 18 帧）
//   帧 1~3（index 0~2）变身；帧 4（index 3）过渡；帧 5~11（index 4~10）待机；帧 12~18（index 11~17）损坏
// 素材：spr_maiya / spr_maiya_1（气泡特效 spr_maiya_bubble 已于 2026-11-04 清理移除）
// 数值：数据.xlsx「通用②」36000→125000，耗能 55（一转 0），冷却 7/6.5/6/5.5/5/4.5/4/3.5/3 秒
// 能力：同格卡片的海底 + 岩浆承载（不补云）；本体 dwarf → 老鼠无视（巨人除外），不会被啃
event_inherited();
plant_id = "maiya";
obj_type = object_index;
event_user(0);

plant_type = "coffee";
feature_type = "dwarf";
provides_bubble = true;
provides_lava = true;
on_lava = false;
remove_timer = 0;

if (shape <= 0) sprite_index = spr_maiya;
else            sprite_index = spr_maiya_1;

image_speed = 0;
flash_speed = 6;

TRANS_LAST   = 2;
IDLE_FIRST   = 4;
IDLE_LAST    = 10;
BROKEN_FIRST = 11;
BROKEN_LAST  = 17;

TRANS_TICKS  = 4;
IDLE_TICKS   = 6;
BROKEN_HP    = 0.5;

anim_t = 0;

idle_anim = IDLE_LAST;
attack_anim = 0;
