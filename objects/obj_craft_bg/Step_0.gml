// ── 融合确认弹窗（系统提示）：开着就吃掉本帧所有输入，只处理「确定 / 取消」──
// 放在最前面 + exit：底下的页签、档位、卡格、概率强化开关一概点不到（模态）
if (fusion_confirm){
	fusion_confirm_hover = -1;
	for (var _ci = 0; _ci < 2; _ci++){
		var _cr = fusion_confirm_rect(_ci);
		if (point_in_rectangle(mouse_x, mouse_y, _cr[0], _cr[1], _cr[2], _cr[3])) fusion_confirm_hover = _ci;
	}
	if (mouse_check_button_pressed(mb_left) && fusion_confirm_hover != -1){
		if (fusion_confirm_hover == 0){        // 确定 → 开演（融合剂在演出结束那帧真扣，见下）
			fusion_confirm = false;
			fusion_phase = 1;
			fusion_t = 0;
		}
		else{                                  // 取消 → 什么都不做
			fusion_confirm = false;
		}
		audio_play_sound(snd_button,0,0);
	}
	craft_tab_hover = -1;
	rate_toggle_hover = false;
	assure_toggle_hover = false;
	// 弹窗期间把合成屋的 X 藏起来（GM 的鼠标事件不派发给 visible=false 的实例 → 也点不到）
	with (obj_closecraft_btn) visible = !other.fusion_confirm;
	exit;
}

// ── 顶部页签切换：卡片宝石 / 神级进化 / 食灵融合（2026-10-26 由 2 个改 3 个）──
//   craft_tab_hover 存的是**页签值**（0 / 3 / 1），不是位置序号
craft_tab_hover = -1
var _tab_ids = [0, 3, 1];
var _tab_xs  = [tab_cardgem_x, tab_evo_x, tab_fusion_x];
var _tab_ys  = [tab_cardgem_y, tab_evo_y, tab_fusion_y];
var _tab_spr = [spr_craft_tab_cardgem, spr_craft_tab_evo, spr_craft_tab_fusion];
for (var _ti = 0; _ti < 3; _ti++){
	if (point_in_rectangle(mouse_x, mouse_y, _tab_xs[_ti], _tab_ys[_ti],
		_tab_xs[_ti] + sprite_get_width(_tab_spr[_ti]) * craft_tab_scale,
		_tab_ys[_ti] + sprite_get_height(_tab_spr[_ti]) * craft_tab_scale)){
		craft_tab_hover = _tab_ids[_ti];
	}
}
if (mouse_check_button_pressed(mb_left) && craft_tab_hover != -1 && craft_tab_hover != craft_top_tab && !tg_help){
	craft_top_tab = craft_tab_hover
	current_uprade_target_id = ""
	// 切页签 = 融合页重开：装填状态和「刚融出来的临时结果卡」一起清掉
	fusion_stage = 0
	fusion_phase = 0
	fusion_t = 0
	fusion_loaded_id = ""
	fusion_fly_hold = 0
	fusion_fly_t = 0
	fusion_result_out = false
	// 神级进化页也清槽（含缺卡占位，否则切回来会留着上组留下的灰卡）
	evo_clear()
	evo_list_dirty = true
	// 转职页的两个弹窗一起关掉（切页签后弹窗不再绘制，留着状态会在切回来时突然冒出来）
	tg_confirm = false
	tg_confirm_mode = 0
	// 切换界面 = 保底归零（2026-10-28 用户口径：换卡 / 切换界面 / 退出合成屋 三个重置点之一）
	tg_pity = 0
	tg_pity_card = ""
	tg_hidden = 0     // 暗概率跟着一起清（2026-10-30）
	// 🔴 2026-10-30：转职列表/元数据（含星级、形态、卡图）必须重建。
	//   否则「转职页 → 强化页把卡强化一下 → 回转职页」会一直显示旧的星级，
	//   因为 tg_list 只在新建 / 转职成功时置脏，切页签这一侧原来漏了。
	tg_list_dirty = true
	audio_play_sound(snd_button,0,0)
}
// 页签切到融合时把「卡片强化 / 宝石强化」两个按钮和强化按钮藏起来，免得点到
// ⚠️ with 里要用 other. 取本实例的变量，直接写 craft_top_tab 会被解析成目标实例的变量 → 报 not set
with (obj_craft_select_btn) visible = (other.craft_top_tab != 1 && other.craft_top_tab != 3)   // 转职页要显示，神级进化页不显示（那页只画「金卡进化」一个按钮）
with (obj_craft_confirm_btn) visible = (other.craft_top_tab == 0)
with (obj_closecraft_btn) visible = true     // 弹窗关掉后恢复（弹窗分支里会被隐藏）

