// 强制清除application_surface，避免上一房间图像残留
surface_set_target(application_surface);
draw_clear_alpha(c_black, 0); // 用透明黑色清除surface，alpha值0表示完全透明
surface_reset_target();

global.menu_screen = false
instance_create_depth(1700,883,-2,obj_battlestart_button)
readyroom_music = mus_readyroom

ds_list_clear(global.selected_deck);
deck_ensure_size();
//for(var i = 0;i < 21;i++){
//add_to_deck("xiao_long_bao",0);
//}
//add_to_deck("small_fire",get_card_info_simple("small_fire").shape);
//add_to_deck("flour_sack",get_card_info_simple("flour_sack").shape);
//add_to_deck("toast_bread",0)
//add_to_deck("toast_bread",0);
select_card_index = ds_list_create()
hover_card_index = -1
deck_sort_order = [] // 卡片排序映射（普通卡在前 → 融合卡居中 → 金卡在后）
hover_slot_index = -1
slot_rows = 11
slot_cols = 13
slot_surface = -1
map_surface = -1
y_offset = 0
y_offset_target = 0
sb_dragging = false
sb_drag_y = 0
sb_drag_offset = 0

fly_active = false
fly_add = true
fly_t = 0
fly_dur = 18
fly_sx = 0
fly_sy = 0
fly_tx = 0
fly_ty = 0
fly_spr = -1
fly_slot = -1
fly_pool_i = -1
fly_batch = []
hover_card_x = 0
hover_card_y = 0
hover_card_spr = -1

function readyroom_pool_visual_index(_card_id) {
	for (var _i = 0; _i < array_length(deck_sort_order); _i++) {
		if (global.player_deck[| deck_sort_order[_i]] == _card_id) return _i;
	}
	return -1;
}

is_submenu_open = false

deck_first_slot_index = 0

selected_custom_deck = 0

for(var i = 1; i < 7;i++){
	var inst = instance_create_depth(x+680+150*i,y+218,depth-5,obj_deck_select_btn)
	inst.deck_index = i
}
instance_create_depth(x+1735,y+215,depth-5,obj_deck_clear_btn)

var prev_btn = instance_create_depth(x+1745,y+105,depth-5,obj_readyroom_slot_btn)
prev_btn.type = "prev"
var next_btn = instance_create_depth(x+1745,y+155,depth-5,obj_readyroom_slot_btn)
next_btn.type = "next"

//统计敌人和BOSS类型
enemy_type_list = []
boss_type_list = []
for(var i = 0;i < global.level_file.total_waves;i ++){
	if global.level_file.waves[i].boss_wave{
		if array_get_index(boss_type_list,global.level_file.waves[i].boss) == -1{
			array_push(boss_type_list,global.level_file.waves[i].boss)
		}
		if is_real(global.level_file.version){
			if array_get_index(boss_type_list,global.level_file.waves[i].boss2) == -1 && global.level_file.waves[i].boss2 != ""{
				array_push(boss_type_list,global.level_file.waves[i].boss2)
			}
		}
	}
	var subwave = global.level_file.waves[i].subwaves
	for(var j = 0 ; j <array_length(subwave);j++){
		var enemy_list = subwave[j].enemy_list
		for(var k = 0 ; k < array_length(enemy_list);k++){
			if array_get_index(enemy_type_list,enemy_list[k].type) == -1{
				array_push(enemy_type_list,enemy_list[k].type)
			}
		}
	}
}


/// 与 Draw_0 里那份「普通卡 → 融合卡 → 金卡」排序**同一套**（改了要两边一起改）
readyroom_deck_order = function() {
    var _order  = [];
    var _fusion = [];
    var _gold   = [];
    for (var si = 0; si < ds_list_size(global.player_deck); si += 2) {
        if (global.player_deck[| si] == "lihe" && !is_random_gift_mode()) continue;
        if (is_random_gift_mode() && !random_gift_is_direct_card_allowed(global.player_deck[| si])) continue;
        var _entry  = global.player_deck[| si+1];
        var _shapes = _entry[? "shapes"];
        var _data   = _shapes[| 0];
        if (is_fusion_card(global.player_deck[| si]))                       array_push(_fusion, si);
        else if (ds_map_find_value(_data, "is_gold") == 1)                  array_push(_gold, si);
        else                                                               array_push(_order, si);
    }
    for (var i = 0; i < array_length(_fusion); i++) array_push(_order, _fusion[i]);
    for (var j = 0; j < array_length(_gold);   j++) array_push(_order, _gold[j]);
    return _order;
};

