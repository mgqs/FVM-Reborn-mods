if (global.is_paused) exit;

// 没被激活 → 一直隐形（电鳗放下后、两次放电之间都不该看到电弧）
if (!active){
    image_alpha = 0;
    exit;
}

// 激活后从第 1 帧播到最后一帧（2 帧/张 ≈ 0.43 秒），播完自己熄掉
var _last = sprite_get_number(sprite_index) - 1;
anim_t++;
image_index = min(anim_t div 2, _last);
image_alpha = 0.85;

if (anim_t >= _last * 2){
    active = false;
    image_alpha = 0;
}
