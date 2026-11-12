longyuan_bridge_update(current_wave, level_stage);
obj_pool_prewarm_tick();

for (var _i = 0; _i < array_length(global._move_instance_pre_arr); _i++) {
    var _inst = global._move_instance_pre_arr[_i];
    with (_inst) {

        var _hasPlant = variable_instance_exists(id, "parent_plant") && instance_exists(parent_plant) && object_is_ancestor(parent_plant.object_index, obj_card_parent);
        var _hasPlayer = variable_instance_exists(id, "parent_player") && instance_exists(parent_player) && object_is_ancestor(parent_player.object_index, obj_card_parent);

		var _hasCard = (object_index == obj_in_water_effect || object_index == obj_sleep_effect || object_index == obj_lava_burn_effect)
			&& variable_instance_exists(id, "banding_card_obj")
			&& instance_exists(banding_card_obj)
			&& object_is_ancestor(banding_card_obj.object_index, obj_card_parent);
		if (_hasPlant || _hasPlayer || _hasCard) {
			if(!object_is_ancestor(object_index,obj_card_parent)){
	            var tid = _hasPlant ? parent_plant.id : (_hasPlayer ? parent_player.id : banding_card_obj.id);
				if !ds_map_exists(global._move_instance_map,tid){
					var _list = ds_list_create()
					ds_map_add(global._move_instance_map,tid,_list);
				}
				var _list = ds_map_find_value(global._move_instance_map,tid)
				ds_list_add(_list,id);
			}
        }
    }
}

global._move_instance_pre_arr = [];

current_wave_hp = 0
current_wave_alive_count = 0
with obj_enemy_parent{
	if target_type != "obstacle"{
		other.current_wave_hp += hp
		if hp > 0 {
			other.current_wave_alive_count += 1
		}
	}
}
var c_min_time = wave_min_time
if is_real(global.level_file.version){
	if global.level_file.version >= 1.3{
		if current_wave < total_wave{
			var current_total_subwaves = array_length(global.level_file.waves[current_wave].subwaves)
			if current_subwave < current_total_subwaves{
				if global.level_file.waves[current_wave].subwaves[current_subwave].local_min_wave_time >0{
					c_min_time = global.level_file.waves[current_wave].subwaves[current_subwave].local_min_wave_time
				}
			}
		}

	}
}
// 本 subwave 的敌人数量决定它的最短停留时间。
// 原来固定用 wave_min_time（4 秒），导致「只有 1 只敌人」的波和 30 只的波一样要等 4.5 秒；
// 龙渊 631 个 subwave、勇士深渊 285 个 subwave 里大量是 1~7 只，整关被拖长数倍。
// 换算：1 只 ≈ 0.33 秒，2 只 ≈ 0.67 秒，12 只以上回到 wave_min_time。
var _sub_enemy_n = 1
if current_wave < total_wave{
	var _sub_arr = global.level_file.waves[current_wave].subwaves
	if current_subwave < array_length(_sub_arr){
		var _sub_entry = _sub_arr[current_subwave]
		if variable_struct_exists(_sub_entry, "enemy_list") && is_array(_sub_entry.enemy_list){
			_sub_enemy_n = max(1, array_length(_sub_entry.enemy_list))
		}
	}
}
var _dyn_min = clamp(_sub_enemy_n * 20, 20, wave_min_time)
if _dyn_min < c_min_time{
	c_min_time = _dyn_min
}
if current_wave_hp <= hp_ratio * current_total_hp && level_stage != "boss"{
	if current_wave_max_time > c_min_time{
		if wave_timer < (current_wave_max_time - c_min_time) && wave_timer > 30{
			wave_timer = 30
		}
	}
}
// 场上已经没有可打的敌人（全清 / 该波敌人都被跳过）：没必要再空等下限时间，压到 0.2 秒后推进。
// 只在 level_stage == "pre" 生效：BOSS 阶段靠 boss_waiting_clear 控制，ready 阶段还没出第一波。
if level_stage == "pre" && current_wave_alive_count == 0 && wave_timer > 12{
	wave_timer = 12
}
if not global.is_paused{
	wave_timer -= obj_battle.time_ticks_this_step
}
var _is_tower = (string_pos("tower_cake_", global.level_data.id) > 0)
// 魔塔最后一波没有 Boss 时，清空敌人即可结束关卡。
// 最后一波的计时器仍在运行会让玩家在已完成后等到限时结束并判负。
if _is_tower && level_stage == "pre" && !boss_waiting_clear && current_wave == total_wave - 1 && current_wave_alive_count == 0 {
	var _last_sub_total = array_length(global.level_file.waves[current_wave].subwaves)
	if _last_sub_total > 0 && current_subwave >= _last_sub_total - 1 {
		battle_finish_win()
	}
}
// 魔塔模式：小兵击杀后立刻进入下一波
if _is_tower && level_stage == "pre" && !boss_waiting_clear && current_wave_alive_count == 0 && current_wave < total_wave - 1 {
	var _curr_sub_total = array_length(global.level_file.waves[current_wave].subwaves)
	if current_subwave >= _curr_sub_total - 1 {

		current_wave += 1
		current_subwave = 0
		wave_timer = 0
		audio_play_sound(snd_mouse_wave_attack,0,0)
		instance_create_depth(room_width/2,room_height/2,-300,obj_huge_wave_text)
	}
}

