/// enemy_body —— 敌人固定判定框表（碰撞精度 B 方案）
/// 生成器：tools/gen_enemy_body.py（重跑即可刷新，勿手改数据段）
///
/// 设计：每个敌人离线扫「站立首帧」的实心像素范围，存成相对实例原点的
/// 固定偏移 { l, r, t, b }。运行时按实例 image_xscale 换算世界坐标，
/// 不再使用实例 bbox —— collisionKind=4 的精灵会随动作突变
/// （巨人鼠挥爪帧左缘从 -57 拉到 -104，凭空多出 47px），导致命中时机忽早忽晚。
///
/// 退回方式：把 ENEMY_BODY_ENABLED 改成 false，全部判定恢复引擎 bbox，
/// 无需改任何调用点。

#macro ENEMY_BODY_ENABLED true

/// @func enemy_body_ensure()
/// @desc 惰性构建 sprite 索引 -> 判定框 的 ds_map，只建一次
function enemy_body_ensure() {
	static _busy = false;
	if (_busy) return;
	if (variable_global_exists("enemy_body_tbl")) return;
	_busy = true;

	var _t = ds_map_create();
	var _rows = [
		["spr_abyss_pharaoh_death", -62, 13, -158, -13],
		["spr_abyss_pharaoh_idle", -63, 15, -158, -13],
		["spr_airbrone_explosive_mouse_air", -134, 43, -153, -38],
		["spr_airbrone_explosive_mouse_drop", -134, 43, -153, -39],
		["spr_airbrone_explosive_mouse_land", -33, 39, -94, -5],
		["spr_aircraft_carrier", -86, 272, -231, -51],
		["spr_aircraft_carrier_release_1", -86, 272, -231, -51],
		["spr_aircraft_carrier_release_2", -86, 272, -231, -51],
		["spr_aircraft_carrier_release_3", -86, 272, -231, -51],
		["spr_angelababy_death", -122, 78, -207, -13],
		["spr_angelababy_idle", -123, 68, -220, 13],
		["spr_angelababy_move_backward", -91, 88, -230, 13],
		["spr_angelababy_move_forward", -150, 59, -206, 13],
		["spr_apple_duck_mouse", -43, 44, -76, -16],
		["spr_apple_duck_mouse_enter", -43, 44, -106, -21],
		["spr_apple_duck_mouse_enter_helmet", -43, 44, -114, -21],
		["spr_apple_duck_mouse_helmet", -42, 42, -87, -17],
		["spr_apple_duck_mouse_land", -43, 44, -106, -21],
		["spr_apple_duck_mouse_land_helmet", -43, 44, -114, -21],
		["spr_apple_football_fan_mouse", -35, 51, -105, -20],
		["spr_apple_football_fan_mouse_helmet", -35, 51, -113, -20],
		["spr_arno_death", -95, 56, -143, -9],
		["spr_arno_idle", -65, 88, -168, -7],
		["spr_arno_skill_1", -95, 60, -143, -9],
		["spr_arson_mouse", -49, 22, -110, -17],
		["spr_arson_mouse_bomb", -49, 22, -110, -17],
		["spr_arson_mouse_ready", -49, 12, -109, -17],
		["spr_arson_mouse_throw", -47, 14, -109, -17],
		["spr_assault_mouse", -44, 44, -86, -26],
		["spr_assault_mouse_helmet", -43, 44, -101, -27],
		["spr_assault_mouse_land", -42, 44, -111, -25],
		["spr_assault_mouse_land_helmet", -42, 45, -126, -25],
		["spr_barrel_mouse", -41, 35, -107, -19],
		["spr_barrel_mouse_act", -45, 33, -105, -19],
		["spr_barrel_mouse_return", -26, 29, -81, -20],
		["spr_bat_mouse", -53, 41, -82, -7],
		["spr_beverage_machine_death", -90, 118, -262, -14],
		["spr_beverage_machine_idle", -90, 118, -262, -14],
		["spr_blonde_mary_death", -98, 105, -132, 21],
		["spr_blonde_mary_idle", -76, 82, -131, -13],
		["spr_butterfly_mouse", -42, 34, -82, -10],
		["spr_butterfly_mouse_enter", -42, 34, -106, -16],
		["spr_butterfly_mouse_enter_shield", -45, 34, -106, -20],
		["spr_butterfly_mouse_land", -42, 34, -106, -20],
		["spr_butterfly_mouse_land_shield", -45, 34, -105, -19],
		["spr_butterfly_mouse_shield", -45, 34, -82, -10],
		["spr_can", -36, 36, -42, 42],
		["spr_can_mouse", -42, 18, -100, -16],
		["spr_can_mouse_drop", -37, 40, -127, -42],
		["spr_can_mouse_with_can", -46, 40, -126, -16],
		["spr_captain_america_mouse_death", -101, 105, -189, -15],
		["spr_captain_america_mouse_idle", -101, 105, -196, -15],
		["spr_caribbean_mouse", -49, 41, -136, -11],
		["spr_carpet_mouse", -37, 34, -100, -11],
		["spr_carpet_mouse_air", -45, 45, -146, -14],
		["spr_carpet_mouse_drop", -45, 45, -146, -14],
		["spr_charge_spring_mouse", -42, 21, -99, -15],
		["spr_charge_spring_mouse_place", -41, 31, -104, -14],
		["spr_charge_spring_mouse_shield", -41, 31, -104, -15],
		["spr_clownfish_mouse", -43, 30, -101, -14],
		["spr_clownfish_mouse_skate", -55, 35, -109, -18],
		["spr_conch_mouse", -68, 28, -128, -17],
		["spr_conch_mouse_act", -68, 28, -128, -17],
		["spr_conch_mouse_ready", -68, 28, -128, -17],
		["spr_cucumber_normal_mouse", -43, 30, -101, -15],
		["spr_cucumber_paper_boat_mouse", -44, 19, -75, -16],
		["spr_cucumber_paper_boat_mouse_enter", -44, 29, -105, -20],
		["spr_cucumber_paper_boat_mouse_land", -44, 29, -105, -20],
		["spr_dentist_mouse", -33, 37, -114, -14],
		["spr_dentist_mouse_dig", -48, 34, -51, -13],
		["spr_dentist_mouse_stun", -33, 36, -114, -13],
		["spr_diver_mouse", -55, 3, -45, -12],
		["spr_diver_mouse_enter", -54, 39, -101, -20],
		["spr_diver_mouse_land", -53, 43, -105, -18],
		["spr_diver_mouse_up", -57, 47, -91, -14],
		["spr_dragon_boat_mouse", -139, 127, -128, -6],
		["spr_duck_mouse", -43, 44, -76, -16],
		["spr_duck_mouse_enter", -43, 43, -106, -20],
		["spr_duck_mouse_enter_helmet", -43, 44, -114, -21],
		["spr_duck_mouse_helmet", -42, 42, -87, -17],
		["spr_duck_mouse_land", -43, 44, -106, -21],
		["spr_duck_mouse_land_helmet", -43, 44, -114, -21],
		["spr_eel_mouse", -51, 72, -98, -26],
		["spr_eel_mouse_bomb", -51, 72, -98, -21],
		["spr_egg_iron_pan_mouse", -44, 17, -98, -13],
		["spr_egg_iron_pan_mouse_helmet", -56, 17, -102, -12],
		["spr_egg_tropical_fish_mouse", -43, 30, -78, -19],
		["spr_egg_tropical_fish_mouse_enter", -44, 30, -108, -24],
		["spr_egg_tropical_fish_mouse_enter_helmet", -56, 31, -114, -24],
		["spr_egg_tropical_fish_mouse_helmet", -54, 31, -87, -19],
		["spr_egg_tropical_fish_mouse_land", -43, 30, -109, -24],
		["spr_egg_tropical_fish_mouse_land_helmet", -56, 31, -113, -23],
		["spr_electric_jellyfish_death", -125, 132, -291, -27],
		["spr_electric_jellyfish_idle", -123, 133, -290, -11],
		["spr_electric_jellyfish_move", -120, 138, -287, -15],
		["spr_electric_jellyfish_move_fast", -120, 138, -287, -15],
		["spr_engineering_vehicle_mouse", -29, 62, -115, -13],
		["spr_engineering_vehicle_mouse_move", -29, 62, -115, -13],
		["spr_explore_mouse", -34, 39, -105, -17],
		["spr_explore_mouse_armor", -23, 31, -20, 16],
		["spr_explore_mouse_helmet", -34, 39, -111, -17],
		["spr_fire_residue_ball", -64, 64, -138, -9],
		["spr_flagship_mouse", -146, 159, -168, -8],
		["spr_flight_barrier_mouse_air", -74, 36, -136, -17],
		["spr_flight_barrier_mouse_drop", -74, 36, -136, -42],
		["spr_flight_barrier_mouse_land", -33, 20, -98, -17],
		["spr_flute_mouse", -42, 20, -109, -16],
		["spr_flute_mouse_perform", -42, 20, -109, -16],
		["spr_fog_julie_death", -111, 128, -157, -47],
		["spr_fog_julie_idle", -111, 128, -157, -49],
		["spr_football_fan_mouse", -40, 46, -104, -19],
		["spr_football_fan_mouse_helmet", -40, 46, -112, -19],
		["spr_football_helmet", -20, 22, -14, 12],
		["spr_frog_prince_mouse", -40, 24, -61, -17],
		["spr_frog_prince_mouse_enter", -34, 40, -110, -7],
		["spr_frog_prince_mouse_frog", -36, 38, -83, -20],
		["spr_frog_prince_mouse_land", -40, 28, -90, -7],
		["spr_gaoqiao_move", -36, 33, -135, -17],
		["spr_garbage_track_mouse", -45, 129, -100, -13],
		["spr_ghost_mouse", -42, 30, -90, -16],
		["spr_giant_mouse", -57, 34, -143, -9],
		["spr_glider_mouse_air", -74, 36, -136, -42],
		["spr_glider_mouse_drop", -74, 36, -136, -42],
		["spr_glider_mouse_land", -33, 20, -98, -17],
		["spr_hazelnut_cannon_mouse", -34, 64, -118, -11],
		["spr_hazelnut_cannon_mouse_move", -34, 64, -118, -11],
		["spr_hells_messenger_death", -81, 71, -139, -9],
		["spr_hells_messenger_idle", -76, 74, -195, -9],
		["spr_hercules_death", -63, 210, -185, -16],
		["spr_hercules_idle", -62, 210, -187, -16],
		["spr_honglonglong_death", -96, 80, -189, -9],
		["spr_honglonglong_drop", -96, 74, -237, -23],
		["spr_honglonglong_idle", -96, 74, -174, -8],
		["spr_honglonglong_launch", -96, 74, -171, -8],
		["spr_honglonglong_move_backword", -102, 74, -237, -24],
		["spr_honglonglong_move_forward", -96, 88, -237, -28],
		["spr_hot_vajra_death", -131, 192, -293, -6],
		["spr_hot_vajra_idle", -131, 192, -293, -6],
		["spr_huang_xiaoming_death", -83, 78, -221, 10],
		["spr_huang_xiaoming_idle", -83, 78, -221, 10],
		["spr_hulk_mouse_death", -140, 86, -278, -7],
		["spr_hulk_mouse_idle", -141, 126, -294, -10],
		["spr_hulk_mouse_move_fast", -142, 126, -294, -10],
		["spr_hulk_mouse_move_slow", -141, 126, -294, -10],
		["spr_ice_residue_ball", -65, 65, -136, -7],
		["spr_ice_residue_bullet", -16, 39, -18, 14],
		["spr_ice_residue_disappear", -66, 33, -129, -7],
		["spr_infected_arno_death", -81, 72, -114, 22],
		["spr_infected_arno_idle", -57, 93, -149, 12],
		["spr_infected_bingzha_ball", -55, 75, -142, -12],
		["spr_infected_bingzha_bullet", -18, 38, -18, 14],
		["spr_infected_bingzha_disappear", -63, 35, -138, -18],
		["spr_infected_bingzha_fire_ball", -54, 75, -140, -11],
		["spr_infected_diver_mouse", -49, 9, -33, 0],
		["spr_infected_diver_mouse_enter", -48, 49, -90, -8],
		["spr_infected_diver_mouse_land", -53, 48, -188, -101],
		["spr_infected_diver_mouse_up", -52, 53, -80, -2],
		["spr_infected_duck_mouse", -52, 33, -105, -43],
		["spr_infected_duck_mouse_enter", -82, -19, -155, -92],
		["spr_infected_duck_mouse_enter_helmet", -60, 32, -126, -44],
		["spr_infected_duck_mouse_helmet", -47, 51, -60, -1],
		["spr_infected_duck_mouse_land", -45, 49, -77, 0],
		["spr_infected_duck_mouse_land_helmet", -66, 32, -121, -43],
		["spr_infected_football_fan_mouse", -46, 48, -74, 3],
		["spr_infected_football_fan_mouse_helmet", -49, 49, -77, 1],
		["spr_infected_frog_prince_mouse", -37, 27, -43, -2],
		["spr_infected_frog_prince_mouse_frog", -35, 39, -149, -90],
		["spr_infected_frog_prince_mouse_land", -35, 32, -72, 4],
		["spr_infected_iron_pan_mouse", -45, 21, -76, 2],
		["spr_infected_iron_pan_mouse_helmet", -70, 6, -94, -14],
		["spr_infected_kangaroo_drop", -33, 61, -95, 2],
		["spr_infected_kangaroo_dropped", -34, 57, -84, 2],
		["spr_infected_landlady_mouse", -52, 21, -78, 2],
		["spr_infected_landlady_mouse_shield", -52, 21, -79, 1],
		["spr_infected_little_panda", -31, 15, -68, 1],
		["spr_infected_little_panda_throw", -32, 15, -71, -5],
		["spr_infected_mario_mouse_dig_down", -55, 53, -110, 1],
		["spr_infected_mario_mouse_idle", -49, 58, -104, 2],
		["spr_infected_mario_pipeline_land", -62, 31, -72, 5],
		["spr_infected_mario_pipeline_water", -58, 44, -69, 17],
		["spr_infected_panda_mouse", -62, 28, -127, 6],
		["spr_infected_panda_mouse_throw", -55, 40, -157, 7],
		["spr_infected_paper_boat_mouse", -40, 29, -58, -1],
		["spr_infected_paper_boat_mouse_enter", -44, 25, -76, 2],
		["spr_infected_paper_boat_mouse_land", -44, 25, -76, 2],
		["spr_infected_pharaoh_death", -52, 23, -147, -3],
		["spr_infected_pharaoh_idle", -62, 12, -138, 6],
		["spr_infected_roller_skating_mouse", -40, 31, -84, 5],
		["spr_infected_roller_skating_mouse_helmet", -43, 30, -77, 5],
		["spr_infected_skateboard_mouse", -37, 41, -75, 3],
		["spr_infected_submarine_mouse", -60, 66, -65, 4],
		["spr_infected_submarine_mouse_enter", -70, 57, -153, 1],
		["spr_infected_submarine_mouse_land", -69, 58, -141, 8],
		["spr_infected_tropical_fish_mouse", -32, 45, -61, 1],
		["spr_infected_tropical_fish_mouse_enter", -39, 39, -77, 2],
		["spr_infected_tropical_fish_mouse_enter_helmet", -55, 38, -78, 2],
		["spr_infected_tropical_fish_mouse_helmet", -48, 43, -59, 0],
		["spr_infected_tropical_fish_mouse_land", -46, 37, -75, 2],
		["spr_infected_tropical_fish_mouse_land_helmet", -54, 38, -77, 1],
		["spr_infected_zhanshen_death", -55, 115, -187, -20],
		["spr_infected_zhanshen_idle", -58, 115, -186, -22],
		["spr_iron_diver_helmet", -24, 25, -29, 24],
		["spr_iron_diver_mouse", -57, 37, -103, -4],
		["spr_iron_diver_mouse_helmet", -64, 37, -110, -4],
		["spr_iron_man_mouse_death", -147, 125, -193, 46],
		["spr_iron_man_mouse_death2", -51, 41, -178, -15],
		["spr_iron_man_mouse_drop", -56, 85, -227, -26],
		["spr_iron_man_mouse_idle", -62, 72, -208, -15],
		["spr_iron_man_mouse_launch", -62, 72, -208, -15],
		["spr_iron_man_mouse_move", -90, 101, -214, 38],
		["spr_iron_pan_mouse", -42, 18, -100, -15],
		["spr_iron_pan_mouse_helmet", -55, 18, -104, -14],
		["spr_irritable_jack_death", -78, 68, -181, -18],
		["spr_irritable_jack_idle", -78, 68, -192, -18],
		["spr_jet_mouse", -46, 40, -109, -13],
		["spr_kamikaze_glider_mouse_air", -51, 72, -165, -35],
		["spr_kamikaze_glider_mouse_drop", -66, 87, -187, -38],
		["spr_kamikaze_glider_mouse_land", -50, 74, -127, -32],
		["spr_kangaroo", -46, 40, -111, -15],
		["spr_kf_zr_arson", -46, 18, -112, -17],
		["spr_kf_zr_arson_ready", -41, 19, -116, -17],
		["spr_kf_zr_arson_throw", -46, 18, -112, -17],
		["spr_kf_zr_can", -43, 19, -94, -16],
		["spr_kf_zr_can_drop", -30, 42, -124, -43],
		["spr_kf_zr_can_withcan", -51, 37, -125, -16],
		["spr_kf_zr_dentist", -41, 46, -108, -14],
		["spr_kf_zr_dentist_dig", -56, 26, -52, -14],
		["spr_kf_zr_dentist_stun", -41, 43, -108, -14],
		["spr_kf_zr_flower", -45, 20, -112, -15],
		["spr_kf_zr_flower_drop", -49, 20, -92, -15],
		["spr_kf_zr_flower_shield", -50, 20, -92, -15],
		["spr_kf_zr_magician", -58, 60, -150, -13],
		["spr_kf_zr_mole", -40, 44, -98, -14],
		["spr_kf_zr_mole_dig", -58, 24, -52, -14],
		["spr_kf_zr_mole_stun", -40, 41, -98, -14],
		["spr_kf_zr_naruto", -43, 29, -104, -11],
		["spr_kf_zr_naruto_minion", -41, 28, -93, -14],
		["spr_kf_zr_naruto_minion_summon", -44, 21, -80, -16],
		["spr_kf_zr_naruto_summon", -53, 29, -97, -13],
		["spr_kf_zr_nonmain", -38, 48, -100, -11],
		["spr_kf_zr_penguin_enter", -44, 22, -101, -15],
		["spr_kf_zr_penguin_land", -44, 22, -101, -15],
		["spr_kf_zr_penguin_throw", -40, 21, -97, -13],
		["spr_kf_zr_penguin_water", -44, 22, -101, -15],
		["spr_kf_zr_sawblade", -39, 45, -120, -12],
		["spr_kf_zr_sawblade_dig", -56, 25, -69, -11],
		["spr_kf_zr_sawblade_stun", -40, 43, -119, -11],
		["spr_kf_zr_warrior", -45, 26, -103, -12],
		["spr_kf_zr_warrior_minion", -41, 28, -93, -14],
		["spr_kf_zr_warrior_minion_summon", -44, 21, -80, -16],
		["spr_kf_zr_warrior_summon", -54, 26, -94, -13],
		["spr_kf_zrb_cap", -95, 99, -195, -15],
		["spr_kf_zrb_cap_death", -101, 105, -198, -15],
		["spr_kf_zrb_jack", -77, 67, -189, -18],
		["spr_kf_zrb_jack_death", -77, 67, -180, -18],
		["spr_kf_zrb_mary", -77, 82, -129, -13],
		["spr_kf_zrb_mary_death", -83, 90, -127, 21],
		["spr_kf_zrb_shi", -74, 71, -194, -9],
		["spr_kf_zrb_shi_death", -80, 70, -138, -9],
		["spr_kf_zrb_vajra", -128, 189, -292, -6],
		["spr_kf_zrb_vajra_death", -128, 189, -292, -6],
		["spr_kof_submarine_mouse", -83, 62, -131, -2],
		["spr_kof_submarine_mouse_enter", -83, 55, -166, -8],
		["spr_kof_submarine_mouse_land", -83, 55, -166, -14],
		["spr_kuafu_airbrone_air", -130, 42, -153, -34],
		["spr_kuafu_airbrone_drop", -130, 42, -154, -39],
		["spr_kuafu_airbrone_land", -31, 37, -82, -5],
		["spr_kuafu_armour", -53, 43, -178, -11],
		["spr_kuafu_armour_empty", -54, 41, -179, -11],
		["spr_kuafu_armour_throw", -56, 41, -175, -10],
		["spr_kuafu_barrier_air", -73, 35, -113, 1],
		["spr_kuafu_barrier_drop", -73, 35, -138, -42],
		["spr_kuafu_barrier_land", -42, 25, -92, -17],
		["spr_kuafu_bat", -52, 41, -83, -7],
		["spr_kuafu_boss_baron_death", -126, 117, -139, -8],
		["spr_kuafu_boss_baron_idle", -126, 117, -139, -8],
		["spr_kuafu_boss_buzz_death", -77, 99, -190, -40],
		["spr_kuafu_boss_buzz_idle", -77, 99, -191, -40],
		["spr_kuafu_boss_buzz_para_air", -51, 45, -198, -14],
		["spr_kuafu_boss_buzz_para_body", -31, 30, -99, -16],
		["spr_kuafu_boss_julie_death", -110, 128, -173, -47],
		["spr_kuafu_boss_julie_idle", -110, 128, -151, -49],
		["spr_kuafu_boss_pete_death", -74, 195, -290, -14],
		["spr_kuafu_boss_pete_idle", -74, 195, -290, -14],
		["spr_kuafu_boss_xiaoming_card_2", -2, 70, -40, 172],
		["spr_kuafu_boss_xiaoming_card_3", -2, 70, -39, 172],
		["spr_kuafu_boss_xiaoming_death", -83, 78, -221, 10],
		["spr_kuafu_boss_xiaoming_idle", -83, 78, -221, 10],
		["spr_kuafu_boss_xiaoming_stomp", -81, 77, -80, 78],
		["spr_kuafu_cucumber", -39, 27, -93, -15],
		["spr_kuafu_flute", -41, 20, -105, -14],
		["spr_kuafu_flute_perform", -40, 19, -110, -15],
		["spr_kuafu_football_fan", -39, 56, -97, -20],
		["spr_kuafu_football_fan_helmet", -40, 58, -99, -20],
		["spr_kuafu_gift", -44, 48, -104, -14],
		["spr_kuafu_glider_air", -73, 35, -138, -42],
		["spr_kuafu_glider_drop", -73, 35, -138, -42],
		["spr_kuafu_glider_land", -42, 25, -92, -17],
		["spr_kuafu_hopper", -46, 40, -113, -15],
		["spr_kuafu_iron_pan", -48, 19, -90, -13],
		["spr_kuafu_iron_pan_helmet", -58, 18, -91, -12],
		["spr_kuafu_jet", -46, 40, -110, -13],
		["spr_kuafu_landlady", -42, 30, -92, -12],
		["spr_kuafu_landlady_door", -36, 36, -81, -1],
		["spr_kuafu_landlady_shield", -41, 31, -92, -12],
		["spr_kuafu_little_armour", -33, 12, -79, -10],
		["spr_kuafu_little_armour_throw", -35, 10, -79, -19],
		["spr_kuafu_little_panda", -35, 11, -84, -15],
		["spr_kuafu_little_panda_throw", -39, 8, -86, -24],
		["spr_kuafu_little_wrestler", -34, 11, -83, -15],
		["spr_kuafu_little_wrestler_throw", -37, 8, -84, -24],
		["spr_kuafu_panda", -50, 38, -176, -14],
		["spr_kuafu_panda_empty", -53, 37, -147, -14],
		["spr_kuafu_panda_throw", -55, 40, -175, -13],
		["spr_kuafu_paratrooper", -31, 30, -99, -16],
		["spr_kuafu_paratrooper_air", -51, 45, -198, -14],
		["spr_kuafu_pirate", -48, 41, -116, -11],
		["spr_kuafu_rambo", -45, 23, -119, -14],
		["spr_kuafu_skateboard", -47, 32, -92, -13],
		["spr_kuafu_skateboard_skate", -48, 31, -108, -13],
		["spr_kuafu_soar", -46, 40, -112, -14],
		["spr_kuafu_waste_flying_air", -81, 62, -168, -31],
		["spr_kuafu_waste_flying_drop", -81, 62, -168, -32],
		["spr_kuafu_waste_flying_land", -31, 56, -97, -14],
		["spr_kuafu_wrestler", -48, 39, -175, -14],
		["spr_kuafu_wrestler_empty", -51, 38, -147, -14],
		["spr_kuafu_wrestler_throw", -54, 41, -175, -13],
		["spr_ladder_shield", -17, 17, -35, 34],
		["spr_lambo_mouse", -44, 23, -140, -14],
		["spr_landlady_mouse", -43, 31, -99, -12],
		["spr_landlady_mouse_shield", -45, 34, -99, -12],
		["spr_landlady_shield", -15, 13, -21, 21],
		["spr_landmine_bullet", -13, 20, -13, 10],
		["spr_landmine_vehicle_mouse", -38, 70, -119, -12],
		["spr_landmine_vehicle_mouse_move", -38, 70, -119, -12],
		["spr_lieutenant_buzz_death", -79, 100, -191, -40],
		["spr_lieutenant_buzz_idle", -79, 100, -191, -40],
		["spr_little_armour_mouse", -40, 15, -90, -10],
		["spr_little_armour_mouse_throw", -43, 12, -81, -19],
		["spr_little_magician", -42, 14, -90, -15],
		["spr_little_magician_throw", -45, 12, -83, -26],
		["spr_little_panda", -41, 13, -90, -15],
		["spr_little_panda_throw", -45, 10, -84, -24],
		["spr_little_undersea_panda_mouse", -31, 11, -82, -10],
		["spr_little_undersea_panda_mouse_throw", -31, 9, -79, -15],
		["spr_little_wrestler", -41, 13, -90, -15],
		["spr_little_wrestler_throw", -45, 10, -84, -24],
		["spr_lobster_knight_bubble_destroy", -51, 51, -97, 5],
		["spr_lobster_knight_death", -112, 207, -306, -28],
		["spr_lobster_knight_idle", -112, 208, -309, -28],
		["spr_lobster_knight_move", -112, 208, -306, -28],
		["spr_machine_bee", -39, 35, -101, -32],
		["spr_machine_beehive_mouse", -52, 52, -159, -16],
		["spr_machine_beehive_release_1", -52, 51, -159, -17],
		["spr_machine_beehive_release_2", -52, 51, -159, -17],
		["spr_machine_beehive_release_3", -52, 51, -159, -17],
		["spr_machine_bomb_mouse_air", -52, 41, -140, -35],
		["spr_machine_bomb_mouse_drop", -52, 21, -140, -35],
		["spr_machine_bomb_mouse_land", -48, 30, -116, -16],
		["spr_machine_flag_mouse_air", -52, 48, -157, -35],
		["spr_machine_flag_mouse_drop", -52, 48, -157, -35],
		["spr_machine_flag_mouse_land", -50, 67, -122, -16],
		["spr_machine_football_fan_mouse", -48, 42, -106, -13],
		["spr_machine_football_fan_mouse_helmet", -48, 42, -107, -13],
		["spr_machine_iron_pan_mouse", -42, 23, -110, -14],
		["spr_machine_iron_pan_mouse_helmet", -47, 23, -110, -14],
		["spr_machine_mouse", -32, 24, -106, -17],
		["spr_machine_mouse_explode", -61, 51, -109, -2],
		["spr_machine_normal_mouse", -46, 19, -106, -13],
		["spr_machine_shark_1_death", -106, 237, -267, -57],
		["spr_machine_shark_1_idle", -115, 230, -260, -49],
		["spr_machine_skateboard_mouse", -31, 35, -107, -12],
		["spr_machine_skateboard_mouse_skate", -44, 50, -131, -20],
		["spr_magician_mouse", -58, 61, -153, -13],
		["spr_mario_mouse_death", -45, 63, -110, -10],
		["spr_mario_mouse_dig_down", -55, 55, -124, -14],
		["spr_mario_mouse_idle", -53, 55, -124, -15],
		["spr_mario_pipeline_land", -62, 32, -78, 0],
		["spr_mario_pipeline_water", -62, 40, -81, 6],
		["spr_mermaid_mary_dash", -160, 100, -242, -15],
		["spr_mermaid_mary_death", -117, 120, -245, -25],
		["spr_mermaid_mary_idle", -117, 119, -245, -25],
		["spr_messenger_fog", -46, 50, -44, 53],
		["spr_minion_mouse", -41, 30, -99, -14],
		["spr_minion_mouse_summon", -43, 22, -84, -21],
		["spr_mirror_mouse", -56, 49, -115, -17],
		["spr_mirror_mouse_acting", -74, 40, -114, -15],
		["spr_mole", -30, 35, -97, -14],
		["spr_mole_dig", -48, 34, -51, -13],
		["spr_mole_stun", -30, 35, -96, -14],
		["spr_mouse_spring_2", -22, 21, -34, -1],
		["spr_mouse_train_1_body_death", -66, 48, -151, 0],
		["spr_mouse_train_1_body_idle", -49, 49, -134, -1],
		["spr_mouse_train_1_head_death", -42, 46, -90, 10],
		["spr_mouse_train_1_head_idle", -42, 40, -88, -2],
		["spr_mouse_train_2_body_death", -64, 87, -113, 1],
		["spr_mouse_train_2_body_idle1", -63, 61, -97, 1],
		["spr_mouse_train_2_body_idle2", -65, 63, -98, 2],
		["spr_mouse_train_2_head_death", -31, 69, -95, -6],
		["spr_mouse_train_2_head_idle", -26, 60, -88, -6],
		["spr_naruto_minion_mouse", -42, 30, -101, -14],
		["spr_naruto_minion_mouse_summon", -43, 22, -79, -16],
		["spr_naruto_mouse", -44, 30, -112, -11],
		["spr_naruto_mouse_summon", -59, 29, -102, -13],
		["spr_needle_baron_death", -127, 117, -140, -8],
		["spr_needle_baron_idle", -127, 117, -139, -8],
		["spr_ninja_mouse", -43, 27, -100, -13],
		["spr_ninja_mouse_summon", -54, 26, -92, -14],
		["spr_non_mainstream_mouse", -35, 46, -101, -12],
		["spr_normal_mouse", -43, 30, -101, -15],
		["spr_orange_prince_mouse", -38, 25, -63, -12],
		["spr_orange_prince_mouse_enter", -33, 42, -110, -2],
		["spr_orange_prince_mouse_frog", -35, 39, -84, -14],
		["spr_orange_prince_mouse_land", -39, 30, -92, -1],
		["spr_oyster_mouse", -41, 38, -112, -11],
		["spr_pan_helmet", -26, 28, -12, 12],
		["spr_panda_mouse", -56, 40, -148, -14],
		["spr_panda_mouse_has_small", -56, 40, -182, -14],
		["spr_panda_mouse_throw", -56, 40, -182, -13],
		["spr_paper_boat_mouse", -44, 19, -75, -16],
		["spr_paper_boat_mouse_enter", -43, 30, -105, -19],
		["spr_paper_boat_mouse_land", -44, 29, -105, -20],
		["spr_paratrooper_mouse", -31, 30, -99, -16],
		["spr_paratrooper_mouse_air", -51, 45, -198, -14],
		["spr_penguin_mouse", -47, 25, -97, -16],
		["spr_penguin_mouse_bomb", -47, 25, -97, -16],
		["spr_penguin_mouse_throw", -40, 22, -97, -14],
		["spr_pete_death", -73, 194, -255, -14],
		["spr_pete_idle", -73, 194, -255, -14],
		["spr_pink_paul_death", -69, 63, -178, 4],
		["spr_pink_paul_idle", -73, 69, -177, 8],
		["spr_pope_mouse", -38, 28, -123, -6],
		["spr_pope_mouse_perform", -38, 29, -123, -6],
		["spr_priest_mouse", -40, 23, -123, -14],
		["spr_priest_mouse_perform", -40, 22, -123, -14],
		["spr_repairman_mouse", -39, 33, -100, -14],
		["spr_repairman_mouse_place", -39, 33, -100, -14],
		["spr_repairman_mouse_shield", -39, 33, -100, -14],
		["spr_roller_skating_mouse", -32, 39, -95, -5],
		["spr_roller_skating_mouse_helmet", -32, 39, -92, -5],
		["spr_rowboat_mouse", -134, 112, -130, -6],
		["spr_rumble_death", -95, 72, -195, -16],
		["spr_rumble_drop", -95, 72, -242, -30],
		["spr_rumble_idle", -95, 72, -179, -16],
		["spr_rumble_launch", -95, 72, -179, -16],
		["spr_rumble_move_backword", -100, 68, -242, -31],
		["spr_rumble_move_forward", -95, 89, -242, -35],
		["spr_sardine_mouse", -40, 34, -109, -13],
		["spr_sardine_mouse_dig", -47, 35, -49, -11],
		["spr_sardine_mouse_stun", -39, 34, -109, -13],
		["spr_sawblade_mouse", -30, 36, -119, -12],
		["spr_sawblade_mouse_dig", -48, 34, -49, -11],
		["spr_sawblade_mouse_stun", -31, 35, -118, -12],
		["spr_seahorse_mouse", -34, 38, -118, -11],
		["spr_seahorse_mouse_jump", -34, 38, -118, -11],
		["spr_shy_landlady_mouse", -44, 31, -113, -13],
		["spr_shy_landlady_mouse_shield", -48, 31, -113, -13],
		["spr_skateboard_mouse", -47, 27, -102, -13],
		["spr_skateboard_mouse_skate", -45, 25, -110, -16],
		["spr_snail_mouse", -45, 96, -121, -15],
		["spr_soar_mouse", -46, 40, -109, -14],
		["spr_soldier_mouse", -63, 28, -154, -9],
		["spr_special_armour_mouse", -55, 41, -186, -11],
		["spr_special_armour_mouse_has_small", -55, 41, -186, -11],
		["spr_special_armour_mouse_throw", -55, 41, -186, -10],
		["spr_spider_man_mouse_death", -67, 43, -639, -57],
		["spr_spider_man_mouse_idle", -48, 85, -720, -78],
		["spr_submarine_mouse", -73, 62, -123, -6],
		["spr_submarine_mouse_enter", -73, 55, -167, -11],
		["spr_submarine_mouse_land", -73, 55, -167, -17],
		["spr_suv_mouse", -59, 130, -147, -16],
		["spr_suv_mouse_act", -59, 121, -147, -16],
		["spr_swordfish_mouse", -92, 86, -128, -20],
		["spr_swordfish_mouse_dash", -103, 82, -117, -8],
		["spr_swordfish_mouse_ready", -92, 86, -128, -10],
		["spr_swordfish_mouse_stun", -88, 85, -128, -20],
		["spr_tangerine_skateboard_mouse", -45, 30, -101, -13],
		["spr_tangerine_skateboard_mouse_skate", -43, 28, -109, -14],
		["spr_taro_toho_mouse", -46, 51, -106, -14],
		["spr_temple_pharaoh_death", -128, 40, -150, -4],
		["spr_temple_pharaoh_idle", -46, 40, -150, -4],
		["spr_thor_body_death", -80, 79, -140, -17],
		["spr_thor_body_idle", -80, 79, -140, -17],
		["spr_thor_head_death", -84, 83, -150, -16],
		["spr_thor_head_idle", -84, 83, -149, -14],
		["spr_thug_submarine_mouse", -83, 62, -128, -6],
		["spr_thug_submarine_mouse_enter", -83, 55, -169, -12],
		["spr_thug_submarine_mouse_land", -83, 55, -169, -17],
		["spr_tire_mouse", -33, 27, -142, -17],
		["spr_tire_mouse_act", -33, 27, -142, -17],
		["spr_tire_mouse_land", -40, 25, -89, -18],
		["spr_travel_recoed_line", -110, -14, 15, 108],
		["spr_travel_record_death_1", -109, 99, -246, -19],
		["spr_travel_record_death_2", -83, 82, -224, -13],
		["spr_travel_record_drop", -83, 82, -247, -19],
		["spr_travel_record_idle_1", -83, 83, -222, -13],
		["spr_travel_record_idle_2", -83, 82, -246, -19],
		["spr_travel_record_launch", -83, 83, -222, -13],
		["spr_travel_record_moon_explode", -44, 42, -80, 6],
		["spr_travel_record_move", -83, 82, -245, -19],
		["spr_tropical_fish_mouse", -43, 30, -78, -19],
		["spr_tropical_fish_mouse_enter", -44, 30, -108, -24],
		["spr_tropical_fish_mouse_enter_helmet", -56, 31, -114, -24],
		["spr_tropical_fish_mouse_helmet", -54, 31, -87, -19],
		["spr_tropical_fish_mouse_land", -43, 30, -109, -24],
		["spr_tropical_fish_mouse_land_helmet", -56, 31, -113, -23],
		["spr_trumpeter_mouse", -64, 43, -124, -13],
		["spr_trumpeter_mouse_perform", -67, 48, -125, -15],
		["spr_undersea_can", -52, 32, -47, 44],
		["spr_undersea_can_mouse", -45, 22, -122, -12],
		["spr_undersea_can_mouse_drop", -47, 43, -138, -36],
		["spr_undersea_can_mouse_with_can", -48, 43, -137, -12],
		["spr_undersea_captain_mouse", -73, 62, -142, -25],
		["spr_undersea_diver_mouse", -62, 35, -103, -3],
		["spr_undersea_panda_mouse", -66, 76, -163, -10],
		["spr_undersea_panda_mouse_has_small", -66, 76, -185, -10],
		["spr_undersea_panda_mouse_throw", -80, 44, -188, -19],
		["spr_undersea_penguin_mouse", -43, 39, -121, -11],
		["spr_undersea_penguin_mouse_ready", -41, 31, -122, -15],
		["spr_undersea_penguin_mouse_throw", -41, 31, -122, -15],
		["spr_undersea_repairman_ladder", -16, 16, -66, -1],
		["spr_undersea_repairman_ladder_1", -16, 16, -66, -1],
		["spr_undersea_repairman_mouse", -47, 64, -114, -9],
		["spr_undersea_repairman_mouse_place", -44, 30, -125, -12],
		["spr_undersea_repairman_mouse_shield", -47, 64, -114, -9],
		["spr_undersea_submarine", -67, 202, -240, -48],
		["spr_undersea_submarine_release_1", -67, 202, -240, -48],
		["spr_undersea_submarine_release_2", -67, 202, -240, -48],
		["spr_war_god_death", -59, 112, -177, -11],
		["spr_war_god_idle", -61, 111, -177, -12],
		["spr_warrior_minion_mouse", -42, 30, -101, -14],
		["spr_warrior_minion_mouse_summon", -43, 22, -79, -16],
		["spr_warrior_mouse", -45, 27, -110, -12],
		["spr_warrior_mouse_summon", -57, 25, -98, -14],
		["spr_waste_flying_mouse_air", -81, 62, -167, -31],
		["spr_waste_flying_mouse_drop", -81, 62, -167, -32],
		["spr_waste_flying_mouse_land", -31, 55, -96, -14],
		["spr_water_penguin_mouse", -46, 17, -64, -12],
		["spr_water_penguin_mouse_enter", -46, 19, -96, -13],
		["spr_water_penguin_mouse_land", -46, 24, -96, -15],
		["spr_water_penguin_mouse_throw", -46, 18, -66, -12],
		["spr_water_taro_toho_mouse", -57, 43, -85, -16],
		["spr_water_taro_toho_mouse_enter", -55, 42, -112, -20],
		["spr_water_taro_toho_mouse_land", -55, 42, -112, -20],
		["spr_weed_helmet", -24, 24, -15, 17],
		["spr_windmill_fish_mouse_air", -67, 53, -160, -33],
		["spr_windmill_fish_mouse_drop", -67, 53, -160, -40],
		["spr_windmill_fish_mouse_land", -35, 28, -126, -14],
		["spr_windmill_fish_mouse_urchin", -28, 28, -57, -9],
		["spr_wrestler_mouse", -55, 41, -148, -14],
		["spr_wrestler_mouse_has_small", -55, 41, -182, -14],
		["spr_wrestler_mouse_throw", -55, 41, -182, -13],
		["spr_xiaoming_ice", -81, 77, -80, 78],
		["spr_xiaoming_text_2", -2, 70, -37, 172],
		["spr_xiaoming_text_3", -2, 70, -36, 172],
		["spr_zhangaiwu_dead", -30, 31, -58, 1],
		["spr_zhangaiwu_idel", -30, 32, -78, 1],
		["spr_zhangaiwu_move", -30, 32, -78, 1],
		["spr_zombie_with_flower_pot", -43, 14, -104, -15],
		["spr_zombie_with_flower_pot_drop", -47, 14, -104, -15],
		["spr_zombie_with_flower_pot_shield", -44, 14, -104, -15],
		["spr_zombie_with_wallnut", -43, 14, -104, -15],
		["spr_zombie_with_wallnut_drop", -43, 14, -104, -15],
		["spr_zombie_with_wallnut_shield", -43, 14, -104, -15],
	];

	var _n = array_length(_rows);
	for (var _i = 0; _i < _n; _i++) {
		var _r = _rows[_i];
		var _spr = asset_get_index(_r[0]);
		if (_spr < 0) continue;
		_t[? _spr] = { l: _r[1], r: _r[2], t: _r[3], b: _r[4] };
	}

	global.enemy_body_tbl = _t;
	_busy = false;
}

