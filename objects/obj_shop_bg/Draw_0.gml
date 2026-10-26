// 绘制事件
panel_anim_step(id)
if (!instance_exists(id)) exit
draw_set_alpha(0.5 * ui_anim_alpha(id));
// 绘制半透明遮罩
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
panel_anim_begin(id)
draw_self()
if (pg_t >= 0) {
	pg_t++;
	if (pg_t > pg_frames) pg_t = -1;
}
pg_alpha = (pg_t >= 0) ? 1 - power(1 - pg_t / pg_frames, 3) : 1;

// 绘制玩家金币数量
draw_set_font(font_number); 
draw_set_color(c_yellow);
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_text(x - 485, y + 447, string(global.save_data.player.gold));

// ── 底条右侧接一段写「威望」（2026-10-26 用户要求，参考原版「余额：金币 X 威望 Y」）──
//   底条本身是烘焙在 spr_shop_bg 里的**单格条**：外框 /「余额：」/ 金币图标 / G 全在图里，
//   只有金币数字是代码画的 → 条内没有第二格的位置。
//   做法：从条右端（sprite x=452 → 屏幕 x-440）用同底色 (3,43,80) 向右延伸一段，
//        里面按原版写法放「威望标签 + 数字」；数字沿用金币那套 font_number 黄字，两边一致。
//   条的几何（sprite → 屏幕，缩放 0.9）：y 998..1052 → y+410..y+459，中心 y+434.5
var _pv   = get_material_amount("prestige");
var _ptag = 1.6;                                    // 标签 32x18 → 51.2x28.8（用户 2026-10-26 自调到 1.6；1.4 ≈ 45x25 才是与烘焙「金币」同高）
var _ptw  = ui_prestige_tag_w(_ptag);
draw_set_font(font_number);
var _pnw  = string_width(string(_pv));
var _px0  = x - 428;                               // 标签左端（条右端在 x-440 → 现在留 12px；用户 2026-10-26 自调）
var _prt  = _px0 + _ptw + 6 + _pnw + 14;            // 延伸段右端
draw_set_colour(make_colour_rgb(3, 43, 80));
draw_roundrect_ext(x - 452, y + 410, _prt, y + 459, 8, 8, false);
ui_prestige_tag_draw(_px0, y + 434.5, _ptag);
draw_set_font(font_number);
draw_set_colour(c_yellow);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text(_px0 + _ptw + 6, y + 434.5, string(_pv));
draw_set_colour(c_white);
//绘制页码
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x + 387, y + 435, string(current_page)+"/"+string(current_max_page));
//绘制背景
draw_sprite_ext(spr_shop_bg_2,0,x,y+58,1.8,1.8,0,c_white,1)

//绘制商品网格
for(var i = 0 ; i< 4; i++){
	for(var j = 0; j < 4; j++){
		draw_sprite_ext(spr_shop_goods_bg,0,x-618+411*i,y-190+165*j,1.8,1.8,0,c_white,1)
	}
}
//按类型绘制图标

