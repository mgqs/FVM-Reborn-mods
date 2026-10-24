// 连体 BOSS 的副体（如哼哈将军牛头）共用血量与 ID，不参与 boss_count/波次推进，也不销毁共用血条
if (ly_boss_is_peer) exit;

// 主体阵亡时同步清理仍存活的副体（同一 ID 与生命值）
if (instance_exists(ly_shared_boss_peer)) instance_destroy(ly_shared_boss_peer);

// BOSS 阵亡：扣减 boss_count、推进波次/结算胜利，并清理血条（照 obj_arno Destroy，去掉阿诺专属解锁）
with obj_battle {
    if boss_count > 1 {
        boss_count--;
    }
    else {
        boss_count = 0;
        if current_wave == total_wave - 1 {
            battle_finish_win();
        }
        else {
            level_stage = "pre";
            current_wave += 1;
            current_subwave = 0;
        }
    }
}
// BOSS 阵亡：切回原本的精英阶段音乐（龙渊 BOSS 均在精英阶段登场）
if (instance_exists(obj_battle_music_controller)) {
    with (obj_battle_music_controller) {
        new_battle_music = global.level_data.elite_music;
        event_user(10);
    }
}
if (instance_exists(hpbar_inst)) instance_destroy(hpbar_inst);