/// @func enemy_body_is_enemy(_e)
/// @desc 实例是否属于 obj_enemy_parent 家族（结果缓存到实例上，只算一次）
function enemy_body_is_enemy(_e) {
	if (is_undefined(_e) || _e == noone) return false;
	// 对象索引（obj_xxx）能骗过 instance_exists，读实例变量会崩，先挡掉
	if (object_exists(_e)) return false;
	if (!instance_exists(_e)) return false;
	if (!variable_instance_exists(_e, "_eb_is_enemy")) {
		var _oi = _e.object_index;
		_e._eb_is_enemy = (_oi == obj_enemy_parent) || object_is_ancestor(_oi, obj_enemy_parent);
	}
	return _e._eb_is_enemy;
}

/// @func enemy_body_get(_e)
/// @desc 返回 { l, r, t, b }（相对原点的固定像素偏移）；不适用返回 undefined
function enemy_body_get(_e) {
	if (!ENEMY_BODY_ENABLED) return undefined;
	if (object_exists(_e)) return undefined;
	if (!enemy_body_is_enemy(_e)) return undefined;
	enemy_body_ensure();
	var _spr = _e.sprite_index;
	if (_spr < 0) return undefined;
	if (!ds_map_exists(global.enemy_body_tbl, _spr)) return undefined;
	return global.enemy_body_tbl[? _spr];
}

