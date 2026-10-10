function zodiac_sprite(_id, _shape, _role = "") {
    var _suffix = (_role == "" ? "" : "_"+_role)+(_shape == 0 ? "" : "_"+string(_shape));
    var _spr = asset_get_index("spr_"+_id+_suffix);
    // 萤火蛇的精灵资源以 sp_ 前缀命名，运行时需要回退查找，否则 sprite_index 会被置为 -1 导致卡片不可见
    if (_spr < 0 && _id == "yinghuoshe") _spr = asset_get_index("sp_"+_id+_suffix);
    return _spr;
}

function zodiac_effect(_spr, _x, _y, _life = -1) {
    if (_spr < 0) return noone;
    var e = instance_create_depth(_x,_y,-3000,obj_zodiac_effect);
    e.sprite_index = _spr;
    e.life = _life < 0 ? max(1,sprite_get_number(_spr)*5) : _life;
    e.image_index = 0;
    e.image_speed = 0.5;
    var _grid_width = global.grid_cell_size_x;
    var _grid_height = global.grid_cell_size_y;
    var _range = 0;
    if (_spr == asset_get_index("spr_yinhema_effect")) _range = 3;
    else if (_spr == asset_get_index("spr_yinhema_effect_1") || _spr == asset_get_index("spr_yinhema_effect_2")
        || _spr == asset_get_index("spr_xingqiongma_effect2") || _spr == asset_get_index("spr_xingqiongma_effect2_1")
        || _spr == asset_get_index("spr_xingqiongma_effect2_2") || _spr == asset_get_index("spr_kuileima_effect2_2")
        || _spr == asset_get_index("spr_kuileima_effect3_1")) _range = 5;
    if (_range > 0) {
        e.image_xscale = _range * _grid_width / sprite_get_width(_spr);
        e.image_yscale = _range * _grid_height / sprite_get_height(_spr);
    }
    return e;
}

function zodiac_enemies() {
    var result = [];
    for (var i = 0; i < instance_number(obj_enemy_parent); i++) {
        var e = instance_find(obj_enemy_parent,i);
        if (instance_exists(e) && e.hp > 0) array_push(result,e);
    }
    // 傀儡马代理在部分版本的父对象枚举中不会返回，显式补入攻击目标列表。
    for (var i = 0; i < instance_number(obj_kuileima_decoy); i++) {
        var d = instance_find(obj_kuileima_decoy,i);
        if (instance_exists(d) && d.hp > 0 && !array_contains(result,d)) array_push(result,d);
    }
    return result;
}

function zodiac_priority_target() {
    var enemies = zodiac_enemies(), best = noone;
    for (var i = 0; i < array_length(enemies); i++) {
        var e = enemies[i];
        if (!instance_exists(best) || (e.is_boss && !best.is_boss)
            || (e.is_boss == best.is_boss && e.hp > best.hp)) best = e;
    }
    return best;
}

function zodiac_hp_target() {
    var enemies = zodiac_enemies(), best = noone;
    for (var i = 0; i < array_length(enemies); i++) {
        var e = enemies[i];
        if (!instance_exists(best) || e.hp > best.hp) best = e;
    }
    return best;
}

function zodiac_hit(_target, _damage, _type = "pierce", _ash = false) {
    if (!instance_exists(_target) || _target.hp <= 0) return;
    with (_target) {
        damage_amount = _damage;
        damage_type = _type;
        event_user(0);
        if (_ash && hp <= 0 && !immune_to_ash) {
            ash_death = true;
            // 二转炎凰马击杀时跳过老鼠普通死亡动画，直接播放灰烬特效。
            if (special_ash) {
                var inst = instance_create_depth(x,y-20,depth,obj_mouse_ash_death);
                inst.special_ash = true;
                inst.sprite_index = sprite_index;
                inst.image_index = image_index;
            } else {
                instance_create_depth(x,y-20,depth,obj_mouse_ash_death);
            }
            instance_destroy();
        }
    }
}

function zodiac_card_create() {
    plant_type = plant_id == "xiandima" ? "gridless" : "normal";
    feature_type = plant_id == "yanhuangma" ? "lava" : "normal";
    sprite_index = zodiac_sprite(plant_id,shape);
    image_xscale = 1.8;
    image_yscale = 1.8;
    attack_anim = 0;
    idle_anim = sprite_get_number(sprite_index)-1;
    if (plant_id == "kuileima") {
        // 0-16待机 17-21受击 22-末帧死亡
        idle_anim = 16;
        attack_anim = 5;
    }
    if (plant_id == "yanhuangma") {
        // 0-13待机 14-20攻击，所有形态均在第18帧召唤炎凰
        idle_anim = 13;
        attack_anim = 6;
    }
    if (plant_id == "starrabbit") {
        idle_anim = 14;
        attack_anim = 8;
    }
    if (plant_id == "yinghuoshe") {
        idle_anim = 12;
        attack_anim = 11;
    }
    if (plant_id == "wugushe") {
        // 0-13 待机，14-27（资源第 15-28 帧）攻击。
        idle_anim = 13;
        attack_anim = 14;
    }
    if (plant_id == "fenjima") {
        // 三种形态统一使用资源第 0-10 帧作为待机动画。
        idle_anim = 10;
    }
    flash_speed = 5;
    zodiac_timer = 0;
    zodiac_age = 0;
    zodiac_horses = 0;
    zodiac_vertical_timer = 0;
    zodiac_shot_this_anim = false; // 炎凰马本轮攻击动画是否已发射子弹
    zodiac_firefly_hit_ids = [];
    zodiac_target = noone;
    zodiac_previous_hp = hp;
    zodiac_dying = false;
    zodiac_death_timer = 0;
    zodiac_hurt_timer = 0;
    if (plant_id == "xingqiongma") {
        var guard = get_plant_data_with_skill(plant_id,shape,current_level,skill);
        zodiac_guard_duration = guard == undefined ? 900 : guard[? "zodiac_guard_duration"];
        // 种下时释放对应形态的5×5范围特效：effect2 / effect2_1 / effect2_2
        zodiac_effect(zodiac_sprite(plant_id,shape,"effect2"),x,y);
    }
    zodiac_effects = [];
    zodiac_stored = []; // 仙笛马停靠中的飞马子弹
    no_revive_record = plant_id == "kuileima" || plant_id == "xingqiongma";
    if (plant_id == "kuileima") {
        zodiac_target = zodiac_hp_target();
        zodiac_decoy = noone;
        if (instance_exists(zodiac_target) && zodiac_target.hp > 0) {
            zodiac_decoy = instance_create_depth(x,y,depth,obj_kuileima_decoy);
            zodiac_decoy.decoy_card = id;
            zodiac_decoy.decoy_target = zodiac_target;
        }
        // effect2_2/effect3_1 为死亡专属特效，放下时不播放（形态2不再创建常驻光环）
        if (shape != 2) {
            var e = zodiac_effect(zodiac_sprite(plant_id,shape,shape == 0 ? "effect" : "effect2"),x,y,2147483647);
            array_push(zodiac_effects,e);
        }
    }
    if (plant_id == "yanyantu" || plant_id == "yinhema") {
        var e = zodiac_effect(zodiac_sprite(plant_id,shape,"effect"),x,y,2147483647);
        array_push(zodiac_effects,e);
        if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
    }
}