if _is_tower && level_stage == "pre" && !boss_waiting_clear && current_wave < total_wave {
	var _tw_data = global.level_file.waves[current_wave]
	if _tw_data.boss_wave && global.save_data.unlocked_items.elite_unlocked {
		boss_waiting_clear = true
	}
}
// 普通关卡的 Boss 波也在这里兜底确认，避免波次计时器与清场发生在同一帧时漏掉 Boss。
var _longyuan_full_progression = string_copy(global.level_id, 1, 8) == "longyuan";
// 龙渊 / 勇士深渊：BOSS 波不再「先清完整波鼠军再单独出 BOSS」。
// 这两个关卡一个 BOSS 波动辄 80~420 只鼠军、5~60 个 subwave，
// 原来的「等最后一个 subwave 出完 + 全场清空」会把 BOSS 藏到几分钟甚至十几分钟后。
// 快速关卡：进入 BOSS 波即召唤 BOSS，后续 subwave 的小怪继续按原逻辑刷出（BOSS 带小怪同场）。
var _fast_boss_level = _longyuan_full_progression || (string_copy(global.level_id, 1, 13) == "abyss_warrior");
// 精英波起切换「BOSS 随机音乐」，一直播到通关（含 BOSS 波）：
// 开关关闭 / 曲库为空 / 加载失败时自动回退关卡自带的 elite_music。
// 每场只抽一次（music_picked），BOSS 阵亡回到 pre 阶段也不会重抽。
// elite_wave 为 0 的关卡（魔塔系）没有精英段，退化为「从最后一波开始」。
if (level_stage == "pre" && instance_exists(obj_battle_music_controller)) {
	var _ew = global.level_file.elite_wave;
	var _music_start_wave = (_ew > 0 && _ew < total_wave) ? _ew : max(0, total_wave - 1);
	if (current_wave >= _music_start_wave) {
		with (obj_battle_music_controller) {
			if (!music_picked) {
				music_picked = true;
				var _rand_music = boss_music_resolve(global.level_data.elite_music);
				new_battle_music = _rand_music;
				// 只有真的换成了曲库里的曲子才算「随机曲生效」。
				// 开关关闭 / 曲库为空时 resolve 原样返回 elite_music，
				// 这时 BOSS 波还要切回关卡自带的 boss_music。
				music_random_active = (_rand_music != global.level_data.elite_music);
				event_user(10);
			}
		}
	}
}
if !_is_tower && level_stage == "pre" && !boss_waiting_clear && current_wave < total_wave && (global.save_data.unlocked_items.elite_unlocked || _longyuan_full_progression || _fast_boss_level) {
	var _main_boss_data = global.level_file.waves[current_wave]
	if _main_boss_data.boss_wave && _main_boss_data.boss != "" {
		if _fast_boss_level {
			// 龙渊 / 勇士深渊：一进入 BOSS 波就召唤，不再等鼠军出完、更不等清场
			boss_waiting_clear = true
		}
		else if current_wave_alive_count == 0 {
			var _main_boss_sub_total = array_length(_main_boss_data.subwaves)
			if _main_boss_sub_total > 0 && current_subwave >= _main_boss_sub_total - 1 {
				boss_waiting_clear = true
			}
		}
	}
}
// BOSS波：等待所有小怪被清光后召唤BOSS（魔塔模式、龙渊/勇士深渊直接召唤）
if boss_waiting_clear && level_stage == "pre" && (current_wave_alive_count == 0 || _is_tower || _fast_boss_level) {
	boss_waiting_clear = false
	level_stage = "boss"
	// BOSS 波音乐：
	//  - 抽到随机曲（开关开 + 曲库有曲子）→ 继续播随机曲，一直播到通关，不切换
	//  - 没抽到（开关关 / 曲库为空 / 加载失败）→ 切回关卡自带的 boss_music
	if (instance_exists(obj_battle_music_controller)) {
		with (obj_battle_music_controller) {
			if (!music_random_active) {
				new_battle_music = global.level_data.boss_music;
				event_user(10);
			}
		}
	}
	if _is_tower {
		wave_timer = 0
		current_subwave = 0
	}
	var wave_data = {}
	if (is_array(global.level_file.waves) && current_wave >= 0 && current_wave < array_length(global.level_file.waves)) {
		wave_data = global.level_file.waves[current_wave]
	}
	var boss_spawn_mult = 1
	if global.difficulty == 5{
		boss_spawn_mult = 2
	}
	var _boss_id = variable_struct_exists(wave_data, "boss") ? wave_data.boss : ""
	if _boss_id != "" && ds_map_exists(global.enemy_map, _boss_id){
		var _boss_data = global.enemy_map[? _boss_id]
		var _has_ver = is_real(global.level_file.version)
		for (var bm = 0; bm < boss_spawn_mult; bm++){
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = get_world_position_from_grid(10,enemy_row)
			var boss_inst = instance_create_depth(enemy_pos.x-80,enemy_pos.y+30,-200,_boss_data._obj)
			boss_count ++
			// 关卡难度系数先乘，海克斯的老鼠侧增幅后乘（顺序铁律：PI 必须在难度系数之后）
			if _has_ver {
				boss_inst.hp *= wave_data.boss_1_hp_modify
				boss_inst.maxhp *= wave_data.boss_1_hp_modify
			}
			hex_enemy_scale_boss(boss_inst);
			// 海克斯「渎神」：BOSS 入场加火苗，本局首个 BOSS 额外给全队攻击
			hex_batch2_on_boss_enter(boss_inst);
			if _has_ver {
				// 连体 BOSS（哼哈将军）：同一 ID 的副体共用血量，不计入 boss_count
				// 副体在缩放之后创建，直接复制已缩放的血量，避免本体/副体倍率不一致
				if (variable_struct_exists(_boss_data, "_peer_obj")) {
					var _peer_row = irandom_range(0,global.grid_rows-1)
					var _peer_pos = get_world_position_from_grid(10,_peer_row)
					var _peer_inst = instance_create_depth(_peer_pos.x-80,_peer_pos.y+30,-200,_boss_data._peer_obj)
					_peer_inst.hp = boss_inst.hp
					_peer_inst.maxhp = boss_inst.maxhp
					_peer_inst.ly_boss_is_peer = true
					_peer_inst.ly_shared_boss_peer = boss_inst
					boss_inst.ly_shared_boss_peer = _peer_inst
				}
				var _boss2_id = wave_data.boss2
				if _boss2_id != "" && ds_map_exists(global.enemy_map, _boss2_id){
					var enemy_row_2 = irandom_range(0,global.grid_rows-1)
					var enemy_pos_2 = get_world_position_from_grid(10,enemy_row_2)
					var boss_2_inst = instance_create_depth(enemy_pos_2.x-80,enemy_pos_2.y+30,-200,global.enemy_map[? _boss2_id]._obj)
					boss_2_inst.hp *= wave_data.boss_2_hp_modify
					boss_2_inst.maxhp *= wave_data.boss_2_hp_modify
					hex_enemy_scale_boss(boss_2_inst);
					boss_count ++
				}
			}
		}
	}
	// BOSS 波音乐已在上面 level_stage = "boss" 处处理过：
	//  抽到随机曲就一直播到通关，没抽到就切关卡自带的 boss_music。
}
if (!global.save_data.unlocked_items.elite_unlocked && current_wave >= global.level_file.elite_wave && !_longyuan_full_progression)||current_wave >= global.level_file.total_waves{
	if current_wave_alive_count == 0 && !instance_exists(obj_game_over) && !instance_exists(obj_gacha_drop){
		battle_finish_win();
	}
}