/// @func enemy_body_has(_e)
/// @desc 该实例是否有固定判定框数据
function enemy_body_has(_e) {
	return !is_undefined(enemy_body_get(_e));
}

/// @func enemy_body_left(_e)
/// @desc 身体左缘的世界坐标；无数据时退回实例 bbox_left
function enemy_body_left(_e) {
	var _b = enemy_body_get(_e);
	if (is_undefined(_b)) return _e.bbox_left;
	var _sx = _e.image_xscale;
	if (_sx < 0) return _e.x + _b.r * _sx;
	return _e.x + _b.l * _sx;
}

/// @func enemy_body_right(_e)
/// @desc 身体右缘的世界坐标；无数据时退回实例 bbox_right
function enemy_body_right(_e) {
	var _b = enemy_body_get(_e);
	if (is_undefined(_b)) return _e.bbox_right;
	var _sx = _e.image_xscale;
	if (_sx < 0) return _e.x + _b.l * _sx;
	return _e.x + _b.r * _sx;
}

/// @func enemy_body_top(_e)
function enemy_body_top(_e) {
	var _b = enemy_body_get(_e);
	if (is_undefined(_b)) return _e.bbox_top;
	return _e.y + _b.t * abs(_e.image_yscale);
}

/// @func enemy_body_bottom(_e)
function enemy_body_bottom(_e) {
	var _b = enemy_body_get(_e);
	if (is_undefined(_b)) return _e.bbox_bottom;
	return _e.y + _b.b * abs(_e.image_yscale);
}

