// obj_yuansushe_bullet Step 事件
// 移动只看 move_speed 的符号（正 = 向右，被反弹后为负 = 向左），
// 命中一律按「行 + 列 + 目标类型」逐只判，整段只吃一次（hitted 列表，回程会被反弹逻辑清空）。
//
// 🔴 口径（2026-11-14 用户定稿）：「可穿过障碍物」但**不穿透老鼠** ——
//   命中障碍物继续飞，命中老鼠（含 BOSS / 非主流 / 空中 / 潜水等一切非障碍目标）立刻停下消散。
//   2026-11-13 本来就是这么写的，2026-11-14 上午按另一句反馈改成了全行穿透，
//   现在按用户原话「元素蛇子弹应该是非穿透老鼠的效果」改回来；
//   当时顺手修掉的两个真问题（遍历源 global.enemy_by_type 不完整、击杀绕过死亡结算）**保留**。
if (global.is_paused)
    exit;

if (ys_delay > 0)
{
    ys_delay--;
    exit;
}

x += move_speed;

// 左右镜像跟随飞行方向（被反弹后朝左飞，子弹也对调）
var _want_sx = (move_speed >= 0) ? 1.3 : -1.3;
visual_scale_x = _want_sx;
visual_scale_y = 1.3;
// 父对象 BeginStep 每帧把 image_scale 夹回 1（并顺手拷进 visual_scale），
// 可 bbox 只认 image_scale —— 所以这里每帧重设一次，判定盒才和 1.3 的视觉对齐，
// 否则 60x28 的原生盒子会在视觉边缘静默漏判（MISTAKES B20）。
image_xscale = _want_sx;
image_yscale = 1.3;

// 自己当前占的是哪一列（供命中判定用，见下方注释）
ys_col_now = floor((x - global.grid_offset_x) / global.grid_cell_size_x);