/// 这张卡在这个列表里**真的画得出来**吗
///   口径与 Draw_0 的 is_unlocked 完全一致：unlocked_cards 里有这个 id，且不在 selected_deck
///   （未解锁 / 已上阵的卡在 Draw 里都是空格，搜索不该把它们算命中 —— 否则会滚到一片空白）
readyroom_card_visible = function(_cid)
{
    var _owned = false;
    for (var k = 0; k < array_length(global.save_data.unlocked_cards); k++)
    {
        if (global.save_data.unlocked_cards[k].id == _cid) { _owned = true; break; }
    }
    if (!_owned) return false;

    for (var s = 0; s < ds_list_size(global.selected_deck); s++)
    {
        if (global.selected_deck[| s][? "card_id"] == _cid
            && !(is_random_gift_mode() && _cid == "lihe"))
            return false;
    }
    return true;
};

// ── 卡片搜索（2026-11-08；2026-11-08 晚抽成通用模块 mod_search_nav_*）──────────
//   这里只留「跟本界面有关」的三件事：候选顺序 / 怎么滚 / 拿什么当 key。
//   搜索框配色、清空 / 下一个按钮、命中集合全在 scripts/mod_info_island_search 的通用层。
rrm_order = [];          // 与 Draw_0 里那份排序同口径（key_of / jump 都用它）

// 🔧 搜索栏位置参数（只改这 6 个，改完重进一次预备房生效）
//   x / y = **屏幕绝对坐标**（管理器实例在 (32,0)，不是相对它的偏移）
//   卡片区第一行的视觉顶部 = 屏幕 y 327，搜索框底边（y + h）别越过这条线
rrm_search_x = 1158;
rrm_search_y = 267;
rrm_search_w = 300;
rrm_search_h = 40;
rrm_btn_w    = 96;    // 「清空」「下一个」按钮的**最小**宽度（实际按文字实测自适应，放不下会更宽）
rrm_btn_gap  = 8;     // 按钮与搜索框的间距

rrm_nav = mod_search_nav_create(id, {
    x: rrm_search_x, y: rrm_search_y, w: rrm_search_w, h: rrm_search_h,
    clear_w: rrm_btn_w, next_w: rrm_btn_w, gap: rrm_btn_gap,
    depth: depth - 1,
    placeholder: "搜索名称/[分类]（可拼音）",
    // 命中下标 = 在 rrm_order（= 绘制顺序）里的位置
    collect: method({ h: id }, function(_groups){
        var _h   = h;
        var _out = [];
        _h.rrm_order = _h.readyroom_deck_order();
        for (var i = 0; i < array_length(_h.rrm_order); i++){
            var _cid = global.player_deck[| _h.rrm_order[i]];
            if (!mod_search_match_card(_cid, _groups)) continue;
            // 只认「真的会画出来」的卡：未解锁 / 已上阵的卡在 Draw 里是空格，搜出来会滚到一片空白
            if (!_h.readyroom_card_visible(_cid)) continue;
            array_push(_out, i);
        }
        return _out;
    }),
    key_of: method({ h: id }, function(_i){ return global.player_deck[| h.rrm_order[_i]]; }),
    // 只写 y_offset_target：卡片和滑块本来就有插值，会一起滑过去
    jump: method({ h: id }, function(_i){
        var _h   = h;
        var _row = _i div _h.slot_rows;
        var _rows = ceil(array_length(_h.rrm_order) / _h.slot_rows);
        if (_rows < _h.slot_cols) _rows = _h.slot_cols;
        var _max = max(0, _rows * 96 - 372);
        _h.y_offset_target = clamp(_row * 96 - 96, 0, _max);
    }),
    should_correspond: method({ h: id }, function(){ return !h.is_submenu_open; })
});
