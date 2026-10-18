event_inherited();
ly_kind = "zhizhujing";
ly_anims = {};
ly_action = "";
ly_frame = 0;
ly_done = false;
ly_once = false;
ly_hit = false;
ly_mode = "seek";
ly_cooldown = 0;
ly_soul = false;
is_soul = false;
invincible = false;
is_vehicle = false;
can_use_ladder = false;
ly_dodge_cooldown = 0;
ly_night = false;
ly_original_hp = 100;
state = ENEMY_STATE.ACTING;

// 本对象的属性、动作和专属状态。
mouse_id = "longyuan_zhizhujing";
ly_anims = longyuan_animation_table("zhizhujing");
hp = 800; maxhp = 800; ly_original_hp = 800;
move_speed = 0; atk = 10; atk_cycle = 90;
ly_night = longyuan_is_night();

// 白天（普通形态）：从天而降偷卡；夜晚死亡后：魂体吐丝结网封格。
target_type = "air";
ly_timer = 0;
ly_target = noone;
ly_tcol = -1;
ly_trow = -1;
ly_warn_fx = noone;
ly_wrap_done = false;

longyuan_begin_death = function() { ly_mode = "dead"; target_plant = noone; ly_action = ""; longyuan_play("死亡", true); };

// 随机选取一张存活卡片作为目标，并记录其格坐标（卡片被销毁后格坐标仍可用）。
ly_pick_target = function() {
    var _cands = [];
    with (obj_card_parent) {
        if (hp > 0 && plant_id != "player" && plant_type != "coffee" && !invincible) array_push(_cands, id);
    }
    if (array_length(_cands) == 0) return false;
    ly_target = _cands[irandom(array_length(_cands) - 1)];
    ly_tcol = ly_target.grid_col;
    ly_trow = ly_target.grid_row;
    return true;
};

// 白天机制：完全参考蝙蝠鼠——预警 2 秒 → 绑蛛丝从天降到卡上 → 等待 2 秒偷走 → 吊起飞走。
ly_spider_day = function() {
    var _air = longyuan_air_speed_multiplier();
    switch (ly_mode) {
        case "seek":
            // 场上暂无卡：在屏外等待，每隔 LY_SPIDER_RETRY 帧重选。
            y = -200;
            longyuan_play("正常待机");
            longyuan_animate();
            if (!instance_exists(ly_target) || ly_target.hp <= 0) {
                ly_timer++;
                if (ly_timer >= LY_SPIDER_RETRY) {
                    ly_timer = 0;
                    if (ly_pick_target()) x = get_world_position_from_grid(ly_tcol, ly_trow).x;
                }
            } else {
                x = get_world_position_from_grid(ly_tcol, ly_trow).x;
                ly_mode = "warn";
                ly_timer = 0;
            }
            break;

        case "warn":
            // 先在卡片上生成 spr_zhizhujing_apper 预警，本体停在屏外同列。
            y = -200;
            if (!instance_exists(ly_warn_fx)) {
                var _wp = get_world_position_from_grid(ly_tcol, ly_trow);
                ly_warn_fx = instance_create_depth(_wp.x, _wp.y - 30, -1300, obj_ly_boss_fx);
                ly_warn_fx.image_xscale = 1.8;
                ly_warn_fx.image_yscale = 1.8;
                longyuan_boss_fx_start(ly_warn_fx, "zhizhujing_apper", "出现", true, 5);
            }
            longyuan_play("正常待机");
            longyuan_animate();
            ly_timer++;
            if (ly_timer >= LY_SPIDER_WARN) {
                if (instance_exists(ly_warn_fx)) instance_destroy(ly_warn_fx);
                ly_warn_fx = noone;
                ly_mode = "descend";
                ly_timer = 0;
            }
            break;

        case "descend": {
            // 身上绑蛛丝从天上降到卡片位置。
            var _dp = get_world_position_from_grid(ly_tcol, ly_trow);
            x = _dp.x;
            var _land_y = _dp.y - 30;
            if (y < _land_y) y = min(_land_y, y + 15 * _air);
            if (y >= _land_y) {
                y = _land_y;
                target_type = "normal";
                ly_mode = "steal";
                ly_timer = 0;
            }
            longyuan_play("正常待机");
            longyuan_animate();
            break;
        }

        case "steal":
            // 落地等待 2 秒后将卡片偷走（仿蝙蝠：变 obj_card_stolen）。
            target_type = "normal";
            longyuan_play("缠绕卡片");
            longyuan_animate();
            ly_timer++;
            if (ly_timer >= LY_SPIDER_STEAL_WAIT) {
                if (instance_exists(ly_target) && ly_target.hp > 0 && ly_target.plant_id != "player") {
                    with (ly_target) {
                        var _stolen = instance_create_depth(x, y, depth + 1, obj_card_stolen);
                        _stolen.sprite_index = sprite_index;
                        _stolen.image_index = image_index;
                        no_revive_record = true;
                        instance_destroy();
                    }
                }
                ly_mode = "fly";
                ly_timer = 0;
            }
            break;

        case "fly":
            target_type = "air";
            longyuan_play("正常待机");
            longyuan_animate();
            y -= 15 * _air;
            if (y <= -200) instance_destroy();
            break;
    }
};