if (variable_global_exists("enemy_by_type")) {
	var _ebt_cols = global.grid_cols;
	if (!variable_global_exists("enemy_col_n") || array_length(global.enemy_col_n) != _ebt_cols) {
		global.enemy_col_n = array_create(_ebt_cols, 0);
	}
	var _ebt_coln = global.enemy_col_n;
	for (var _ebt_z = 0; _ebt_z < _ebt_cols; _ebt_z++) _ebt_coln[_ebt_z] = 0;

	var _ebt_min = 1000000;
	var _ebt_max = -1000000;
	var _ebt_sx = [];
	var _ebt_keys = variable_struct_get_names(global.enemy_by_type);
	var _ebt_kn = array_length(_ebt_keys);
	for (var _ebt_k = 0; _ebt_k < _ebt_kn; _ebt_k++) {
		var _ebt_key = _ebt_keys[_ebt_k];
		var _ebt_list = global.enemy_by_type[$ _ebt_key];
		if (!is_array(_ebt_list)) continue;
		var _ebt_len = array_length(_ebt_list);
		if (_ebt_len == 0) continue;
		var _ebt_dead = 0;
		for (var _ebt_i = 0; _ebt_i < _ebt_len; _ebt_i++) {
			var _ebt_id = _ebt_list[_ebt_i];
			// object_exists 命中的是「对象索引」被误登记进目标表：instance_exists 对它
			// 只要有任意实例就为真，但下面读 .x / .bbox_left 会直接抛
			// "Unable to find instance for object index"。按死数据处理，让表自愈。
			if (!instance_exists(_ebt_id) || object_exists(_ebt_id)) { _ebt_dead++; continue; }
			var _ebt_x = _ebt_id.x;
			if (_ebt_x < -10000) { _ebt_dead++; continue; }
			var _ebt_l = _ebt_id.bbox_left;
			if (_ebt_l < _ebt_min) _ebt_min = _ebt_l;
			var _ebt_r = _ebt_id.bbox_right;
			if (_ebt_r > _ebt_max) _ebt_max = _ebt_r;
			array_push(_ebt_sx, _ebt_id);

			var _ebt_cc0 = clamp(floor((_ebt_l - global.grid_offset_x) / global.grid_cell_size_x), 0, _ebt_cols - 1);
			var _ebt_cc1 = clamp(floor((_ebt_r - global.grid_offset_x) / global.grid_cell_size_x), 0, _ebt_cols - 1);
			for (var _ebt_cc = _ebt_cc0; _ebt_cc <= _ebt_cc1; _ebt_cc++) _ebt_coln[_ebt_cc] = _ebt_coln[_ebt_cc] + 1;
		}
		if (_ebt_dead > 0) {
			var _ebt_keep = [];
			for (var _ebt_i = 0; _ebt_i < _ebt_len; _ebt_i++) {
				var _ebt_id = _ebt_list[_ebt_i];
				if (!instance_exists(_ebt_id) || object_exists(_ebt_id)) continue;
				if (_ebt_id.x < -10000) continue;
				array_push(_ebt_keep, _ebt_id);
			}
			global.enemy_by_type[$ _ebt_key] = _ebt_keep;
		}
	}
	global.enemy_min_left = _ebt_min;
	global.enemy_max_right = _ebt_max;

	var _ebt_n2 = array_length(_ebt_sx);
	var _ebt_sl = array_create(_ebt_n2, 0);
	var _ebt_sr = array_create(_ebt_n2, 0);
	for (var _ebt_s = 0; _ebt_s < _ebt_n2; _ebt_s++) {
		var _ebt_ee = _ebt_sx[_ebt_s];
		_ebt_sl[_ebt_s] = _ebt_ee.bbox_left;
		_ebt_sr[_ebt_s] = _ebt_ee.bbox_right;
	}

	var _ebt_gap = floor(_ebt_n2 / 2);
	while (_ebt_gap > 0) {
		for (var _ebt_i2 = _ebt_gap; _ebt_i2 < _ebt_n2; _ebt_i2++) {
			var _ebt_kv = _ebt_sl[_ebt_i2];
			var _ebt_rv = _ebt_sr[_ebt_i2];
			var _ebt_iv = _ebt_sx[_ebt_i2];
			var _ebt_j = _ebt_i2;
			while (_ebt_j >= _ebt_gap && _ebt_sl[_ebt_j - _ebt_gap] > _ebt_kv) {
				_ebt_sl[_ebt_j] = _ebt_sl[_ebt_j - _ebt_gap];
				_ebt_sr[_ebt_j] = _ebt_sr[_ebt_j - _ebt_gap];
				_ebt_sx[_ebt_j] = _ebt_sx[_ebt_j - _ebt_gap];
				_ebt_j -= _ebt_gap;
			}
			_ebt_sl[_ebt_j] = _ebt_kv;
			_ebt_sr[_ebt_j] = _ebt_rv;
			_ebt_sx[_ebt_j] = _ebt_iv;
		}
		_ebt_gap = floor(_ebt_gap / 2);
	}

	var _ebt_pm = array_create(_ebt_n2, -1000000);
	var _ebt_run = -1000000;
	for (var _ebt_s = 0; _ebt_s < _ebt_n2; _ebt_s++) {
		if (_ebt_sr[_ebt_s] > _ebt_run) _ebt_run = _ebt_sr[_ebt_s];
		_ebt_pm[_ebt_s] = _ebt_run;
	}
	global.enemy_sx = _ebt_sx;
	global.enemy_sx_l = _ebt_sl;
	global.enemy_sx_pmax = _ebt_pm;
	global.enemy_sx_n = _ebt_n2;
	if (!variable_global_exists("enemy_sx_gen")) global.enemy_sx_gen = 0;
	global.enemy_sx_gen++;
}