function zodiac_card_begin_death() {
    zodiac_dying = true;
    zodiac_death_timer = 0;
    zodiac_hurt_timer = 0;
    hp = 1; // 保持存活以播放死亡动画，动画结束后再真正销毁
    zodiac_previous_hp = hp;
    state = CARD_STATE.DEAD;
    image_index = idle_anim+attack_anim+1; // 死亡帧起点（22）
}

function zodiac_card_before_step() {
    if (plant_id == "kuileima") {
        if (zodiac_dying) {
            if (hp <= 0) hp = 1; // 死亡动画期间免疫后续伤害
            zodiac_death_timer++;
            if (zodiac_death_timer >= flash_speed) {
                zodiac_death_timer = 0;
                if (image_index < sprite_get_number(sprite_index)-1) image_index++;
                else instance_destroy(); // 死亡动画播放完毕，销毁并触发死亡特效
            }
            return;
        }
        if (zodiac_hurt_timer > 0) {
            zodiac_hurt_timer--;
            if (zodiac_hurt_timer <= 0 && state == CARD_STATE.ATTACK) {
                state = CARD_STATE.IDLE;
                image_index = 0;
            }
        }
        if (hp < zodiac_previous_hp) {
            zodiac_hit(zodiac_target,(zodiac_previous_hp-hp)*zodiac_base_multiplier(id));
        }
        zodiac_previous_hp = hp;
        if (hp <= 0) zodiac_card_begin_death();
        return;
    }
    zodiac_previous_hp = hp;
}

function zodiac_card_hurt() {
    if (variable_instance_exists(id,"zodiac_guard_time") && zodiac_guard_time > 0 && zodiac_guard_hits > 0 && hp < zodiac_guard_hp) {
        hp = zodiac_guard_hp;
        zodiac_guard_hits--;
        if (zodiac_guard_hits <= 0) zodiac_guard_time = 0;
    }
    if (variable_instance_exists(id,"zodiac_previous_hp") && plant_id == "kuileima" && !zodiac_dying && hp < zodiac_previous_hp) {
        zodiac_hit(zodiac_target,(zodiac_previous_hp-hp)*zodiac_base_multiplier(id));
        zodiac_previous_hp = hp;
        zodiac_card_play_hurt();
    }
}

function zodiac_card_play_hurt() {
    if (plant_id != "kuileima" || zodiac_dying) return;
    // 受击动画 17-21
    state = CARD_STATE.ATTACK;
    image_index = idle_anim+1;
    zodiac_hurt_timer = attack_anim*flash_speed;
}

function zodiac_base_multiplier(_card) {
    var data = get_plant_data_with_skill(_card.plant_id,_card.shape,_card.current_level,_card.skill);
    return data == undefined ? 1 : data[? "atk"];
}

function zodiac_named_target(_card, _names) {
    var data = get_plant_upgrade(_card.plant_id,0,0);
    if (data == undefined) return false;
    var pdata = get_plant_shape_data(_card.plant_id,0);
    if (pdata == undefined) return false;
    var n = pdata[? "name"];
    for (var i = 0; i < array_length(_names); i++) {
        if (n == _names[i] || string_pos(_names[i],n) > 0) return true;
    }
    return false;
}

function zodiac_aura_multiplier(_card, _source_id) {
    var result = 1;
    for (var i = 0; i < instance_number(obj_card_parent); i++) {
        var source_card = instance_find(obj_card_parent,i);
        if (!instance_exists(source_card) || source_card.hp <= 0 || source_card.plant_id != _source_id) continue;
        var radius = _source_id == "yanyantu" ? (source_card.shape == 2 ? 2 : 1) : (source_card.shape == 0 ? 1 : 2);
        if (abs(source_card.grid_col-_card.grid_col) <= radius && abs(source_card.grid_row-_card.grid_row) <= radius)
            result = max(result,zodiac_base_multiplier(source_card));
    }
    return result;
}

