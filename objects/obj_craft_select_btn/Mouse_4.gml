if instance_exists(obj_craft_bg){
	// 转职确认窗开着 / 成功特效播放中：锁住页签切换
	// （否则切页会把 obj_craft_bg.tg_card 清掉，动画停住、待结算数据卡死在 tg_fx_pending）
	if (obj_craft_bg.tg_fx || obj_craft_bg.tg_confirm){
		exit
	}
	if (button_index == 2){
		// 卡片转职：切到 craft_top_tab == 2（再点一次不重复播声音）
		if (obj_craft_bg.craft_top_tab != 2){
			obj_craft_bg.craft_top_tab = 2
			obj_craft_bg.tg_card = ""
			global.audio.play(snd_button,0,0)
		}
		exit
	}
	// 卡片 / 宝石：先回到 craft_top_tab == 0（从转职页回来）
	if (obj_craft_bg.craft_top_tab != 0){
		obj_craft_bg.craft_top_tab = 0
		obj_craft_bg.tg_card = ""
	}
	if obj_craft_bg.button_select != button_index{
		obj_craft_bg.button_select = button_index
		obj_craft_bg.current_uprade_target_id = ""
		obj_craft_bg.y_offset = 0
		obj_craft_bg.hover_card_index = -1
		obj_craft_bg.hover_gem_index = -1
		global.audio.play(snd_button,0,0)
	}
}