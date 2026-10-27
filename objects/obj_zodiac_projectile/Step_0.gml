if (global.is_paused) exit;

if (stored) {
    // 停靠状态：跟随宿主卡片最右方，从下往上堆叠，不移动不计时不碰撞
    if (!instance_exists(owner_id)) {instance_destroy(); return;}
    x = owner_id.x+34;
    y = owner_id.y-16-park_index*28;
    image_angle = 0;
    exit;
}
timer++;
// 移动保持每帧更新，碰撞按全局间隔执行；候选列表由 SAP 在同一帧复用。
hit_tick++;
if (kind == "star" && variable_global_exists("enemy_sx_n") && variable_global_exists("enemy_sx_gen")
    && global.enemy_sx_gen > 0 && global.enemy_sx_n <= 0) {
    instance_destroy();
    exit;
}
if (timer > (kind == "star" ? 300 : 600)) {instance_destroy();exit;}
var old_x = x, old_y = y;
if (kind == "return" || kind == "flute") {
    if (!instance_exists(target_id) || target_id.hp <= 0) {
        if (kind == "flute") {
            // 仙笛马子弹丢失目标时重新全屏索敌：优先BOSS，其次最高血量
            var fc_list = [];
            for (var fc_i = 0; fc_i < instance_number(obj_enemy_parent); fc_i++) {
                var fc_e = instance_find(obj_enemy_parent,fc_i);
                if (instance_exists(fc_e) && fc_e.hp > 0) array_push(fc_list,fc_e);
            }
            for (var fc_i = 0; fc_i < instance_number(obj_kuileima_decoy); fc_i++) {
                var fc_d = instance_find(obj_kuileima_decoy,fc_i);
                if (instance_exists(fc_d) && fc_d.hp > 0 && !array_contains(fc_list,fc_d)) array_push(fc_list,fc_d);
            }
            target_id = noone;
            for (var fc_i = 0; fc_i < array_length(fc_list); fc_i++) {
                var fc_e = fc_list[fc_i];
                if (!instance_exists(target_id) || (fc_e.is_boss && !target_id.is_boss)
                    || (fc_e.is_boss == target_id.is_boss && fc_e.hp > target_id.hp)) target_id = fc_e;
            }
        }
        if (!instance_exists(target_id) || target_id.hp <= 0) {instance_destroy();exit;}
    }
    var direction_to_target = point_direction(x,y,target_id.x,target_id.y-30);
    move_x = lengthdir_x(10,direction_to_target);
    move_y = lengthdir_y(10,direction_to_target);
    image_angle = direction_to_target;
}
x += move_x;
y += move_y;
// 追踪弹的命中半径较小，保持逐帧判定避免高速转向时穿过目标；直线弹使用统一节流。
var _hit_interval = (kind == "return" || kind == "flute") ? 1
    : (kind == "star" ? 10
    : (variable_global_exists("bullet_hit_interval") ? global.bullet_hit_interval : 2));
