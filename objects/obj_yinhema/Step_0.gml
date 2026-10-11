if (global.is_paused) exit;
event_inherited();
if (hp <= 0) exit;

zodiac_age++;
// 光环特效跟随卡片
for (var i = 0; i < array_length(zodiac_effects); i++) {
    var e = zodiac_effects[i];
    if (instance_exists(e)) {e.x = x; e.y = y;}
}
// 每5帧触发一次增幅范围内卡片的增幅重算
if (zodiac_age mod 5 == 0 && variable_global_exists("buff_apply_id")) global.buff_apply_id++;
