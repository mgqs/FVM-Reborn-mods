if (ds_exists(chomp_sound_list, ds_type_list)) {
	ds_list_destroy(chomp_sound_list);
}

// ══════════ 海克斯：本关没通关就离开战斗 = 放弃本局（docs 1.2 / 6.1）══════════
// 通关离场由 complete_level() 置 hex_level_cleared，此时保留序列标记以便魔塔等连续关接着算
if (hex_enabled() && !global.hex_level_cleared) {
    hex_reset_run();
}
global.hex_level_cleared = false;