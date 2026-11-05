image_xscale = 1.8
image_yscale = 1.8
image_speed = 0

timer = 0
attack_timer = 0
row = -1
col = -1

enemy_list = []
enemy_left_time = []

state = "idle"

ignore_list = ["mario_mouse","mario_pipeline","arno","pharaoh_coffin","temple_pharaoh","ice_residue","ice_residue_ball","abyss_pharaoh","pink_paul","paul_tentacle","blonde_mary","pete","pete_claw","pete_spike",
				"rowboat_mouse","barrier","hells_messenger","messenger_mace","messenger_poop","fog_julie","lieutenant_buzz","barrier","needle_baron","baron_bats","irritable_jack","irritable_jack_rock",
				"hot_vajra","hot_vajra_spike","paratrooper_mouse_shield","huang_xiaoming","angelababy","angelababy_diamond","mouse_train_1","captain_america_mouse","captain_rainbow","iron_man_mouse","iron_man",
				"mouse_train_2","spider_man_mouse","hulk_mouse","mouse_train_3","mermaid_mary","mermaid_wave","machine_shark_1","lobster_knight","electric_jellyfish","jellyfish_bullet","war_god",
				"war_god_duck","war_god_wood","hercules","thor",
				"kuafu_boss_buzz","kuafu_boss_julie","kuafu_boss_pete","kuafu_boss_baron","kuafu_boss_xiaoming","kuafu_boss_pete_claw","kuafu_boss_pete_spike",
				"kuafu_boss_baron_bats","kuafu_boss_buzz_para_shield",
				// 跨服·灼热地域 变异僵尸 BOSS 与其技能产物：原版同名对象（pete / hot_vajra / captain_rainbow 等）
				// 本来就在豁免表里，弹簧不该把它们弹晕（2026-11-05）
				"kf_zrb_mary","kf_zrb_shi","kf_zrb_jack","kf_zrb_vajra","kf_zrb_cap",
				"kf_zrb_cap_rainbow","kf_zrb_shi_mace","kf_zrb_shi_poop","kf_zrb_vajra_spike"
]

left_use_times = 5