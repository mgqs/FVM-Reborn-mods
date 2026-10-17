event_inherited();
image_speed = 0; // 动画完全由 longyuan_clip_* 驱动

// ===== 谛听鼠 =====
ly_kind = "diting";
ly_anims = longyuan_animation_table("diting");
mouse_id = "ly_diting";
hp = 200000; maxhp = 200000;

// ===== 占位数值（可调）=====
atk = 5000;                     // 占位：技能伤害
wait_time = 60;                 // 占位：待机时长（步）
ly_move_speed = 2;              // 占位：移动速度（像素/步）
ly_grid_fire_cols = [2, 5, 8];  // 占位：网格火所在列
ly_prison_inst = noone;         // 常驻狱鼠陷阱实例
ly_prison_col = 0;              // 陷阱所在列

ly_boss_step = function() {
    var _act, _tcol, _tpos, _r;

    // 常驻狱鼠陷阱：持续灼烧其所在列（占位：每 30 步一次）
    if (instance_exists(ly_prison_inst) && timer mod 30 == 0) {
        ly_damage_col(ly_prison_col);
    }

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
        case BOSS_STATE.MOVE: {
            if (ly_phase == 0) {
                _act = longyuan_variant("正常钻入地下", "破损钻入地下");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) {
                _act = longyuan_variant("正常移动", "破损移动");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                x -= ly_move_speed; // 占位：向左靠近目标列
                _tcol = ly_target_col();
                _tpos = get_world_position_from_grid(_tcol, grid_row);
                if (x <= _tpos.x + 40 || timer >= 60) { ly_phase = 2; timer = 0; }
            }
            else {
                _act = longyuan_variant("正常钻出", "破损钻出");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        }
        case BOSS_STATE.SKILL1: { // 遁地突袭
            if (ly_phase == 0) {
                _act = longyuan_variant("正常技能1钻入", "破损技能1钻入");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) {
                _act = longyuan_variant("正常技能移动", "破损技能移动");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                x -= ly_move_speed * 2; // 占位：地下高速横移
                if (timer >= 24) { ly_phase = 2; timer = 0; } // 占位：位移时长
            }
            else {
                _act = longyuan_variant("正常技能1钻出", "破损技能1钻出");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (!ly_hit && timer >= 10) { ly_damage_col(grid_col); ly_hit = true; } // 占位命中帧：钻出瞬间伤害所在列
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        }
        case BOSS_STATE.SKILL2: { // 音波：向左推进并灼烧同行植物
            _act = longyuan_variant("正常技能2", "破损技能2");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (timer == 18) { // 占位：中段生成音波演出
                longyuan_boss_fx_start(instance_create_depth(x, y - 60, -200, obj_ly_boss_fx), "diting_soundwave", "待机", true, 5);
            }
            if (timer >= 18 && timer mod 20 == 0) ly_damage_row(grid_row); // 占位：音波推进时灼烧同行
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
        case BOSS_STATE.SKILL3: { // 网格火 + 狱鼠陷阱
            _act = longyuan_variant("正常技能3", "破损技能3");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (timer == 20) { // 占位：中段布火并即时灼烧
                for (var _i = 0; _i < array_length(ly_grid_fire_cols); _i++) {
                    var _fc = ly_grid_fire_cols[_i];
                    var _fp = get_world_position_from_grid(_fc, grid_row);
                    longyuan_boss_fx_start(instance_create_depth(_fp.x, _fp.y - 40, -200, obj_ly_boss_fx), "diting_grid_fire", "待机", true, 5);
                }
                ly_damage_row(grid_row);
            }
            if (timer == 40 && !instance_exists(ly_prison_inst)) { // 占位：生成一只常驻狱鼠陷阱
                ly_prison_col = grid_col;
                ly_prison_inst = instance_create_depth(x, y - 60, -200, obj_ly_boss_fx);
                longyuan_boss_fx_start(ly_prison_inst, "diting_prison", "出生", false, 5, "激活待机", true);
            }
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
    }
};
