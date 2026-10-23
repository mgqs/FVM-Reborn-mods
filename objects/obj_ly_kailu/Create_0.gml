event_inherited();
ly_kind = "kailu";
ly_anims = {};
ly_action = "";
ly_frame = 0;
ly_done = false;
ly_once = false;
ly_hit = false;
ly_mode = "walk";
ly_cooldown = 0;
ly_soul = false;
ly_boss_soul = false;
ly_absorb_boss = noone;
ly_dash_exploded = false;
is_soul = false;
invincible = false;
// 防爆：炸弹等秒杀效果只造成伤害。
immune_to_ash = true;
is_vehicle = false;
ly_dodge_cooldown = 0;
ly_dash_cols = [7, 3];
ly_dashed_cols = [];
ly_dash_target_x = 0;
ly_night = false;
ly_original_hp = 100;
can_use_ladder = false;
state = ENEMY_STATE.ACTING;

// 本对象的属性、动作和专属状态。
mouse_id = "longyuan_kailu";
ly_anims = longyuan_animation_table("kailu");
hp = 1000; maxhp = 1000; ly_original_hp = 1000;
move_speed = 0.6; atk = LY_KAILU_BITE_DAMAGE; atk_cycle = 42;
ly_night = longyuan_is_night();

longyuan_move_action = function() { return ly_soul ? longyuan_variant("正常前进", "破损前进") : longyuan_variant("正常前进", "破损前进"); };
longyuan_attack_action = function() { return ly_soul ? longyuan_variant("正常前进", "破损前进") : longyuan_variant("正常撞击", "破损撞击"); };
longyuan_begin_death = function() {
    ly_mode = "dead"; target_plant = noone; ly_action = "";
    if (ly_soul) longyuan_play(ash_death ? "爆炸死亡" : "普通死亡", true);
    else longyuan_play("死亡", true);
};
longyuan_change_soul = function() {
    ly_soul = true; is_soul = true; target_type = "normal";
    ly_kind = "kailu_soul"; ly_anims = longyuan_animation_table(ly_kind);
    hp = maxhp; ash_death = false; image_alpha = 1; ly_action = "";
    ly_mode = "spawn"; longyuan_play("出生", true);
};
