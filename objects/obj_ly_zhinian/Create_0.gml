event_inherited();
ly_kind = "zhinian";
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
ly_dodge_cooldown = 0;
ly_soul_attack_count = 0;
ly_soul_special = false;
ly_rush_moved = false;
ly_night = false;
ly_original_hp = 100;
can_use_ladder = false;
state = ENEMY_STATE.ACTING;

// 本对象的属性、动作和专属状态。
mouse_id = "longyuan_zhinian";
ly_anims = longyuan_animation_table("zhinian");
hp = 1000; maxhp = 1000; ly_original_hp = 1000;
move_speed = 0.3; atk = 10; atk_cycle = 36;
ly_night = longyuan_is_night();

longyuan_move_action = function() { return ly_soul ? longyuan_variant("正常灵魂前进", "破损灵魂前进") : longyuan_variant("正常前进", "破损前进"); };
longyuan_attack_action = function() { return ly_soul ? longyuan_variant("正常攻击卡片", "破损攻击卡片") : longyuan_variant("正常啃咬", "破损啃咬"); };
longyuan_begin_death = function() { ly_mode = "dead"; target_plant = noone; ly_action = ""; longyuan_play("死亡", true); };
longyuan_change_soul = function() {
    ly_soul = true; is_soul = true; target_type = "invisible";
    ly_kind = "zhinian_soul"; ly_anims = longyuan_animation_table(ly_kind);
    hp = maxhp; ash_death = false; image_alpha = 1; ly_action = "";
    ly_mode = "spawn"; longyuan_play("出生", true);
    atk = LY_ZHINIAN_SOUL_ATK; ly_soul_attack_count = 0; ly_soul_special = false; ly_rush_moved = false; move_speed = 0.6;
};
