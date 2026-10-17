event_inherited();
image_speed = 0; // 动画完全由 longyuan_clip_* 驱动

// ===== 哼哈二将·马面 =====
ly_kind = "hengha_horseface";
ly_anims = longyuan_animation_table("hengha_horseface");
mouse_id = "ly_hengha_horseface";
hp = 180000; maxhp = 180000;

// ===== 占位数值（可调）=====
atk = 4000;          // 占位：技能伤害
wait_time = 60;      // 占位：待机时长（步）
ly_move_speed = 2;   // 占位：移动速度（像素/步）
ly_rounds = 0;       // 技能2已召唤轮数
ly_round_max = 3;    // 占位：技能2循环召唤轮数

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
            _act = longyuan_variant("正常有铃铛待机", "破损有铃铛待机");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, true);
            if (timer >= wait_time) {
                timer = 0; ly_phase = 0; ly_rounds = 0;
                _r = irandom_range(1, 100); // 占位权重：MOVE 40 / SKILL1 30 / SKILL2 30
                if (_r <= 40) state = BOSS_STATE.MOVE;
                else if (_r <= 70) state = BOSS_STATE.SKILL1;
                else state = BOSS_STATE.SKILL2;
            }
            break;
        }
        case BOSS_STATE.MOVE: { // 有铃待机 → 无铃消失(闪现) → 无铃出现
            if (ly_phase == 0) {
                _act = longyuan_variant("正常有铃铛待机", "破损有铃铛待机");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                if (timer >= 20) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) {
                _act = longyuan_variant("正常无铃消失", "破损无铃消失");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    _tcol = ly_target_col();
                    _tpos = get_world_position_from_grid(_tcol, grid_row);
                    x = _tpos.x + 60; // 占位：闪现到目标列右侧
                    ly_phase = 2; timer = 0;
                }
            }
            else {
                _act = longyuan_variant("正常无铃出现", "破损无铃出现");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        }
        case BOSS_STATE.SKILL1: { // 掷铃
            if (ly_phase == 0) {
                _act = longyuan_variant("正常技能1开始", "破损技能1开始");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) { // 抛第 1 个铃铛
                _act = longyuan_variant("正常技能1抛出1", "破损技能1抛出1");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (timer == 6) {
                    // 占位：fx 仅支持单次链接（飞行→变大），无法再链到「待机」循环
                    longyuan_boss_fx_start(instance_create_depth(x - 60, y - 100, -200, obj_ly_boss_fx), "hengha_bell", "飞行", false, 5, "变大", false);
                }
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_damage_row(grid_row); ly_phase = 2; timer = 0; } // 占位：铃铛落地爆炸
            }
            else { // 抛第 2 个铃铛
                _act = longyuan_variant("正常技能1抛出2", "破损技能1抛出2");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (timer == 6) {
                    longyuan_boss_fx_start(instance_create_depth(x - 60, y - 100, -200, obj_ly_boss_fx), "hengha_bell", "飞行", false, 5, "变大", false);
                }
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_damage_row(grid_row); ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE; } // 占位：爆炸
            }
            break;
        }
        case BOSS_STATE.SKILL2: { // 召食物精灵
            if (ly_phase == 0) {
                _act = longyuan_variant("正常技能2开始", "破损技能2开始");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) { // 循环召唤冲撞小怪
                _act = longyuan_variant("正常技能2循环", "破损技能2循环");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                if (timer mod 24 == 0) {
                    longyuan_boss_fx_start(instance_create_depth(x - 60, y - 40, -200, obj_ly_boss_fx), "hengha_food_spirit", "出生", false, 5, "待机", true);
                    ly_rounds++;
                }
                if (ly_rounds >= ly_round_max) { ly_phase = 2; timer = 0; }
            }
            else {
                _act = longyuan_variant("正常技能2结束", "破损技能2结束");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        }
    }
};
