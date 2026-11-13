// 宝石冷却就绪闪光（2026-11-13）
// 贴图 spr_gem_cooldown_flash：12 帧 270×250，按 3 格 × 3 格铺开（网格 107×116）
image_speed = 0;
image_index = 0;
timer = 0;

var _w = sprite_get_width(sprite_index);
var _h = sprite_get_height(sprite_index);
if (_w > 0) image_xscale = (107 * GEM_FLASH_CELLS) / _w;
if (_h > 0) image_yscale = (116 * GEM_FLASH_CELLS) / _h;
