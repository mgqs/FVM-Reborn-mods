if (global.is_paused) exit;
event_inherited();
if (hp <= 0) exit;

zodiac_age++;

if (is_frozen || state == CARD_STATE.SLEEP) exit;

zodiac_timer++;
if (zodiac_timer >= cycle) {
    zodiac_timer = 0;
    // 没有同行前方的有效老鼠时保持待机，不进入攻击动画。
    var fj_can_attack = false;
    for (var fj_i = 0; fj_i < instance_number(obj_enemy_parent); fj_i++) {
        var fj_e = instance_find(obj_enemy_parent, fj_i);
        if (instance_exists(fj_e) && fj_e.hp > 0 && fj_e.x >= x
            && fj_e.grid_row == grid_row && fj_e.target_type != "underground"
            && fj_e.target_type != "invisible") {
            fj_can_attack = true;
            break;
        }
    }
    if (fj_can_attack) {
        state = CARD_STATE.ATTACK;
        // Start the attack sequence from its first frame even if the idle
        // animation timer was partway through a cycle.
        timer = 0;
        image_index = idle_anim + 1;
        zodiac_shot_this_anim = false;
    }
}

// 攻击动画使用第 11-21 帧，在第 18 帧生成直线弹。
if (state == CARD_STATE.ATTACK) {
    var fj_target_alive = false;
    for (var fj_i = 0; fj_i < instance_number(obj_enemy_parent); fj_i++) {
        var fj_e = instance_find(obj_enemy_parent, fj_i);
        if (instance_exists(fj_e) && fj_e.hp > 0 && fj_e.x >= x
            && fj_e.grid_row == grid_row && fj_e.target_type != "underground"
            && fj_e.target_type != "invisible") {
            fj_target_alive = true;
            break;
        }
    }
    if (!fj_target_alive) {
        state = CARD_STATE.IDLE;
        image_index = 0;
        zodiac_shot_this_anim = false;
        exit;
    }
    // The parent animation advances on its own timer, so use a range here
    // instead of requiring an exact frame boundary.
    if (!zodiac_shot_this_anim && image_index >= 18) {
        zodiac_shot_this_anim = true;
    // 索敌：正前方同行最近的可见陆军，排除地下鼠与未显形鬼鼠
    var fj_list = [];
    for (var fj_i = 0; fj_i < instance_number(obj_enemy_parent); fj_i++) {
        var fj_e = instance_find(obj_enemy_parent,fj_i);
        if (instance_exists(fj_e) && fj_e.hp > 0) array_push(fj_list,fj_e);
    }
    for (var fj_i = 0; fj_i < instance_number(obj_kuileima_decoy); fj_i++) {
        var fj_d = instance_find(obj_kuileima_decoy,fj_i);
        if (instance_exists(fj_d) && fj_d.hp > 0 && !array_contains(fj_list,fj_d)) array_push(fj_list,fj_d);
    }
    var t = noone, fj_dist = 2147483647;
    for (var fj_i = 0; fj_i < array_length(fj_list); fj_i++) {
        var fj_te = fj_list[fj_i];
        if (fj_te.x < x || abs(fj_te.grid_row-grid_row) > 0
            || fj_te.target_type == "underground" || fj_te.target_type == "invisible") continue;
        var fj_td = point_distance(x,y,fj_te.x,fj_te.y);
        if (fj_td < fj_dist) {fj_dist = fj_td; t = fj_te;}
    }
        if (instance_exists(t)) {
        // 子弹的碰撞高度沿用卡片攻击层，但行号必须随发射卡片传递；
        // 否则只有第 0 行会参与老鼠、反弹和火焰卡片的判定。
        var b = instance_create_depth(x,y-30,-2500,obj_zodiac_projectile);
        b.kind = "fire";
        b.damage = atk;
        b.base_damage = atk;
        b.shape = shape;
        b.target_id = noone;
        b.move_x = lengthdir_x(8,0);
        b.move_y = lengthdir_y(8,0);
        b.image_angle = 0;
        b.sprite_index = spr_fenjima_bullet;
        if (shape == 1) b.sprite_index = spr_fenjima_bullet_1;
        else if (shape >= 2) b.sprite_index = spr_fenjima_bullet_2;
        b.can_dandantu_store = true;
        b.damage_type = "pierce";
        b.row = grid_row;
        b.center_row = grid_row;
        }
    }
    if (zodiac_shot_this_anim && image_index > idle_anim + attack_anim) {
        state = CARD_STATE.IDLE;
        timer = 0;
        image_index = 0;
        zodiac_shot_this_anim = false;
    }
}
