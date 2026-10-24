if unlocked{
	global.audio.play(snd_button,0,0)
	obj_world_map_button.world_map = 0
	panel_anim_close(obj_world_map_menu)
	if map_id == "undersea_vortex"{
		texture_prefetch("pack_undersea_vortex")
	}
	if map_id != "tower_cake"{
		var _known_map = ds_map_exists(global.maps_map, map_id)
		if _known_map && global.map_id != map_id{
			if room == room_target {
				room_transition_in_place(map_switch_apply, { id: map_id, name: map_name })
			} else {
				global.map_name = map_name
				global.map_id = map_id
			}
		}
		if room != room_target{
			global.gui_stack.to(room_target)
		}
	}
	else{
		global.gui_stack.to(room_tower_cake)
	}
}
else{
	if level_require > 80{
		show_notice("暂未开放，敬请期待！",60)
	}
	else{
		show_notice("达到"+string(level_require)+"级以解锁此地图",60)
	}
}
