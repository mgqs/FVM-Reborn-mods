event_inherited();
image_speed = 0; // 动画完全由 longyuan_clip_* 驱动

// ===== 无常鼠（白/黑双形态）=====
ly_kind = "wuchang";
ly_anims = longyuan_animation_table("wuchang");
mouse_id = "ly_wuchang";
hp = 250000; maxhp = 250000;

// ===== 占位数值（可调）=====
atk = 5000;          // 占位：技能伤害
wait_time = 60;      // 占位：待机时长（步）
ly_move_speed = 2;   // 占位：移动速度（像素/步）
ly_white = true;     // 自定义：true=白形态，false=黑形态（决定下一次待机动作名）
ly_skill_index = 0;

ly_boss_step = function() {
    var _act, _tcol, _tpos, _r;

    switch (state) {
        case BOSS_STATE.APPEAR: {
            if (ly_action != "出生") longyuan_clip_set("出生");
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
        case BOSS_STATE.IDLE: {
            _act = ly_white ? longyuan_variant("正常白待机", "破损白待机") : longyuan_variant("正常黑待机", "破损黑待机");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, true);
            if (timer >= wait_time) {
                timer = 0; ly_phase = 0;
                var _cycle = [BOSS_STATE.SKILL1, BOSS_STATE.SKILL2, BOSS_STATE.SKILL3, BOSS_STATE.SKILL4];
                state = _cycle[ly_skill_index mod array_length(_cycle)];
                ly_skill_index++;
                ly_white = !ly_white;
            }
            break;
        }
        case BOSS_STATE.MOVE: { // 白↔黑闪出/闪进 + 位移
            if (ly_phase == 0) {
                _act = ly_white ? longyuan_variant("正常白闪出", "破损白闪出") : longyuan_variant("正常黑闪出", "破损黑闪出");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    _tcol = ly_target_col();
                    _tpos = get_world_position_from_grid(_tcol, grid_row);
                    x = _tpos.x + 60;   // 占位：闪现到目标列右侧
                    ly_white = !ly_white; // 形态切换
                    ly_phase = 1; timer = 0;
                }
            }
            else {
                _act = ly_white ? longyuan_variant("正常白闪进", "破损白闪进") : longyuan_variant("正常黑闪进", "破损黑闪进");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        }
        case BOSS_STATE.SKILL1: { // 撒金币
            _act = longyuan_variant("正常技能1", "破损技能1");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (timer == 12) { // 占位：中段生成金币（旋转→爆炸）
                longyuan_boss_fx_start(instance_create_depth(x - 60, y - 20, -200, obj_ly_boss_fx), "wuchang_gold_ingot", "旋转", false, 5, "爆炸", false);
            }
            if (!ly_hit && timer >= 30) { ly_damage_row(grid_row); ly_hit = true; } // 占位命中帧：爆炸伤害
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
        case BOSS_STATE.SKILL2: { // 锁链
            _act = longyuan_variant("正常技能2", "破损技能2");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (timer == 12) { // 占位：中段生成锁链（主段 + 连接段）
                longyuan_boss_fx_start(instance_create_depth(x, y - 20, -200, obj_ly_boss_fx), "wuchang_chain2_blue", "开始1", false, 5, "循环1", true);
                longyuan_boss_fx_start(instance_create_depth(x - 60, y - 20, -200, obj_ly_boss_fx), "wuchang_chain", "待机", true, 5);
                longyuan_boss_fx_start(instance_create_depth(x - 100, y - 20, -200, obj_ly_boss_fx), "wuchang_chain1_blue", "待机", true, 5);
                longyuan_boss_fx_start(instance_create_depth(x - 140, y - 20, -200, obj_ly_boss_fx), "wuchang_chain1_red", "动画", true, 5);
            }
            if (!ly_hit && timer >= 24) { ly_damage_col(grid_col); ly_hit = true; } // 占位命中帧
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
        case BOSS_STATE.SKILL3: { // 火轮（横向推进）
            _act = longyuan_variant("正常技能3", "破损技能3");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (timer == 12) { // 占位：中段生成火轮
                longyuan_boss_fx_start(instance_create_depth(x - 60, y + 20, -200, obj_ly_boss_fx), "wuchang_fire_wheel", "旋转", true, 5);
            }
            if (timer >= 12 && timer mod 20 == 0) ly_damage_row(grid_row); // 占位：火轮推进灼烧
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
        case BOSS_STATE.SKILL4: { // 招魂幡 + 福州市鼠
            if (ly_phase == 0) {
                _act = longyuan_variant("正常技能4开始", "破损技能4开始");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (timer == 12) { // 占位：中段生成魂幡与福州鼠演出
                    longyuan_boss_fx_start(instance_create_depth(x, y - 60, -200, obj_ly_boss_fx), "wuchang_soul_banner", "待机", true, 5);
                    // 注：福州市鼠目前用 fx 表现（无独立小怪对象），如后续需要冲撞小怪可另建对象
                    longyuan_boss_fx_start(instance_create_depth(x - 80, y + 20, -200, obj_ly_boss_fx), "wuchang_fuzhou", "出生", false, 5, "正常前进", true);
                }
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else {
                _act = longyuan_variant("正常技能4结束", "破损技能4结束");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        }
    }
};