// ── 食灵融合页：档位按钮 + 融合按钮 + 演出计时（纯演出，不判断任何前置、不消耗）──
if (craft_top_tab == 1){
	// 热区全部用 Create_0 算好的 fusion_* 几何（与 Draw_0 同一套，别再本地换算）
	var _lvs = fusion_ssy
	var _lvx = fusion_lx + 6 * fusion_ssx
	var _cfg = fusion_levels[fusion_level - 1]
	var _shape = _cfg.shape

	// 右侧列表的滚动上限（Draw 只读这两个值，滚轮在 Mouse_60/61 改 *_scroll_t）
	fusion_rows_recipe_max = max(0, ceil(array_length(fusion_recipe_list(_shape)) / fusion_gcols) - fusion_grows1)
	fusion_rows_card_max = max(0, ceil(array_length(fusion_card_list(fusion_level)) / fusion_gcols) - fusion_grows2)
	fusion_recipe_scroll_t = clamp(fusion_recipe_scroll_t, 0, fusion_rows_recipe_max)
	fusion_card_scroll_t = clamp(fusion_card_scroll_t, 0, fusion_rows_card_max)

	// 左侧四档：初级 / 深度 / 灵魂（演出中不让切）
	if fusion_phase != 1{
		for (var _li = 0; _li < 3; _li++){
			var _ly = fusion_ly + (100 + _li*55)*_lvs
			if point_in_rectangle(mouse_x, mouse_y, _lvx, _ly, _lvx + 55*_lvs, _ly + 59*_lvs){
				if mouse_check_button_pressed(mb_left) && fusion_level != _li + 1{
					fusion_level = _li + 1
					fusion_phase = 0
					fusion_t = 0
					fusion_stage = 0
					fusion_fly_hold = 0
					fusion_fly_t = 0
					fusion_result_out = false
					fusion_loaded_id = ""
					audio_play_sound(snd_button,0,0)
				}
			}
		}
	}

	// 卡片升阶 → 切回「卡片宝石」页
	var _uy = fusion_ly + 265*_lvs
	fusion_up_hover = point_in_rectangle(mouse_x, mouse_y, _lvx, _uy, _lvx + 55*_lvs, _uy + 59*_lvs)
	if fusion_up_hover && mouse_check_button_pressed(mb_left){
		craft_top_tab = 0
		audio_play_sound(snd_button,0,0)
	}

	// ── 融合菜谱格：点一下装填，再点一下（或点菜谱槽）卸下 ──
	if mouse_check_button_pressed(mb_left) && fusion_phase != 1{
		var _rcp_ids = fusion_recipe_list(_shape)
		var _r_off = floor(fusion_recipe_scroll)
		for (var _i1 = _r_off*fusion_gcols; _i1 < min(array_length(_rcp_ids), (_r_off + fusion_grows1)*fusion_gcols); _i1++){
			var _cid1 = _rcp_ids[_i1];
			if (fusion_stage >= 1 && _cid1 == fusion_loaded_id) continue;
			var _cx = fusion_g1x + (_i1 mod fusion_gcols)*fusion_gpx
			var _cy = fusion_g1y + (_i1 div fusion_gcols - _r_off)*fusion_gpy
			if point_in_rectangle(mouse_x, mouse_y, _cx - fusion_gpx*0.5, _cy - fusion_gpy*0.5, _cx + fusion_gpx*0.5, _cy + fusion_gpy*0.5){
				var _rid = _rcp_ids[_i1]
				if (fusion_loaded_id == _rid){
					fusion_stage = 0
					fusion_fly_hold = 0
					fusion_fly_t = 0
					fusion_result_out = false
					fusion_loaded_id = ""
				}
				else{
					fusion_loaded_id = _rid
					fusion_stage = 1
					fusion_phase = 0
					fusion_t = 0
				}
				audio_play_sound(snd_button,0,0)
				break
			}
		}
		// 点「融合菜谱」槽 = 卸下（跟强化页点卡槽取回一个手感）
		var _s0x = fusion_ppx + fusion_slot_x[0]*fusion_ssx
		var _s0y = fusion_ppy + fusion_slot_prop_y*fusion_ssy
		if ((fusion_stage >= 1) && point_in_rectangle(mouse_x, mouse_y, _s0x, _s0y, _s0x + 58*fusion_ssx, _s0y + 58*fusion_ssy)){
			fusion_stage = 0
			fusion_fly_hold = 0
			fusion_fly_t = 0
			fusion_result_out = false
			fusion_loaded_id = ""
			audio_play_sound(snd_button,0,0)
		}
	}

	// ── 融合按钮：装满了才能点 ──
	fusion_btn_hover = point_in_rectangle(mouse_x, mouse_y,
		fusion_ppx + fusion_btn_x*fusion_ssx, fusion_ppy + fusion_btn_y*fusion_ssy,
		fusion_ppx + (fusion_btn_x+161)*fusion_ssx, fusion_ppy + (fusion_btn_y+44)*fusion_ssy)
	if fusion_btn_hover && mouse_check_button_pressed(mb_left) && fusion_phase != 1{
		// 前置判定跟 Draw 的按钮共用 fusion_check()，提示词也由它给（缺什么说什么）
		var _chk = fusion_check();
		if (!_chk.ok){
			show_notice(_chk.reason, 80)
		}
		else{
			// 都满足了 → 弹「系统提示」确认，点确定才开演（扣金币 / 融合剂 / 食谱在演出结束那帧）
			fusion_confirm = true
			fusion_confirm_hover = -1
			audio_play_sound(snd_button,0,0)
		}
	}

	// ── 演出计时 → 出结果 ──
	if fusion_phase == 1{
		fusion_t += 1
		// 结束判定按 fusion_fx_speed 换算：0.5 = 半速 → 124 tick 才结束（原来 62）
		if (fusion_t * fusion_fx_speed >= 62){
			fusion_phase = 0
			fusion_t = 0
			fusion_stage = 2
			fusion_fly_hold = 28
			fusion_fly_t = 0
			fusion_result_out = false
			// 金币真扣（弹窗文案就是「是否消耗金币继续」，不扣等于白嫖）
			if (global.save_data.player.gold >= _cfg.gold){
				global.save_data.player.gold -= _cfg.gold
			}
			// 融合剂真扣（卡不扣，只走动画）
			if (get_material_amount(_cfg.mat) >= _cfg.mat_n){
				add_material_amount(_cfg.mat, -_cfg.mat_n)
			}
			// 食谱（融合凭证）扣 1 本：诸神商店卖的是可持有道具，用掉就少一本
			var _recipe_item = fusion_recipe_item_id(fusion_loaded_id, _cfg.shape)
			if (get_material_amount(_recipe_item) > 0) add_material_amount(_recipe_item, -1)
			// 结果卡真进存档（原来只播动画，白扣材料拿不到卡）；unlock_card 内部取 max，不会把已练的形态降下来
			unlock_card(fusion_loaded_id, 0, _cfg.shape, 0)
			// 「融合XX成功」的飘字提示去掉（用户要求不要了），结果直接看结果槽
		}
	}

	// ── 融合完成后的飞卡计时：结果槽停一会 → 卡飞出去（离开结果槽）→ 24 帧后落地 ──
	if (fusion_stage == 2){
		if (!fusion_result_out){
			if (fusion_fly_hold > 0){
				fusion_fly_hold -= 1;
			}
			else{
				fusion_result_out = true;
				fusion_fly_t = 1;
			}
		}
		else if (fusion_fly_t > 0){
			if (fusion_fly_t < 24) fusion_fly_t += 1;   // 到 24 停住 = 已落地，卡留在那格里（列表刷新才清）
		}
	}
}
else{
	fusion_phase = 0
	fusion_t = 0
	fusion_btn_hover = false
	fusion_up_hover = false
}

