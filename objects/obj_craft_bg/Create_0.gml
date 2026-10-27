image_xscale = 0.9
image_yscale = 0.9

is_submenu_opened = false
button_select = 0

instance_create_depth(x+785,y-466,depth-1,obj_closecraft_btn)
instance_create_depth(x-305,y+220,depth-1,obj_craft_confirm_btn)

var btn1 = instance_create_depth(x-661,y-50,depth-1,obj_craft_select_btn)
btn1.button_index = 0
btn1.text_spr = spr_craft_card_text
var btn2 = instance_create_depth(x-661,y+100,depth-1,obj_craft_select_btn)
btn2.button_index = 1
btn2.text_spr = spr_craft_gem_text
// 第 3 个按钮：卡片转职（2026-10-25，竖排字 837；点它把 craft_top_tab 切到 2）
var btn3 = instance_create_depth(x-661,y+250,depth-1,obj_craft_select_btn)
btn3.button_index = 2
btn3.text_spr = spr_transfer_tab_text

card_material_id_list = ["natural_spices","secret_spices","royal_spices","clover_1","clover_2","clover_3","clover_4"]
gem_material_id_list = ["less_crystal","middle_crystal","advanced_crystal"]


hover_card_index = -1
hover_gem_index = -1
close_timer = -1

y_offset = 0
y_offset_target = 0
// 滚动条状态（绘制与拖动都在 Draw_0 末尾，与滚轮共用 y_offset）
sb_dragging = false
sb_drag_y = 0
sb_drag_offset = 0
card_surface = -1

current_uprade_target_id = ""
// 卡片列表排序映射（普卡 → 融合 → 金卡）：Draw_0 每帧重建，Mouse_53 点卡时按下标取卡
craft_sort_order = []

// 顶部页签：0 = 卡片宝石（强化面板），1 = 食灵融合（官方融合页演出）
// 位置按 928 整窗空间算（左上角 = (x-829, y-524)，1.8 倍）：
//   整窗上沿那条蓝色空带是 y28~51（「合成屋」横幅左边那段），页签就坐在这条带子里，
//   高度 1.35 倍（119x31 → 161x42）正好等于带高，右侧让开横幅（928 x288 起）
// 顶部页签（2026-10-26 改成 3 个，顺序 = 卡片宝石 / 神级进化 / 食灵融合）
// 值：0 = 卡片宝石（强化面板），1 = 食灵融合，2 = 卡片转职（左侧按钮进），3 = 神级进化（金卡进化）
craft_top_tab = 0
craft_tab_scale = 1.35
tab_cardgem_x = x - 829 + 16 * 1.8
tab_cardgem_y = y - 524 + 28 * 1.8
tab_evo_x = tab_cardgem_x + 119 * craft_tab_scale + 10
tab_evo_y = tab_cardgem_y
tab_fusion_x = tab_evo_x + 119 * craft_tab_scale + 10
tab_fusion_y = tab_cardgem_y
craft_tab_hover = -1

/// @func fusion_sb_draw(top, height, row, max_row, vis_rows, dragging)
/// 融合页列表滚动条：直接画在 928 凹槽里（内容不满时半透明铺满整条）
function fusion_sb_draw(_top, _h, _row, _max_row, _vis, _drag){
	var _kx = fusion_sbx;
	var _kw = fusion_sbw;
	var _rad = 5 * fusion_ws;
	var _inset = 2 * fusion_ws;
	draw_set_alpha(1);
	draw_set_colour(make_colour_rgb(8, 48, 92));
	draw_roundrect_ext(_kx, _top, _kx + _kw, _top + _h, _rad, _rad, false);
	draw_set_colour(make_colour_rgb(0, 30, 60));
	draw_roundrect_ext(_kx, _top, _kx + _kw, _top + _h, _rad, _rad, true);
	var _ty = _top + _inset;
	var _th = _h - _inset*2;
	if (_max_row > 0){
		// 滑块长 = 可见行 / 总行数
		var _tot = _max_row + _vis;
		_th = max(24*fusion_ws, (_h - _inset*2) * _vis / _tot);
		_ty = _top + _inset + (_h - _inset*2 - _th) * clamp(_row / _max_row, 0, 1);
	}
	else{
		draw_set_alpha(0.4);
	}
	draw_set_colour(_drag ? make_colour_rgb(200, 240, 255) : make_colour_rgb(120, 190, 240));
	draw_roundrect_ext(_kx + _inset, _ty, _kx + _kw - _inset, _ty + _th, _rad*0.8, _rad*0.8, false);
	draw_set_alpha(1);
	draw_set_colour(c_white);
}

/// @func fusion_draw_center(spr, sub, cx, cy, box) 按最长边缩到 box 并「居中」绘制
/// ⚠️ 原点不统一（卡底/凭证/材料是中心原点 4，食谱图是左上角 0）→ 用 xoffset/yoffset 换算，
///    不能一律当左上角减半个宽高（那会把中心原点的图往左上推半个身位）
/// _bw：true = 走 sh_fusion_gray（去色成黑白 + 轻压暗），做「未拥有」那种灰显；卡底与卡面要传同一个值
function fusion_draw_center(_spr, _sub, _cx, _cy, _box, _bw = false){
	if (_spr == -1 || _spr == noone) return;
	var _w = sprite_get_width(_spr), _h = sprite_get_height(_spr);
	var _sc = _box / max(_w, _h);
	if (_bw) shader_set(sh_fusion_gray);
	draw_sprite_ext(_spr, _sub,
		_cx + (sprite_get_xoffset(_spr) - _w * 0.5) * _sc,
		_cy + (sprite_get_yoffset(_spr) - _h * 0.5) * _sc,
		_sc, _sc, 0, c_white, 1);
	if (_bw) shader_reset();
}

/// @func fusion_draw_center_slot(cx, cy) 居中画一张「空槽」（58x68，居中到给定中心点）
function fusion_draw_center_slot(_cx, _cy){
	fusion_draw_center(spr_fusion_slot_card, 1, _cx, _cy, fusion_slot_h * fusion_ssy);
}

/// @func fusion_card_blit(spr, sub, x, y, scale, bw) 纯等比缩放绘制（坐标就是精灵原点落点），
/// 跟强化页 / 防御卡格里的 `draw_sprite_ext(spr, 0, x, y, 0.7, 0.7, ...)` 一模一样；
/// _bw = true 时套 sh_fusion_gray（黑白，做「未拥有」灰显）
function fusion_card_blit(_spr, _sub, _x, _y, _scale, _bw){
	if (_spr == -1 || _spr == noone) return;
	if (_bw) shader_set(sh_fusion_gray);
	draw_sprite_ext(_spr, _sub, _x, _y, _scale, _scale, 0, c_white, 1);
	if (_bw) shader_reset();
}

