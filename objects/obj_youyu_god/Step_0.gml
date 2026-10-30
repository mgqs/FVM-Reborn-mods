if (global.is_paused)
    exit;

event_inherited();

if (is_frozen)
    exit;

var current_flash_speed = flash_speed;
if (is_slowdown)
    current_flash_speed *= 2;

// 索敌：三级判定 —— 便宜的粗筛尽量剔除，只有「可能命中」的敌人才走精确判定
//   口径与开火脚本 Other_11.gml 完全一致：弹口 (x+7, y-44)、方向同一张表、
//   射程 = max_life 600 帧 × move_speed 8 px/帧 = 4800px
//   ① 类型筛：只认 global.enemy_by_type 里的 normal（鱿鱼只打陆地鼠，无对空 / 幽灵能力）
//   ② 粗筛（廉价且保守放宽，绝不漏判）：射程外 / 格子比例带之外 直接丢弃
//   ③ 精确：射线与敌人 bbox 的 slab 相交
//   ★ 性能：射线单位向量每帧只算一次（sin/cos 不进敌人循环），
//     粗筛让绝大多数敌人只花 ~10 次运算；旧写法每帧每敌人要算 ~20 次三角函数
var _hittable = ["normal"];

var _mx = x + 7;
var _my = y - 44;
var _ray_len = 4800;
var _ray_len_sq = _ray_len * _ray_len;

// 方向表 / 单位向量（与 Other_11 的 _angles 同源；shape2 起 ±45° 换成 ±30° / ±60°）
var _angles = (shape >= 2)
    ? [0, 30, 60, 90, 135, 180, 225, 270, 300, 330]
    : [0, 45, 90, 135, 180, 225, 270, 315];
var _na = array_length(_angles);
var _ux = array_create(_na);
var _uy = array_create(_na);
for (var _a = 0; _a < _na; _a++)
{
    _ux[_a] = lengthdir_x(1, _angles[_a]);
    _uy[_a] = lengthdir_y(1, _angles[_a]);
}

var has_enemy = false;
if (variable_global_exists("enemy_by_type"))
{
    // 长度先取出来：GML 的 for 条件每轮都会重新求值，内联 array_length 会变成逐敌人一次函数调用
    // ⚠️ 变量名必须与内层 slab 用的 _t_in / _t_out 区分：GML 的 var 是**事件级作用域**、不分块，
    //    同名会互相覆盖（曾误用 _tn 同时当「类型表长度」与「射线进入参数」，把循环上界冲掉 → _hittable 越界）
    var _type_n = array_length(_hittable);
    for (var _t = 0; _t < _type_n && !has_enemy; _t++)
    {
        var _key = _hittable[_t];
        if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
        var _list = global.enemy_by_type[$ _key];
        var _ln = array_length(_list);
        for (var _i = 0; _i < _ln && !has_enemy; _i++)
        {
            var _e = _list[_i];
            if (!instance_exists(_e) || _e.hp <= 0) continue;

            // ② a：射程外（比平方，省一次开方）
            var _ddx = _e.x - _mx;
            var _ddy = _e.y - _my;
            if (_ddx * _ddx + _ddy * _ddy > _ray_len_sq) continue;

            // ② b：格子比例带 —— 同行 / 同列一律放行；其余要求
            //       横向格数 ÷ 纵向格数 ∈ [0.35, 2.6]（覆盖 30°/45°/60° 三条斜线并留冗余）
            var _drow = _e.grid_row - grid_row;
            var _dcol = _e.grid_col - grid_col;
            if (_drow != 0 && _dcol != 0)
            {
                var _ratio = abs(_dcol) / abs(_drow);
                if (_ratio < 0.35 || _ratio > 2.6) continue;
            }

            // ③ 精确：射线 × 碰撞框
            var _bl = _e.bbox_left;
            var _br = _e.bbox_right;
            var _bt = _e.bbox_top;
            var _bb = _e.bbox_bottom;
            if (_br <= _bl || _bb <= _bt)
            {
                // 碰撞框退化时用合成框兜底
                _bl = _e.x - 30;
                _br = _e.x + 30;
                _bt = _e.y - 80;
                _bb = _e.y;
            }

            // 圆心取碰撞框中心，半径取「半宽 + 半高」—— 恒 ≥ 半对角，保证圆一定包住碰撞框，
            // 所以后面用它做粗挡绝不会把真的命中挡掉
            var _ex = (_bl + _br) * 0.5 - _mx;
            var _ey = (_bt + _bb) * 0.5 - _my;
            var _rad = ((_br - _bl) + (_bb - _bt)) * 0.5;

            for (var _r = 0; _r < _na; _r++)
            {
                // 圆近似粗挡（~5 次运算）：背后 / 超出射程 / 离射线太远 → 直接看下一条
                var _proj = _ex * _ux[_r] + _ey * _uy[_r];
                if (_proj < -_rad || _proj > _ray_len + _rad) continue;
                if (abs(_ex * _uy[_r] - _ey * _ux[_r]) > _rad) continue;

                // slab 精确相交
                var _t_in = 0;         // 进入框的参数
                var _t_out = _ray_len; // 离开框的参数
                var _hit = true;

                if (abs(_ux[_r]) < 0.00001)
                {
                    if (_mx < _bl || _mx > _br) _hit = false;
                }
                else
                {
                    var _tx1 = (_bl - _mx) / _ux[_r];
                    var _tx2 = (_br - _mx) / _ux[_r];
                    _t_in = max(_t_in, min(_tx1, _tx2));
                    _t_out = min(_t_out, max(_tx1, _tx2));
                }

                if (_hit)
                {
                    if (abs(_uy[_r]) < 0.00001)
                    {
                        if (_my < _bt || _my > _bb) _hit = false;
                    }
                    else
                    {
                        var _ty1 = (_bt - _my) / _uy[_r];
                        var _ty2 = (_bb - _my) / _uy[_r];
                        _t_in = max(_t_in, min(_ty1, _ty2));
                        _t_out = min(_t_out, max(_ty1, _ty2));
                    }
                }

                if (_hit && _t_in <= _t_out)
                {
                    has_enemy = true;
                    break;
                }
            }
        }
    }
}

if (has_enemy)
{
    attack_timer++;

    // 攻击段长度按 attack_anim 算：ATTACK 段 = attack_anim × flash_speed 帧
    // （父对象每 flash_speed 帧推进 1 个 image_index，故这样能完整播完 sprite 第 14~24 帧）
    if (attack_timer >= (cycle - attack_anim * current_flash_speed))
        state = CARD_STATE.ATTACK;

    // 开火：绑在攻击动画第 20 帧（image_index 19）—— 一次攻击动画只开火一次，
    // 全部子弹在这一次 event_user(1) 里吐出（多方向 / 多发的错帧由 Other_11 的 delay 负责）
    // 用 fired_this_attack 兜住：image_index 会在 19~23 区间停留多个 flash_speed 帧
    if (state == CARD_STATE.ATTACK && !fired_this_attack && image_index >= 19)
    {
        fired_this_attack = true;
        event_user(1);
    }

    if (attack_timer > cycle)
    {
        attack_timer = 0;
        fired_this_attack = false;
        state = CARD_STATE.IDLE;
    }
}
else
{
    attack_timer = 0;
    fired_this_attack = false;
    state = CARD_STATE.IDLE;
}
