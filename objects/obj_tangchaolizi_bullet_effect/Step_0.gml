// obj_tangchaolizi_bullet_effect（落地灼烧）Step 事件
// 帧段按精灵总帧数推（0 转 32 帧 / 1·2 转 36 帧）：
//   8~13 爆开（5 步一帧）→ 14~倒数第2帧 燃烧（摊满 10 跳 × 0.2s = 120 步）→ 最后一帧空帧
// 灼烧每 12 步（0.2s）结算一次，共 10 次。
if (global.is_paused) exit;

timer++;

var _total = sprite_get_number(sprite_index);
var _boom      = 8;                 // 爆开起始帧
var _burn_from = 14;                // 火焰起始帧
var _burn_to   = _total - 2;        // 末尾 1 帧是空帧
var _fs        = 5;                 // 非燃烧帧速
var _pre       = (_burn_from - _boom) * _fs;    // 爆开段 30 步
var _burn_ticks = 12 * 10;                      // 10 跳 × 0.2s
var _burn_frames = _burn_to - _burn_from + 1;

if (timer <= _pre)
    image_index = _boom + (timer - 1) div _fs;
else if (timer <= _pre + _burn_ticks)
    image_index = _burn_from + ((timer - _pre - 1) * _burn_frames) div _burn_ticks;
else
    image_index = _burn_to + 1 + (timer - _pre - _burn_ticks - 1) div _fs;

if (image_index >= _total) image_index = _total - 1;

// 灼烧结算：燃烧段内每 12 步一跳
var _bt = timer - _pre;
if (_bt >= 1 && _bt <= _burn_ticks && ((_bt - 1) div 12) != (_bt div 12))
    event_user(0);

if (timer > _pre + _burn_ticks + (_total - 1 - _burn_to + 1) * _fs)
    instance_destroy();
