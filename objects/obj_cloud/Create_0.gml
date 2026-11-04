image_xscale = 1.8
image_yscale = 1.8
image_speed = 0

image_alpha = 0

col = -1
row = -1
is_hole = false
timer = 0

// 【已停用】棉花糖空缺不再伤害任何老鼠（obj_cloud/Step_0 里对敌人的判定已移除），
// 这份名单仅作历史保留。若以后要恢复「部分 BOSS 免疫、其余老鼠被吞」，把 Step_0 的
// with obj_enemy_parent 段落加回去即可复用。
ignore_list = ["mario_mouse","mario_pipeline","arno","pharaoh_coffin","temple_pharaoh","ice_residue","rumble","abyss_pharaoh",
				"pink_paul","paul_tentacle","blonde_mary","pete","pete_claw","pete_spike","hells_messenger","messenger_mace","messenger_poop",
				"needle_baron","fog_julie","lieutenant_buzz","hot_vajra","hot_vajra_spike","irritable_jack","irritable_jack_rock","bat_mouse",
				"huang_xiaoming","angelababy","mouse_train_1","captain_america_mouse","captain_rainbow","iron_man_mouse","mouse_train_2",
				"iron_man","spider_man_mouse","hulk_mouse","mouse_train_3","mermaid_mary","mermaid_wave","machine_shark_1",
				"lobster_knight","electric_jellyfish","jellyfish_bullet","war_god","war_god_duck","war_god_wood","hercules","thor",
				"kuafu_boss_buzz","kuafu_boss_julie","kuafu_boss_pete","kuafu_boss_baron","kuafu_boss_xiaoming","kuafu_boss_pete_claw","kuafu_boss_pete_spike"
]