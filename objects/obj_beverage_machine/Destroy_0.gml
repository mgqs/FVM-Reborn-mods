with obj_battle{
	if boss_count > 1{
		boss_count--
	}
	else{
		boss_count = 0
		// 测试关卡：BOSS 只是被放下来测伤害的木桩，打死不结算（所有玩法模式一致）
		if (!battle_is_test_level()) {
			if  current_wave == total_wave-1 {
				// 2026-11-03：改走统一胜利入口，抽卡 / 欧皇模式才会掉抽卡礼盒
				battle_finish_win();
			}
			else{
				level_stage = "pre"
				current_wave += 1
				current_subwave = 0
			}
		}
	}
}
ds_list_destroy(avaliable_pos)
instance_destroy(hpbar_inst)
