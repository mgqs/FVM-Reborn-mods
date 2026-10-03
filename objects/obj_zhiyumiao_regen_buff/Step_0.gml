if (global.is_paused)
    exit;

// 目标不存在或已阵亡：销毁Buff，不复活
if (!instance_exists(target_id) || target_id.hp <= 0) {
    instance_destroy();
    exit;
}

// 跟随目标位置
x = target_id.x;
y = target_id.y;

// 减速时tick间隔翻倍
var _tick_interval = tick_interval_frames;
if (variable_instance_exists(target_id, "is_slowdown") && target_id.is_slowdown)
    _tick_interval *= 2;

elapsed_frames++;
tick_timer_frames++;

// 周期跳血
if (tick_timer_frames >= _tick_interval) {
    tick_timer_frames = 0;

    var _applied = min(tick_amount, target_id.max_hp - target_id.hp);
    if (_applied > 0) {
        target_id.hp += _applied;
        instance_create_depth(target_id.x, target_id.y + 30, target_id.depth - 4, obj_card_heal_effect);
    }
}

// 持续时间耗尽：销毁
var _duration = duration_frames;
if (variable_instance_exists(target_id, "is_slowdown") && target_id.is_slowdown)
    _duration *= 2;

if (elapsed_frames >= _duration)
    instance_destroy();