/// @func fusion_card_block(cd, icon_spr, icon_sub, card_id, cx, cy, bw)
/// 一个「完整的卡格」= 卡底 0.25 + 卡面 0.7 + 星级 0.7(-25,-35) + 造价(font_pixel)，
/// 跟「卡片强化」页 / 防御卡列表同一套写法、同一尺寸，直接可以互相对照
function fusion_card_block(_cd, _icon_spr, _icon_sub, _card_id, _cx, _cy, _bw){
	if (_cd == noone) return;
	var _sb = (ds_map_exists(_cd, "is_fusion") && _cd[? "is_fusion"] == 1) ? spr_slot_2
		: ((ds_map_exists(_cd, "is_gold") && _cd[? "is_gold"] == 1) ? spr_slot_1 : spr_slot);
	fusion_card_blit(_sb, 0, _cx, _cy - 3, fusion_card_base_s, _bw);
	fusion_card_blit(_icon_spr, _icon_sub, _cx, _cy + 15, fusion_card_face_s, _bw);
	// 星级：卡底左上角（跟列表同位置）
	if (_card_id != ""){
		var _info = get_card_info_simple(_card_id);
		if (_info != false && _info.max_level > 0){
			var _frm = min(_info.max_level, sprite_get_number(spr_star_slot)) - 1;
			fusion_card_blit(spr_star_slot, _frm, _cx - 25, _cy - 35, fusion_card_face_s, _bw);
		}
	}
	// 造价
	draw_set_font(font_pixel);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_set_colour(_bw ? c_gray : c_black);
	draw_text(_cx, _cy + 37, _cd[? "cost"]);
	draw_set_colour(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

/// @func fusion_shape_name(id, shape) 某张卡某个形态的中文名（查不到就退回 0 转名 / id）
/// ⚠️ 形态数据是 ds_map，直接 `[? "name"]` 取（跟 obj_battle_pause_manager 同一写法）；
///    别加 is_real() 守卫 —— 新版运行时的 ds_map 句柄过 is_real 会返回 false，名字就会退回成卡 id
function fusion_shape_name(_id, _shape){
	if (_id == "") return "—";
	var _nm = "";
	var _pd = get_plant_data(_id);
	if (_pd != undefined){
		var _sm = _pd[? "shapes"];
		var _k  = string(_shape);
		if (ds_map_exists(_sm, _k)){
			var _sd = _sm[? _k];
			var _v = _sd[? "name"];
			if (!is_undefined(_v) && is_string(_v)) _nm = _v;
		}
	}
	if (_nm == "" && _shape != 0){
		var _meta = get_plant_shape_data(_id, 0);
		if (_meta != undefined){
			var _v0 = _meta[? "name"];
			if (!is_undefined(_v0) && is_string(_v0)) _nm = _v0;
		}
	}
	if (_nm == "") _nm = _id;
	return _nm;
}

/// @func fusion_pre_card(id) 这张融合卡的前置卡（初融的主卡）
function fusion_pre_card(_id){
	for (var _i = 0; _i < array_length(fusion_demo); _i++){
		if (fusion_demo[_i].id == _id) return fusion_demo[_i].pre;
	}
	return "";
}

/// @func fusion_shape_tag(shape) 形态标签（提示词里跟在卡名后面：卡牌名（二转））
function fusion_shape_tag(_shape){
	if (_shape >= 2) return "（二转）";
	if (_shape == 1) return "（一转）";
	return "（本体）";
}

/// @func fusion_recipe_tip(id) 鼠标悬在食谱格上的提示文本（三行）
///   第一行 = 食谱名：优先直接取**诸神商店那条商品**的 recipe_name / display_name（跟商店一字不差），
///            取不到才用 fusion_recipe_display_name() 现拼
///   主卡 / 副卡 = 食谱实际要的那种形态的卡名 + 形态标签（初融就是「卡牌名（二转）」）
function fusion_recipe_tip(_id){
	var _shape = fusion_levels[fusion_level - 1].shape;

	// ① 标题：诸神商店口径
	var _title = "";
	var _goods_id = (_shape <= 0) ? _id : _id + "_" + string(_shape);
	if (variable_global_exists("gods_goods_map") && ds_map_exists(global.gods_goods_map, _goods_id)){
		var _g = global.gods_goods_map[? _goods_id];
		if (!is_undefined(_g)){
			if (variable_struct_exists(_g, "recipe_name") && is_string(_g.recipe_name) && _g.recipe_name != "") _title = _g.recipe_name;
			else if (variable_struct_exists(_g, "display_name") && is_string(_g.display_name)) _title = _g.display_name;
		}
	}
	if (_title == "") _title = fusion_recipe_display_name(_id, _shape);

	// ② 主卡 / 副卡：**要几转由食谱决定**（need 已按卡的可用形态兜底），不再一律写二转
	var _main_id = (_shape == 0) ? fusion_pre_card(_id) : _id;
	var _main_nd = (_shape == 0) ? fusion_main_need_of(_main_id) : (_shape - 1);
	var _main_sh = mod_fusion_need_shape(_main_id, _main_nd);
	var _tip = _title + "\n主卡：" + fusion_shape_name(_main_id, _main_sh) + fusion_shape_tag(_main_sh);
	var _sq = fusion_sub_card(_id);
	if (_sq.id != "") _tip += "\n副卡：" + fusion_shape_name(_sq.id, _sq.need) + fusion_shape_tag(_sq.need);
	return _tip;
}

// ── 融合页几何（928 整窗空间，Draw_0 与 Step_0 共用这一套，别各算一份）──
fusion_ws = 1.8                     // 整窗底图缩放（921x582 -> 1658x1048）
fusion_wx = x - 829
fusion_wy = y - 524
// 左区（928 空间 x14~535 / y64~494）：场景按这个矩形拉满，不留边
// （底边从 500 收到 494：给底部道具栏让出上沿，道具框不再被压住）
fusion_lx = fusion_wx + 14 * fusion_ws
fusion_ly = fusion_wy + 64 * fusion_ws
fusion_lw = 521 * fusion_ws
fusion_lh = 430 * fusion_ws
fusion_ssx = fusion_lw / 528        // 场景横向缩放
fusion_ssy = fusion_lh / 410        // 场景纵向缩放
fusion_ppx = fusion_lx - 2 * fusion_ssx   // 四格面板（907 是 924 裁掉左上 2px）
fusion_ppy = fusion_ly - 2 * fusion_ssy
// 四个槽（928 面板空间）：卡槽 58x68 间距 72，整体对齐场景里白箭头的轴线（928 x≈273.6）；第 4 个是道具槽 58x58
fusion_slot_x = [136, 208, 280, 352]
fusion_slot_y = 71
fusion_slot_h = 68
fusion_slot_prop_y = 76
// 结果槽：中心对齐白箭头正下方（928 x 273.5 / y 235.5）
fusion_res_x = 265.5
fusion_res_y = 235.5
// 成功率条 / 需金币字段（面板烘焙）
fusion_bar_l = 197
fusion_bar_r = 340
fusion_bar_y = 295
fusion_gold_y = 330
fusion_gold_cx = 274
// 融合按钮（从面板抠出来的 161x44）：中心对齐四槽 / 结果槽（273.5）
fusion_btn_x = 192
fusion_btn_y = 348
// 右侧两块列表：跟「卡片强化」页同一套卡槽格 —— 格 0.9 倍(88x102) / 间距 84x96 / 7 列，
// 铺满 928 底图的面板内区（实测 x543~886 / 上 y82~278 / 下 y311~539），正好上 3 行、下 4 行
fusion_gcols = 7
fusion_gcscl = 0.9
fusion_gpx = 84
fusion_gpy = 96
fusion_gcw = sprite_get_width(spr_package_slot_bg) * fusion_gcscl
fusion_gch = sprite_get_height(spr_package_slot_bg) * fusion_gcscl
fusion_grows1 = 3
fusion_grows2 = 4
fusion_in_l = fusion_wx + 543 * fusion_ws
fusion_in_r = fusion_wx + 886 * fusion_ws
fusion_in_t1 = fusion_wy + 82 * fusion_ws
fusion_in_b1 = fusion_wy + 278 * fusion_ws
fusion_in_t2 = fusion_wy + 311 * fusion_ws
fusion_in_b2 = fusion_wy + 539 * fusion_ws
// 首格「中心」坐标（Draw 与 Step 共用，别再各算一份）
fusion_g1x = fusion_in_l + (fusion_in_r - fusion_in_l - ((fusion_gcols-1)*fusion_gpx + fusion_gcw)) * 0.5 + fusion_gcw * 0.5
fusion_g1y = fusion_in_t1 + (fusion_in_b1 - fusion_in_t1 - ((fusion_grows1-1)*fusion_gpy + fusion_gch)) * 0.5 + fusion_gch * 0.5
fusion_g2x = fusion_g1x
fusion_g2y = fusion_in_t2 + (fusion_in_b2 - fusion_in_t2 - ((fusion_grows2-1)*fusion_gpy + fusion_gch)) * 0.5 + fusion_gch * 0.5
// 滚动槽（928 空间 x888~902）
fusion_sbx = fusion_wx + 888 * fusion_ws
fusion_sbw = 14 * fusion_ws
fusion_sb1y = fusion_wy + 92 * fusion_ws
fusion_sb1h = 176 * fusion_ws
fusion_sb2y = fusion_wy + 322 * fusion_ws
fusion_sb2h = 208 * fusion_ws
// 槽内小字：44x40 画布里字形并不居中，按字形包围盒中心兜回来（否则看着总是偏右偏下）
fusion_lbl_cx = [25.5, 27.5, 27.5, 25, 25, 25]
fusion_lbl_cy = 21
// 常用尺寸常量（原来散在 Draw_0 里写死，挪位置要改好几处）
fusion_slot_inner  = 29;      // 槽内容中心（58/2，横竖都用它）
fusion_card_inner  = 34;      // 卡槽内容中心 y（68/2）
fusion_cell_h      = 46.7;    // 底部道具栏格高（×ws = 84px）
fusion_mat_icon    = 40;      // 融合剂槽图标尺寸
fusion_need_txt_y  = 50;      // 「当前/需求」文字 y
fusion_card_base_s = 0.25;    // 卡底缩放（跟强化页/列表一口径）
fusion_card_face_s = 0.7;     // 卡面缩放

// ── 三档配置：需金币 / 融合剂（秘制 → 四叶草 → 皇室）──
fusion_levels = mod_fusion_levels();          // 三档配置（名字/形态/金币/材料）走 mod/craft 表
// 初融「主卡」要求的形态：0 = 拥有本体即可 / 1 = 一转 / 2 = 二转（**默认值，不是硬规则**）
// 2026-10-24 用户口径：现有食谱的主卡/副卡一律要二转 → 默认值设 2（数据，不是代码硬编码）
// 单张融合卡想另配主卡要求 → 写进下面的 fusion_main_needs（卡 id → need），没写的才用这个默认
// （深度/灵魂 的主卡结构上就是上一形态，不用配；副卡要求全在副卡表里逐条写 need）
fusion_main_need   = mod_fusion_main_need();    // 「初融」档主卡默认要求形态（表里配）
fusion_main_needs  = mod_fusion_main_needs();   // 逐卡覆盖（表里配）

/// @func fusion_recipe_item_id(id, shape) 食谱道具在背包里的 id（诸神商店卖的就是这个）
function fusion_recipe_item_id(_id, _shape){
	return fusion_recipe_id(_id, _shape);
}

/// @func fusion_recipe_owned(id, shape) 这条食谱还在不在（背包里有这本食谱道具）
function fusion_recipe_owned(_id, _shape){
	return has_fusion_recipe(_id, _shape);
}

/// @func fusion_recipe_spr(id, shape) 食谱图标：形态 0 用 spr_fusion_recipe0，1/2 用现成的 spr_voucher_*
function fusion_recipe_spr(_id, _shape){
	if (_shape == 0){
		for (var _i = 0; _i < array_length(fusion_demo); _i++){
			if (fusion_demo[_i].id == _id) return [spr_fusion_recipe0, _i];
		}
		return [spr_fusion_recipe0, 0];
	}
	var _s = asset_get_index("spr_voucher_" + _id + "_" + string(_shape));
	if (_s == -1) _s = spr_fusion_recipe0;
	return [_s, 0];
}

/// @func fusion_recipe_list(shape) 当前档位「还拥有」的食谱 → **融合卡 id 数组**（Draw / Step 共用）
function fusion_recipe_list(_shape){
	var _a = [];
	for (var _i = 0; _i < array_length(fusion_demo); _i++){
		if (fusion_recipe_owned(fusion_demo[_i].id, _shape)) array_push(_a, fusion_demo[_i].id);
	}
	return _a;
}

/// @func fusion_card_list(level) 当前档位「防御卡」面板要画的卡 → [{ id, shape }]
/// ① 初融的主卡（9 张前置卡，只收练到要求的）② 本档副卡（有填且练到该条 need）③ 融合卡（只有深度/灵魂档有，见下）
/// 深度 / 灵魂 没有独立的主卡段：它们的主卡就是融合卡自己，由 ③ 按「玩家拥有的形态」画
/// 🔴 拼完统一过一次 fusion_card_sort()：**白卡 → 金卡 → 融合卡**（融合卡永远排最后），
///    Draw 画格 / 飞卡落点 / Step 滚动上限都吃这一份，三处顺序不会再各说各话
function fusion_card_list(_lv){
	var _a = [];       // [{ id, shape }]
	var _seen = [];    // 去重用的 id 表
	var _sh = fusion_levels[_lv - 1].shape;

	// ① 主卡：只有初融有独立的主卡列表（9 张前置卡）；深度 / 灵魂 的主卡就是融合卡自己 → 交给 ③
	//    要求的形态逐张取（fusion_main_needs 覆盖 → fusion_main_need 默认），**不再是写死的二转**
	if (_lv == 1){
		for (var _i = 0; _i < array_length(fusion_pre_cards); _i++){
			var _id = fusion_pre_cards[_i];
			var _mneed = mod_fusion_need_shape(_id, fusion_main_need_of(_id));
			if (fusion_owned_max_shape(_id) < _mneed) continue;     // 没练到食谱要求的形态就先不列（槽里会画灰）
			if (array_get_index(_seen, _id) != -1) continue;
			array_push(_seen, _id);
			array_push(_a, { id: _id, shape: _mneed });
		}
	}

	// ② 副卡：本档副卡表里的卡（有填、且练到该条 need 要求才画；need 由食谱决定，0 = 本体即可）
	var _tbl = fusion_sub_cards[_lv - 1];
	var _names = variable_struct_get_names(_tbl);
	for (var _j = 0; _j < array_length(_names); _j++){
		var _sreq = fusion_sub_card_at(_lv, _names[_j]);
		if (_sreq.id == "") continue;
		if (fusion_owned_max_shape(_sreq.id) < _sreq.need) continue;
		if (array_get_index(_seen, _sreq.id) != -1) continue;
		array_push(_seen, _sreq.id);
		array_push(_a, { id: _sreq.id, shape: _sreq.need });
	}

	// ③ 融合卡 = 深度 / 灵魂档的「主卡」（初级的主卡是前置卡本体、已经在 ① 里，所以初级这里不列）。
	//    形态画**本档主卡要求的那个形态**：深度 = 0 转（初融图）、灵魂 = 1 转（深融图）——
	//    不是玩家练到的最高形态（练到灵融的人在深度档也该看到初融图，因为深度融合要的是 0 转本体）。
	//    若某张卡还被副卡表以更高的 need 要求：② 段会先收它，③ 段因去重跳过 → 自动画高形态、只出一格。
	//    过滤：拥有形态 < 本档主卡要求的不列（灵融档里只有 0 转的融合炮不出现）。
	//    跟「当前选中哪张食谱」无关 —— 选中之后那张会被拉进槽里，由 Draw_0 的「已进槽原位留空」处理。
	if (_lv >= 2){
		var _fneed = _sh - 1;
		for (var _k = 0; _k < array_length(fusion_demo); _k++){
			var _fid = fusion_demo[_k].id;
			if (fusion_owned_max_shape(_fid) < _fneed) continue;
			if (array_get_index(_seen, _fid) != -1) continue;
			array_push(_seen, _fid);
			array_push(_a, { id: _fid, shape: _fneed });
		}
	}

	// 统一固定排序（用户 2026-10-24 口径）：白卡 → 金卡 → 融合卡；同档保持上面 ①②③ 的收集顺序
	return fusion_card_sort(_a);
}

/// @func fusion_main_card_id() 当前装填后「主卡」那张卡的真实 id（初级 = 前置卡本体，深度/灵魂 = 融合卡自己）
function fusion_main_card_id(){
	if (fusion_stage < 1) return "";
	if (fusion_loaded_id == "") return "";
	if (fusion_levels[fusion_level - 1].shape == 0){
		for (var _i = 0; _i < array_length(fusion_demo); _i++){
			if (fusion_demo[_i].id == fusion_loaded_id) return fusion_demo[_i].pre;
		}
		return "";
	}
	return fusion_loaded_id;
}

// ── 食灵融合页（纯演出：不读写存档、不扣卡；融合剂会真扣，见 Step_0）──
fusion_phase = 0          // 0 待机 / 1 演出中（2 未使用）
fusion_t = 0
fusion_level = 1          // 1 初级 / 2 深度 / 3 灵魂
fusion_up_hover = false
fusion_btn_hover = false
// 装填状态：四个槽默认全空（跟强化页一样，点了菜谱才上卡）
fusion_stage = 0          // 0 空 / 1 已装填（可融合）/ 2 已融合（结果留槽，菜谱与融合剂已消耗）
fusion_loaded_id = ""     // 装进「融合菜谱」槽的融合卡 id，"" = 空
// 融合完成后的「飞卡」动画：结果槽停 fusion_fly_hold 帧 → 卡飞进防御卡格 → result_out 置 true
fusion_fly_hold = 0
fusion_fly_t = 0
fusion_result_out = false
// ── 三档融合演出特效（初融 / 深融 / 灵融，各 25 帧，原点左上角，485x341 / 491x347）──
// 官方素材，按 fusion_level 取；落位 = 面板内水平居中 + 顶部对齐面板上沿（见 Draw_0 的演出块）
fusion_fx_sprites = [spr_fusion_fx_chu, spr_fusion_fx_shen, spr_fusion_fx_ling];
fusion_fx_frames  = 25;
// 演出速度：1.0 = 原速（25 帧铺在 t=0~50，整段 62 tick ≈ 1s）
//   0.5 = 半速（25 帧铺到 t=0~100，整段 124 tick ≈ 2s，2026-10-26 用户要求跟转职特效一样放慢）
//   改这一个数即可：Draw 的取帧 / 白闪起点、Step 的演出结束判定都按它换算
fusion_fx_speed   = 0.5;

// ── 融合确认弹窗（系统提示）：点「融合」先问一句，点确定才开演 ──
// 内联画在本对象里（不新建对象），面板复用 spr_battle_escape_menu、按钮复用 spr_common_button
fusion_confirm = false;        // true = 弹窗开着
fusion_confirm_hover = -1;     // -1 没悬停 / 0 确定 / 1 取消

/// @func fusion_confirm_rect(i) 弹窗按钮矩形（0=确定 / 1=取消）：Draw 画图与 Step 判点共用
function fusion_confirm_rect(_i){
	var _bx = room_width * 0.5 + ((_i == 0) ? -80 : 80);
	var _by = room_height * 0.5 + 70;
	var _hw = sprite_get_width(spr_common_button) * 0.75 * 0.5;   // 0.75 跟 obj_shop_buy_confirm 同一手感，别放大（≥1 会左右挤在一起）
	var _hh = sprite_get_height(spr_common_button) * 0.75 * 0.5;
	return [_bx - _hw, _by - _hh, _bx + _hw, _by + _hh];
}

/// @func fusion_confirm_draw() 融合确认弹窗（在 panel_anim_end_parts 之后调 = 盖在最上层）
function fusion_confirm_draw(){
	var _px = room_width * 0.5, _py = room_height * 0.5;
	draw_set_alpha(0.55);
	draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
	draw_sprite_ext(spr_battle_escape_menu, 0, _px, _py, 1.5, 1.5, 0, c_white, 1);
	draw_set_font(font_yuan);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_colour(c_white);
	draw_text(_px, _py - 112, "系统提示");
	draw_text(_px, _py - 20, "融合后，菜谱以及融合剂");
	draw_text(_px, _py + 12, "将消失，是否消耗金币继续？");
	var _lbl = ["确定", "取消"];
	for (var _i = 0; _i < 2; _i++){
		var _r  = fusion_confirm_rect(_i);
		var _bx = (_r[0] + _r[2]) * 0.5, _by = (_r[1] + _r[3]) * 0.5;
		var _fr = (fusion_confirm_hover == _i) ? (mouse_check_button(mb_left) ? 2 : 1) : 0;
		draw_sprite_ext(spr_common_button, _fr, _bx, _by, 0.75, 0.75, 0, c_white, 1);
		draw_set_colour(c_white);
		draw_text(_bx, _by, _lbl[_i]);
	}
	draw_set_colour(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(1);
}

fusion_demo = mod_fusion_card_order();   // 9 张融合卡的收集顺序 + 前置主卡（表在 mod/craft）

// ── 融合页列表：整行滚动（不做半行）──
fusion_recipe_scroll = 0;   // 菜谱列表当前行（实际值，Draw 里向目标值插值）
fusion_card_scroll = 0;     // 防御卡列表当前行
fusion_recipe_scroll_t = 0; // 滚轮 / 拖条改这个
fusion_card_scroll_t = 0;
fusion_rows_recipe_max = 0;  // 可见行以外的行数（Step_0 每帧算，Draw / 滚轮只读）
fusion_rows_card_max = 0;

/// @func fusion_owned_max_shape(id) 存档里这张卡「练到过」的最高形态（没拥有 = -1）
///      ⚠️ 不能用 deck_get_card_data 判：它查的是**注册表**，
///         所有卡的所有形态都在表里，永远返回 2。要判「有没有二转」只能读 save_data 的 max_shape
function fusion_owned_max_shape(_id){
	for (var _i = 0; _i < array_length(global.save_data.unlocked_cards); _i++){
		if (global.save_data.unlocked_cards[_i].id == _id) return global.save_data.unlocked_cards[_i].max_shape;
	}
	return -1;
}

// ── 三档副卡表：数据在 scripts/mod_craft_fusion_table（mod/craft 分组），这里只引用 ──
//    每条写成 { id:"卡id", need:N }，N = 这道食谱要求的形态（0 本体 / 1 一转 / 2 二转）
//    改数据请改 mod_fusion_sub_cards()，别在这里加表
fusion_sub_cards = mod_fusion_sub_cards();

/// @func fusion_sub_card(id) 当前档位这张融合卡要的副卡 → { id, need }（没有副卡 = { id:"", need:0 }）
/// need 已经按卡的可用形态兜底过，调用方直接用，不要自己再判「是不是二转」
function fusion_sub_card(_id){
	return fusion_sub_card_at(fusion_level, _id);
}

/// @func fusion_sub_card_at(level, id) 指定档位版的 fusion_sub_card（防御卡列表要按档取，不能吃全局 fusion_level）
function fusion_sub_card_at(_lv, _id){
	var _tbl = fusion_sub_cards[_lv - 1];
	if (!variable_struct_exists(_tbl, _id)) return { id: "", need: 0 };
	var _v = _tbl[$ _id];
	// 表里统一写 { id:"卡id", need:N }；老写法 "卡id" 仍兼容（= 拥有本体即可）
	if (is_struct(_v)){
		if (_v.id == "") return { id: "", need: 0 };
		return { id: _v.id, need: mod_fusion_need_shape(_v.id, _v.need) };
	}
	if (_v == "") return { id: "", need: 0 };
	return { id: _v, need: 0 };
}

/// @func fusion_main_need_of(id) 初融这张主卡要求的形态：先查逐条覆盖表 fusion_main_needs，没写就用全局 fusion_main_need
function fusion_main_need_of(_id){
	if (_id == "") return fusion_main_need;
	if (variable_struct_exists(fusion_main_needs, _id)) return fusion_main_needs[$ _id];
	return fusion_main_need;
}

/// @func fusion_main_req() 当前档位「主卡」要求 → { id, need }（need 已兜底）
/// 初融 = 前置卡（要求看 fusion_main_needs / fusion_main_need）；深度/灵魂 = 融合卡自己，要上一形态
function fusion_main_req(){
	if (fusion_stage < 1 || fusion_loaded_id == "") return { id: "", need: 0 };
	var _cfg = fusion_levels[fusion_level - 1];
	if (_cfg.shape == 0){
		var _pid = fusion_main_card_id();
		if (_pid == "") return { id: "", need: 0 };
		return { id: _pid, need: mod_fusion_need_shape(_pid, fusion_main_need_of(_pid)) };
	}
	var _nd = _cfg.shape - 1;
	return { id: fusion_loaded_id, need: mod_fusion_need_shape(fusion_loaded_id, _nd) };
}

/// @func fusion_card_enough(id, need) 这张卡够不够融合用（need 0 = 拥有本体即可）
function fusion_card_enough(_id, _need){
	if (_id == "") return false;
	return fusion_owned_max_shape(_id) >= mod_fusion_need_shape(_id, _need);
}

/// @func fusion_check() 融合前置统一判定：Draw 的按钮亮暗、Step 的点击提示都走这一份，
/// 别再各写一套（之前三处手抄，已经出现过「按钮亮了但槽是灰的」）
/// @return {struct} ok / reason / ready / gold_ok / mat_ok / main_ok / sub_ok / main_id / sub_id / need_main / need_sub
function fusion_check(){
	var _cfg = fusion_levels[fusion_level - 1];
	var _r = {
		ok: false, reason: "",
		ready: (fusion_stage == 1),
		gold_ok: false, mat_ok: false, main_ok: false, sub_ok: false,
		main_id: "", sub_id: "", need_main: 0, need_sub: 0
	};
	if (fusion_stage != 1){ _r.reason = "先选一条融合菜谱"; return _r; }

	// 主卡 / 副卡要哪张、要几转，全走 fusion_main_req() / fusion_sub_card()（口径只有一处）
	var _mq      = fusion_main_req();
	_r.main_id   = _mq.id;
	_r.need_main = _mq.need;
	var _sub     = fusion_sub_card(fusion_loaded_id);
	_r.sub_id    = _sub.id;
	_r.need_sub  = _sub.need;

	_r.main_ok = fusion_card_enough(_r.main_id, _r.need_main);
	_r.sub_ok  = (_r.sub_id == "") ? true : fusion_card_enough(_r.sub_id, _r.need_sub);
	_r.gold_ok = (global.save_data.player.gold >= _cfg.gold);
	_r.mat_ok  = (get_material_amount(_cfg.mat) >= _cfg.mat_n);

	// 提示词只说「缺哪一边」，具体要几转由槽位卡面 / 灰显表达（用户 2026-10-24 口径）
	if (!_r.main_ok)      _r.reason = "缺少可用融合主卡，无法融合";
	else if (!_r.sub_ok)  _r.reason = "缺少可用融合副卡，无法融合";
	else if (!_r.gold_ok) _r.reason = "金币不足，无法融合";
	else if (!_r.mat_ok)  _r.reason = "融合剂不足，无法融合";
	else _r.ok = true;
	return _r;
}

// 初融「主卡」列表 = 9 张前置卡（收集顺序，排序交给 fusion_card_list() 的最终统一排序）
// 深度 / 灵魂 的主卡就是融合卡自己，由 fusion_card_list() 的第 ③ 段按本档形态统一画，不在这里重复
fusion_pre_cards = [];
for (var _ci = 0; _ci < array_length(fusion_demo); _ci++) array_push(fusion_pre_cards, fusion_demo[_ci].pre);
fusion_pre_cards = fusion_sort_by_rank(fusion_pre_cards);

/// @func fusion_rank(id) 排序权重：白卡 0 / 金卡 1 / 融合卡 2（融合卡永远排最后）
/// 判定口径跟卡底一致（is_fusion_card / is_gold），不额外维护名单
function fusion_rank(_id){
	var _sd = deck_get_card_data(_id, 0);
	if (_sd == noone) return 0;
	if (ds_map_exists(_sd, "is_fusion") && _sd[? "is_fusion"] == 1) return 2;
	if (ds_map_exists(_sd, "is_gold") && _sd[? "is_gold"] == 1) return 1;
	return 0;
}

/// @func fusion_sort_by_rank(arr) 稳定插入排序（同档位保持原顺序）—— 给 id 数组用
function fusion_sort_by_rank(_arr){
	var _a = [];
	for (var _i = 0; _i < array_length(_arr); _i++) array_push(_a, _arr[_i]);
	for (var _i = 1; _i < array_length(_a); _i++){
		var _it = _a[_i], _rk = fusion_rank(_it), _j = _i;
		while (_j > 0 && fusion_rank(_a[_j-1]) > _rk){ _a[_j] = _a[_j-1]; _j--; }
		_a[_j] = _it;
	}
	return _a;
}

/// @func fusion_card_sort(list) 防御卡列表固定排序：[{id, shape}] → 白卡 → 金卡 → 融合卡
/// 稳定排序（同档保持收集顺序：主卡 → 副卡 → 融合卡）；每张卡的权重只算一次，
/// 别用 fusion_sort_by_rank 直接套（那个按 id 数组、比较时反复查卡表）
function fusion_card_sort(_list){
	var _n = array_length(_list);
	if (_n < 2) return _list;
	var _out = [];
	var _rk  = [];
	for (var _i = 0; _i < _n; _i++){
		var _r = fusion_rank(_list[_i].id);
		var _j = _i;
		while (_j > 0 && _rk[_j-1] > _r){
			_out[_j] = _out[_j-1];
			_rk[_j]  = _rk[_j-1];
			_j--;
		}
		_out[_j] = _list[_i];
		_rk[_j]  = _r;
	}
	return _out;
}

// Probability-upgrade toggles
rate_toggle_x = x - 600
rate_toggle_y = y - 105
rate_toggle_hover = false
assure_badge_cx = x - 90
assure_badge_cy = y + 140
assure_toggle_x = x - 90
assure_toggle_y = y + 202
assure_toggle_hover = false

spices_use_order = ["natural_spices","secret_spices","royal_spices"]
clover_use_order = ["clover_1","clover_2","clover_3","clover_4"]
crystal_use_order = ["less_crystal","middle_crystal","advanced_crystal"]

// 整块面板的进出场过渡（实现在 scripts/GuiStack/GuiStack.gml）
// ─────────────────────────────────────────────────────────────
// 卡片转职页（craft_top_tab == 2）—— 2026-10-25
// 几何 / 状态 / 判定函数全部集中在这里，Draw 与 Step 共用同一套（别各算一份）
// 消耗入口 = 左侧第 3 个按钮；凭证来自商店；数值挂点见 tg_gold_cost / tg_assure_cost / tg_rate
// ─────────────────────────────────────────────────────────────
tg_slot_x = [x - 455, x - 305, x - 155]      // 屏幕顺序：左 A / 中 C / 右 B
tg_slot_y = y - 20
tg_main_x = x - 307                           // 与强化页主卡槽同一点（卡底 0.25 / 卡面 0.7）
tg_main_y = y + 103
tg_btn_x  = x - 305
tg_btn_y  = y + 220
tg_gold_x = x - 350                           // 需金币条（origin 在右端）
tg_rate_x = x - 45                            // 成功率条（origin 在右端）
tg_bar_y  = y + 300
tg_list_x = x + 196                           // 右侧列表首格中心（跟强化页同一套 84×96 / 7 列）
tg_list_y = y - 321
tg_gpx = 84
tg_gpy = 96
tg_gcols = 7
tg_grows = 8
tg_scroll = 0
tg_scroll_target = 0
tg_rows_max = 0
tg_list = []
tg_list_dirty = true                          // 列表 + 卡元数据要不要重建（进页 / 转职后置 true）
tg_meta = {}                                  // id → { shape, level, is_gold, sprite, cost }
tg_card = ""                                  // 主卡槽里的卡 id，"" = 空
tg_assure = false                             // 保险金开关（独立于强化页那个）

// ── 转职保底（2026-10-27 用户定）──
//   口径：**只在保险金开着时累计**，同一张卡、同一次打开合成屋，连转第 15 次必成（不至于连炸过多）
//         **保险金开关本身不影响次数**（开着关着来回点，已累计的照旧；只有开着的那几次才 +1）
//   归零的三种情况：① 换成别的卡（含点主卡槽取回）② 转职成功 ③ 退出合成屋
//     ③ 是天然的：obj_craft_bg 每次进合成屋都是新实例（obj_player_menu_btn 里 instance_create_depth），
//        关面板 panel_anim_close() 会 instance_destroy()，实例变量跟着一起没
tg_pity      = 0                              // 本次已累计的转职次数（不区分成没成，成功即清零）
// 「第几次必成」= mod_tg_pity_max()（在 scripts/mod_craft_transfer_table，现在是 15）
tg_pity_card = ""                             // 累计期间绑的那张卡，换卡就归零
tg_hover_card = -1
tg_btn_hover = false
tg_btn_press = 0

// ── 转职确认窗 + 成功特效（2026-10-26 用户定流程）──
// 点「转职」→ 先弹确认窗（文案见 tg_confirm_draw）→ 确定后掷骰：
//   失败 = 直接弹提示；成功 = **播完 tg_fx_frames 帧特效** 才提示 + 卡回列表
tg_confirm = false                            // 确认窗开着
tg_confirm_hover = -1                         // -1 无 / 0 确定 / 1 取消
tg_fx = false                                 // 成功特效播放中（此期间锁住其它交互）
tg_fx_t = 0                                   // 已播帧数（浮点，按 tg_fx_speed 递增）
tg_fx_frames = 28                             // spr_transfer_success_fx 的帧数（2026-10-26 用户定 28 帧：
                                              //   原 75 帧 → 46 帧 → 28 帧，后面全是白框空闪，删掉）
tg_fx_speed = 0.25                             // 每 tick 推进几帧：1.0 = 原速
                                              //   0.1 = 1/10 速（测试值）；0.25 = 1/4 速（28 帧 ≈ 1.9s）
tg_fx_scale = 1.6                             // 显示倍数：素材卡片框 61×75 → ×1.6 ≈ 98×120
                                              //   主卡槽底板 48×61 @1.8 = 86×110 → 框**包在槽外一圈**（左右各 6px）
tg_fx_pending = undefined                     // 成功但动画还没播完时的待生效数据（见 tg_do / Step_0）
// 落点：素材里的「卡片框」中心（287×196 画布坐标，离线实测 140.5 / 119.5）
//      —— 对齐到**主卡槽中心**（不是卡面中心，2026-10-26 用户口径：框对准槽就行）
tg_fx_ox = -305                               // 主卡槽中心 x（相对面板；= tg_main_x + 2 - x）
tg_fx_oy = 100                                // 主卡槽中心 y（相对面板；= tg_main_y - 3 - y）
tg_fx_card_cx = 140.5                         // 素材内卡片框中心 x（实测，别乱改）
tg_fx_card_cy = 119.5                         // 素材内卡片框中心 y（实测，别乱改）

// ── 转职的**数值 / 判定 / 确认窗绘制**都在 scripts/mod_craft_transfer_table（2026-10-27 拆出）──
//    这里只留同名薄包装，Draw / Step 的调用点一行都不用改
//    要改价格 / 成功率 / 保底次数 / 提示文案 → 去那个脚本，别在对象里加第二份
function tg_confirm_rect(_i){ return mod_tg_confirm_rect(_i); }
function tg_confirm_draw(){ mod_tg_confirm_draw(tg_confirm_hover); }
function tg_target_shape(_id){ return mod_tg_target_shape(_id); }
function tg_gold_cost(_tier){ return mod_tg_gold(_tier); }
function tg_assure_cost(_tier){ return mod_tg_assure(_tier); }
function tg_rate(_tier){ return mod_tg_rate(_tier); }

/// @func tg_meta_get(id) 取卡的元数据（shape / level / is_gold / sprite / cost）；没建过 → undefined
function tg_meta_get(_id){
    if (variable_struct_exists(tg_meta, _id)) return tg_meta[$ _id];
    return undefined;
}

/// @func tg_rebuild() 重建右侧列表 + 卡元数据 —— **只在 tg_list_dirty 时调，别每帧调**
///       性能口径（2026-10-26 修：188 张卡时整页卡成幻灯片）：
///         ① 每张卡只查一次 deck_get_card_data（它是线性扫 global.player_deck）→ O(n)
///         ② 不排序：普卡桶 + 金卡桶直接拼（融合卡已过滤，只剩 2 档）
///         ③ 列表和元数据都缓存，绘制 O(1) 取，不再扫 unlocked_cards / player_deck
function tg_rebuild(){
    var _uc = global.save_data.unlocked_cards;
    var _meta = {};
    var _norm = [];                              // 普卡（保持存档顺序）
    var _gold = [];                              // 金卡
    for (var _i = 0; _i < array_length(_uc); _i++){
        var _id = _uc[_i].id;
        var _sh = _uc[_i].shape;
        var _d  = deck_get_card_data(_id, _sh);  // 每张卡只查这一次
        if (_d != noone && ds_map_find_value(_d, "is_fusion") == 1) continue;   // 融合卡不进列表
        if (_d != noone){
            // 缺键给安全默认值（sprite = -1 → 绘制端跳过；cost = 0），避免个别卡把绘制搞崩
            _meta[$ _id] = {
                shape:   _sh,
                level:   _uc[_i].max_level,
                is_gold: (ds_map_find_value(_d, "is_gold") == 1),
                sprite:  ds_map_exists(_d, "sprite") ? _d[? "sprite"] : -1,
                cost:    ds_map_exists(_d, "cost")   ? _d[? "cost"]   : 0
            };
        }
        // 没有 deck 数据的老卡也留在列表里（格子空着，至少能点）
        if (_d != noone && ds_map_find_value(_d, "is_gold") == 1) array_push(_gold, _id);
        else array_push(_norm, _id);
    }
    var _out = [];
    for (var _a = 0; _a < array_length(_norm); _a++) array_push(_out, _norm[_a]);
    for (var _b = 0; _b < array_length(_gold); _b++) array_push(_out, _gold[_b]);

    tg_meta = _meta;
    tg_list = _out;
    tg_list_dirty = false;
}

/// @func tg_notice(text) 转职页专用提示：**先清掉已有提示**再显示。
///       全局 show_notice 是往 global.notice_list 里 push，连点两下就会两条字叠在一起
///       （2026-10-25 用户：金币不足 和 此卡已无法转职 叠着显示）。转职页只留最后一条。
function tg_notice(_text){
    if (variable_global_exists("notice_list")) global.notice_list = [];
    show_notice(_text, 70);
}

/// @func tg_check() 能不能转 —— 判定在 mod_tg_check（数值 / 提示优先级都在表里），这里只喂界面状态
function tg_check(){
    return mod_tg_check(tg_card, tg_assure, global.save_data.player.gold, global.debug);
}

/// @func tg_do() 真转一次：掷骰 → **成功只登记待结算**（动画播完才扣钱/扣凭证/提形态）/ 失败立刻结算
///       ⚠️ 2026-10-26 用户口径：动画期间「凭证和卡都不变」，播完才 清槽 + 提示 + 卡回列表。
///          所以成功分支里**一样都不能改**（存档、形态、凭证、金币），全部塞进 tg_fx_pending，
///          由 Step_0 在特效收尾时调 tg_fx_commit() 一次做完。
function tg_do(){
    var _r = tg_check();
    if (!_r.ok){
        tg_notice(_r.reason);
        return;
    }
    var _id = tg_card;
    var _shape = _r.shape;

    // ── 转职保底：累计次数由对象存（换卡要清零），掷骰与「第 N 次必成」在 mod_tg_roll ──
    if (tg_card != tg_pity_card){
        tg_pity = 0;
        tg_pity_card = tg_card;
    }
    var _roll = mod_tg_roll(_r.rate, tg_pity, mod_tg_pity_max(), tg_assure);
    tg_pity  = _roll.pity;
    var _win = _roll.win;

    if (_win){
        // 保留原来的 level / skill，只把形态提上去（unlock_card 内部取 max，不会降）
        var _lev = 0;
        var _skl = 0;
        var _uc = global.save_data.unlocked_cards;
        for (var _i = 0; _i < array_length(_uc); _i++){
            if (_uc[_i].id == _id){
                _lev = _uc[_i].level;
                _skl = _uc[_i].skill;
                break;
            }
        }
        // 不在此时落账：动画期间显示必须保持原样（2026-10-26）
        tg_fx_pending = {
            id:        _id,
            shape:     _shape,
            lev:       _lev,
            skl:       _skl,
            gold:      _r.gold,
            assure:    _r.assure,
            keep_credit: false                            // 成功必扣凭证（保险金只在失败时生效）
        };
        tg_fx = true;
        tg_fx_t = 0;
        }
    else{
        // 失败是即时的（没有动画）：钱照扣；保险金开着则凭证保住，没开就连凭证一起扣
        global.save_data.player.gold -= _r.gold + _r.assure;
        if (!tg_assure) add_material_amount(transfer_credit_id(_id, _shape), -1);
        tg_notice("不够好运，转职失败");
        save_file(global.save_slot);
    }
    audio_play_sound(snd_button, 0, 0);
}

/// @func tg_fx_commit() 特效播完才真正生效：扣钱 → 扣凭证 → 提形态 → 清主卡槽
///       只由 Step_0 的特效收尾调用；没有待结算数据就直接返回（防御）
function tg_fx_commit(){
    var _p = tg_fx_pending;
    tg_fx_pending = undefined;
    if (is_undefined(_p)) return;

    global.save_data.player.gold -= _p.gold + _p.assure;
    if (!_p.keep_credit) add_material_amount(transfer_credit_id(_p.id, _p.shape), -1);
    unlock_card(_p.id, _p.lev, _p.shape, _p.skl);

    tg_list_dirty = true;                              // 形态变了 → 列表 / 元数据下次绘制前重建
    tg_card = "";                                      // 主卡槽清空，三槽一起回到「只显示槽名」
    tg_pity = 0;                                       // 保底：转成功了就重新数
    tg_pity_card = "";
    save_file(global.save_slot);
}

// ─────────────────────────────────────────────────────────────
// 神级进化页（craft_top_tab == 3）：金卡进化
//   布局照原版截图：三槽（第 1 槽·星座卡 / 第 2 槽·普通卡 / 进化凭证）→ ▼ → 结果槽 → 进化按钮
//   🔴 数据全在 mod/craft：scripts/mod_craft_evo_table（前置表 / 槽位 / 形态要求 / 凭证绘制）
//      这个对象只留「界面状态 + 交互状态机」：evo_cards / evo_miss / evo_target → evo_pick / evo_check / evo_do
//   结果槽：不管能不能进化，都提前画出能进化成的金卡（用户口径）
// ─────────────────────────────────────────────────────────────
evo_slot_x  = [x - 455, x - 305, x - 155]      // 卡1 / 卡2 / 进化凭证
evo_slot_y  = y - 40
evo_arrow_x = x - 305
evo_arrow_y = y + 34
evo_res_x   = x - 305
evo_res_y   = y + 118
evo_btn_x   = x - 305
evo_btn_y   = y + 216
evo_left_x  = x - 662                          // 左侧「金卡进化」竖排按钮
evo_left_y  = y - 30
evo_list_x  = x + 196                          // 右侧防御卡列表（与强化页同一套 84×96 / 7 列）
evo_list_y  = y - 321
evo_cards   = ["", ""]                         // 两个前置卡槽（0 = 星座槽 / 1 = 普通槽，进哪个槽由表决定）
evo_miss    = ["", ""]                         // 槽里「表要求、但玩家没有」的卡 → 画需求形态 + 灰滤镜、不可点
evo_target  = ""                               // 当前能进化成的金卡
evo_hover_card = -1
evo_btn_press  = 0
evo_fx      = false
evo_fx_t    = 0
evo_fx_frames = 55                             // spr_evo_fx 共 55 帧
evo_fx_speed  = 0.5
evo_fx_pending = undefined
evo_list    = []
evo_meta    = {}
evo_list_dirty = true

// 右侧列表的滚动（跟转职页 / 强化页同一套：7 列 × 8 行、84×96、整行滚、Draw 里 0.28 平滑）
evo_gcols = 7
evo_grows = 8
evo_gpx   = 84
evo_gpy   = 96
evo_scroll        = 0      // 平滑后的滚动行（Draw 用 floor 取值）
evo_scroll_target = 0      // 滚轮改这个（Mouse_60/61）
evo_rows_max      = 0      // Draw 每帧按卡数算（ceil(n/列) - 8），Step 只读

/// 前置关系一律走 mod/craft 的表（scripts/mod_craft_evo_table）
///   slot 0 = 第 1 槽（星座卡）/ slot 1 = 第 2 槽（普通卡）/ need = 该前置卡要求的形态
///   这里只做「拿表 + 拼界面状态」，不再自己存一份关系表

/// @func evo_clear() 两个槽 + 缺卡占位一起清空
function evo_clear(){
    evo_cards = ["", ""];
    evo_miss  = ["", ""];
    evo_target = "";
}

/// @func evo_apply(target, slot, card_id) 落槽：规则（进哪槽 / 另一槽补谁）在 mod_evo_resolve，这里只存状态
function evo_apply(_target, _slot, _card_id){
    var _r = mod_evo_resolve(_target, _slot, _card_id);
    evo_cards  = _r.cards;
    evo_miss   = _r.miss;
    evo_target = _r.target;
}

/// @func evo_pick(card_id) 点右侧列表的卡 → 整组落槽（找哪个目标 / 进哪一槽的规则在 mod_evo_pick_target）
/// @return bool 是否进场成功
function evo_pick(_card_id){
    var _p = mod_evo_pick_target(_card_id);
    if (is_undefined(_p)) return false;
    evo_apply(_p.target, _p.slot, _card_id);
    return true;
}

/// @func evo_check() 能不能进化（判定规则在 mod_evo_check，这里只把状态喂进去）
/// @return { ok, reason, target }
function evo_check(){
    var _r = mod_evo_check(evo_target, evo_cards, evo_miss);
    return { ok: _r.ok, reason: _r.reason, target: evo_target };
}

/// @func evo_do() 进化：成功 → 播 55 帧特效，播完才落账（与转职同一套「延迟结算」）
function evo_do(){
    var _r = evo_check();
    if (!_r.ok){ show_notice(_r.reason, 70); return; }
    evo_fx_pending = { target: _r.target, a: evo_cards[0], b: evo_cards[1] };
    evo_fx = true;
    evo_fx_t = 0;
    evo_btn_press = 8;
    audio_play_sound(snd_button, 0, 0);
}

/// @func evo_commit() 特效播完：扣凭证 → 解锁金卡 → 清槽
function evo_commit(){
    var _p = evo_fx_pending;
    evo_fx_pending = undefined;
    if (is_undefined(_p)) return;
    // 扣凭证 + 解锁金卡（星级从 0 起）都在 mod_evo_reward 里
    mod_evo_reward(_p.target);
    evo_clear();
    evo_list_dirty = true;
    if (variable_global_exists("notice_list")) global.notice_list = [];
    show_notice("进化成功！", 80);
    save_file(global.save_slot);
}

/// @func evo_rebuild() 右侧列表：只列 mod_evo_needed_cards() 说的那批「现在还需要的前置卡」里已拥有的
///   （哪张金卡已拥有 → 它的前置不再列；前置本身是金卡/融合卡，只要还被需要就照常列）
function evo_rebuild(){
    evo_meta = {};
    var _out = [];
    var _uc  = global.save_data.unlocked_cards;
    var _need = mod_evo_needed_cards();
    var _set = {};
    for (var _i = 0; _i < array_length(_need); _i++) _set[$ _need[_i]] = true;
    for (var _i = 0; _i < array_length(_uc); _i++){
        var _id = _uc[_i].id;
        if (!variable_struct_exists(_set, _id)) continue;
        var _d = deck_get_card_data(_id, _uc[_i].shape);
        if (_d != noone){
            evo_meta[$ _id] = {
                sprite: ds_map_exists(_d, "sprite") ? _d[? "sprite"] : -1,
                level:  _uc[_i].max_level,          // 星级（画左上角星星）
                cost:   ds_map_exists(_d, "cost")   ? _d[? "cost"]   : 0
            };
        }
        array_push(_out, _id);
    }
    evo_list = _out;
    evo_list_dirty = false;
}

panel_anim_init(id, 0.28, 0.18, 260)
panel_anim_kids(id, [obj_closecraft_btn, obj_craft_select_btn, obj_craft_confirm_btn])

// 合成屋的三个元素（房间坐标 1920x1080，对着绘制坐标算的）：[x1,y1,x2,y2,dx,dy]，dx/dy = 从哪边来
craft_parts = [[130,  15, 1096,  900, -1, 0],   // 左上板块（卡片/宝石强化台）：从左边
               [130, 900, 1096, 1065,  0, 1],   // 下面的道具条：从下边
               [1096, 15, 1790, 1065,  1, 0]]   // 右边的素材格：从右边
