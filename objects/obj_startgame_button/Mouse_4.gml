// 授权窗是模态的：没授权之前不许进游戏（否则点得到"开始"就绕过了强制授权）
if (variable_global_exists("auth_gate_open") && global.auth_gate_open) {
	exit;
}

if on_click and obj_player_info_ui.menu_type == 0 and global.preloaded{
	global.audio.play(snd_button,0,0)
	global.gui_stack.to(room_map)
	global.map_name = "美味岛"
	global.map_id = "delicious_island"
	//resource_texture_prepare("enemy_delicious")
	//resource_texture_prepare("enemy_volcanic")
	//resource_texture_prepare("enemy_tower")
}