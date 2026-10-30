/// @function battle_is_test_level()
/// @desc 当前是否在测试关卡里。测试关卡是沙盒：永远不会结算（不出胜利界面、
///       不写通关记录、不发奖励），放下的老鼠包括 BOSS 都只当普通老鼠打。
///       关卡 id 与通关判定同源（global.level_data.id），取不到时退回 global.level_id
function battle_is_test_level() {
    // 先后顺序要紧：global.level_id 每次进关都会被重写，是最可信的来源；
    // global.level_data 可能残留上一关的数据，只作为兜底
    if (variable_global_exists("level_id") && is_string(global.level_id) && global.level_id != "") {
        return (global.level_id == "test_level");
    }
    if (variable_global_exists("level_data") && is_struct(global.level_data)
        && variable_struct_exists(global.level_data, "id")
        && global.level_data.id == "test_level") return true;
    return false;
}

/// @function battle_finish_win()
/// @desc 统一胜利入口函数，根据难度决定创建普通胜利对象还是礼盒对象
function battle_finish_win() {
    if (battle_is_test_level()) return;   // 测试关卡：只测试，不结算（所有玩法模式一致）
    if (global.game_over) return;

    global.game_over = true;
    global.is_paused = true;

    // 海克斯：胜利瞬间记账（重复通关也要记，所以不能只放在首次通关的 complete_level 里）。
    // 放在这里是因为清场判胜根本不经过 BOSS 的 Destroy_0，掉落拿到的词条会漏记。
    // 内部自己对 committed 幂等，与 BOSS 死亡路径重复调用不会写两次。
    hex_on_win();

    if (is_eternal_gacha_mode()) {
        instance_create_depth(
            room_width / 2,
            room_height / 2,
            -3001,
            obj_gacha_drop
        );
        return;
    }

    var over = instance_create_depth(
        room_width / 2,
        room_height / 2,
        -3001,
        obj_game_over
    );

    over.sprite_index = spr_win;
    audio_play_sound(snd_win, 0, 0);
}