for(var i = 0 ; i< 4; i++){
	for(var j = 0; j < 4; j++){
		//绘制卡片类型商品
		if shop_button_select == 1{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
				//根据商品id获取卡片信息
				var card_data = deck_get_card_data(global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id,0)
				if (card_data != noone && ds_exists(card_data, ds_type_map)){
					draw_sprite_ext(spr_slot, 0, x-618+411*j-122,y-190+165*i, 0.33, 0.33, 0, c_white, 1);
					draw_sprite_ext(card_data[? "sprite"],0,x-618+411*j-122,y-190+165*i+25,1,1,0,c_white,1)
					draw_set_halign(fa_left);
					draw_set_valign(fa_middle);
					draw_set_color(c_black);
					draw_set_font(font_number);
					draw_text_ext_transformed(x-618+411*j-122-12, y-190+165*i+44, string(card_data[? "cost"]),25,1800,1,1,0);
					draw_sprite_ext(spr_flame, 0, x-618+411*j-122-24, y-190+165*i+43, 0.3, 0.3, 0, c_white, 1);
					draw_set_halign(fa_left);
					draw_set_valign(fa_top);
					// 检查卡片是否已解锁
			            var is_unlocked = false;
			            for(var k = 0; k < array_length(global.save_data.unlocked_cards); k++) {
			                if (global.save_data.unlocked_cards[k].id == global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id) {
			                    is_unlocked = true;
			                    break;
			                }
			            }
					if is_unlocked{

						draw_set_color(c_black)
						draw_set_alpha(0.5)
						draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
						draw_set_alpha(1)
						draw_sprite_ext(spr_sold_out, 0, x-618+411*j,y-190+165*i, 1.8, 1.8, 0, c_white, 1);
					}
				}
			}
		}
		//绘制装备类型商品
		else if shop_button_select == 2{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
				//根据id获取装备信息
				var goods_data = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)]
				if goods_data.type == "weapon"{
					var weapon_data = get_weapon_info(goods_data.unlock_item_id)
					draw_sprite_ext(weapon_data.icon,0,x-618+411*j-122,y-210+165*i+25,1.5,1.5,0,c_white,1)
					//检查是否解锁
					var is_unlocked = is_weapon_unlocked(goods_data.unlock_item_id)
					if is_unlocked{
					
						draw_set_color(c_black)
						draw_set_alpha(0.5)
						draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
						draw_set_alpha(1)
						draw_sprite_ext(spr_sold_out, 0, x-618+411*j,y-190+165*i, 1.8, 1.8, 0, c_white, 1);
					}
				}
				else if goods_data.type == "gem"{
					var weapon_data = get_gem_info(goods_data.unlock_item_id)
					draw_sprite_ext(weapon_data.icon,0,x-618+411*j-122,y-210+165*i+25,0.9,0.9,0,c_white,1)
					//检查是否解锁
					var is_unlocked = is_gem_unlocked(goods_data.unlock_item_id)
					if is_unlocked{
					
						draw_set_color(c_black)
						draw_set_alpha(0.5)
						draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
						draw_set_alpha(1)
						draw_sprite_ext(spr_sold_out, 0, x-618+411*j,y-190+165*i, 1.8, 1.8, 0, c_white, 1);
					}
				}
			}
		}
		//绘制道具类型商品
		else if shop_button_select == 3{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
				//根据商品id获取商品信息
				var goods_info = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)]
				var goods_spr = goods_info.spr
				
				// 神秘礼盒单独调整位置（居中显示）
				if (goods_info.unlock_item_id == "gacha_box"){
					draw_sprite_ext(goods_spr,0,x-618+411*j-122,y-215+165*i+60,1.5,1.5,0,c_white,1)
				}
				else{
					draw_sprite_ext(goods_spr,0,x-618+411*j-122,y-215+165*i+25,1.8,1.8,0,c_white,1)
				}
				
				//判断卡槽物品是否已售完
				if ((goods_info.unlock_item_id == "card_slot" && global.save_data.unlocked_items.max_slot >= 18)
					||(goods_info.unlock_item_id == "card_slot_19" && global.save_data.unlocked_items.max_slot > 18)
					||(goods_info.unlock_item_id == "card_slot_20" && global.save_data.unlocked_items.max_slot > 19)
					||(goods_info.unlock_item_id == "card_slot_21" && global.save_data.unlocked_items.max_slot > 20)
					)
				{
					draw_set_color(c_black)
					draw_set_alpha(0.5)
					draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
					draw_set_alpha(1)
					draw_sprite_ext(spr_sold_out, 0, x-618+411*j,y-190+165*i, 1.8, 1.8, 0, c_white, 1);
				}
				
			}
		}
		//绘制转职凭证（凭证/兑换项）
		else if shop_button_select == 6{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
				var _cg = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)]
				var _cgx = x-618+411*j
				var _cgy = y-190+165*i
				if (_cg.credit_shape > 0){
					// 凭证：底板 + 实时形态卡面，画在格子左侧图标区（跟道具页 icon 同一位置：格子中心左移 122）
					// 尺寸 110 → 96、中心上移 12（2026-10-26 用户：给底下那行「通过X-X层可买」腾位置，
					//   否则字会压在凭证上、还被格子底边裁掉）
					var _cp = transfer_credit_parse(_cg.unlock_item_id)
					var _csz = 96
					transfer_credit_draw(_cgx-122-_csz*0.5, _cgy-12-_csz*0.5, _cp.card_id, _cp.shape, _csz, 0, 1)
					// 只有「永久锁」（形态不存在 / 已持有 / 已转职）才盖黑影 + 售完；
					// 爬塔门槛和余额不足不盖，点购买时才弹提示（2026-10-26 用户定）
					if (transfer_credit_buyable_locked(_cp.card_id, _cp.shape)) {
						draw_set_color(c_black)
						draw_set_alpha(0.5)
						draw_rectangle(_cgx-205, _cgy-82, _cgx+205, _cgy+82, false)
						draw_set_alpha(1)
						draw_sprite_ext(spr_sold_out, 0, _cgx, _cgy, 1.8, 1.8, 0, c_white, 1)
					}
				}
				else{
					// 兑换项：威望图标
					draw_sprite_ext(spr_prestige_icon, 0, _cgx-122, _cgy, 2.8, 2.8, 0, c_white, 1)
				}
			}
		}
		//绘制时装类型商品
		if shop_button_select == 4{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
				//根据商品id获取卡片信息
				var card_data = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)]
				var attire_data = get_attire_info(card_data.unlock_item_id)
				draw_sprite_ext(spr_slot, 0, x-618+411*j-122,y-190+165*i, 0.33, 0.33, 0, c_white, 1);
				draw_sprite_ext(attire_data.icon,0,x-618+411*j-122,y-190+165*i+25,1,1,0,c_white,1)
				draw_set_halign(fa_left);
				draw_set_valign(fa_middle);
				draw_set_color(c_black);
				draw_set_font(font_number);
				//draw_text_ext_transformed(x-618+411*j-122-12, y-190+165*i+44, "0",25,1800,1,1,0);
				//draw_sprite_ext(spr_flame, 0, x-618+411*j-122-24, y-190+165*i+43, 0.3, 0.3, 0, c_white, 1);
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				// 检查时装是否已解锁
		            var is_unlocked = false;
		            if is_attire_unlocked(card_data.unlock_item_id){
						is_unlocked = true
					}
				if is_unlocked{
					
					draw_set_color(c_black)
					draw_set_alpha(0.5)
					draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
					draw_set_alpha(1)
					draw_sprite_ext(spr_sold_out, 0, x-618+411*j,y-190+165*i, 1.8, 1.8, 0, c_white, 1);
				}
			}
		}
		if shop_button_select == 5{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
				//根据商品id获取卡片信息
				var card_data = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)]
				var attire_data = get_attire_info(card_data.unlock_item_id)
				draw_sprite_ext(attire_data.icon,0,x-618+411*j-122,y-210+165*i+25,1,1,0,c_white,1)
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				// 检查时装是否已解锁
		            var is_unlocked = false;
		            if is_attire_unlocked(card_data.unlock_item_id){
						is_unlocked = true
					}
				if is_unlocked && get_attire_state(card_data.unlock_item_id) == "equipped"{
					
					draw_set_color(c_black)
					draw_set_alpha(0.5)
					draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
					draw_set_alpha(1)
				}
			}
		}
	}
}

