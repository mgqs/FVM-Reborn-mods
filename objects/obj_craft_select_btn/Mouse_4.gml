// 🔴 2026-11-16：藏起来 ≠ 点不到。visible = false 只让 Draw 事件跳过，Mouse 事件照样派发。
//   本对象在「食灵融合 / 神级进化」页只是被 Step 里 `visible = false` 藏掉、并不销毁，
//   而它的位置（x-661，y-50 / y+100 / y+250）和神级进化页左侧那三个子页按钮
//   （x-660，y-80 / y+80 / y+240，46×85×1.8）**几乎完全重合** →
//   点「神器进化」会连带命中这里的「宝石强化」，把 craft_top_tab 拽回 0，
//   表现为「点神器进化却跳回卡片宝石页」。同族先例：obj_craft_confirm_btn/Mouse_4 就是按页签拦的。
if (!instance_exists(obj_craft_bg)) exit
if (!visible) exit
if (obj_craft_bg.craft_top_tab == 1 || obj_craft_bg.craft_top_tab == 3) exit   // 融合页 / 神级进化页没有这三个按钮

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
			// 转职列表/元数据要重建：中间可能去过强化页把卡升了星，星级/形态都变了（2026-10-30 修）
			obj_craft_bg.tg_list_dirty = true
			global.audio.play(snd_button,0,0)
		}
		exit
	}
	// 卡片 / 宝石：先回到 craft_top_tab == 0（从转职页回来）
	if (obj_craft_bg.craft_top_tab != 0){
		obj_craft_bg.craft_top_tab = 0
		obj_craft_bg.tg_card = ""
		obj_craft_bg.tg_list_dirty = true     // 回到强化页也置脏，下次进转职页自然是新的
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