function zodiac_flame_multiplier(_card) {
    if (!instance_exists(_card)) return 1;
    if (_card.plant_id == "sun_god" || _card.plant_id == "shuangzi") return zodiac_aura_multiplier(_card,"yanyantu");
    var names = ["小火炉","大火炉","酒杯灯","双子座","太阳神","暖暖鸡","咕咕鸡","火焰牛","7周年蜡烛","生日帽","守能汪","喵喵炉","扑克牌护罩"];
    return zodiac_named_target(_card,names) ? zodiac_aura_multiplier(_card,"yanyantu") : 1;
}

function zodiac_music_multiplier(_card) {
    if (!instance_exists(_card)) return 1;
    var names = ["迷你披萨炉","赖皮蛇","工匠神","炎凰马","炎帝"];
    return zodiac_named_target(_card,names) ? zodiac_aura_multiplier(_card,"yinhema") : 1;
}

function zodiac_card_step() {
    zodiac_age++;
    for (var i = 0; i < array_length(zodiac_effects); i++) {
        var e = zodiac_effects[i];
        if (instance_exists(e)) {e.x = x; e.y = y;}
    }
    if (plant_id == "yanyantu" || plant_id == "yinhema") {
        if (zodiac_age mod 5 == 0 && variable_global_exists("buff_apply_id")) global.buff_apply_id++;
        return;
    }
    if (plant_id == "kuileima") {
        if (zodiac_dying) return;
        if (!instance_exists(zodiac_target) || zodiac_target.hp <= 0 || zodiac_age >= origin_cycle) {zodiac_card_begin_death(); return;}
        if (zodiac_age mod 15 == 1) {
            // 多节原尺寸锁链从卡片连接指向绑定的老鼠
            var chain_spr = zodiac_sprite(plant_id,shape,"chain");
            if (chain_spr > -1) {
                var dir = point_direction(x,y-30,zodiac_target.x,zodiac_target.y-30);
                var dist = point_distance(x,y-30,zodiac_target.x,zodiac_target.y-30);
                var count = max(1,ceil(dist/sprite_get_width(chain_spr)));
                var spacing = dist/count;
                for (var i = 0; i < count; i++) {
                    var e = zodiac_effect(chain_spr,x+lengthdir_x(spacing*(i+0.5),dir),y-30+lengthdir_y(spacing*(i+0.5),dir),15);
                    if (instance_exists(e)) {
                        e.image_angle = dir;
                        e.image_xscale = 1;
                        e.image_yscale = 1;
                    }
                }
            }
        }
        return;
    }
    if (plant_id == "xingqiongma") {
        if (zodiac_age >= 72) {zodiac_revive();instance_destroy();}
        return;
    }
    if (is_frozen || state == CARD_STATE.SLEEP) return;
    if (plant_id == "yinghuoshe") zodiac_firefly_check_entries();
    // 和狮子座一致：范围内没有目标时不累计攻击周期，也不保留攻击动画。
    if (plant_id == "wugushe" && !zodiac_poison_has_target()) {
        zodiac_timer = 0;
        // 仅在退出攻击时回到待机首帧；待机状态下不要每帧重置，
        // 让父对象继续循环 0-14 帧。
        if (state != CARD_STATE.IDLE) {
            state = CARD_STATE.IDLE;
            image_index = 0;
            zodiac_shot_this_anim = false;
        }
        return;
    }
    var interval = plant_id == "xiandima" ? cycle/3 : cycle;
    if (plant_id == "yinghuoshe" && state == CARD_STATE.IDLE && zodiac_timer == 0
        && zodiac_firefly_has_target()) zodiac_timer = interval - 1;
    zodiac_timer++;
    if (zodiac_timer >= interval) {
        zodiac_timer = 0;
        switch (plant_id) {
            case "wugushe":
                state = CARD_STATE.ATTACK;
                image_index = idle_anim + 1;
                zodiac_shot_this_anim = false;
                break;
            case "yufengma": zodiac_wind(); break;
            case "fenjima": zodiac_fire_shot(); break;
            case "guiyuanma": zodiac_return_shot(); break;
            case "yanhuangma":
                // 无论场上是否有敌人，都按攻击间隔进入攻击动画。
                state = CARD_STATE.ATTACK;
                image_index = idle_anim+1;
                zodiac_shot_this_anim = false;
                break;
            case "xiandima":
                // 每攻击间隔的1/3召唤1只飞马，停靠在卡片最右方并从下往上累积，集满3只后一起飞出追踪敌人
                if (zodiac_horses < 3) {
                    var b = zodiac_projectile("flute",x+34,y-16-zodiac_horses*28,0,atk,shape);
                    b.stored = true;
                    b.owner_id = id;
                    b.park_index = zodiac_horses;
                    array_push(zodiac_stored,b);
                    zodiac_horses++;
                }
                if (zodiac_horses == 3) {
                    var t = zodiac_priority_target();
                    if (instance_exists(t)) {
                        // 有目标才放飞；没有目标时保持停靠，等下个召唤周期再检查
                        zodiac_horses = 0;
                        for (var n = 0; n < array_length(zodiac_stored); n++) {
                            var bb = zodiac_stored[n];
                            if (!instance_exists(bb)) continue;
                            bb.stored = false;
                            bb.owner_id = noone;
                            bb.target_id = t;
                        }
                        zodiac_stored = [];
                    }
                }
                break;
            case "starrabbit":
                state = CARD_STATE.ATTACK;
                image_index = idle_anim + 1;
                zodiac_shot_this_anim = false;
                break;
            case "yinghuoshe":
                state = CARD_STATE.ATTACK;
                image_index = idle_anim + 1;
                zodiac_shot_this_anim = false;
                break;
        }
    }
    if (plant_id == "yanhuangma") {
        // 攻击动画推进到第18帧（idle_anim+5）时发射子弹；动画循环回起点后恢复待机
        if (state == CARD_STATE.ATTACK) {
            if (!zodiac_shot_this_anim && image_index == idle_anim+5) {
                zodiac_shot_this_anim = true;
                zodiac_phoenix(false);
            }
            if (zodiac_shot_this_anim && image_index == idle_anim+1) {
                state = CARD_STATE.IDLE;
                image_index = 0;
                zodiac_shot_this_anim = false;
            }
        }
        if (shape >= 1) {
            zodiac_vertical_timer++;
            if (zodiac_vertical_timer >= 300) {
                var count = 0, strongest = noone;
                for (var i = 0; i < instance_number(obj_yanhuangma); i++) {
                    var p = instance_find(obj_yanhuangma,i);
                    if (!instance_exists(p) || p.hp <= 0) continue;
                    count++;
                    if (p.shape >= 1 && (!instance_exists(strongest) || p.atk > strongest.atk
                        || (p.atk == strongest.atk && p.id < strongest.id))) strongest = p;
                }
                if (count >= 7 && strongest == id) {
                    zodiac_phoenix(true);
                    zodiac_vertical_timer = 0;
                }
                // 未满足7只时保留计时，满足条件后立即由最高攻击力卡片召唤。
                if (count < 7) zodiac_vertical_timer = 300;
            }
        }
    }
    if (plant_id == "wugushe" && state == CARD_STATE.ATTACK) {
        if (!zodiac_shot_this_anim && image_index == idle_anim + 1) {
            zodiac_shot_this_anim = true;
            zodiac_poison();
        }
        if (zodiac_shot_this_anim && image_index > idle_anim + attack_anim) {
            state = CARD_STATE.IDLE;
            image_index = 0;
            zodiac_shot_this_anim = false;
        }
    }
    if ((plant_id == "starrabbit" || plant_id == "yinghuoshe") && state == CARD_STATE.ATTACK) {
        // 两张卡都在动画第18帧执行攻击动作。
        if (!zodiac_shot_this_anim && image_index == 18) {
            zodiac_shot_this_anim = true;
            if (plant_id == "starrabbit") zodiac_star_shot();
            else zodiac_firefly_shot();
        }
        if (zodiac_shot_this_anim && zodiac_timer > 0 && image_index == idle_anim + 1) {
            state = CARD_STATE.IDLE;
            image_index = 0;
            zodiac_shot_this_anim = false;
        }
    }
}

