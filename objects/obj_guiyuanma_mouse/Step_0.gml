event_inherited();
// 归元马送回鼠专属动画（父级 Step 之后再覆盖 image_index）：
// 0-7 送回登场（单次）→ 7-15 行走（循环）→ 16-23 啃咬（循环）→ 23-34 死亡（单次后淡出）
if (global.is_paused) exit;
var _step = max(1,flash_speed);
if (state == ENEMY_STATE.DEAD) {
    if (ash_death) exit; // 灰烬死亡由父级逻辑直接隐藏并移除
    var _progress = min(floor(timer/_step),gy_death_end-gy_death_start);
    image_index = gy_death_start+_progress;
    if (_progress >= gy_death_end-gy_death_start) image_alpha -= 0.08; // 播完后淡出，销毁与注销仍由父级处理
    exit;
}
if (state == ENEMY_STATE.ATTACK) {
    gy_returning = false;
    image_index = gy_bite_start+(floor(timer/_step) mod (gy_bite_end-gy_bite_start+1));
    exit;
}
if (state == ENEMY_STATE.NORMAL) {
    if (gy_returning) {
        var _frame = min(gy_return_start+floor(timer/_step),gy_return_end);
        image_index = _frame;
        if (_frame >= gy_return_end) { gy_returning = false; timer = 0; } // 登场动画播完进入行走
    }
    else {
        image_index = gy_walk_start+(floor(timer/_step) mod (gy_walk_end-gy_walk_start+1));
    }
    exit;
}
