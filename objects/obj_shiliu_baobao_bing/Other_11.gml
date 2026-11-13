// 石榴爆爆冰 —— 引爆结算（User Event 1）
// 数据表口径（数据信息.xlsx A47）：
//   3*3 / 3*3 / 5*5 [攻击力] 灰烬爆炸，死亡碎冰效果；未死亡附加冰冻减速
//   对 5*5 / 7*7 / 7*7 范围最近 2 / 2 / 4 个陆、地目标造成 [攻击力] 伤害碾压
//
// 实现要点：
//   * 灰烬爆炸直接用 damage_type = "ash"（无视护盾直接扣血，见 obj_enemy_parent/Other_10）；
//     不防爆的非 BOSS 当场清场 → 生成碎冰 obj_mouse_ash_death（覆写 spr_shiliu_ash_effect）；
//     防爆/BOSS 只吃这一份伤害，不走秒杀；
//   * 碾压只结算「爆炸没打到」的陆、地目标，避免同一只敌人吃两次全额伤害；
//   * 冰冻 4s = frozen_timer 240、减速 20s = ice_timer 1200（沿用 obj_enemy_parent 现成口径）；
//   * 冰晶迸发用 obj_shiliu_freeze_burst（spr_shiliu_freeze_effect 6 帧）；
//     不改 enemies 的 ice_sprite —— 那是 157x124，与 spr_mouse_frozen 161x143 尺寸不同，换图会错位。
var _ccol = grid_col;
var _crow = grid_row;
var _atk = atk;
var _expl = explode_radius;
var _crush_r = crush_radius;
var _crush_n = crush_count;
var _freeze = freeze_ticks;
var _slow = slow_ticks;
var _tgt = target_type;

var _hit = ds_list_create();
var _br = -1;
var _fx = -1;
var _br2 = -1;
var _fx2 = -1;

// ========== 灰烬爆炸（3*3 / 3*3 / 5*5）==========
with (obj_enemy_parent) {
    if (hp > 0 && can_hit_ash(_tgt, target_type)) {
        if (abs(grid_col - _ccol) <= _expl && abs(grid_row - _crow) <= _expl) {
            damage_amount = _atk;
            damage_type = "ash";
            event_user(0);
            ds_list_add(_hit, id);

            // 冰晶迸发（命中即播，死活都一样）
            _br = instance_create_depth(x, y - 40, depth - 1, obj_shiliu_freeze_burst);
            _br.image_xscale = 1.5;
            _br.image_yscale = 1.5;

            if (hp > 0) {
                // 未死亡：附加冰冻 + 减速
                if (frozen_timer < _freeze) frozen_timer = _freeze;
                if (ice_timer < _slow) ice_timer = _slow;
            }
            else {
                // 死亡碎冰
                _fx = instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                _fx.sprite_index = spr_shiliu_ash_effect;
                _fx.image_speed = 0;
                _fx.image_xscale = 1.8;
                _fx.image_yscale = 1.8;
                instance_destroy();
            }
        }
    }
}

// ========== 碾压：范围内最近的 2 / 2 / 4 个陆、地目标 ==========
var _cands = [];
with (obj_enemy_parent) {
    if (hp > 0 && can_hit_ash(_tgt, target_type)) {
        // 陆、地目标：normal / diver / obstacle / underground / invisible（排除空中与腾空）
        if (target_type == "normal" || target_type == "diver" || target_type == "obstacle"
            || target_type == "underground" || target_type == "invisible") {
            if (abs(grid_col - _ccol) <= _crush_r && abs(grid_row - _crow) <= _crush_r) {
                if (ds_list_find_index(_hit, id) == -1) {
                    array_push(_cands, { inst: id, dist: point_distance(x, y, other.x, other.y) });
                }
            }
        }
    }
}

// 选择排序取最近 _crush_n 个（不依赖 array_sort 的比较器）
var _n = array_length(_cands);
var _i = 0;
var _j = 0;
var _mi = 0;
var _tmp = 0;
for (_i = 0; _i < _n; _i++) {
    _mi = _i;
    for (_j = _i + 1; _j < _n; _j++) {
        if (_cands[_j].dist < _cands[_mi].dist) _mi = _j;
    }
    if (_mi != _i) {
        _tmp = _cands[_i];
        _cands[_i] = _cands[_mi];
        _cands[_mi] = _tmp;
    }
}

var _cnt = min(_crush_n, _n);
var _k = 0;
var _e = noone;
for (_k = 0; _k < _cnt; _k++) {
    _e = _cands[_k].inst;
    if (instance_exists(_e) && _e.hp > 0) {
        with (_e) {
            damage_amount = _atk;
            damage_type = "ash";
            event_user(0);

            _br2 = instance_create_depth(x, y - 40, depth - 1, obj_shiliu_freeze_burst);
            _br2.image_xscale = 1.5;
            _br2.image_yscale = 1.5;

            if (hp > 0) {
                if (frozen_timer < _freeze) frozen_timer = _freeze;
                if (ice_timer < _slow) ice_timer = _slow;
            }
            else {
                _fx2 = instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                _fx2.sprite_index = spr_shiliu_ash_effect;
                _fx2.image_speed = 0;
                _fx2.image_xscale = 1.8;
                _fx2.image_yscale = 1.8;
                instance_destroy();
            }
        }
    }
}

ds_list_destroy(_hit);

// ========== 表现 ==========
global.audio.play(snd_coke_bomb_explode, 0, false);
if global.screen_shake {
    Camera_Shock(5, 20);
}

// 标记已引爆；销毁时机交给 Step_0（等爆炸帧播完）
triggered = true;