function zodiac_star_shot() {
    var angles = [0,22.5,-22.5,45,-45];
    var shot_shape = clamp(round(shape),0,2);
    if (sprite_index == asset_get_index("spr_starrabbit_2")) shot_shape = max(shot_shape,2);
    else if (sprite_index == asset_get_index("spr_starrabbit_1")) shot_shape = max(shot_shape,1);
    var shots_per_angle = shot_shape + 1;
    for (var i = 0; i < array_length(angles); i++) {
        for (var j = 0; j < shots_per_angle; j++)
            zodiac_projectile("star",x,y-30,angles[i],atk,shot_shape);
    }
}

function zodiac_firefly_shot() {
    var count = shape == 0 ? 1 : (shape == 1 ? 2 : 2);
    var value = 20;
    if (variable_instance_exists(id,"flame_produce")) {
        value = is_array(flame_produce)
            ? flame_produce[clamp(current_level,0,array_length(flame_produce)-1)]
            : flame_produce;
    }
    for (var f = 0; f < count; f++) {
        var inst = instance_create_depth(x,y-60,depth-1000,obj_flame);
        inst.value = value;
    }
}

function zodiac_firefly_check_entries() {
    var enemies = zodiac_enemies();
    var radius = 1;
    for (var i = 0; i < array_length(enemies); i++) {
        var e = enemies[i];
        if (e.target_type == "underground" || e.target_type == "non_mainstream"
            || e.target_type == "ghost" || e.target_type == "invisible") continue;
        if (array_contains(zodiac_firefly_hit_ids,e.id)) continue;
        var eg = get_grid_position_from_world(e.x,e.y);
        if (abs(eg.col-grid_col) <= radius && abs(eg.row-grid_row) <= radius) {
            array_push(zodiac_firefly_hit_ids,e.id);
            zodiac_hit(e,atk);
        }
    }
}

function zodiac_firefly_has_target() {
    var enemies = zodiac_enemies();
    var radius = 1;
    for (var i = 0; i < array_length(enemies); i++) {
        var e = enemies[i];
        if (e.target_type == "underground" || e.target_type == "non_mainstream"
            || e.target_type == "ghost" || e.target_type == "invisible") continue;
        var eg = get_grid_position_from_world(e.x,e.y);
        if (abs(eg.col-grid_col) <= radius && abs(eg.row-grid_row) <= radius) return true;
    }
    return false;
}

function zodiac_poison_has_target() {
    var enemies = zodiac_enemies(), radius = shape == 2 ? 2 : 1;
    for (var i = 0; i < array_length(enemies); i++) {
        var e = enemies[i];
        if (e.target_type != "normal" && e.target_type != "air") continue;
        var g = get_grid_position_from_world(e.x,e.y);
        if (g.col >= 0 && g.col < global.grid_cols && g.row >= 0 && g.row < global.grid_rows
            && abs(g.col-grid_col) <= radius && abs(g.row-grid_row) <= radius) return true;
    }
    return false;
}

