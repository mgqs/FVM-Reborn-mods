event_inherited();
image_speed = 0; // 动画完全由 longyuan_clip_* 驱动

// ===== 孟婆鼠（只有正常形态，无 variant）=====
ly_kind = "mengpo";
ly_anims = longyuan_animation_table("mengpo");
mouse_id = "ly_mengpo";
hp = 300000; maxhp = 300000;

// ===== 占位数值（可调）=====
atk = 5000;          // 占位：技能伤害
wait_time = 60;      // 占位：待机时长（步）
ly_move_speed = 2;   // 占位：移动速度（像素/步）
ly_rain_inst = noone;  // 常驻下雨实例
ly_wind_inst = noone;  // 常驻狂风实例
ly_skill_index = 0;

ly_boss_step = function() {
    var _act, _tcol, _tpos, _r;

    // 下雨：覆盖全屏，持续伤害（占位：每 30 步对全部行灼烧一次）
    if (instance_exists(ly_rain_inst) && timer mod 30 == 0) {
        for (var _rr = 0; _rr < global.grid_rows; _rr++) ly_damage_row(_rr);
    }

    switch (state) {
        case BOSS_STATE.APPEAR: {
            if (ly_action != "出生") longyuan_clip_set("出生");
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
        case BOSS_STATE.IDLE: {
            if (ly_action != "正常待机") longyuan_clip_set("正常待机");
            longyuan_clip_frame(timer, ly_anim_rate, true);
            if (timer >= wait_time) {
                timer = 0; ly_phase = 0;
                var _cycle = [BOSS_STATE.SKILL2, BOSS_STATE.SKILL1, BOSS_STATE.SKILL2, BOSS_STATE.SKILL3];
                state = _cycle[ly_skill_index mod array_length(_cycle)];
                ly_skill_index++;
            }
            break;
        }
        case BOSS_STATE.MOVE: { // 闪出 → 位移 → 闪进
            if (ly_phase == 0) {
                if (ly_action != "正常闪出") longyuan_clip_set("正常闪出");
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    _tcol = ly_target_col();
                    _tpos = get_world_position_from_grid(_tcol, grid_row);
                    x = _tpos.x + 60; // 占位：闪现到目标列右侧
                    ly_phase = 1; timer = 0;
                }
            }
            else {
                if (ly_action != "正常闪进") longyuan_clip_set("正常闪进");
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        }
        case BOSS_STATE.SKILL1: { // 下雨
            if (ly_action != "正常技能1") longyuan_clip_set("正常技能1");
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (timer == 10 && !instance_exists(ly_rain_inst)) { // 占位：中段生成全屏雨幕
                ly_rain_inst = instance_create_depth(x, y + 200, -250, obj_ly_boss_fx);
                longyuan_boss_fx_start(ly_rain_inst, "mengpo_rain", "下雨", true, 5);
            }
            if (!ly_hit && timer >= 20) { // 占位命中帧
                for (var _r1 = 0; _r1 < global.grid_rows; _r1++) ly_damage_row(_r1);
                ly_hit = true;
            }
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
        case BOSS_STATE.SKILL2: { // 狂风
            if (ly_action != "正常技能2") longyuan_clip_set("正常技能2");
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (timer == 10) { // 占位：中段生成风场演出
                ly_wind_inst = instance_create_depth(x, y - 40, -200, obj_ly_boss_fx);
                longyuan_boss_fx_start(ly_wind_inst, "mengpo_strong_wind", "待机", true, 5);
                longyuan_boss_fx_start(instance_create_depth(x, y + 60, -200, obj_ly_boss_fx), "mengpo_wind_mist", "待机", true, 5);
            }
            if (timer == 20 || timer == 40 || timer == 60) { // 占位：风向演出（左/右/下/上）
                var _wandirs = ["mengpo_wind_left", "mengpo_wind_right", "mengpo_wind_down", "mengpo_wind_up"];
                var _wdir = _wandirs[irandom_range(0, 3)];
                longyuan_boss_fx_start(instance_create_depth(x, y, -200, obj_ly_boss_fx), _wdir, "待机", true, 5);
            }
            if (timer == 30) { // 占位：命中演出一帧
                longyuan_boss_fx_start(instance_create_depth(x - 120, y, -200, obj_ly_boss_fx), "mengpo_wind_hit", "待机", true, 5);
                ly_damage_row(grid_row);
            }
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
        case BOSS_STATE.SKILL3: { // 茶 + 菇
            if (ly_phase == 0) {
                if (ly_action != "正常技能3") longyuan_clip_set("正常技能3");
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) { // 罐子循环，期间生成茶树与蘑菇作为持续输出单位
                if (ly_action != "正常技能3罐子循环") longyuan_clip_set("正常技能3罐子循环");
                longyuan_clip_frame(timer, ly_anim_rate, true);
                if (timer == 1) { // 占位：生成茶树（常驻）
                    longyuan_boss_fx_start(instance_create_depth(x - 60, y + 20, -200, obj_ly_boss_fx), "mengpo_tea_tree", "生长出树枝", false, 5, "树枝待机", true);
                }
                if (timer == 12) { // 占位：生成蘑菇（常驻）
                    longyuan_boss_fx_start(instance_create_depth(x - 120, y + 20, -200, obj_ly_boss_fx), "mengpo_mushroom", "出生", false, 5, "待机", true);
                }
                if (timer >= 48) { ly_phase = 2; timer = 0; } // 占位：循环时长
            }
            else if (ly_phase == 2) {
                if (ly_action != "正常技能3收茶叶") longyuan_clip_set("正常技能3收茶叶");
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 3; timer = 0; }
            }
            else if (ly_phase == 3) {
                if (ly_action != "正常技能3控制倒水") longyuan_clip_set("正常技能3控制倒水");
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 4; timer = 0; }
            }
            else {
                if (ly_action != "正常技能3结束") longyuan_clip_set("正常技能3结束");
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        }
    }
};
