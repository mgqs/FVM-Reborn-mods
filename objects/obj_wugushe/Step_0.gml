if (global.is_paused) exit;
event_inherited();
if (hp <= 0) exit;

zodiac_age++;

if (is_frozen || state == CARD_STATE.SLEEP) exit;

// 和狮子座一致：范围内没有目标时不累计攻击周期，也不保留攻击动画。
// 索敌：仅陆军/空军，排除地下鼠、隐身鬼鼠等不可见目标及障碍物（它们同样挂在 obj_enemy_parent 下）
var ht_enemies = [];
for (var he_i = 0; he_i < instance_number(obj_enemy_parent); he_i++) {
    var he_e = instance_find(obj_enemy_parent,he_i);
    if (instance_exists(he_e) && he_e.hp > 0) array_push(ht_enemies,he_e);
}
for (var he_i = 0; he_i < instance_number(obj_kuileima_decoy); he_i++) {
    var he_d = instance_find(obj_kuileima_decoy,he_i);
    if (instance_exists(he_d) && he_d.hp > 0 && !array_contains(ht_enemies,he_d)) array_push(ht_enemies,he_d);
}
var ht_radius = shape == 2 ? 2 : 1;
var has_target = false;
for (var ht_i = 0; ht_i < array_length(ht_enemies); ht_i++) {
    var ht_e = ht_enemies[ht_i];
    if (!is_digging_dijing(ht_e) && ht_e.target_type != "normal" && ht_e.target_type != "air") continue;
    var ht_g = get_grid_position_from_world(ht_e.x,ht_e.y);
    if (ht_g.col >= 0 && ht_g.col < global.grid_cols && ht_g.row >= 0 && ht_g.row < global.grid_rows
        && abs(ht_g.col-grid_col) <= ht_radius && abs(ht_g.row-grid_row) <= ht_radius) {has_target = true; break;}
}
if (!has_target) {
    zodiac_timer = 0;
    // 仅在退出攻击时回到待机首帧；待机状态下不要每帧重置，
    // 让父对象继续循环 0-14 帧。
    if (state != CARD_STATE.IDLE) {
        state = CARD_STATE.IDLE;
        image_index = 0;
        zodiac_shot_this_anim = false;
    }
    exit;
}

// 待机且无累计周期时，范围内已有目标则立即进入攻击计时（进范围立即开火，无需等满一个周期）
if (state == CARD_STATE.IDLE && zodiac_timer == 0) {
    zodiac_timer = cycle - 1;
}

zodiac_timer++;
if (zodiac_timer >= cycle) {
    zodiac_timer = 0;
    state = CARD_STATE.ATTACK;
    image_index = idle_anim + 1;
    zodiac_shot_this_anim = false;
}
if (state == CARD_STATE.ATTACK) {
    if (!zodiac_shot_this_anim && image_index == idle_anim + 1) {
        zodiac_shot_this_anim = true;
        // 施加蛊毒：先筛选攻击范围内可被命中的可见老鼠
        var po_enemies = [];
        for (var pe_i = 0; pe_i < instance_number(obj_enemy_parent); pe_i++) {
            var pe_e = instance_find(obj_enemy_parent,pe_i);
            if (instance_exists(pe_e) && pe_e.hp > 0) array_push(po_enemies,pe_e);
        }
        for (var pe_i = 0; pe_i < instance_number(obj_kuileima_decoy); pe_i++) {
            var pe_d = instance_find(obj_kuileima_decoy,pe_i);
            if (instance_exists(pe_d) && pe_d.hp > 0 && !array_contains(po_enemies,pe_d)) array_push(po_enemies,pe_d);
        }
        var po_radius = shape == 2 ? 2 : 1;
        var po_waves = shape == 0 ? 2 : 3;
        var po_targets = [];
        for (var po_i = 0; po_i < array_length(po_enemies); po_i++) {
            var po_e = po_enemies[po_i];
            // 钻地中的地精鼠也可被喷壶类（巫蛊蛇）命中
            var po_e_dig_dijing = (variable_instance_exists(po_e, "mouse_id") && po_e.mouse_id == "longyuan_dijing"
                && variable_instance_exists(po_e, "ly_mode") && po_e.ly_mode == "dig");
            if (!po_e_dig_dijing && po_e.target_type != "normal" && po_e.target_type != "air") continue;
            var po_g = get_grid_position_from_world(po_e.x,po_e.y);
            if (po_g.col < 0 || po_g.col >= global.grid_cols || po_g.row < 0 || po_g.row >= global.grid_rows) continue;
            if (abs(po_g.col-grid_col) <= po_radius && abs(po_g.row-grid_row) <= po_radius) array_push(po_targets,po_e);
        }
        for (var po_i = 0; po_i < array_length(po_targets); po_i++) {
            var po_t = po_targets[po_i];
            for (var po_w = 0; po_w < po_waves && instance_exists(po_t) && po_t.hp > 0; po_w++) {
                // 表列总伤害平摊到每一波
                var wg_dmg = atk/po_waves;
                with (po_t) {
                    damage_amount = wg_dmg;
                    damage_type = "pierce";
                    if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
                    event_user(0);
                }
                if (random(1) < (shape == 0 ? 0.10 : 0.15)) {
                    // 蛊毒特效跟随老鼠，播放一次后自动销毁；卡片死亡/铲除时由 Destroy 事件清理
                    var fx = instance_create_depth(po_t.x,po_t.y-30,-3000,obj_zodiac_effect);
                fx.sprite_index = spr_wugushe_effect;
                if (shape == 1) fx.sprite_index = spr_wugushe_effect_1;
                else if (shape >= 2) fx.sprite_index = spr_wugushe_effect_2;
                    fx.life = max(1,sprite_get_number(fx.sprite_index)*5);
                    fx.image_index = 0;
                    fx.image_speed = 0.5;
                    fx.follow = po_t;
                    fx.poison_source = id;
                    // 每波独立判定：额外造成满血（最大生命）5%/8%/8% 的真实伤害，上限 1000/1500/1500
                    var gu_ratio = shape == 0 ? 0.05 : 0.08;
                    var gu_cap = shape == 0 ? 1000 : 1500;
                    var gt_dmg = 0;
                    if (instance_exists(po_t)) gt_dmg = min(po_t.maxhp*gu_ratio,gu_cap);
                    with (po_t) {
                        damage_amount = gt_dmg;
                        damage_type = "true";
                        if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
                        event_user(0);
                    }
                    // 非防爆鼠（情报岛中不防爆，即非精英/BOSS）直接秒杀；防爆鼠仅承受百分比伤害
                    if (instance_exists(po_t) && po_t.hp > 0 && !po_t.immune_to_ash) {
                        var gk_dmg = po_t.hp+po_t.shield_hp+po_t.helmet_hp;
                        with (po_t) {
                            damage_amount = gk_dmg;
                            damage_type = "true";
                            if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
                            event_user(0);
                        }
                    }
                }
            }
        }
    }
    if (zodiac_shot_this_anim && image_index > idle_anim + attack_anim) {
        state = CARD_STATE.IDLE;
        image_index = 0;
        zodiac_shot_this_anim = false;
    }
}
