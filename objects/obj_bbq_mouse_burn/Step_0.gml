// obj_bbq_mouse_burn Step 事件
// 跟着老鼠走：位置对齐目标、depth 压到老鼠下面一层；life 帧后自动消失（目标死亡/离场也消失）。
if (global.is_paused) exit;

if (!instance_exists(target))
{
    instance_destroy();
    exit;
}

if (fx_spr != -1 && sprite_index != fx_spr) sprite_index = fx_spr;

x = target.x;
y = target.y - y_off;
depth = target.depth - 1;

t++;

// 把整个精灵的帧均匀铺到 life 帧上（素材 21 帧 / 1 秒）
var _n = sprite_get_number(sprite_index);
if (_n > 0)
{
    image_index = (t * _n) div max(1, life);
    if (image_index > _n - 1) image_index = _n - 1;
}

if (t >= life) instance_destroy();