function zodiac_poison() {
    var enemies = zodiac_enemies(), radius = shape == 2 ? 2 : 1;
    var waves = shape == 0 ? 2 : 3;
    // 先筛选攻击范围内可被命中的可见老鼠：仅陆军/空军，
    // 排除地下鼠、隐身鬼鼠等不可见目标及障碍物（它们同样挂在 obj_enemy_parent 下）
    var targets = [];
    for (var i = 0; i < array_length(enemies); i++) {
        var e = enemies[i];
        if (e.target_type != "normal" && e.target_type != "air") continue;
        var g = get_grid_position_from_world(e.x,e.y);
        if (g.col < 0 || g.col >= global.grid_cols || g.row < 0 || g.row >= global.grid_rows) continue;
        if (abs(g.col-grid_col) <= radius && abs(g.row-grid_row) <= radius) array_push(targets,e);
    }
    if (array_length(targets) == 0) return false;
    for (var i = 0; i < array_length(targets); i++) {
        var e = targets[i];
        for (var w = 0; w < waves && instance_exists(e) && e.hp > 0; w++) {
            zodiac_hit(e,atk/waves);
            if (random(1) < (shape == 0 ? 0.10 : 0.15)) {
                // 蛊毒特效跟随老鼠，播放一次后自动销毁；卡片死亡/铲除时由 zodiac_card_destroy 清理
                var fx = zodiac_effect(zodiac_sprite(plant_id,shape,"effect"),e.x,e.y-30);
                if (instance_exists(fx)) {
                    fx.follow = e;
                    fx.poison_source = id;
                }
                // 每波独立判定：额外造成满血（最大生命）5%/8%/8% 的真实伤害，上限 1000/1500/1500
                var gu_ratio = shape == 0 ? 0.05 : 0.08;
                var gu_cap = shape == 0 ? 1000 : 1500;
                zodiac_hit(e,min(e.maxhp*gu_ratio,gu_cap),"true");
                // 非防爆鼠（情报岛中不防爆，即非精英/BOSS）直接秒杀；防爆鼠仅承受百分比伤害
                if (instance_exists(e) && e.hp > 0 && !e.immune_to_ash)
                    zodiac_hit(e,e.hp+e.shield_hp+e.helmet_hp,"true");
            }
        }
    }
    return true;
}

function zodiac_has_fan() {
    for (var i = 0; i < instance_number(obj_card_parent); i++) {
        var p = instance_find(obj_card_parent,i);
        if (instance_exists(p) && p.hp > 0 && (p.plant_id == "ventilation_fan" || p.plant_id == "xuanfengniu"
            || zodiac_named_target(p,["9周年幸运草扇"]))) return true;
    }
    return false;
}

function zodiac_front_target(_rows) {
    var enemies = zodiac_enemies(), best = noone, distance = 2147483647;
    for (var i = 0; i < array_length(enemies); i++) {
        var e = enemies[i];
        if (e.x < x || abs(e.grid_row-grid_row) > _rows || e.target_type == "underground" || e.target_type == "invisible") continue;
        var d = point_distance(x,y,e.x,e.y);
        if (d < distance) {distance = d; best = e;}
    }
    return best;
}

function zodiac_wind() {
    var big = zodiac_has_fan();
    if (!instance_exists(zodiac_front_target(big ? 1 : 0))) return;
    var spr = zodiac_sprite(plant_id,shape,big ? "bullet_big" : "bullet");
    var b = zodiac_projectile("wind",x,y-30,0,atk,shape);
    b.rows = big ? 1 : 0;
    b.sprite_index = spr;
    b.center_row = grid_row;
    if (big && spr >= 0) {
        // 有风扇时大风弹：shape0/1/2 分别使用 bullet_big/_1/_2，动画纵向拉伸至3行高度并以卡片行中心对称覆盖（伤害同为这3行）
        b.image_yscale = 3*global.grid_cell_size_y/sprite_get_height(spr);
        b.y = y - 1.5*global.grid_cell_size_y + sprite_get_yoffset(spr)*b.image_yscale;
    }
}

function zodiac_fire_shot() {
    if (!instance_exists(zodiac_front_target(0))) return;
    // 子弹的碰撞高度沿用卡片攻击层，但行号必须随发射卡片传递；
    // 否则只有第 0 行会参与老鼠、反弹和火焰卡片的判定。
    var b = zodiac_projectile("fire",x,y-30,0,atk,shape);
    b.row = grid_row;
    b.center_row = grid_row;
}

function zodiac_return_shot() {
    var t = zodiac_front_target(shape == 2 ? 2 : 1);
    if (!instance_exists(t)) return;
    for (var i = 0; i < (shape == 2 ? 2 : 1); i++) zodiac_projectile("return",x,y-35-i*12,0,atk,shape,t);
}

function zodiac_phoenix(_vertical) {
    var left = global.grid_offset_x, right = left+global.grid_cols*global.grid_cell_size_x;
    if (_vertical) {
        // 一转：最右两列（第8/9列）各召唤1发竖向子弹，从上向下飞行；第8列受击2次，第9列1次。
        var b = zodiac_projectile("phoenix",left+7.5*global.grid_cell_size_x,global.grid_offset_y-0.25*global.grid_cell_size_y,90,atk,shape);
        b.vertical = true;
        b.cover_a = 7;
        b.cover_b = 7;
        var c = zodiac_projectile("phoenix",left+8.5*global.grid_cell_size_x,global.grid_offset_y-0.25*global.grid_cell_size_y,90,atk,shape);
        c.vertical = true;
        c.cover_a = 8;
        c.cover_b = 8;
    } else {
        // 四只横向子弹：根据卡片所在行，取其上中缝隙和中下缝隙，左右各一只。
        // 左侧向右、右侧向左飞行；每只覆盖相邻两行。
        var upper_gap = clamp(grid_row,1,global.grid_rows-1);
        var lower_gap = clamp(grid_row+1,1,global.grid_rows-1);
        var upper_left = zodiac_projectile("phoenix",left-20,global.grid_offset_y+(upper_gap-0.25)*global.grid_cell_size_y,0,atk,shape);
        upper_left.cover_a = upper_gap-1;
        upper_left.cover_b = upper_gap;
        var upper_right = zodiac_projectile("phoenix",right+20,global.grid_offset_y+(upper_gap-0.25)*global.grid_cell_size_y,180,atk,shape);
        upper_right.image_angle = 0;
        upper_right.image_xscale = -1;
        upper_right.cover_a = upper_gap-1;
        upper_right.cover_b = upper_gap;
        var lower_left = zodiac_projectile("phoenix",left-20,global.grid_offset_y+(lower_gap-0.25)*global.grid_cell_size_y,0,atk,shape);
        lower_left.cover_a = lower_gap-1;
        lower_left.cover_b = lower_gap;
        var lower_right = zodiac_projectile("phoenix",right+20,global.grid_offset_y+(lower_gap-0.25)*global.grid_cell_size_y,180,atk,shape);
        lower_right.image_angle = 0;
        lower_right.image_xscale = -1;
        lower_right.cover_a = lower_gap-1;
        lower_right.cover_b = lower_gap;
    }
}