var _do_hit = hit_tick >= _hit_interval;
if (_do_hit) hit_tick = 0;
// 星星兔弹数量最多，优先建立一次宽松的 SAP 候选父集；后续普通/空中类型直接复用。
var enemies = _zodiac_candidates;
// 星星兔星弹为全场穿透弹：不做水平距离裁剪，只要场上有敌人就持续飞行索敌，
// 无敌人时由上方 enemy_sx_n<=0 分支销毁，飞出场地由边界判定销毁。
var _can_reach = _do_hit && (kind == "star" || bullet_enemy_reachable(id));
if (kind == "star" && _do_hit && variable_global_exists("enemy_sx_gen") && global.enemy_sx_gen > 0 && !_can_reach) {
    instance_destroy();
    exit;
}
if (_can_reach && kind != "phoenix" && variable_global_exists("enemy_sx") && variable_global_exists("enemy_sx_gen")) {
    var _sap_y_margin = (kind == "star" && variable_global_exists("grid_cell_size_y")) ? global.grid_cell_size_y : 0;
    var _sap_targets = bullet_sap_type_list(id,kind == "star" ? "__all__" : "normal",_sap_y_margin);
    if (kind == "star") enemies = _sap_targets;
    else if (_sap_targets != undefined) enemies = _sap_all;
} else if (_do_hit && !_can_reach) {
    enemies = [];
} else if (_do_hit) {
    // 枚举全场存活老鼠；傀儡马代理在部分版本的父对象枚举中不会返回，显式补入攻击目标列表。
    enemies = [];
    for (var ze_i = 0; ze_i < instance_number(obj_enemy_parent); ze_i++) {
        var ze_e = instance_find(obj_enemy_parent,ze_i);
        if (instance_exists(ze_e) && ze_e.hp > 0) array_push(enemies,ze_e);
    }
    for (var ze_i = 0; ze_i < instance_number(obj_kuileima_decoy); ze_i++) {
        var ze_d = instance_find(obj_kuileima_decoy,ze_i);
        if (instance_exists(ze_d) && ze_d.hp > 0 && !array_contains(enemies,ze_d)) array_push(enemies,ze_d);
    }
}
// 傀儡马代理不一定注册进 enemy_by_type，补回原有目标集合语义；没有代理时不进入扫描。
var _decoy_count = 0;
if (_do_hit) _decoy_count = instance_number(obj_kuileima_decoy);
if (_do_hit && _decoy_count > 0) {
    for (var _di = 0; _di < _decoy_count; _di++) {
        var _decoy = instance_find(obj_kuileima_decoy,_di);
        if (instance_exists(_decoy) && _decoy.hp > 0 && !array_contains(enemies,_decoy)) array_push(enemies,_decoy);
    }
}
// 御风马二转秒杀表只在风弹路径中建立，避免其他投射物每步分配临时数组。
var wind_execute_ids = undefined;
if (kind == "wind") wind_execute_ids = ["glider_mouse","waste_flying_mouse","kamikaze_glider_mouse","flight_barrier_mouse","paratrooper_mouse","machine_bomb_mouse"];
for (var i = 0; i < array_length(enemies); i++) {
    var e = enemies[i];
    if (array_contains(hit_ids,e.id)) continue;
    if (kind == "return" && e.object_index == obj_kuileima_decoy) continue; // 归元马忽略傀儡马，绝不攻击傀儡马代理
    if (e.target_type != "normal" && e.target_type != "air") continue;
    var collision = false;
    if (kind == "phoenix") {
        // 炎凰马只命中已显形陆军，不能命中幽灵、非主流、地下鼠或障碍物
        if (e.target_type != "normal") continue;
        if (vertical) collision = (e.grid_col == cover_a || e.grid_col == cover_b) && abs(e.y-y) < 18;
        else collision = (e.grid_row == cover_a || e.grid_row == cover_b) && abs(e.x-x) < 18;
    } else if (kind == "wind") {
        collision = abs(e.grid_row-center_row) <= rows && abs(e.x-x) < 20;
    } else if (kind == "return" || kind == "flute") {
        collision = e == target_id && point_distance(x,y,e.x,e.y-30) < 16;
    } else if (kind == "star") {
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
            if (shape == 2 && array_contains(wind_execute_ids,e.mouse_id) && !e.is_boss) {
                var wk_dmg = 0;
                if (instance_exists(e)) wk_dmg = e.hp+e.shield_hp+e.helmet_hp;
                with (e) {
                    damage_amount = wk_dmg;
                    damage_type = "true";
                    event_user(0);
                }
            } else {
                var wd_dmg = damage;
                with (e) {
                    damage_amount = wd_dmg;
                    damage_type = "pierce";
                    event_user(0);
                }
                if (!e.is_boss) e.x += global.grid_cell_size_x*0.5;
            }
            break;
        case "fire":
            {
                var fd_dmg = damage;
                with (e) {
                    damage_amount = fd_dmg;
                    damage_type = "normal";
                    event_user(0);
                }
                // 以子弹当前飞行方向为基准分裂：0°、±90°共3发；shape2追加±45°共5发
                // 过火盆等卡片只强化伤害，kind 不变，因此强化后的子弹依旧会分裂
                var base_angle = point_direction(0,0,move_x,move_y);
                var angles = shape == 2 ? [0,90,-90,45,-45] : [0,90,-90];
                var wave_damage = base_damage*(shape == 0 ? 1 : 1.5);
                var hit_col = e.grid_col;
                var hit_row = e.grid_row;
                var wave_spr = spr_fenjima_bullet;
                if (shape == 1) wave_spr = spr_fenjima_bullet_1;
                else if (shape >= 2) wave_spr = spr_fenjima_bullet_2;
                for (var a = 0; a < array_length(angles); a++) {
                    var wb = instance_create_depth(e.x,e.y-30,-2500,obj_zodiac_projectile);
                    wb.kind = "wave";
                    wb.damage = wave_damage;
                    wb.base_damage = wave_damage;
                    wb.shape = shape;
                    wb.target_id = noone;
                    wb.move_x = lengthdir_x(8,base_angle+angles[a]);
                    wb.move_y = lengthdir_y(8,base_angle+angles[a]);
                    wb.image_angle = base_angle+angles[a];
                    wb.sprite_index = wave_spr;
                    wb.can_dandantu_store = false;
                    wb.damage_type = "pierce";
                    for (var j = 0; j < array_length(enemies); j++) {
                        var cell_enemy = enemies[j];
                        if (!instance_exists(cell_enemy) || cell_enemy.target_type != "normal") continue;
                        if (cell_enemy.grid_col == hit_col && cell_enemy.grid_row == hit_row) {
                            var wc_dmg = wave_damage;
                            with (cell_enemy) {
                                damage_amount = wc_dmg;
                                damage_type = "pierce";
                                event_user(0);
                            }
                            array_push(wb.hit_ids,cell_enemy.id);
                        }
                    }
                }
                instance_destroy();exit;
            }
        case "return":
            var gy_returned = e.object_index == obj_guiyuanma_mouse; // 呆呆鼠：归元马子弹只会扣血，不再触发秒杀或送回变身
            if (!gy_returned && !e.is_boss && e.hp/e.maxhp < (shape == 0 ? 0.30 : 0.50)) {
                var rk_dmg = 0;
                if (instance_exists(e)) rk_dmg = e.hp+e.shield_hp+e.helmet_hp;
                with (e) {
                    damage_amount = rk_dmg;
                    damage_type = "true";
                    event_user(0);
                }
            } else {
                var original_hp = e.maxhp;
                var rd_dmg = damage;
                with (e) {
                    damage_amount = rd_dmg;
                    damage_type = "pierce";
                    event_user(0);
                }
                // 送回目标必须有真实可用的网格行：空中单位（target_type=="air"）常常飞在场地网格上方，
                // grid_row 会算成 -1；刚创建、本帧还没跑过 Step 的敌人 grid_row 是占位值 99。
                // 这两种值直接拿去当 grid_terrains 下标会越界崩溃（Variable Index [-1] out of range [7]），
                // 因此空中单位只结算伤害不做送回收容。
                var rm_row = e.grid_row;
                var rm_col = global.grid_cols-1;
                var rm_rows_n = array_length(global.grid_terrains);
                var rm_row_ok = (rm_rows_n > 0) && (rm_row >= 0) && (rm_row < rm_rows_n);
                if (rm_row_ok) rm_row_ok = (rm_col >= 0) && (rm_col < array_length(global.grid_terrains[rm_row]));
                if (!gy_returned && rm_row_ok && e.target_type == "normal"
                    && instance_exists(e) && e.hp > 0 && !e.is_boss) {
                    // 送回第9列变为归元马呆呆鼠：仅非BOSS敌人才会变身，能力同平民鼠，继承原老鼠50%最大生命，动画由专属对象接管
                    var rm_pos = get_world_position_from_grid(rm_col,rm_row);
                    var rm_spr = spr_guiyuanma_effect_land;
                    if (shape == 1) rm_spr = spr_guiyuanma_effect_land_1;
                    else if (shape >= 2) rm_spr = spr_guiyuanma_effect_land_2;
                    if (global.grid_terrains[rm_row][rm_col].type == "water") {
                        rm_spr = spr_guiyuanma_effect_water;
                        if (shape == 1) rm_spr = spr_guiyuanma_effect_water_1;
                        else if (shape >= 2) rm_spr = spr_guiyuanma_effect_water_2;
                    }
                    with (e) {
                        if (is_boss) exit; // 双重保险：BOSS绝不触发变身
                        instance_change(obj_guiyuanma_mouse,true);
                        if (rm_spr > -1) {
                            sprite_index = rm_spr;
                            gy_death_end = min(34,sprite_get_number(sprite_index)-1);
                        }
                        hp = original_hp*0.5;
                        maxhp = hp;
                        hp_modified = true; // 继承的血量已含难度系数，避免开局难度修正二次叠加
                        shield_hp = 0;
                        shield_max_hp = 0;
                        helmet_hp = 0;
                        helmet_max_hp = 0;
                        feature_type = "normal";
                        mouse_id = "normal_mouse";
                        move_speed = 0.30; // 与注册表中平民鼠速度一致
                        x = rm_pos.x;
                        y = rm_pos.y;
                        grid_col = rm_col;
                        grid_row = rm_row;
                        target_type = "normal";
                    }
                }
            }
            instance_destroy();exit;
        case "flute":
            {
                // BOSS判定：is_boss标记优先；未打标记的BOSS类敌人（如测试鼠）回退到BOSS注册表比对mouse_id
                var fl_boss = e.is_boss || (variable_global_exists("boss_list") && ds_exists(global.boss_list, ds_type_map)
                    && variable_instance_exists(e, "mouse_id") && ds_map_exists(global.boss_list, e.mouse_id));
                var fl_dmg = damage*(shape >= 1 && fl_boss ? 2.1 : 1);
                with (e) {
                    damage_amount = fl_dmg;
                    damage_type = "pierce";
                    event_user(0);
                }
                instance_destroy();exit;
            }
        case "star":
            {
                var st_dmg = damage;
                with (e) {
                    damage_amount = st_dmg;
                    damage_type = "pierce";
                    event_user(0);
                }
                // 星弹为穿透弹，命中后继续飞行，靠 hit_ids 防止重复伤害同一目标。
                break;
            }
        case "phoenix":
            {
                var ph_dmg = damage*(vertical && e.grid_col == 7 ? 2 : 1);
                var ph_ash = shape == 2;
                with (e) {
                    damage_amount = ph_dmg;
                    damage_type = "pierce";
                    event_user(0);
                    if (ph_ash && hp <= 0 && !immune_to_ash) {
                        ash_death = true;
                        // 二转炎凰马击杀时跳过老鼠普通死亡动画，直接播放灰烬特效。
                        if (special_ash) {
                            var ash_inst = instance_create_depth(x,y-20,depth,obj_mouse_ash_death);
                            ash_inst.special_ash = true;
                            ash_inst.sprite_index = sprite_index;
                            ash_inst.image_index = image_index;
                        } else {
                            instance_create_depth(x,y-20,depth,obj_mouse_ash_death);
                        }
                        instance_destroy();
                    }
                }
                break;
            }
        default:
            {
                var df_dmg = damage;
                with (e) {
                    damage_amount = df_dmg;
                    damage_type = "pierce";
                    event_user(0);
                }
                break;
            }
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
        exit;
    }
}
var margin = 80;
if (x < global.grid_offset_x-margin || x > global.grid_offset_x+global.grid_cols*global.grid_cell_size_x+margin
    || y < global.grid_offset_y-margin || y > global.grid_offset_y+global.grid_rows*global.grid_cell_size_y+margin) instance_destroy();
