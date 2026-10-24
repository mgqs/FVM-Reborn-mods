// obj_fushengcha（浮生茶）Step 事件
// 只做两件事：光环跟随本体、周期性触发全卡增幅重算。
// 本体不索敌、不攻击，动画停在闲置循环。
if (global.is_paused) exit;
event_inherited();
if (hp <= 0) exit;

fushengcha_age++;

// 光环特效跟随卡片（含被移动板块/铲子挪动的情况）
for (var i = 0; i < array_length(fushengcha_effects); i++) {
    var _e = fushengcha_effects[i];
    if (instance_exists(_e)) { _e.x = x; _e.y = y; }
}

// 每 5 帧触发一次增幅重算（与音盒马同频），让范围内卡片及时读到最新倍率
if (fushengcha_age mod 5 == 0 && variable_global_exists("buff_apply_id")) global.buff_apply_id++;
