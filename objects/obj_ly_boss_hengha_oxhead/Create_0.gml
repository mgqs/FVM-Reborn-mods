event_inherited();
image_speed = 0; // 动画完全由 longyuan_clip_* 驱动

// ===== 哼哈二将·牛头 =====
ly_kind = "hengha_oxhead";
ly_anims = longyuan_animation_table("hengha_oxhead");
mouse_id = "ly_hengha_oxhead";
hp = 180000; maxhp = 180000;

// ===== 占位数值（可调）=====
atk = 4000;          // 占位：技能伤害
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
        case BOSS_STATE.MOVE: { // 移动，穿插闪出/闪进做闪现
            if (ly_phase == 0) {
                _act = longyuan_variant("正常移动", "破损移动");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                x -= ly_move_speed; // 占位：向左移动
                if (timer >= 24) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) {
                _act = longyuan_variant("正常闪出", "破损闪出");
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
                _act = longyuan_variant("正常闪进", "破损闪进");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        }
        case BOSS_STATE.SKILL1: { // 中段对前方整列造成伤害
            _act = longyuan_variant("正常技能1", "破损技能1");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (!ly_hit && timer >= 30) { // 占位命中帧
                ly_damage_col(grid_col);
                ly_damage_col(grid_col + 1);
                ly_hit = true;
            }
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
        case BOSS_STATE.SKILL2: { // 跳跃砸地：预备 → 跳跃 → 下落
            if (ly_phase == 0) {
                _act = longyuan_variant("正常跳跃预备", "破损跳跃预备");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) {
                _act = longyuan_variant("正常跳跃", "破损跳跃");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 2; timer = 0; }
            }
            else {
                _act = longyuan_variant("正常下落", "破损下落");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { // 落地：整行伤害 + 震屏
                    ly_damage_row(grid_row);
                    if (global.screen_shake) Camera_Shock(6, 20); // 占位：震屏
                    ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE;
                }
            }
            break;
        }
        case BOSS_STATE.SKILL3: {
            _act = longyuan_variant("正常技能3", "破损技能3");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (!ly_hit && timer >= 40) { ly_damage_row(grid_row); ly_hit = true; } // 占位命中帧
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
    }
};