function zodiac_projectile(_kind, _x, _y, _direction, _damage, _shape, _target = noone) {
    var b = instance_create_depth(_x,_y,-2500,obj_zodiac_projectile);
    b.kind = _kind;
    b.damage = _damage;
    b.base_damage = _damage;
    b.shape = _shape;
    b.target_id = _target;
    if (_kind == "star") b.center_row = grid_row;
    b.move_x = lengthdir_x(8,_direction);
    b.move_y = lengthdir_y(8,_direction);
    b.image_angle = _direction;
    var card_id = "fenjima";
    switch (_kind) {
        case "wind": card_id = "yufengma"; break;
        case "return": card_id = "guiyuanma"; break;
        case "phoenix": card_id = "yanhuangma"; break;
        case "flute": card_id = "xiandima"; break;
        case "star": card_id = "starrabbit"; break;
    }
    b.sprite_index = zodiac_sprite(card_id,_shape,"bullet");
    b.can_dandantu_store = _kind == "fire";
    // 焚寂马的直线弹和分裂波标记为穿透：避免被障碍物(obj_obstacle)销毁，确保能穿过火盆等卡片
    // 注：实际对老鼠的伤害类型仍由 zodiac_hit 的参数决定，不影响伤害计算
    if (_kind == "fire" || _kind == "wave") b.damage_type = "pierce";
    return b;
}

function zodiac_wind_execute(_e) {
    // shape2 秒杀表列：(僵尸)滑翔鼠/废品飞兵鼠/神风滑翔鼠/(僵尸)飞行路障鼠/伞兵鼠/机械投弹鼠
    var ids = ["glider_mouse","waste_flying_mouse","kamikaze_glider_mouse","flight_barrier_mouse","paratrooper_mouse","machine_bomb_mouse"];
    return array_contains(ids,_e.mouse_id);
}

