// obj_shiliu_bullet Step —— 跟随目标 → 落地帧结算碾压 → 播完自毁
if (global.is_paused) exit;

if (!sprite_exists(sprite_index)) {
    instance_destroy();
    exit;
}

// 跟随目标：籽从天而降的全过程都锁在目标头顶，保证「砸中」的观感
if (instance_exists(target_inst) && target_inst.hp > 0) {
    x = target_inst.x;
    y = target_inst.y + fall_offset_y;
    last_x = x;
    last_y = y;
}

// 逐帧推进
frame_timer++;
if (frame_timer >= frame_speed) {
    frame_timer = 0;
    image_index++;
}

// ── 落地帧：结算碾压伤害 ────────────────────────────────────────────
if (!landed && image_index >= impact_frame) {
    landed = true;

    if (instance_exists(target_inst) && target_inst.hp > 0) {
        var _t = target_inst;
        var _dmg = damage_value;
        var _fz  = apply_freeze;
        var _fzt = freeze_ticks;
        var _slt = slow_ticks;

        with (_t) {
            damage_amount = _dmg;
            damage_type = "ash";     // 灰烬类：无视护盾（见 obj_enemy_parent/Other_10）
            event_user(0);
        }

        if (instance_exists(_t)) {
            if (_t.hp > 0) {
                // 未死亡：冰冻 + 减速 + 冰晶迸发（只有爆炸范围内的目标才附加冰冻）
                with (_t) {
                    if (_fz) {
                        if (frozen_timer < _fzt) frozen_timer = _fzt;
                        if (ice_timer < _slt)    ice_timer    = _slt;
                    }
                }
                var _br = instance_create_depth(_t.x, _t.y - 40, _t.depth - 1, obj_shiliu_freeze_burst);
                _br.image_xscale = 1.5;
                _br.image_yscale = 1.5;
            }
            else {
                // 死亡：**只播碎冰**，不播老鼠自己的死亡动画。
                // 不直接 instance_destroy —— 父类 Step 的死亡分支还要跑击杀结算
                // （hex_on_kill / hex_try_drop / 塔之诅咒），直接销毁会把这些漏掉。
                // 置 ash_death = true 后父类会 image_alpha = 0（立刻隐形）+ 走完结算再自己销毁。
                var _dx = _t.x;
                var _dy = _t.y;
                var _dd = _t.depth;
                with (_t) {
                    ash_death = true;
                    image_alpha = 0;    // 同帧就隐形，别等父类下一帧（否则会闪一帧死亡动画）
                }
                instance_create_depth(_dx, _dy - 20, _dd - 1, obj_shiliu_ash_fx);
            }
        }
        else {
            // 受伤流程里已经把实例销毁了 → 在记录的落点补播碎冰
            instance_create_depth(last_x, last_y - 20, depth, obj_shiliu_ash_fx);
        }
    }
}

// 播完自毁
if (image_index >= sprite_get_number(sprite_index)) {
    instance_destroy();
}
