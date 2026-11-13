// 宝石冷却就绪闪光（2026-11-13）：12 帧贴图均摊到 180 帧（3 秒），播完自毁
if (global.is_paused) exit;

timer++;
var _n = sprite_get_number(sprite_index);
if (_n > 0) image_index = floor(timer * _n / GEM_FLASH_DURATION);

if (timer >= GEM_FLASH_DURATION) {
    instance_destroy();
    exit;
}