function zodiac_projectile_step() {
    if (stored) {
        // 停靠状态：跟随宿主卡片最右方，从下往上堆叠，不移动不计时不碰撞
        if (!instance_exists(owner_id)) {instance_destroy(); return;}
        x = owner_id.x+34;
        y = owner_id.y-16-park_index*28;
        image_angle = 0;
        return;
    }
    timer++;
    if (timer > 600 && kind != "star") {instance_destroy();return;}
    var old_x = x, old_y = y;
    if (kind == "return" || kind == "flute") {
        if (!instance_exists(target_id) || target_id.hp <= 0) {
            if (kind == "flute") target_id = zodiac_priority_target();
            if (!instance_exists(target_id) || target_id.hp <= 0) {instance_destroy();return;}
        }
        var direction_to_target = point_direction(x,y,target_id.x,target_id.y-30);
        move_x = lengthdir_x(10,direction_to_target);
        move_y = lengthdir_y(10,direction_to_target);
        image_angle = direction_to_target;
    }
    x += move_x;
    y += move_y;
    var enemies = zodiac_enemies();
    for (var i = 0; i < array_length(enemies); i++) {
        var e = enemies[i];
        if (array_contains(hit_ids,e.id)) continue;
        var collision = false;
        if (kind == "phoenix") {
            // 炎凰马只命中已显形陆军，不能命中幽灵、非主流、地下鼠或障碍物
            if (e.target_type != "normal") continue;
            if (vertical) collision = (e.grid_col == cover_a || e.grid_col == cover_b) && abs(e.y-y) < 18;
            else collision = (e.grid_row == cover_a || e.grid_row == cover_b) && abs(e.x-x) < 18;
        } else if (kind == "wind") {
            if (e.target_type != "normal" && e.target_type != "air") continue;
            collision = abs(e.grid_row-center_row) <= rows && abs(e.x-x) < 20;
        } else if (kind == "return" || kind == "flute") {
            collision = e == target_id && point_distance(x,y,e.x,e.y-30) < 16;
        } else if (kind == "star") {
            if (e.target_type != "normal" && e.target_type != "air") continue;
            collision = bbox_right >= e.bbox_left && bbox_left <= e.bbox_right
                && bbox_bottom >= e.bbox_top && bbox_top <= e.bbox_bottom;
        } else if (kind == "fire") {
            // 直线弹按行+精确碰撞：老鼠站位与卡片中心有约38px高度差，点距判定不可靠
            if (e.target_type != "normal") continue;
            collision = abs(e.grid_row-center_row) <= 0 && precise_bbox_collision(id,e);
        } else if (kind == "wave") {
            // 分裂波用精确碰撞：全方位飞行，点距判定受高度差影响打不到老鼠
            if (e.target_type != "normal") continue;
            collision = precise_bbox_collision(id,e);
        } else {
            if (e.target_type != "normal") continue;
            collision = point_distance(x,y,e.x,e.y-30) < 24;
        }
        if (!collision) continue;
        array_push(hit_ids,e.id);
        switch (kind) {
            case "wind":
                if (shape == 2 && zodiac_wind_execute(e) && !e.is_boss) zodiac_hit(e,e.hp+e.shield_hp+e.helmet_hp,"true");
                else {zodiac_hit(e,damage);if (!e.is_boss) e.x += global.grid_cell_size_x*0.5;}
                break;
            case "fire":
                zodiac_hit(e,damage,"normal");
                // 以子弹当前飞行方向为基准分裂：0°、±90°共3发；shape2追加±45°共5发
                // 过火盆等卡片只强化伤害，kind 不变，因此强化后的子弹依旧会分裂
                var base_angle = point_direction(0,0,move_x,move_y);
                var angles = shape == 2 ? [0,90,-90,45,-45] : [0,90,-90];
                var wave_damage = base_damage*(shape == 0 ? 1 : 1.5);
                var hit_grid = get_grid_position_from_world(e.x,e.y);
                for (var a = 0; a < array_length(angles); a++) {
                    var b = zodiac_projectile("wave",e.x,e.y-30,base_angle+angles[a],wave_damage,shape);
                    for (var j = 0; j < array_length(enemies); j++) {
                        var cell_enemy = enemies[j];
                        if (!instance_exists(cell_enemy) || cell_enemy.target_type != "normal") continue;
                        var eg = get_grid_position_from_world(cell_enemy.x,cell_enemy.y);
                        if (eg.col == hit_grid.col && eg.row == hit_grid.row) {
                            zodiac_hit(cell_enemy,wave_damage);
                            array_push(b.hit_ids,cell_enemy.id);
                        }
                    }
                }
                instance_destroy();return;
            case "return":
                if (!e.is_boss && e.hp/e.maxhp < (shape == 0 ? 0.30 : 0.50)) zodiac_hit(e,e.hp+e.shield_hp+e.helmet_hp,"true");
                else {
                    var original_hp = e.maxhp;
                    zodiac_hit(e,damage);
                    if (instance_exists(e) && e.hp > 0 && !e.is_boss) zodiac_return_mouse(e,original_hp);
                }
                instance_destroy();return;
            case "flute":
                zodiac_hit(e,damage*(shape >= 1 && e.is_boss ? 2.1 : 1));
                instance_destroy();return;
            case "star":
                zodiac_hit(e,damage);
                for (var s = 0; s < instance_number(obj_enemy_parent); s++) {
                    var splash = instance_find(obj_enemy_parent,s);
                    if (instance_exists(splash) && splash != e && splash.target_type == "normal"
                        && get_grid_position_from_world(splash.x,splash.y).col == get_grid_position_from_world(e.x,e.y).col
                        && get_grid_position_from_world(splash.x,splash.y).row == get_grid_position_from_world(e.x,e.y).row)
                        zodiac_hit(splash,damage*0.3);
                }
                instance_destroy();return;
            case "phoenix":
                zodiac_hit(e,damage*(vertical && e.grid_col == 7 ? 2 : 1),"pierce",shape == 2);
                break;
            default: zodiac_hit(e,damage);break;
        }
    }
    if (kind == "phoenix") {
        var field_left = global.grid_offset_x;
        var field_right = field_left + global.grid_cols * global.grid_cell_size_x;
        var field_top = global.grid_offset_y;
        var field_bottom = field_top + global.grid_rows * global.grid_cell_size_y;
        if ((vertical && y > field_bottom + 0.25*global.grid_cell_size_y)
            || (!vertical && ((move_x > 0 && x >= field_right) || (move_x < 0 && x <= field_left)))) {
            instance_destroy();
            return;
        }
    }
    var margin = 80;
    if (kind != "star" && (x < global.grid_offset_x-margin || x > global.grid_offset_x+global.grid_cols*global.grid_cell_size_x+margin
        || y < global.grid_offset_y-margin || y > global.grid_offset_y+global.grid_rows*global.grid_cell_size_y+margin)) instance_destroy();
}

function zodiac_return_mouse(_e, _maxhp) {
    var row = _e.grid_row;
    var col = global.grid_cols-1; // 最右方
    var pos = get_world_position_from_grid(col,row);
    var spr = zodiac_sprite("guiyuanma",shape,"effect_land");
    if (global.grid_terrains[row][col].type == "water") spr = zodiac_sprite("guiyuanma",shape,"effect_water");
    // 原老鼠消失，原地变为归元马送回鼠：能力同平民鼠，继承原老鼠50%最大生命，动画由专属对象接管
    with (_e) {
        instance_change(obj_guiyuanma_mouse,true);
        if (spr > -1) {
            sprite_index = spr;
            gy_death_end = min(34,sprite_get_number(sprite_index)-1);
        }
        hp = _maxhp*0.5;
        maxhp = hp;
        hp_modified = true; // 继承的血量已含难度系数，避免开局难度修正二次叠加
        shield_hp = 0;
        shield_max_hp = 0;
        helmet_hp = 0;
        helmet_max_hp = 0;
        feature_type = "normal";
        mouse_id = "normal_mouse";
        move_speed = 0.30; // 与注册表中平民鼠速度一致
        x = pos.x;
        y = pos.y;
        grid_col = col;
        grid_row = row;
        target_type = "normal";
    }
}