// ── 转职凭证页：左上角分类页签（一转 / 二转 / 全部）──
// 位置（2026-10-25 改）：从「压在面板上沿」上移到**面板上方那条蓝带**里
//   —— 顶部页签行底边 y-332.5、内面板顶边 y-286.5，标签中心 y-307（高 34）正好坐进去，
//      既不压面板边框、也不压第一排商品格；三个标签等距排列
// ⚠️ 原来这条带右边还有个「威望图标 + 数字」，2026-10-26 用户要求撤掉 ——
//    威望已经写进底部余额条（见本文件开头那段延伸条），顶栏不再重复显示
if (shop_button_select == 6) {
	var _ct_scl = 1.6
	var _ct_y = y - 307
	// 顺序：一转(1) / 二转(2) / 全部(0)
	// 🔴 frame 0 = 金色 = 选中、frame 1 = 蓝色 = 未选中（2026-10-25 修正：原来写反了）
	var _ct_spr = [spr_shop_credit_tab_1, spr_shop_credit_tab_2, spr_shop_credit_tab_all]
	var _ct_val = [1, 2, 0]
	var _ct_cx = [x - 740, x - 616, x - 517]
	for (var _ct = 0; _ct < 3; _ct++) {
		draw_sprite_ext(_ct_spr[_ct], (credit_tab == _ct_val[_ct]) ? 0 : 1,
			_ct_cx[_ct], _ct_y, _ct_scl, _ct_scl, 0, c_white, 1)
	}
}

draw_set_alpha(1)
panel_anim_end_slide(id, 260)