// ── 神级进化页（craft_top_tab == 3，2026-10-26）：金卡进化交互 ──
if (craft_top_tab == 3) {
	if (evo_list_dirty) evo_rebuild();
	if (evo_btn_press > 0) evo_btn_press -= 1;

	// 特效播放中：只推进帧，播完才落账（与转职同一套延迟结算）
	if (evo_fx) {
		evo_fx_t += evo_fx_speed;
		if (evo_fx_t >= evo_fx_frames) {
			evo_fx = false;
			evo_fx_t = 0;
			evo_commit();
		}
		exit;                                   // 演出期间锁住其它交互
	}

	if (mouse_check_button_pressed(mb_left)) {
		// ① 右侧列表：点卡 → 整组落槽（进哪个槽由表里的 slot 决定；另一张自动补齐或画灰占位）
		evo_hover_card = -1;
		var _n = array_length(evo_list);
		var _off = floor(evo_scroll);                 // 热区要跟着滚动一起偏移，否则点到的和看到的不一致
		for (var _r = 0; _r < evo_grows; _r++) {
			for (var _c = 0; _c < evo_gcols; _c++) {
				var _ci = (_r + _off) * evo_gcols + _c;
				if (_ci >= _n) break;
				var _gx = evo_list_x + _c * evo_gpx;
				var _gy = evo_list_y + _r * evo_gpy;
				if (point_in_rectangle(mouse_x, mouse_y, _gx - 42, _gy - 48, _gx + 42, _gy + 48)) {
					var _cid = evo_list[_ci];
					if (evo_pick(_cid)) {
						audio_play_sound(snd_button, 0, 0);
					}
					exit;
				}
			}
		}

		// ② 点卡槽 → 整组下卡（一组两张，不单独留一张）。灰占位（未拥有）不可点
		//    ⚠️ 绿色箭头在下面，且 x 与第 2 槽重合 —— 点在箭头区不算点槽（原来会误当成取回）
		var _on_arrow = point_in_rectangle(mouse_x, mouse_y, evo_arrow_x - 32, evo_arrow_y - 32,
			evo_arrow_x + 32, evo_arrow_y + 32);
		for (var _i = 0; _i < 2; _i++) {
			if (_on_arrow) break;
			if (point_in_rectangle(mouse_x, mouse_y, evo_slot_x[_i] - 40, evo_slot_y - 45,
				evo_slot_x[_i] + 40, evo_slot_y + 45)) {
				if (evo_cards[_i] != "") {
					evo_clear();
					audio_play_sound(snd_button, 0, 0);
				}
				exit;
			}
		}
		// ③ 进化按钮
		if (point_in_rectangle(mouse_x, mouse_y, evo_btn_x - 73, evo_btn_y - 36,
			evo_btn_x + 73, evo_btn_y + 36)) {
			evo_do();
			exit;
		}
	}
	// 🔴 2026-10-27 修：这里原来有一句 exit（在 if 块内、非点击分支之后），
	//    会把事件尾部「close_timer → panel_anim_close」整段跳过 → 在神级进化页点右上角 X 关不掉窗口。
	//    exit 只保留在上面的各个点击分支里。
}


