event_inherited();
image_speed = 0; // 动画完全由 longyuan_clip_* 驱动
// 敌人父类默认 1.8 倍显示尺寸；记录原始缩放，所有动作都必须沿用，避免横纵比例不一致被拉扁
ly_scale_x = image_xscale;

// ===== 无常鼠（白/黑双形态，技能 1→2→3→4 循环）=====
ly_kind = "wuchang";
ly_anims = longyuan_animation_table("wuchang");
mouse_id = "ly_wuchang";
hp = 250000; maxhp = 250000;

// 对象无默认精灵：创建当帧先把 sprite_index 设为出生动作，避免 Draw 时精灵为 -1
ly_action = "";
longyuan_play("出生");

// ===== 数值 =====
atk = 5000;
wait_time = 120;                 // 待机时长（步）
ly_bai = true;                   // 当前形态：true=白 false=黑（初始为白形态）
ly_skill_index = 0;              // 技能循环指针
ly_next_state = BOSS_STATE.SKILL1;
ly_tp_x = x; ly_tp_y = y;        // 闪入目标位置
ly_row = -1;                     // 技能1目标行
ly_banner_col = -1; ly_banner_row = -1; // 技能4法杖目标格
ly_wheel_done = false;           // 技能3魂勾绕圈完成标记

// 技能对应形态：1黑、2白、3白、4黑
ly_skill_is_bai = function(_st) {
    return (_st == BOSS_STATE.SKILL2 || _st == BOSS_STATE.SKILL3);
};

ly_idle_action = function() { return ly_bai ? "白待机" : "黑待机"; };
ly_shanchu_action = function() { return ly_bai ? "白闪出" : "黑闪出"; };
ly_shanru_action = function() { return ly_bai ? "白闪入" : "黑闪入"; };

// 计算技能起手位置（设计坐标为 1 基(行,列)，内部换算为 0 基(col,row)）
ly_prepare_skill = function(_st) {
    var _gp;
    switch (_st) {
        case BOSS_STATE.SKILL1: // 随机某一行第9列
            ly_row = irandom(global.grid_rows - 1);
            _gp = get_world_position_from_grid(global.grid_cols - 1, ly_row);
            break;
        case BOSS_STATE.SKILL2: // 第2列随机一行
            _gp = get_world_position_from_grid(1, irandom(global.grid_rows - 1));
            break;
        case BOSS_STATE.SKILL3: // (7,1)
            _gp = get_world_position_from_grid(0, global.grid_rows - 1);
            break;
        case BOSS_STATE.SKILL4: // (1,8)或(7,8) → 法杖目标(7,2)或(1,2)
            var _sr = choose(0, global.grid_rows - 1);
            ly_banner_row = (_sr == 0) ? global.grid_rows - 1 : 0;
            ly_banner_col = 1;
            _gp = get_world_position_from_grid(global.grid_cols - 2, _sr);
            break;
    }
    ly_tp_x = _gp.x; ly_tp_y = _gp.y;
};

