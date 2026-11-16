image_xscale = 1.8
image_yscale = 1.8
image_speed = 0

// 巫毒研究所（spr_wuduyanjiusuo_*）：底图美术原本把铁笼（风洞外观）画进了地图，
// 与这里绘制的风洞特效叠成两层。现在底图上那 39 个铁笼已由
// tools/wudu_erase_windtunnel.py 擦除（原图备份在 output/_tmp/bak_wuduyanjiusuo_*），
// 特效成为唯一的风洞外观，因此恢复原尺寸 1.8 倍、并对齐到底图原铁笼。
// obj_battle 按 map_object_init 的 (x_offset 5, y_offset -35) 生成，这里先抵消掉；
// 抵消后精灵内容比原铁笼低 32 世界像素（实测：原铁笼底边在格心 +40.6，
// 精灵内容底边在格心 +72），再上移 32 才能与底图铁笼重合。
var _map_spr = "";
if (variable_global_exists("level_file") && is_struct(global.level_file)) {
	if (variable_struct_exists(global.level_file, "map_sprite")) {
		_map_spr = string(global.level_file.map_sprite);
	}
}
if (string_starts_with(_map_spr, "spr_wuduyanjiusuo")) {
	x -= 5;			// 抵消 x_offset +5
	y += 35 - 32;	// 抵消 y_offset -35，再上移 32 对齐底图原铁笼（红框实测距离）
}

timer = 0
attack_timer = 0
row = -1
col = -1
depth = 48

enemy_list = []
enemy_left_time = []

state = "idle"

ignore_list = ["mario_mouse","mario_pipeline","arno","pharaoh_coffin","temple_pharaoh","ice_residue","rumble","abyss_pharaoh",
				"pink_paul","paul_tentacle","blonde_mary","pete","pete_claw","pete_spike","hells_messenger","messenger_mace","messenger_poop",
				"needle_baron","fog_julie","lieutenant_buzz","hot_vajra","hot_vajra_spike","irritable_jack","irritable_jack_rock","bat_mouse",
				"huang_xiaoming","angelababy","mouse_train_1","captain_america_mouse","captain_rainbow","iron_man_mouse","mouse_train_2",
				"iron_man","spider_man_mouse","hulk_mouse","mouse_train_3","mermaid_mary","mermaid_wave","machine_shark_1",
				"lobster_knight","electric_jellyfish","jellyfish_bullet","war_god","war_god_duck","war_god_wood","hercules","thor"
]