/// @func enemy_body_rect(_e)
/// @desc 一次性取四点，避免上面四个函数各查一次表
function enemy_body_rect(_e) {
	var _b = enemy_body_get(_e);
	if (is_undefined(_b)) {
		return { l: _e.bbox_left, r: _e.bbox_right, t: _e.bbox_top, b: _e.bbox_bottom };
	}
	var _sx = abs(_e.image_xscale);
	var _sy = abs(_e.image_yscale);
	var _neg = (_e.image_xscale < 0);
	return {
		l: _e.x + (_neg ? _b.r : _b.l) * _sx,
		r: _e.x + (_neg ? _b.l : _b.r) * _sx,
		t: _e.y + _b.t * _sy,
		b: _e.y + _b.b * _sy
	};
}

/// @func enemy_in_blast(_e, _bx, _by, _r)
/// @desc 爆炸判定：爆炸点到敌人身体矩形的最近距离 <= _r（贴视觉，只放宽不收紧）
function enemy_in_blast(_e, _bx, _by, _r) {
	if (!instance_exists(_e)) return false;
	var _rc = enemy_body_rect(_e);
	var _dx = 0;
	if (_bx < _rc.l) _dx = _rc.l - _bx;
	else if (_bx > _rc.r) _dx = _bx - _rc.r;
	var _dy = 0;
	if (_by < _rc.t) _dy = _rc.t - _by;
	else if (_by > _rc.b) _dy = _by - _rc.b;
	return (_dx * _dx + _dy * _dy) <= (_r * _r);
}

/// @func enemy_in_card_range(_cx, _cy, _e, _range_px)
/// @desc 卡片索敌辅助：卡片中心到敌人身体矩形的最近距离 <= _range_px
///       给需要像素级射程的卡用；老卡继续用整格判定不受影响
function enemy_in_card_range(_cx, _cy, _e, _range_px) {
	if (!instance_exists(_e)) return false;
	var _rc = enemy_body_rect(_e);
	var _dx = 0;
	if (_cx < _rc.l) _dx = _rc.l - _cx;
	else if (_cx > _rc.r) _dx = _cx - _rc.r;
	var _dy = 0;
	if (_cy < _rc.t) _dy = _rc.t - _cy;
	else if (_cy > _rc.b) _dy = _cy - _rc.b;
	return (_dx * _dx + _dy * _dy) <= (_range_px * _range_px);
}
