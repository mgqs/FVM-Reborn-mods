var row_offset = 1;
var col_offset = (shape >= 2) ? 2 : 1;

if (shape == 2)
    row_offset = 2;
else if (shape == 3)
    row_offset = 3;

// 先把「这一下打死了谁」收集起来，统一在循环外生成骨灰。
// 原来是在 with 里 event_user(0) 之后直接 instance_create + instance_destroy()（火焰自毁）：
//   · 火焰在 with 还没走完时就没了，后面的老鼠再读 other.grid_col 就是访问已销毁实例；
//   · 受击回调里老鼠自己也可能被销毁（BOSS 交接 / 词条致死保护等），再去读 hp 同样报错。
// 玩家看到的就是「火焰一烧死老鼠就崩」。先收集、后处理，两个坑一起绕开。
var _dead = [];
with (obj_enemy_parent)
{
    if (grid_col >= (other.grid_col - col_offset) && grid_col <= (other.grid_col + col_offset) && abs(grid_row - other.grid_row) <= row_offset && can_hit(other.target_type, target_type) && hp > 0)
    {
        var _me = id;
        var _prev_hp = hp;
        damage_amount = other.damage * other.stack_count;
        damage_type = other.damage_type;
        event_user(0);

        // 受击回调里可能直接把这具老鼠销毁，之后再读 hp 就是访问已销毁实例
        if (!instance_exists(_me)) continue;
        if (_prev_hp > 0 && hp <= 0)
        {
            // 注意：这里在 with (obj_enemy_parent) 内，火焰自身的属性必须走 other.，
            // 直接写 shape 会去读敌人身上不存在的变量 → obj_normal_mouse.shape not set 崩溃
            array_push(_dead, {
                px:  x,
                py:  y,
                pd:  depth,
                psp: sprite_index,          // 老鼠的贴图：骨灰沿用它的样子
                pidx: image_index,
                pbig: (other.shape >= 2)    // 火焰的星级决定是不是「特殊骨灰」
            });
        }
    }
}

for (var i = 0; i < array_length(_dead); i++)
{
    var _d = _dead[i];
    var _ash = instance_create_depth(_d.px, _d.py - 20, _d.pd, obj_mouse_ash_death);
    if (_d.pbig)
    {
        _ash.special_ash   = true;
        _ash.sprite_index  = _d.psp;
        _ash.image_index   = _d.pidx;
    }
}

// 火焰不再「烧死一只就自毁」：它有自己的存活时间（hex_life / sprite 帧数），
// 由 Step_0 负责倒计时销毁。原来一有击杀就 instance_destroy()，
// 以我残躯化烈火的「10 秒火焰」实际只烧了一下就没了。
