/// boss_music —— BOSS 随机音乐
///
/// 曲库位置：%LOCALAPPDATA%\FVM_Reborn_makk\boss_music\  （只认 .ogg）
/// 开关：设置 → 音频设置 → 「BOSS 随机音乐」，存 config.ini 的 settings/boss_music_random
///
/// 设计要点：
///   ① 曲库为空 / 读取失败时【静默回退内置 boss_music】，不影响正常流程
///   ② 每场战斗最多创建 1~2 个流（BOSS 波切歌时才建），房间结束时统一回收
///   ③ 不在切歌那一刻销毁旧流 —— obj_battle_music_controller 的 Other_10 还在拿旧
///      id 调 audio_stop_sound，销毁早了会报「索引不映射到音频资产」

/// 沙盒相对路径：GM 会自动映射到 %LOCALAPPDATA%\<项目名>\boss_music\
/// 用绝对路径喂 file_find_first / audio_create_stream 在沙盒模式下会失败，这是
/// 「开关打开了却没声音」的根因。
#macro kBossMusicRelDir "boss_music"

/// 绝对路径只用于「打开文件夹」这类给玩家看的场景
#macro kBossMusicFolderSuffix "\\FVM_Reborn_makk\\boss_music"

/// 随游戏分发的内置曲库：datafiles/boss_music_pack/ → 运行时 boss_music_pack/
/// 用固定清单而不是扫目录 —— 打包版里 included files 的目录枚举在不同运行时上
/// 行为不一致，逐个 audio_create_stream 最稳，失败的会自动换下一首
#macro kBossMusicPackDir "boss_music_pack"

/// @func boss_music_dir()
/// @desc 曲库目录的绝对路径（不带尾反斜杠）
function boss_music_dir() {
	return global.native_util.get_path_in_local_appdata(kBossMusicFolderSuffix);
}

/// @func boss_music_ensure_dir()
/// @desc 目录不存在就建一个，方便玩家第一次进设置就能看到文件夹
function boss_music_ensure_dir() {
	if (!directory_exists(kBossMusicRelDir)) {
		directory_create(kBossMusicRelDir);
	}
	return kBossMusicRelDir;
}

/// @func boss_music_scan()
/// @desc 扫描曲库，返回 .ogg 的**沙盒相对路径**数组（可直接喂 audio_create_stream）
function boss_music_scan() {
	var _out = [];

	// ① 沙盒相对路径（正常工作路径：GM 自动映射到 %LOCALAPPDATA%\<项目>\boss_music\）
	var _f = file_find_first(kBossMusicRelDir + "\\*.ogg", fa_readonly | fa_archive);
	while (_f != "") {
		array_push(_out, kBossMusicRelDir + "\\" + _f);
		_f = file_find_next();
	}
	file_find_close();

	// ② 兜底：某些运行时对相对路径不买账，用绝对路径再扫一遍
	if (array_length(_out) == 0) {
		var _abs = boss_music_dir();
		if (directory_exists(_abs)) {
			_f = file_find_first(_abs + "\\*.ogg", fa_readonly | fa_archive);
			while (_f != "") {
				array_push(_out, _abs + "\\" + _f);
				_f = file_find_next();
			}
			file_find_close();
		}
	}

	// ③ 内置曲库（随游戏分发，新设备开箱即有）
	var _builtin = boss_music_builtin_list();
	var _bn = array_length(_builtin);
	for (var _bi = 0; _bi < _bn; _bi++) {
		array_push(_out, kBossMusicPackDir + "\\" + _builtin[_bi]);
	}
	return _out;
}

/// @func boss_music_builtin_list()
/// @desc 内置曲库的文件名清单（不含目录）。改歌单只需改这里 + 同步 datafiles/boss_music_pack/
function boss_music_builtin_list() {
	return [
		"周杰伦 - 晴天.ogg",
		"阿YueYue,刘兆宇 - 冬眠.ogg",
		"蔡健雅 - 红色高跟鞋.ogg",
		"未知歌手 - 七里香.ogg",
		"杨丞琳 - 雨爱.ogg",
		"张芸京 - 偏爱.ogg",
		"周杰伦 - 花海.ogg",
		"周杰伦 - 明明就.ogg",
		"周杰伦 - 青花瓷.ogg",
		"(猴叫司凤版)-泡泡心.ogg"
	];
}

/// @func boss_music_count()
/// @desc 曲库曲目数。设置界面每帧都会调，所以带 3 秒缓存，避免逐帧扫目录
function boss_music_count() {
	var _now = current_time;
	if (variable_global_exists("boss_music_count_ms")
		&& _now - global.boss_music_count_ms < 3000) {
		return global.boss_music_count_cache;
	}
	var _n = array_length(boss_music_scan());
	global.boss_music_count_cache = _n;
	global.boss_music_count_ms = _now;
	return _n;
}

/// @func boss_music_track(_s)
/// @desc 登记一个已创建的流，房间结束时统一销毁
function boss_music_track(_s) {
	if (!variable_global_exists("boss_music_streams")) {
		global.boss_music_streams = [];
	}
	array_push(global.boss_music_streams, _s);
}

/// @func boss_music_stream_free_all()
/// @desc 停止并销毁本场战斗创建的所有流（obj_battle_music_controller 的 Room End 调用）
function boss_music_stream_free_all() {
	if (!variable_global_exists("boss_music_streams")) return;
	var _a = global.boss_music_streams;
	var _n = array_length(_a);
	for (var _i = 0; _i < _n; _i++) {
		var _s = _a[_i];
		if (_s != -1 && audio_exists(_s)) {
			if (audio_is_playing(_s)) audio_stop_sound(_s);
			audio_destroy_stream(_s);
		}
	}
	global.boss_music_streams = [];
}

/// @func boss_music_resolve(_fallback)
/// @desc 取一首 BOSS 音乐。开关关闭 / 曲库为空 / 加载失败时返回 _fallback。
/// @param {Real} _fallback 内置 boss_music 的资产索引
/// @return {Real} 可直接交给 audio_play_sound 的声音索引
function boss_music_resolve(_fallback) {
	var _on = false;
	if (variable_global_exists("boss_music_random")) _on = global.boss_music_random;
	if (!_on) return _fallback;

	var _list = boss_music_scan();
	var _n = array_length(_list);
	if (_n == 0) return _fallback;

	// 随机起点，最多试 8 首 —— 单首损坏/路径不可达时换下一首，别整场哑掉
	var _start = irandom(_n - 1);
	var _tries = min(_n, 8);
	for (var _t = 0; _t < _tries; _t++) {
		var _path = _list[(_start + _t) mod _n];
		var _loaded = audio_create_stream(_path);

		// 兜底：玩家目录里的歌，相对路径失败时换绝对路径再试一次
		if (_loaded == -1 && !string_starts_with(_path, kBossMusicPackDir)) {
			var _abs2 = global.native_util.get_path_in_local_appdata(kBossMusicFolderSuffix)
			            + "\\" + filename_name(_path);
			_loaded = audio_create_stream(_abs2);
			if (_loaded != -1) _path = _abs2;
		}
		if (_loaded == -1) continue;

		boss_music_track(_loaded);
		global.boss_music_last_path = _path;
		return _loaded;
	}
	return _fallback;
}
