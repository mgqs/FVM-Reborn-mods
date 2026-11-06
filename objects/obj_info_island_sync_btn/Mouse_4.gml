// 点「同步背包」：把当前查看卡的星级 / 转职 / 技能，按背包里的真实数据重新套一遍
if (obj_info_island_bg.info_button_select == 1
	&& obj_info_island_bg.select_card_index != -1
	&& obj_info_island_bg.select_card_index < array_length(obj_info_island_bg.info_view)){

	global.audio.play(snd_button,0,0)

	var _bg  = obj_info_island_bg;
	var _cid = global.player_deck[| _bg.info_view[_bg.select_card_index]];
	var _ci  = get_card_info(_cid);
	if (_ci != false){
		_bg.view_card_level = _ci.level;
		_bg.view_card_shape = _ci.shape;
		_bg.view_card_skill = _ci.skill;
	}
	else{
		// 未拥有（图鉴 / 商店预览）：回 0/0/0，和以前一致
		_bg.view_card_level = 0;
		_bg.view_card_shape = 0;
		_bg.view_card_skill = 0;
	}
}
