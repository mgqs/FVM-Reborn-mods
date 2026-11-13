// obj_yuansushe_bullet Step 事件
// 移动只看 move_speed 的符号（正 = 向右，被反弹后为负 = 向左），
// 命中一律按「行 + 包围盒 + 白名单」逐只判，整段只吃一次（hitted 列表，回程会被反弹逻辑清空）。
if (global.is_paused)
    exit;

if (ys_delay > 0)
{
    ys_delay--;
    exit;
}

x += move_speed;

// 左右镜像跟随飞行方向（被反弹后 visual_scale_x 变负，子弹朝向也对得上）
var _want_sx = (move_speed >= 0) ? 1.3 : -1.3;
if (visual_scale_x != _want_sx) visual_scale_x = _want_sx;

// ── 命中判定：只按白名单逐只判包围盒，不做屏障碰撞（可过障碍）
for (var _t = 0; _t < array_length(ys_hittable); _t++)
{
    var _key = ys_hittable[_t];
    if (!variable_struct_exists(global.enemy_by_type, _key))
        continue;

    var _list = global.enemy_by_type[$ _key];
    for (var _i = 0; _i < array_length(_list); _i++)
    {
        var _e = _list[_i];
        if (!instance_exists(_e))
            continue;

        with (_e)
        {
            if (hp > 0
                && other.row == grid_row
                && ds_list_find_index(other.hitted, id) == -1
                && other.bbox_right >= bbox_left && other.bbox_left <= bbox_right
                && other.bbox_bottom >= bbox_top && other.bbox_top <= bbox_bottom)
            {
                ds_list_add(other.hitted, id);

                var _dmg = other.damage;
                var _is_crit = (random(1) < other.ys_crit_chance);
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
                // 🔴 不再包 `if (hp > 0)`。
                //   元素蛇攻击力很高（120~2700），命中基本都是一击必杀，而老鼠一死 hp 就 <= 0，
                //   写成「活着才附加」的话绝大多数命中都不会出效果/特效 ——
                //   玩家看到的就是「不同子弹效果有时候（几乎总是不）生效」。
                //   现在命中即判定：活着 → 状态生效；刚被打死 → 状态写进去也无害（实例本帧就销毁），
                //   毒气更是照放（它会在原地毒到周围其它老鼠，跟目标死活无关）。
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

                // 不穿透老鼠：打到非障碍物就地停住（障碍物穿过继续飞）
                if (target_type != "obstacle") other.ys_stop = true;

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
                    instance_destroy();
                }
            }
        }

        // 已打到老鼠 → 不再继续找后面的目标（不穿透）
        if (ys_stop) break;
    }

    if (ys_stop) break;
}

// 命中老鼠：子弹当帧消失（伤害 / 特效已在上面结算完）
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
