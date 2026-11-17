// obj_water_god Step 事件
// 待机循环交给父对象（第 1~13 帧）；被反弹时播一遍第 14~18 帧再回待机
if (global.is_paused)
    exit;

event_inherited();

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

// ── 反弹动作：wg_reflect_t 由 mod_bullet_hazard 的反弹处置 1，这里自己推帧 ──
if (wg_reflect_t > 0)
{
    var _li = floor((wg_reflect_t - 1) / wg_anim_step);      // 0 ~ attack_anim-1
    if (_li >= attack_anim)
    {
        wg_reflect_t = 0;
        image_index  = 0;                                     // 回待机首帧
    }
    else
    {
        image_index   = idle_anim + 1 + _li;
        wg_reflect_t++;
    }
}