// 不写 exit：末尾 close_timer 还要跑；强化/宝石那几段现在都有 craft_top_tab == 0 守卫
// ── 卡片转职页（craft_top_tab == 2，2026-10-25）：交互全在这里 ──
// 说明弹窗只属于转职页：切到别的页就关掉（否则切回来会莫名其妙又弹出来）
if (craft_top_tab != 2) tg_help = false;
if (craft_top_tab == 2) {
	// 清掉强化页的悬停索引，免得残留值被下面的点击逻辑误用
	hover_card_index = -1;
	hover_gem_index = -1;
	// 列表还没重建过（切进这一页的第一帧 / 刚转职完）→ 先建，避免点到空列表
	if (tg_list_dirty) tg_rebuild();
	if (tg_btn_press > 0) tg_btn_press -= 1;

	// ⓪ 「转职说明」弹窗开着 → 模态：只处理「确定」，底下页签 / 卡格 / 转职按钮一概点不到
	//    （跟融合页「系统提示」同一口径：顺便把合成屋的 X 藏起来，免得点着 X 关窗）
	if (tg_help) {
		with (obj_closecraft_btn) visible = false;
		var _hr = tg_help_rect();
		tg_help_hover = point_in_rectangle(mouse_x, mouse_y, _hr[0], _hr[1], _hr[2], _hr[3]);
		if (mouse_check_button_pressed(mb_left) && tg_help_hover) {
			tg_help = false;
			tg_help_hover = false;
			audio_play_sound(snd_button, 0, 0);
		}
	}
	// ① 转职确认窗开着 → 只处理确认窗（其它交互全锁；mode 1 = 缺凭证「补全并转职」）
	else if (tg_confirm) {
		tg_confirm_hover = -1;
		for (var _ci2 = 0; _ci2 < 2; _ci2++) {
			var _cr = tg_confirm_rect(_ci2);
			if (point_in_rectangle(mouse_x, mouse_y, _cr[0], _cr[1], _cr[2], _cr[3])) tg_confirm_hover = _ci2;
		}
		if (mouse_check_button_pressed(mb_left)) {
			if (tg_confirm_hover == 0) {
				var _fill_mode = (tg_confirm_mode == 1);
				tg_confirm = false;
				tg_confirm_hover = -1;
				audio_play_sound(snd_button, 0, 0);
				if (_fill_mode) tg_fill_do();              // 补凭证：扣钱发凭证后立刻转一次
				else            tg_do();                   // 普通确认：真转（成功切特效，失败直接弹提示）
			}
			else if (tg_confirm_hover == 1) {
				tg_confirm = false;
				tg_confirm_mode = 0;
				tg_confirm_hover = -1;
				audio_play_sound(snd_button, 0, 0);
			}
		}
	}
	// ② 特效播放中 → 只推进帧；**播完才结算**（扣钱/扣凭证/提形态 + 清槽 + 提示）
	//    帧推进按 tg_fx_speed（Create_0）：0.25 = 1/4 速（28 帧 ≈ 1.9s@60fps）
	//    ⚠️ 动画期间凭证槽和主卡槽都保持**转职前**的样子（用户 2026-10-26 要求），
	//       所以真正的存档改动全在 tg_fx_commit() 里，这里只负责在正确时机调它。
	else if (tg_fx) {
		tg_fx_t += tg_fx_speed;
		if (tg_fx_t >= tg_fx_frames) {
			tg_fx = false;
			tg_fx_t = 0;
			tg_fx_commit();                               // 形态/金币/凭证在这里才生效，同时清空主卡槽
			tg_notice("卡片转职成功！");                    // 提示也等播完
		}
	}
	// ③ 正常交互
	else if (mouse_check_button_pressed(mb_left)) {
		// ⓪ 「转职说明」按钮（面板左上角空白处）→ 打开星级要求弹窗
		if (point_in_rectangle(mouse_x, mouse_y,
			tg_help_x - tg_help_w * 0.5, tg_help_y - tg_help_h * 0.5,
			tg_help_x + tg_help_w * 0.5, tg_help_y + tg_help_h * 0.5)) {
			tg_help = true;
			tg_help_hover = false;
			audio_play_sound(snd_button, 0, 0);
		}
		// ① 右侧列表选卡 → 进主卡槽（**只有换到另一张卡才清保底**，2026-10-28 用户口径）
		//    转职成功后槽会自动清空，再放回同一张卡不算换卡 → 保底接着累计
		else if (tg_hover_card != -1 && tg_hover_card < array_length(tg_list)) {
			var _pick = tg_list[tg_hover_card];
			// 换卡：保底与暗概率一起归零（2026-10-30）
			if (tg_pity_card != "" && tg_pity_card != _pick) { tg_pity = 0; tg_pity_card = ""; tg_hidden = 0; }
			tg_card = _pick;
			audio_play_sound(snd_button, 0, 0);
		}
		// ② 点主卡槽 = 卸下（**不清保底**：取下来再放回同一张卡时计数保留）
		else if (point_in_rectangle(mouse_x, mouse_y, tg_main_x - 44, tg_main_y - 44, tg_main_x + 44, tg_main_y + 44)) {
			if (tg_card != "") {
				tg_card = "";
				audio_play_sound(snd_button, 0, 0);
			}
		}
		// ③ 保险金：点徽章或勾选框都算（独立开关，不动强化页那个配置）
		//    ⚠️ 开关**不影响保底次数**（用户 2026-10-27 明确）：开着关着来回点，已累计的次数照旧
		else if (point_in_rectangle(mouse_x, mouse_y, assure_badge_cx - 33, assure_badge_cy - 36, assure_badge_cx + 33, assure_toggle_y + 18)) {
			tg_assure = !tg_assure;
			audio_play_sound(snd_button, 0, 0);
			tg_notice(tg_assure ? "保险金已开启：失败不消耗凭证" : "保险金已关闭");
		}
		// ④ 转职按钮（2026-10-28 改）：能转 → 普通确认窗；**只差凭证** → 「补全并转职」确认窗；其它 → 提示原因
		else if (point_in_rectangle(mouse_x, mouse_y, tg_btn_x - 73, tg_btn_y - 40, tg_btn_x + 73, tg_btn_y + 40)) {
			tg_btn_press = 8;
			var _chk0 = tg_check();
			if (_chk0.ok) {
				tg_confirm = true;
				tg_confirm_mode = 0;
				tg_confirm_hover = -1;
				audio_play_sound(snd_button, 0, 0);
			}
			else if (string_pos("缺少", _chk0.reason) == 1) {
				// 缺凭证 → 当场补（价格读威望商店 / 诸神 / 跨服；补不了 tg_fill_open 里会提示原因）
				if (tg_fill_open()) audio_play_sound(snd_button, 0, 0);
			}
			else {
				tg_notice(_chk0.reason);                  // 不满足条件直接给原因，别让人点了确认才发现转不了
			}
		}
	}
}

