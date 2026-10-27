if global.is_paused {
    exit;
}

// 注册到全局敌人类型注册表（照 obj_arno Step 第 6-22 行）
if (!enemy_registered || enemy_registered_type != target_type) {
    if (enemy_registered) {
        var _old_list = global.enemy_by_type[$ enemy_registered_type];
        var _old_idx = array_get_index(_old_list, id);
        if (_old_idx != -1) array_delete(_old_list, _old_idx, 1);
    }
    if (!variable_global_exists("enemy_by_type")) {
        global.enemy_by_type = {};
    }
    var _reg_key = target_type;
    if (!variable_struct_exists(global.enemy_by_type, _reg_key)) {
        global.enemy_by_type[$ _reg_key] = [];
    }
    array_push(global.enemy_by_type[$ _reg_key], id);
    enemy_registered = true;
    enemy_registered_type = target_type;
}

if flash_value > 0 {
    flash_value -= 10;
}

// 延迟创建血条：先由子类 Create 设好 mouse_id，再建血条，规避 Create 顺序问题
if (!ly_hpbar_done && mouse_id != "") {
    // 连体 BOSS（哼哈将军牛头/马面）共用一条血条：沿用同伴已创建的血条
    if (instance_exists(ly_shared_boss_peer) && ly_shared_boss_peer.ly_hpbar_done) {
        hpbar_inst = ly_shared_boss_peer.hpbar_inst;
        ly_hpbar_done = true;
    }
    else {
        hpbar_inst = instance_create_depth(450, 1040, -900, obj_boss_hpbar);
        hpbar_inst.target_boss = id;
        hpbar_inst.boss_id = mouse_id;
        if (obj_battle.boss_count > 0) hpbar_inst.y -= 40;
        ly_hpbar_done = true;
    }
}

// 死亡判定（照 obj_arno）
if (hp <= 0 && state != BOSS_STATE.DEATH) {
    // 连体 BOSS 的副体不重复发放击杀奖励
    if (!ly_boss_is_peer) global.save_data.player.gold += 500;
    timer = 0;
    state = BOSS_STATE.DEATH;
    target_plant = noone;  // 清除攻击目标
    with obj_battle {
        if boss_count <= 1 && current_wave >= total_wave - 1 {
            timer_pause = true;
        }
    }
}

if (state == BOSS_STATE.DEATH) {
    // 由父对象统一播放死亡动作，播完后淡出并停在最后一帧
    if (ly_action != "死亡") longyuan_clip_set("死亡");
    longyuan_clip_frame(timer, ly_anim_rate, false);
    if (longyuan_clip_done(timer, ly_anim_rate)) {
        image_alpha -= 0.1;
    }
}
else {
    // 子类把状态机实现为 ly_boss_step 函数
    if (variable_instance_exists(id, "ly_boss_step")) ly_boss_step();
}

timer++;

// 透明度处理
if (image_alpha <= 0 && state == BOSS_STATE.DEATH) {
    instance_destroy();
    exit;
}

// 网格位置与深度更新（照 obj_arno Step 第 210-220 行）
var zombie_grid = get_grid_position_from_world(x, y);
var base_depth = -10 - (zombie_grid.row * 45) - (zombie_grid.col * 5);
// 比龙柱（同格卡片深度 - 8）再往前 4，保证龙柱「在卡片之上、BOSS 之下」的层次
depth = base_depth - 12;
grid_col = zombie_grid.col;
grid_row = zombie_grid.row;
