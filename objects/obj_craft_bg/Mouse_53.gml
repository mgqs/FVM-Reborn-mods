if !is_submenu_opened{
	// ── 只有「卡片宝石」页（craft_top_tab == 0）才处理点卡 / 点宝石 ──
	// 这个事件是**全局左键**，页签切走之后它照样会触发；不留页签守卫的话，
	// 在转职 / 神级进化 / 食灵融合页点同一块区域会顺手把强化槽的目标卡改掉。
	if craft_top_tab == 0{
		if button_select == 0 && hover_card_index != -1{
			// hover_card_index 是上一帧 Draw 算出来的：鼠标在同一帧里滑到按钮上再点，
			// 仍会命中这张卡（「点转职同时把强化目标卡设上」就是这个）→ 按当前鼠标位置复核
			if point_in_rectangle(mouse_x, mouse_y, hover_card_cx - 42, hover_card_cy - 48, hover_card_cx + 42, hover_card_cy + 48){
				global.audio.play(snd_button,0,0)
				current_uprade_target_id = global.save_data.unlocked_cards[craft_sort_order[hover_card_index]].id
			}
		}
		if button_select == 1 && hover_gem_index != -1{
			if point_in_rectangle(mouse_x, mouse_y, hover_gem_cx - 42, hover_gem_cy - 44, hover_gem_cx + 42, hover_gem_cy + 44){
				global.audio.play(snd_button,0,0)
				current_uprade_target_id = global.save_data.unlocked_gems[hover_gem_index].id
			}
		}
	}
}