// 概率强化 = 总开关：关掉时「保险金」一并关掉
// 「失败掉星」已内置进概率强化 —— 没有独立开关，开着就一定掉（5★ 及以下免疫）
// 热区要连右侧文字一起算（原来只到 +18，点「概率强化」四个字是点不到的）
// ⚠️ 只在「卡片宝石」页生效：融合页（craft_top_tab == 1）右边没有 exit，
//    这个热区正好压在融合场景的锅左侧 → 点场景会静默改开关 + 写 config.ini
rate_toggle_hover = (craft_top_tab == 0) && point_in_rectangle(mouse_x, mouse_y, rate_toggle_x-18, rate_toggle_y-18, rate_toggle_x+118, rate_toggle_y+18)
if mouse_check_button_pressed(mb_left) && rate_toggle_hover{
	var _s = craft_rate_settings()
	_s.enabled = !_s.enabled
	if !_s.enabled{
		_s.assure_enabled = false
	}
	audio_play_sound(snd_button,0,0)
	ini_open("config.ini")
	ini_write_bool("settings","craft_rate_enabled",_s.enabled)
	ini_write_bool("settings","craft_assure_enabled",_s.assure_enabled)
	ini_close()
	if _s.enabled show_notice("概率强化已开启",60)
	else show_notice("概率强化已关闭",60)
}

