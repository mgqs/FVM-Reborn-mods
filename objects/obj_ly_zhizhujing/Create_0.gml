event_inherited();
ly_kind = "zhizhujing";
ly_anims = {};
ly_action = "";
ly_frame = 0;
ly_done = false;
ly_once = false;
ly_hit = false;
ly_mode = "walk";
ly_cooldown = 0;
ly_soul = false;
is_soul = false;
invincible = false;
is_vehicle = false;
ly_wind_multiplier = 1.5; // 未给定风力倍率
ly_webbed = false;
ly_fan = true;
ly_dodge_cooldown = 0;
ly_night = false;
ly_original_hp = 100;
can_use_ladder = false;
state = ENEMY_STATE.ACTING;

// 本对象的属性、动作和专属状态。
mouse_id = "longyuan_zhizhujing";
ly_anims = longyuan_animation_table("zhizhujing");
hp = 660; maxhp = 660; ly_original_hp = 660;
move_speed = 0; atk = 10; atk_cycle = 90;
if (variable_struct_exists(global.level_file, "is_night")) ly_night = global.level_file.is_night;
else if (variable_global_exists("level_id")) {
    var _level = string(global.level_id);
    ly_night = string_pos("night", _level) > 0 || string_pos("_ye", _level) > 0;
}
target_type = "air"; ly_mode = "spider";
longyuan_move_action = function() { return longyuan_variant("正常前进", "破损前进"); };
longyuan_attack_action = function() { return longyuan_variant("正常啃咬", "破损啃咬"); };
longyuan_begin_death = function() { ly_mode = "dead"; target_plant = noone; ly_action = ""; longyuan_play("死亡", true); };
longyuan_change_soul = function() {
    ly_soul = true; is_soul = true; target_type = "invisible";
    ly_kind = "zhizhujing_soul"; ly_anims = longyuan_animation_table(ly_kind);
    hp = maxhp; ash_death = false; image_alpha = 1; ly_action = "";
    ly_mode = "spider"; move_speed = 0.6; longyuan_play("正常待机");
};
