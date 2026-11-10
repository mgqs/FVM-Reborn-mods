// obj_tianxie_needle Step 事件
// 两个阶段（2026-11-09 用户：尖刺太快了，**按正常平射口径**飞）：
//   ① 飞行段：素材定格在「针飞出去」那张（第 6 帧），实体按 fx_move_speed 直线飞向落点 —— 速度与平射子弹同量级，
//      不再用「6 帧内从出弹口瞬移到目标」那种一帧 100+ 像素的滑行。
//   ② 落地段：到达落点后从第 7 帧开始播「依次冒白烟 → 四针立住」，第 7/11/13/15 帧逐格结算。
//   ③ 播完（第 23 帧）自毁，顺手销毁 fx_hit 列表。
if (global.is_paused) exit;

if (!fx_ready)
{
    fx_ready = true;
    if (array_length(fx_landed) != fx_cells) fx_landed = array_create(fx_cells, false);
    // 目标在出弹口左边（打自身格 / 身后）时没有可飞的距离 → 直接贴上去，别倒着飞
    if (fx_land_x <= fx_from_x) fx_from_x = fx_land_x;
    fx_fly_x = fx_from_x;
}

y = fx_ground_y;

// ── ① 飞行段：定帧 + 匀速前推，这一段不结算伤害 ──
if (!fx_arrived)
{
    image_index = fx_fly_anim;
    fx_fly_x += fx_move_speed;
    if (fx_fly_x >= fx_land_x)
    {
        fx_fly_x  = fx_land_x;
        fx_arrived = true;
        fx_t       = 0;
    }
    x = fx_fly_x;
    // 纵向：**不做任何升降** —— y 在函数开头就固定成 fx_ground_y（= 出弹口高度），
    //   走一条水平直线，到老鼠面前也不会突然下沉（2026-11-09 用户口径）
    exit;
}

// ── ② 落地段：从第 7 帧播到第 23 帧，逐针结算 ──
fx_t++;
var _idx = fx_land_anim + fx_t - 1;

for (var _k = 0; _k < fx_cells; _k++)
{
    if (fx_landed[_k]) continue;
    var _sf = fx_stick_frames[min(_k, array_length(fx_stick_frames) - 1)];
    if (_idx < _sf) continue;
    fx_landed[_k] = true;
    fx_hit_cell(fx_col0 + _k);
}

// ③ 播完自毁
if (_idx >= sprite_get_number(sprite_index))
{
    ds_list_destroy(fx_hit);
    instance_destroy();
    exit;
}

x = fx_land_x;
image_index = _idx;
