image_xscale = 1.8
image_yscale = 1.8
image_speed = 0
timer = 0
row = 0
state = "idle"
can_loss = true

move_speed = 4

flash_speed = 6
idle_anim = 10
awake_anim = 4
attack_anim = 8
attack_timer = 0

// 跨服·梦魇天空 变异僵尸 BOSS：与原版 BOSS（pete/needle_baron/fog_julie/lieutenant_buzz/huang_xiaoming）同口径，
// 不吃第 0 列猫的唤醒与撞击清理；pete_claw / pete_spike 对应原版同名附属物，
// 闹太套贴纸走无敌 + 必破 3 格，也不能被猫撞掉。
ignore_list = ["mario_mouse","mario_pipeline","arno","pharaoh_coffin","temple_pharaoh","ice_residue","rumble","abyss_pharaoh",
				"pink_paul","paul_tentacle","blonde_mary","pete","pete_claw","pete_spike","barrier","hells_messenger","messenger_mace","messenger_poop",
				"needle_baron","fog_julie","lieutenant_buzz","irritable_jack","hot_vajra","hot_vajra_spike","huang_xiaoming",
				"angelababy","angelababy_diamond","mouse_train_1","captain_america_mouse","captain_rainbow","iron_man_mouse","mouse_train_2",
				"iron_man","spider_man_mouse","hulk_mouse","mouse_train_3","mermaid_mary","mermaid_wave","machine_shark_1",
				"lobster_knight","electric_jellyfish","jellyfish_bullet","war_god","war_god_duck","war_god_wood","hercules",
				"thor","infected_arno","infected_mario_pipeline","infected_mario_mouse",
				"honglonglong","infected_zhanshen","infected_pharaoh","longyuan_dijing",
				"ly_diting","ly_youshen","travel_record","beverage_machine","face_cookie",
				"kuafu_boss_buzz","kuafu_boss_julie","kuafu_boss_pete","kuafu_boss_baron","kuafu_boss_xiaoming",
				"kuafu_boss_pete_claw","kuafu_boss_pete_spike","kuafu_boss_xiaoming_card",
				// 跨服·灼热地域 变异僵尸 BOSS：与其它 BOSS 同口径，不吃第 0 列猫的唤醒与冲撞秒杀；
				// 紧随其后的 4 个是技能产物，原版同名附属物（captain_rainbow / messenger_mace /
				// messenger_poop / hot_vajra_spike）本来就在豁免表里，这里保持一致（2026-11-05）
				"kf_zrb_mary","kf_zrb_shi","kf_zrb_jack","kf_zrb_vajra","kf_zrb_cap",
				"kf_zrb_cap_rainbow","kf_zrb_shi_mace","kf_zrb_shi_poop","kf_zrb_vajra_spike"
]

target_ignore = ["mole","bat_mouse","sawblade_mouse","dentist_mouse","baron_bats","paratrooper_mouse_shield","kamikaze_glider_mouse",
				"sardine_mouse",
				"kuafu_boss_baron_bats","kuafu_boss_buzz_para_shield"
]