// ── 命中判定：**直接扫场上所有敌人**，不再按 global.enemy_by_type 白名单逐类遍历
//
// 🔴 2026-11-14 第三次修（真正让「打不到老鼠」消失的一刀）：
//   前两版都用 `global.enemy_by_type` 当遍历源，而那张表是**敌人自己在 Step 里注册**的
//   （obj_enemy_parent/Step_0:7-23 的那段）。工程里有 57 个敌人对象重写了 Step_0 却
//   **没有** `event_inherited()`，其中一部分根本没写注册代码（火车各节、若干换皮鼠、
//   部分 BOSS 部件）→ 它们永远不在表里，子弹按表遍历时看不到它们，
//   表现就是用户报的「子弹从老鼠身上飞过去，一点反应都没有」，而障碍物
//   （obj_barrier 自己手写了注册）反而能正常吃到伤害。
//   改成 with (obj_enemy_parent) 全量扫描后，命中与「注册表是否完整」「精灵尺寸」
//   「image_xscale 缩放」「精灵原点在哪」全部解耦，任何继承 obj_enemy_parent 的对象都能被打到。
//
//   判据 = 同行 + 同列 + can_hit 类型过滤
//
// 🔴 2026-11-14 第四次修（用户报「提前一格受击」）：把「同列」重新定义成唯一判据，
//   并把原来的 `|| 横向包围盒重叠` 删掉。
//   实测原因：敌人自己 `image_xscale = 1.8`（obj_enemy_parent/Create_0:2-3），
//   而 spr_normal_mouse 的声明 bbox 是 3..101（自动包围盒取**全帧并集**，含 32~36 帧的
//   倒地动作），相对原点是 [-51,+47] → 1.8 倍下宽 176px = **1.65 格**。
//   敌人出生点又是格心 +30（obj_battle/Create_0:413），于是它左沿落在 x-91.8，
//   也就是**上一格最后 8px 里**。子弹尖端比中心领先 37.7px（60px 宽 ×1.3 / 2），
//   两者一叠 → 子弹中心还在上一格时就置了命中（col3 打到 col4 的敌人），
//   表现就是用户说的「提前一格受击」。
//   现在改成「子弹中心进入敌人所在格」才算命中：此时子弹尖端已扎进老鼠身体约 38px
//   （身体左沿在 x-47.4，格左沿在 x-53.5），视觉与判定一致，也不会再跨格误伤。
//   顺带收益：不再依赖任何精灵尺寸 / 原点 / 帧数，宽体鼠与瘦体鼠一视同仁。
with (obj_enemy_parent)
{
    // 防御：少数自制敌人重写了 Create 却没 event_inherited()，身上可能没有这几个字段
    //   （工程里读未定义实例变量是硬崩「Variable ... not set before reading it」，
    //    不是静默 false）—— 缺字段的直接跳过，别让一发子弹把整场战斗打断。
    if (!variable_instance_exists(id, "hp")
        || !variable_instance_exists(id, "grid_col")
        || !variable_instance_exists(id, "grid_row")
        || !variable_instance_exists(id, "target_type"))
        continue;

    // can_hit(子弹口径, 敌人类型) 就是 can_target_on 的别名：穿透口径 = 陆/非主流/障碍/未显形
    var _hit_ok = (hp > 0)
        && (grid_row == other.row)
        && (ds_list_find_index(other.hitted, id) == -1)
        && (grid_col == other.ys_col_now)
        && can_hit(other.target_type, target_type);

    if (_hit_ok)
    {
        ds_list_add(other.hitted, id);

        var _dmg = other.damage;
        // 暴击**只属于红色弹**（情报岛原文：红色暴击弹 = 30% 概率 2/3 倍伤害）。
        //   旧写法不分颜色一律 random < ys_crit_chance，导致黄/紫/蓝也常数暴击、
        //   到处冒暴击闪光，反而把「红色才是暴击弹」的辨识度冲掉了。
        var _is_crit = (other.ys_color == 3 && random(1) < other.ys_crit_chance);
        if (_is_crit)
            _dmg = _dmg * other.ys_crit_mult;

        // 暴击打击感：命中特效 + 更明显的闪白
        if (_is_crit)
        {
            var _cfx = instance_create_depth(x, y - 40, depth - 20, obj_yuansushe_fx);
            _cfx.sprite_index     = spr_yuansushe_fx_crit;
            _cfx.fx_frame_ticks   = 3;    // 5 帧 × 3 tick ≈ 0.25 秒（1 tick/帧只有 0.08 秒，看不到）
            _cfx.image_xscale = 1.6;
            _cfx.image_yscale = 1.6;
            flash_value = 220;
        }

        damage_amount = _dmg;
        damage_type   = "pierce";
        event_user(0);

        // ── 四色附加效果 ──────────────────────────────
        // 🔴 不包 `if (hp > 0)`：元素蛇攻击力 120~2700，命中基本都是一击必杀，
        //   而老鼠一死 hp 就 <= 0，写成「活着才附加」的话绝大多数命中都不会出特效 ——
        //   玩家看到的就是「不同子弹效果有时候（几乎总是不）生效」。
        //   命中即判定：活着 → 状态生效；刚被打死 → 状态写进去也无害（本帧末就清掉），
        //   特效照播，毒气照放（它会在原地毒到周围其它老鼠，与目标死活无关）。
        //   障碍物没有状态机（state 是字符串、没有 frozen/stun 语义），只吃伤害不出状态。
        if (target_type != "obstacle")
        {
            switch (other.ys_color)
            {
                case 0:  // 黄：定身
                    if (random(1) < other.ys_pin_chance)
                    {
                        if (stun_timer < other.ys_pin_ticks)
                            stun_timer = other.ys_pin_ticks;
                        var _dfx = instance_create_depth(x, y - 90, depth - 20, obj_yuansushe_fx);
                        _dfx.sprite_index     = spr_yuansushe_fx_dizzy;
                        _dfx.fx_frame_ticks   = 6;    // 20 帧 × 6 tick ≈ 2 秒，覆盖定身 1.5 秒
                        _dfx.image_xscale = 1.4;
                        _dfx.image_yscale = 1.4;
                    }
                    break;

                case 1:  // 紫：毒气（1 次固定伤害，范围沿用毒雾对象自己的判定）
                    if (random(1) < other.ys_poison_chance)
                    {
                        var _p = instance_create_depth(x, y - 40, depth - 30, other.ys_poison_obj);
                        _p.sprite_index    = spr_yuansushe_fx_poison;
                        _p.damage          = other.ys_poison_damage;
                        // 毒气沿用元素蛇的命中口径（穿透）：写 "normal" 的话
                        // can_target_on("normal", "dance"/"invisible") 是 false，
                        // 非主流鼠 / 未显形幽灵吃不到毒。
                        _p.damage_type     = "pierce";
                        _p.target_type     = "pierce";
                        _p.grid_row        = grid_row;
                        _p.grid_col        = grid_col;
                        _p.image_xscale    = 1.8;
                        _p.image_yscale    = 1.8;
                    }
                    break;

                case 2:  // 蓝：冰冻 2 秒后减速 2 秒
                    if (random(1) < other.ys_freeze_chance)
                    {
                        if (frozen_timer < other.ys_freeze_ticks)
                            frozen_timer = other.ys_freeze_ticks;
                        // ice_timer 与 frozen_timer 同时倒计时：设成 冰冻+减速 的总和，
                        // 冰冻结束后还剩 2 秒减速
                        if (ice_timer < other.ys_slow_ticks)
                            ice_timer = other.ys_slow_ticks;
                        var _ffx = instance_create_depth(x, y - 60, depth - 20, obj_yuansushe_fx);
                        _ffx.sprite_index     = spr_yuansushe_fx_froze;
                        _ffx.fx_frame_ticks   = 4;    // 6 帧 × 4 tick ≈ 0.4 秒（1 tick/帧只有 0.1 秒，看不见）
                        _ffx.image_xscale = 0.9;
                        _ffx.image_yscale = 0.9;
                    }
                    break;

                case 3:  // 红：暴击（伤害已在上面乘过）
                    break;
            }
        }

        // 穿透口径的边界：**只有障碍物**挡不住子弹，其它目标（老鼠 / BOSS / 非主流 /
        //   空中 / 潜水 / 未显形幽灵）命中即停。
        //   注意：`break` 必须放在下面的死亡结算之后 —— 先 break 的话
        //   `ash_death / image_alpha` 那一段就整段跳过，老鼠会以 hp<=0 但活着的状态赖在场上。
        var _stop_here = (target_type != "obstacle");

        audio_play_sound(hit_sound, 0, 0);

        if (hp <= 0)
        {
            // 灰烬口径：special_ash 的变体鼠要保留原精灵帧（同 obj_burn_cell）
            if (special_ash)
            {
                var _ash = instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                _ash.special_ash = true;
                _ash.sprite_index = sprite_index;
                _ash.image_index = image_index;
            }
            else
            {
                instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
            }
            // 🔴 不要在这里 instance_destroy()：那会绕过 obj_enemy_parent/Step_0:427 的死亡结算
            //   （hex_batch2_on_enemy_death / hex_on_kill / hex_try_drop 全丢，见 MISTAKES B18）。
            //   置 ash_death 让父对象自己收尾：结算 → state = DEAD → image_alpha = 0 → 当帧注销并销毁。
            //
            //   同时把三种控制状态清零：obj_enemy_parent/Step_0:106 是
            //   `if (is_frozen || is_scare || is_stun) exit;`，只要身上挂着冰冻/定身，
            //   死亡分支（:427）就一直走不到 —— 蓝弹/黄弹打死的老鼠会顶着 0 透明留在场上
            //   2 秒才消失，看起来像「打死没死、子弹穿过没效果」。这里清掉就即时收尾。
            frozen_timer = 0;
            ice_timer    = 0;
            stun_timer   = 0;
            scare_timer  = 0;
            ash_death    = true;
            image_alpha  = 0;
        }

        // 命中非障碍目标 → 这一发到此为止（同格叠多只时也只结算这一只）
        if (_stop_here)
        {
            other.ys_stop = true;
            break;
        }
    }
}

// 命中老鼠后自毁（障碍物继续飞）。放在循环外：本帧先把命中结算与特效都做完，
//   再销毁子弹，避免特效随着子弹一起消失。
if (ys_stop)
{
    instance_destroy();
    exit;
}

// 出界消散：向右飞出地图右沿 / 被弹回后向左飞出地图左沿
if (move_speed >= 0)
{
    if (x > get_world_position_from_grid(ys_end_col, row).x)
        instance_destroy();
}
else if (x < global.grid_offset_x - global.grid_cell_size_x)
{
    instance_destroy();
}
