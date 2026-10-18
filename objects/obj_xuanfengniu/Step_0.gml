if global.is_paused { exit; }
event_inherited();

if (is_frozen) { exit; }

// 起手动画播放完一整轮（image_index 环绕归零）后触发一次全屏吹走，随后卡片退场
// 通过环绕检测而非固定帧数计时，减速/冻结等状态下也能与实际动画进度对齐
var _anim_loop_done = (image_index < prev_image_index);
prev_image_index = image_index;

if (!has_activated && _anim_loop_done) {
    has_activated = true;
    is_activating = true;
    state = CARD_STATE.RELAX;

    // 1) 快照指定名单内的老鼠，逐个执行秒杀。
    var _ids = [];

    with (obj_enemy_parent) {
        if (hp <= 0) continue;
        if (state == ENEMY_STATE.DEAD) continue;
        if (array_get_index(other.instant_kill_mouse_ids, mouse_id) == -1) continue;

        array_push(_ids, id);
    }

    // 按 id 升序稳定排序，保证幂等
    array_sort(_ids, function(a, b) {
        if (a < b) return -1;
        if (a > b) return 1;
        return 0;
    });

    // 2) 逐个幂等移除（秒杀方式：不掉金币、不计击杀）
    for (var i = 0; i < array_length(_ids); i++) {
        var _e = _ids[i];
        if (!instance_exists(_e)) continue;
        if (_e.hp <= 0 || _e.state == ENEMY_STATE.DEAD) continue;

        // 标记移除原因，跳过金币掉落与击杀奖励
        _e.is_blown_away = true;
        _e.hp = 0;
        _e.shield_hp = 0;
        _e.helmet_hp = 0;
        _e.state = ENEMY_STATE.DEAD;
        _e.target_type = "normal";
        instance_create_depth(_e.x, _e.y, _e.depth - 10, obj_xuanfengniu_effect);
        instance_destroy(_e);
    }

    // 3) 一转及以上：清障结算
    //    分别处理不同类型的障碍对象，确保不遗漏
    if (can_clear_obstacles) {
        var _obstacles = [];

        // 3a) 鼠洞（独立对象，不继承 obj_enemy_parent）
        with (obj_mouse_hole) {
            if (!instance_exists(id)) continue;
            array_push(_obstacles, id);
        }

        // 3b) 梯子（独立对象，不继承 obj_enemy_parent）
        with (obj_ladder) {
            if (!instance_exists(id)) continue;
            array_push(_obstacles, id);
        }

        // 3c) 弹簧（独立对象，不继承 obj_enemy_parent）
        with (obj_mouse_spring) {
            if (!instance_exists(id)) continue;
            array_push(_obstacles, id);
        }

        // 3d) 继承自 obj_enemy_parent 的障碍（如 barrier）
        with (obj_enemy_parent) {
            if (target_type != "obstacle") continue;
            if (!instance_exists(id)) continue;
            if (is_boss) continue;
            array_push(_obstacles, id);
        }

        // 逐个清除障碍
        for (var i = 0; i < array_length(_obstacles); i++) {
            var _obs = _obstacles[i];
            if (!instance_exists(_obs)) continue;
            instance_create_depth(_obs.x, _obs.y, _obs.depth - 10, obj_xuanfengniu_effect);
            instance_destroy(_obs);
        }
    }
}

if (is_activating) {
    image_alpha -= 0.1;
    if (image_alpha <= 0) {
        instance_destroy();
    }
}
