event_inherited();
ly_kind = "fuzhou";
ly_anims = {};
ly_action = "";
ly_frame = 0;
ly_done = false;
ly_once = false;
ly_hit = false;
ly_mode = "walk";
ly_cooldown = 0;
is_soul = false;
invincible = false;
is_vehicle = false;
ly_fire = 0;
ly_amulet = noone;
ly_summon_cols = [7, 5, 3];   // 三次施法推进阈值（0-based：第8/6/4列，啃咬停在卡右一格时也能触发）
ly_dodge_cooldown = 0;
ly_original_hp = 100;
can_use_ladder = false;
state = ENEMY_STATE.ACTING;

// 本对象的属性、动作和专属状态。
mouse_id = "longyuan_fuzhou";
ly_anims = longyuan_animation_table("fuzhou");
hp = 1200; maxhp = 1200; ly_original_hp = 1200;
move_speed = 0.3; atk = 10; atk_cycle = 48;
is_soul = false; ly_fire = 3; ly_cooldown = 0;
longyuan_move_action = function() { return longyuan_variant("正常前进", "破损前进"); };
longyuan_attack_action = function() { return longyuan_variant("正常攻击", "破损攻击"); };
longyuan_begin_death = function() { ly_mode = "dead"; target_plant = noone; ly_action = ""; longyuan_play("死亡", true); };
// 本体无敌唯一真值：施法中由 Step 置位；非施法帧只要场上还有属于自己的符咒或符咒魂鼠就保持无敌。
ly_has_servant = function(_self) {
    var _has = false;
    with (obj_ly_amulet) if (owner == _self) _has = true;
    with (obj_ly_fuzhou_minion) if (variable_instance_exists(id, "ly_owner") && ly_owner == _self) _has = true;
    return _has;
};
