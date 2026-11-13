/// Runs in a disposable project built with the real desktop staging code.
function layout_assert(_ok, _message) {
    if (!_ok) {
        show_debug_message("DESKTOP_ASSETS_FAIL: " + _message);
        game_end();
    }
}

function layout_probe_step() {
    frame_number++;
    if (frame_number == 1) {
        layout_assert(resource_memory_enabled(), "grouped resource detection");
        layout_assert(!file_exists("cards_0.yytex"), "texture at resource root");
        layout_assert(!file_exists("mus_town.ogg"), "music at resource root");
        texturegroup_load("cards", false);
        texturegroup_load("enemy_longyuan", false);
        texturegroup_load("cards_ui", false);
        sprite_prefetch(spr_layout_card);
        sprite_prefetch(spr_layout_enemy);
        sprite_prefetch(spr_layout_icon);
        audio_sound_gain(mus_town, 0.25, 0);
        audio_sound_set_track_position(mus_town, 0.2);
        voice = audio_play_sound(mus_town, 0, true);
        other_voice = audio_play_sound(mus_menu, 0, true, 0.5, 0, 1.1);
        effect_voice = audio_play_sound(snd_layout_effect, 1, false);
        layout_assert(voice != -1 && other_voice != -1 && effect_voice != -1, "native playback IDs");
    }
    if (frame_number == 6) {
        layout_assert(audio_is_playing(mus_town) && audio_is_playing(mus_menu), "both streamed assets play");
        layout_assert(audio_sound_length(mus_town) > 2, "streamed duration");
        layout_assert(abs(audio_sound_get_gain(mus_town) - 0.25) < 0.01, "music volume");
        layout_assert(audio_sound_get_track_position(voice) >= 0.2, "asset-level start position");
        layout_assert(texturegroup_get_status("cards") != texturegroup_status_unloaded, "dynamic texture path");
        layout_assert(texturegroup_get_status("enemy_longyuan") != texturegroup_status_unloaded, "enemy texture path");
        audio_pause_sound(mus_town);
    }
    if (frame_number == 12) {
        layout_assert(audio_is_paused(mus_town), "pause by asset ID");
        paused_position = audio_sound_get_track_position(voice);
        audio_sound_gain(mus_town, 0.1, 0);
    }
    if (frame_number == 18) {
        layout_assert(abs(audio_sound_get_track_position(voice) - paused_position) < 0.05, "pause retains position");
        audio_resume_sound(mus_town);
    }
    if (frame_number == 25) {
        layout_assert(!audio_is_paused(mus_town) && audio_is_playing(mus_town), "resume by asset ID");
        layout_assert(audio_sound_get_track_position(voice) > paused_position, "resume advances position");
        audio_stop_sound(mus_town);
        layout_assert(!audio_is_playing(voice) && audio_is_playing(other_voice), "stop by asset ID isolates tracks");
        voice = audio_play_sound(mus_town, 0, true);
    }
    if (frame_number == 32) {
        audio_stop_sound(voice);
        layout_assert(!audio_is_playing(mus_town), "stop by voice ID");
        custom_stream = audio_create_stream("boss_music_pack/custom.ogg");
        layout_assert(custom_stream != -1, "custom audio path");
        custom_voice = audio_play_sound(custom_stream, 1, true);
    }
    if (frame_number == 40) {
        layout_assert(audio_is_playing(custom_voice), "custom stream playback");
        audio_pause_all();
    }
    if (frame_number == 46) {
        layout_assert(audio_is_paused(other_voice) && audio_is_paused(custom_voice), "pause all");
        audio_resume_all();
    }
    if (frame_number == 55) {
        layout_assert(audio_is_playing(other_voice) && !audio_is_paused(other_voice), "resume all");
        audio_stop_sound(custom_stream);
        audio_destroy_stream(custom_stream);
        audio_stop_sound(mus_menu);
        texturegroup_unload("cards");
        texturegroup_unload("enemy_longyuan");
        texturegroup_unload("cards_ui");
        show_debug_message("DESKTOP_ASSETS_PASS");
        game_end();
    }
}