// 夜魂体：飞至卡片处吐丝缠绕（销毁卡片），在该格结网封格，然后飞走。
ly_spider_night = function() {
    var _air = longyuan_air_speed_multiplier();
    switch (ly_mode) {
        case "sseek":
            longyuan_play("正常待机");
            longyuan_animate();
            if (!instance_exists(ly_target) || ly_target.hp <= 0) {
                ly_timer++;
                if (ly_timer >= LY_SPIDER_RETRY) {
                    ly_timer = 0;
                    if (ly_pick_target()) ly_mode = "smove";
                }
            } else ly_mode = "smove";
            break;

        case "smove": {
            if (!instance_exists(ly_target) || ly_target.hp <= 0) {
                ly_mode = "sseek";
                ly_timer = 0;
                break;
            }
            var _tx = ly_target.x;
            var _ty = ly_target.y - 30;
            var _dist = point_distance(x, y, _tx, _ty);
            if (_dist > 10) {
                var _sp = min(2.2 * _air, _dist);
                var _dir = point_direction(x, y, _tx, _ty);
                x += lengthdir_x(_sp, _dir);
                y += lengthdir_y(_sp, _dir);
            } else {
                x = _tx; y = _ty;
                ly_mode = "swrap";
                ly_timer = 0;
            }
            longyuan_play("正常待机");
            longyuan_animate();
            break;
        }

        case "swrap":
            longyuan_play("正常抱住物品", true);
            longyuan_animate();
            if (!ly_wrap_done && ly_frame >= 4) {
                ly_wrap_done = true;
                if (instance_exists(ly_target) && ly_target.hp > 0) {
                    var _wc = ly_target.grid_col;
                    var _wr = ly_target.grid_row;
                    var _wd = ly_target.depth;
                    longyuan_destroy_card(ly_target);
                    longyuan_web_make(_wc, _wr, _wd);
                }
                ly_target = noone;
            }
            if (ly_done) { ly_mode = "sfly"; ly_timer = 0; }
            break;

        case "sfly":
            longyuan_play("正常待机");
            longyuan_animate();
            y -= 15 * _air;
            if (y <= -200) instance_destroy();
            break;
    }
};

longyuan_change_soul = function() {
    ly_soul = true; is_soul = true; target_type = "invisible";
    ly_kind = "zhizhujing_soul"; ly_anims = longyuan_animation_table(ly_kind);
    hp = maxhp; ash_death = false; image_alpha = 1; ly_action = "";
    ly_target = noone; ly_tcol = -1; ly_trow = -1; ly_timer = 0; ly_wrap_done = false;
    ly_mode = "sseek";
    longyuan_play("正常待机");
};