ly_boss_step = function() {
    var _act;

    // 闪出/闪入位移期间与技能3回收瞬移期间无敌
    invincible = (state == BOSS_STATE.MOVE) || (state == BOSS_STATE.SKILL3 && ly_phase >= 2);

    switch (state) {
        case BOSS_STATE.APPEAR: { // 出场
            if (ly_action != "出生") longyuan_clip_set("出生");
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
        case BOSS_STATE.IDLE: {
            image_xscale = ly_scale_x;
            _act = ly_idle_action();
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, true);
            if (timer >= wait_time) {
                // 按 1→2→3→4 循环取下一个技能，形态由下一个技能决定
                var _cycle = [BOSS_STATE.SKILL1, BOSS_STATE.SKILL2, BOSS_STATE.SKILL3, BOSS_STATE.SKILL4];
                ly_next_state = _cycle[ly_skill_index mod array_length(_cycle)];
                ly_skill_index++;
                ly_bai = ly_skill_is_bai(ly_next_state);
                ly_prepare_skill(ly_next_state);
                ly_phase = 0; timer = 0; state = BOSS_STATE.MOVE;
            }
            break;
        }
        case BOSS_STATE.MOVE: { // 技能前摇：原位置闪出 → 新位置闪入（均为下一个技能的形态）
            if (ly_phase == 0) {
                image_xscale = ly_scale_x;
                _act = ly_shanchu_action();
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    x = ly_tp_x; y = ly_tp_y;
                    ly_phase = 1; timer = 0;
                    if (ly_next_state == BOSS_STATE.SKILL2) image_xscale = -ly_scale_x; // 献宝朝右（沿用原始缩放镜像）
                }
            }
            else {
                _act = ly_shanru_action();
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    if (ly_next_state == BOSS_STATE.SKILL3) {
                        // 降落至(7,1)：踩扁该格美食（直接摧毁，无爆炸特效）
                        var _sc = ds_grid_get(global.grid_plants, 0, global.grid_rows - 1);
                        for (var _si = ds_list_size(_sc) - 1; _si >= 0; _si--) {
                            var _sd = _sc[| _si];
                            if (!instance_exists(_sd) || _sd.plant_id == "player" || _sd.plant_type == "coffee") continue;
                            longyuan_destroy_card(_sd, true);
                        }
                    }
                    ly_phase = 0; timer = 0; state = ly_next_state;
                }
            }
            break;
        }
        case BOSS_STATE.SKILL1: { // 黑无常拘魂：向本行第2列投出锁链，播完后本行2~9列出现可击毁锁链
            _act = "技能1";
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (!ly_hit && ly_frame >= 13) { // 投出锁链
                ly_hit = true;
                var _to = get_world_position_from_grid(1, ly_row);
                var _fx = instance_create_depth(x - 40, y - 30, -1300, obj_ly_boss_fx);
                longyuan_boss_fx_start(_fx, "wuchang_chain", "待机", true, 5);
                _fx.fx_kind = "wuchang_chain_throw";
                _fx.fx_target_x = _to.x; _fx.fx_speed = 10;
            }
            if (longyuan_clip_done(timer, ly_anim_rate)) {
                for (var _c = 1; _c <= global.grid_cols - 1; _c++) {
                    var _dup = false;
                    with (obj_ly_wuchang_chain) {
                        if (hp > 0 && chain_col == _c && chain_row == other.ly_row) _dup = true;
                    }
                    if (_dup) continue;
                    var _cp = get_world_position_from_grid(_c, ly_row);
                    var _ch = instance_create_depth(_cp.x, _cp.y, -600, obj_ly_wuchang_chain);
                    _ch.chain_col = _c; _ch.chain_row = ly_row;
                }
                timer = 0; state = BOSS_STATE.IDLE;
            }
            break;
        }
        case BOSS_STATE.SKILL2: { // 白无常献宝：第18帧向7~9列随机格丢出元宝
            _act = "技能2";
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (!ly_hit && ly_frame >= 18) { // 丢出元宝
                ly_hit = true;
                var _tc = irandom_range(global.grid_cols - 3, global.grid_cols - 1);
                var _tr = irandom(global.grid_rows - 1);
                var _tp = get_world_position_from_grid(_tc, _tr);
                var _fx = instance_create_depth(x + 40, y - 60, -1300, obj_ly_boss_fx);
                longyuan_boss_fx_start(_fx, "wuchang_yuanbao", "飞行", true, 5);
                _fx.fx_kind = "wuchang_yuanbao";
                _fx.fx_stage = 0;
                _fx.fx_col = _tc; _fx.fx_row = _tr;
                _fx.fx_target_x = _tp.x; _fx.fx_target_y = _tp.y;
                _fx.fx_owner = id; _fx.fx_speed = 9;
            }
            if (longyuan_clip_done(timer, ly_anim_rate)) {
                image_xscale = ly_scale_x; // 恢复朝左（原始缩放）
                timer = 0; state = BOSS_STATE.IDLE;
            }
            break;
        }
        case BOSS_STATE.SKILL3: { // 白无常勾魂：扔出魂勾顺时针绕最外圈一周，随后在(1,9)回收
            if (ly_phase == 0) {
                _act = "技能3";
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (!ly_hit && ly_frame >= 13) { // 扔出魂勾
                    ly_hit = true;
                    // 魂勾从(1,9)出现，顺时针沿最外圈移动完整一周
                    var _path = [];
                    var _R = global.grid_rows - 1, _C = global.grid_cols - 1;
                    for (var _r = 1; _r <= _R; _r++) array_push(_path, [_r, _C]);       // 右列下行
                    for (var _c = _C - 1; _c >= 0; _c--) array_push(_path, [_R, _c]);   // 底行左行
                    for (var _r = _R - 1; _r >= 0; _r--) array_push(_path, [_r, 0]);    // 左列上行
                    for (var _c = 1; _c <= _C; _c++) array_push(_path, [0, _c]);        // 顶行右行回到(1,9)
                    var _sp = get_world_position_from_grid(_C, 0);
                    var _fx = instance_create_depth(_sp.x, _sp.y, -1300, obj_ly_boss_fx);
                    longyuan_boss_fx_start(_fx, "wuchang_fire_wheel", "旋转", true, 5);
                    _fx.fx_kind = "wuchang_fire_wheel_live";
                    _fx.fx_path = _path; _fx.fx_path_idx = 0; _fx.fx_speed = 7;
                    _fx.fx_owner = id; _fx.fx_last_cell = "";
                    ly_wheel_done = false;
                }
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) { // 原地待机等待魂勾绕完一周
                _act = ly_idle_action();
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                if (ly_wheel_done) { ly_phase = 2; timer = 0; }
            }
            else if (ly_phase == 2) { // 闪出，前往(1,9)回收
                _act = ly_shanchu_action();
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    var _gp = get_world_position_from_grid(global.grid_cols - 1, 0);
                    x = _gp.x; y = _gp.y;
                    ly_phase = 3; timer = 0;
                }
            }
            else { // 在(1,9)闪入回收
                _act = ly_shanru_action();
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        }
        case BOSS_STATE.SKILL4: { // 黑无常招魂：沿对角线扔出鸡毛掸子法杖
            if (ly_phase == 0) {
                _act = "技能4开始";
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (!ly_hit && ly_frame >= 13) { // 扔出法杖
                    ly_hit = true;
                    var _tp = get_world_position_from_grid(ly_banner_col, ly_banner_row);
                    var _fx = instance_create_depth(x, y - 60, -1300, obj_ly_boss_fx);
                    longyuan_boss_fx_start(_fx, "wuchang_soul_banner", "待机", true, 5);
                    _fx.fx_kind = "wuchang_soul_banner_live";
                    _fx.fx_target_x = _tp.x; _fx.fx_target_y = _tp.y;
                    _fx.fx_speed = 9; _fx.fx_last_cell = "";
                    _fx.image_angle = point_direction(x, y - 60, _tp.x, _tp.y); // 法杖沿对角线倾斜
                }
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else {
                _act = "技能4结束";
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        }
    }
};
