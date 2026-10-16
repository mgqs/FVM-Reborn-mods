event_inherited();
image_speed = 0; // 动画完全由 longyuan_clip_* 驱动

// ===== 游神鼠 =====
ly_kind = "youshen";
ly_anims = longyuan_animation_table("youshen");
mouse_id = "ly_youshen";
hp = 300000; maxhp = 300000;

// ===== 占位数值（可调）=====
atk = 6000;          // 占位：技能伤害
wait_time = 60;      // 占位：待机时长（步）
ly_move_speed = 2;   // 占位：移动速度（像素/步）

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
            _act = longyuan_variant("正常待机", "破损待机");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, true);
            if (timer >= wait_time) {
                timer = 0; ly_phase = 0;
                _r = irandom_range(1, 100); // 占位权重：MOVE 40 / SKILL1 25 / SKILL2 20 / SKILL3 15
                if (_r <= 40) state = BOSS_STATE.MOVE;
                else if (_r <= 65) state = BOSS_STATE.SKILL1;
                else if (_r <= 85) state = BOSS_STATE.SKILL2;
                else state = BOSS_STATE.SKILL3;
            }
            break;
        }
        case BOSS_STATE.MOVE: { // 移动，瞬移用 游出/游进
            if (ly_phase == 0) {
                _act = longyuan_variant("正常移动", "破损移动");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                x -= ly_move_speed; // 占位：向左移动
                if (timer >= 24) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) {
                _act = longyuan_variant("正常游出", "破损游出");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    _tcol = ly_target_col();
                    _tpos = get_world_position_from_grid(_tcol, grid_row);
                    x = _tpos.x + 60; // 占位：瞬移到目标列右侧
                    ly_phase = 2; timer = 0;
                }
            }
            else {
                _act = longyuan_variant("正常游进", "破损游进");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        }
        case BOSS_STATE.SKILL1: { // 卷轴
            _act = longyuan_variant("正常技能1", "破损技能1");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (timer == 12) { // 占位：中段生成卷轴（飞行→打开）
                longyuan_boss_fx_start(instance_create_depth(x - 60, y - 80, -200, obj_ly_boss_fx), "youshen_scroll", "飞行", false, 5, "打开", false);
            }
            if (!ly_hit && timer >= 24) { // 占位命中帧：展开后对前方造成伤害
                ly_damage_col(grid_col);
                ly_damage_col(grid_col + 1);
                ly_hit = true;
                longyuan_boss_fx_start(instance_create_depth(x - 120, y - 80, -200, obj_ly_boss_fx), "youshen_scroll", "消失", false, 5); // 消失演出
            }
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
        case BOSS_STATE.SKILL2: { // 迷雾
            _act = longyuan_variant("正常技能2", "破损技能2");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (timer == 12) { // 占位：中段生成迷雾（覆盖所在行）
                longyuan_boss_fx_start(instance_create_depth(x, y - 40, -200, obj_ly_boss_fx), "youshen_mist", "待机", true, 5);
            }
            if (timer >= 12 && timer mod 20 == 0) ly_damage_row(grid_row); // 占位：持续伤害所在行
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
        case BOSS_STATE.SKILL3: { // 冲撞
            if (ly_phase == 0) {
                _act = longyuan_variant("正常技能3", "破损技能3");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) { // 高速冲刺撞击
                _act = longyuan_variant("正常技能3冲刺", "破损技能3冲刺");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                x -= ly_move_speed * 3; // 占位：冲刺速度
                if (!ly_hit && timer >= 6) { ly_damage_col(grid_col); ly_hit = true; } // 占位命中帧：撞击整列
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 2; timer = 0; }
            }
            else {
                _act = longyuan_variant("正常技能3结束", "破损技能3结束");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        }
    }
};
