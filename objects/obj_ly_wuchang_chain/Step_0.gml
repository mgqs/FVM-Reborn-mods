if (global.is_paused) exit;

// 锁链不移动：固定在生成格，由父类负责注册与受伤状态。
var _saved_index = image_index;
var _saved_alpha = image_alpha;
state = ENEMY_STATE.ACTING;
event_inherited();
if (!instance_exists(id)) exit;
image_index = _saved_index;
image_alpha = _saved_alpha;
depth = -600; // 图层在卡片上方

if (chain_col < 0) { chain_col = grid_col; chain_row = grid_row; }

// 被击毁：播死亡帧
if (hp <= 0 && ly_mode != "dead") {
    ly_mode = "dead";
    longyuan_play("死亡", true);
}

// 存在期间锁定本格卡片的铲除（只锁定一次，恢复时只恢复自己锁过的）
if (ly_mode == "idle" && chain_col >= 0 && chain_col < global.grid_cols && chain_row >= 0 && chain_row < global.grid_rows) {
    var _l = ds_grid_get(global.grid_plants, chain_col, chain_row);
    for (var _i = 0; _i < ds_list_size(_l); _i++) {
        var _p = _l[| _i];
        if (!instance_exists(_p) || !variable_instance_exists(_p, "can_shovel_remove")) continue;
        if (_p.plant_id == "player") continue;
        if (_p.can_shovel_remove) {
            _p.can_shovel_remove = false;
            ds_list_add(locked_cards, _p);
        }
    }
}

longyuan_animate();
if (ly_mode == "dead" && ly_done) instance_destroy();