function zodiac_revive() {
    zodiac_effect(zodiac_sprite(plant_id,shape,"effect1"),x,y);
    // 0转：复活5×5范围内最近1张被老鼠咬死的卡；1转：不复活，只给范围内卡片加减伤；2转：复活3张（死因不限，铲除除外，同重生神）
    var limit = shape == 0 ? 1 : (shape == 2 ? 3 : 0);
    var mouse_only = shape == 0;
    var done = 0;
    var death_count = variable_global_exists("dead_cards") && ds_exists(global.dead_cards,ds_type_list) ? ds_list_size(global.dead_cards) : 0;
    for (var i = death_count-1; i >= 0 && done < limit; i--) {
        var d = global.dead_cards[| i];
        if (!ds_exists(d,ds_type_map)) continue;
        if (mouse_only) {
            if (d[? "death_cause"] != "mouse") continue;
        } else if (d[? "death_cause"] == "shovel") continue;
        var card_id = d[? "plant_id"];
        if (array_contains(["brahma","baibianshe","magic_chicken","kuileima","xingqiongma"],card_id)) continue;
        var col = d[? "grid_col"], row = d[? "grid_row"];
        if (abs(col-grid_col) > 2 || abs(row-grid_row) > 2) continue;
        var card = deck_get_card_data(card_id,d[? "shape"]);
        if (card == noone || !revive_cell_can_place(col,row,card,card_id)) continue;
        var previous_context = variable_global_exists("random_gift_spawn_context") ? global.random_gift_spawn_context : undefined;
        global.random_gift_spawn_context = {card_id:card_id,shape:d[? "shape"],level:d[? "level"],skill:d[? "skill"]};
        var pos = get_world_position_from_grid(col,row);
        var p = instance_create_depth(pos.x,pos.y,0,card[? "obj"]);
        global.random_gift_spawn_context = previous_context;
        card_created(p,col,row);
        p.depth = calculate_plant_depth(col,row,p.plant_type);
        // 被复活卡片身上播放单体effect1；effect2是种下时的5×5范围特效，不能在复活位置使用
        zodiac_effect(zodiac_sprite(plant_id,shape,"effect1"),pos.x,pos.y);
        ds_list_delete(global.dead_cards,i);
        ds_map_destroy(d);
        done++;
    }
    if (shape == 1) {
        // 1转：5×5范围内卡片获得减伤，减伤时间内抵挡指定次数老鼠攻击（含致命伤）
        for (var gi = 0; gi < instance_number(obj_card_parent); gi++) {
            var gp = instance_find(obj_card_parent,gi);
            if (!instance_exists(gp) || gp.hp <= 0 || gp.id == id
                || abs(gp.grid_col-grid_col) > 2 || abs(gp.grid_row-grid_row) > 2) continue;
            gp.zodiac_guard_time = zodiac_guard_duration;
            gp.zodiac_guard_hits = skill == 8 ? 2 : 1;
            gp.zodiac_guard_hp = gp.hp;
        }
    }
}

function zodiac_card_destroy() {
    if (!variable_instance_exists(id,"zodiac_effects")) return;
    if (variable_instance_exists(id,"zodiac_decoy") && instance_exists(zodiac_decoy)) instance_destroy(zodiac_decoy);
    for (var i = 0; i < array_length(zodiac_effects); i++) if (instance_exists(zodiac_effects[i])) instance_destroy(zodiac_effects[i]);
    // 清理仙笛马停靠中的飞马子弹
    if (variable_instance_exists(id,"zodiac_stored"))
        for (var i = 0; i < array_length(zodiac_stored); i++) if (instance_exists(zodiac_stored[i])) instance_destroy(zodiac_stored[i]);
    // 清理巫蛊蛇残留的蛊毒特效，避免卡片死亡/铲除后继续造成伤害
    for (var i = instance_number(obj_zodiac_effect) - 1; i >= 0; i--) {
        var eff = instance_find(obj_zodiac_effect, i);
        if (instance_exists(eff) && variable_instance_exists(eff, "poison_source") && eff.poison_source == id) {
            instance_destroy(eff);
        }
    }
    if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
    if (!instance_exists(obj_battle) || (variable_global_exists("game_over") && global.game_over)) return;
    var _is_shoveled = variable_instance_exists(id,"is_shoveled") && is_shoveled;
    if (plant_id == "kuileima" && shape >= 1) {
        // 死亡或铲除都播放完整特效动画：形态1用effect2_2，形态2用effect3_1
        var _death_effect = zodiac_effect(shape == 1 ? spr_kuileima_effect2_2 : spr_kuileima_effect3_1,x,y);
        if (instance_exists(_death_effect)) {
            _death_effect.image_index = 0;
            _death_effect.image_speed = 0.5;
        }
        var enemies = zodiac_enemies();
        for (var i = 0; i < array_length(enemies); i++) {
            var e = enemies[i], g = get_grid_position_from_world(e.x,e.y);
            if (abs(g.col-grid_col) <= 2 && abs(g.row-grid_row) <= 2) zodiac_hit(e,900,"ash",true);
        }
    }
    if (_is_shoveled) return;
    if (plant_id == "yufengma" && shape >= 1) {
        var enemies = zodiac_enemies();
        for (var i = 0; i < array_length(enemies); i++) {
            var e = enemies[i];
            if (e.target_type == "air" && !e.is_boss) {
                var effect = instance_create_depth(e.x,e.y,-3000,obj_mouse_blow_effect);
                effect.sprite_index = e.sprite_index;
                effect.image_index = e.image_index;
                effect.image_xscale = e.image_xscale;
                effect.image_yscale = e.image_yscale;
                e.is_blown_away = true;
                instance_destroy(e);
            }
        }
        zodiac_effect(zodiac_sprite(plant_id,shape,"bullet_big"),x,y);
    }
}
