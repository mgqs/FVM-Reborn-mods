/// @function battle_finish_win()
/// @desc 统一胜利入口函数，根据难度决定创建普通胜利对象还是礼盒对象
function battle_finish_win() {
    if (global.game_over) return;

    global.game_over = true;
    global.is_paused = true;

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
