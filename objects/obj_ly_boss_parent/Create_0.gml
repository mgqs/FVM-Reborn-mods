// 继承 obj_enemy_parent 的默认值（hp/hurt_rate/timer/target_plant/flash_value/enemy_registered 等）
event_inherited();

// ===== 龙渊 BOSS 公共状态 =====
is_boss = true;
// 龙渊 BOSS 防爆：炸弹等秒杀类效果只造成伤害，不能直接消灭 BOSS。
immune_to_ash = true;
ly_kind = "";
ly_anims = {};
ly_action = "";
ly_frame = 0;
ly_hit = false;
ly_done = false;
ly_anim_rate = 5;       // 每动画帧停留 5 步（约 12fps）
ly_hpbar_done = false;  // 血条是否已延迟创建
hpbar_inst = noone;     // 血条实例（Destroy 时清理）
ly_shared_boss_peer = noone;
ly_boss_is_peer = false;  // 连体 BOSS 的副体（如哼哈将军牛头），不参与 boss_count 与波次推进
ly_phase = 0;           // 技能分段的子阶段计时（子类复用）
state = BOSS_STATE.APPEAR;
image_speed = 0;        // BOSS 动画完全由 longyuan_clip_* 驱动，禁用引擎自动帧推进
// flash_value 保持 obj_enemy_parent 默认（0）

// ===== 通用伤害辅助（统一读取 atk，atk 由子类设占位值）=====
/// 对 grid_row 行的某一列所有植物造成伤害
ly_damage_col = function(_col_in) {
    if (_col_in < 0 || _col_in >= global.grid_cols || grid_row < 0 || grid_row >= global.grid_rows) return;
    var _list = ds_grid_get(global.grid_plants, _col_in, grid_row);
    for (var _i = 0; _i < ds_list_size(_list); _i++) {
        var _p = ds_list_find_value(_list, _i);
        if (instance_exists(_p)) longyuan_damage_plant(_p, atk);
    }
};

/// 对指定行的整行植物造成伤害
ly_damage_row = function(_row) {
    if (_row < 0 || _row >= global.grid_rows) return;
    for (var _c = 0; _c < global.grid_cols; _c++) {
        var _list = ds_grid_get(global.grid_plants, _c, _row);
        for (var _i = 0; _i < ds_list_size(_list); _i++) {
            var _p = ds_list_find_value(_list, _i);
            if (instance_exists(_p)) longyuan_damage_plant(_p, atk);
        }
    }
};

/// 本行最靠左的植物所在列（占位：MOVE 靠近目标列）
ly_target_col = function() {
    for (var _j = 0; _j < global.grid_cols; _j++) {
        var _l = ds_grid_get(global.grid_plants, _j, grid_row);
        if (ds_list_size(_l) != 0) return _j;
    }
    return 0;
};