// 保险金开关点击（在徽章上：点徽章或下面那个勾选框都算；只在卡片强化页）
// 保险金是单独开关，但必须建立在「概率强化」开着的前提下（掉星内置在概率强化里，开概率强化才有星可保）
assure_toggle_hover = false
if (button_select == 0 && craft_top_tab == 0){
	assure_toggle_hover = point_in_rectangle(mouse_x, mouse_y, assure_badge_cx-33, assure_badge_cy-36, assure_badge_cx+33, assure_toggle_y+18)
	if mouse_check_button_pressed(mb_left) && assure_toggle_hover{
		var _a = craft_rate_settings()
		if !_a.enabled{
			show_notice("要先开启[概率强化]",80)
		}
		else{
			// 开启前先算清「本次强化总共要花多少金币」（强化金币 + 保险金），不够就不让勾上
			var _need_total = -1
			if current_uprade_target_id != ""{
				var _cd = get_card_info_simple(current_uprade_target_id)
				if _cd != false{
					var _ri = get_card_craft_rule(string(_cd.max_level+1))
					if !is_undefined(_ri) _need_total = _ri.gold_amount + craft_assure_gold(_cd.max_level)
				}
			}
			if !_a.assure_enabled && _need_total >= 0 && global.save_data.player.gold < _need_total{
				show_notice("金币不足，无法开启保险金",80)
			}
			else{
				_a.assure_enabled = !_a.assure_enabled
				audio_play_sound(snd_button,0,0)
				ini_open("config.ini")
				ini_write_bool("settings","craft_assure_enabled",_a.assure_enabled)
				ini_close()
				if _a.assure_enabled show_notice("保险金已开启",80)
				else show_notice("保险金已关闭",60)
			}
		}
	}
}

if close_timer > 0{
	close_timer --
}
if close_timer == 0{
	panel_anim_close(id)
	close_timer = -1
}
