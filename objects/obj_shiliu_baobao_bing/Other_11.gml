// 石榴爆爆冰 —— 引爆（User Event 1）
// 机制（2026-11-13 用户口径）：
//   范围内有老鼠 → 生长 → 爆炸 → 对范围内每只目标各投一颗石榴籽（spr_shiliu_bullet_*）
//   → 籽落地时结算碾压伤害 → 活着的：冰冻 + 减速 + 冰晶迸发；死的：**只播** spr_shiliu_ash_effect
//
// 伤害由籽在落地帧结算（obj_shiliu_bullet/Step_0），不在这里直接扣：
// 籽从画布顶部落到底要 3 帧（≈9 tick），先扣血再让籽慢慢掉，和「子弹砸死」的观感是矛盾的。
//
// 目标分两批，同一只只算一次：
//   ① 爆炸范围 3*3 / 3*3 / 5*5 内**所有**可打目标 → 全额伤害 + 冰冻减速
//   ② 碾压范围 5*5 / 7*7 / 7*7 内最近的 2 / 2 / 4 个陆、地目标 → 全额伤害（不附加冰冻）
//
// 沿用口径：冰冻 4s = frozen_timer 240、减速 20s = ice_timer 1200（见 obj_enemy_parent）；
// 冰晶迸发用 obj_shiliu_freeze_burst（spr_shiliu_freeze_effect 6 帧），
// 不改 enemies 的 ice_sprite —— 那是 157x124，与 spr_mouse_frozen 161x143 尺寸不同，换图会错位。
var _ccol = grid_col;
var _crow = grid_row;
var _atk = atk;
var _expl = explode_radius;
var _crush_r = crush_radius;
var _crush_n = crush_count;
var _freeze = freeze_ticks;
var _slow = slow_ticks;
var _tgt = target_type;

// 子弹精灵跟着形态走（三个形态各一套 12 帧籽）
var _bspr = spr_shiliu_bullet_0;
if (shape == 1)      _bspr = spr_shiliu_bullet_1;
else if (shape >= 2) _bspr = spr_shiliu_bullet_2;

var _targets = [];            // { inst, freeze }
var _used = ds_list_create();

// ========== ① 爆炸范围内所有可打目标 ==========
with (obj_enemy_parent) {
    if (hp > 0 && can_hit_ash(_tgt, target_type)
        && abs(grid_col - _ccol) <= _expl && abs(grid_row - _crow) <= _expl) {
        array_push(_targets, { inst: id, freeze: true });
        ds_list_add(_used, id);
    }
}

// ========== ② 碾压范围：最近的 _crush_n 个陆、地目标 ==========
var _cands = [];
with (obj_enemy_parent) {
    if (hp > 0 && can_hit_ash(_tgt, target_type)) {
        // 陆、地目标：normal / diver / obstacle / underground / invisible（排除空中与腾空）
        if (target_type == "normal" || target_type == "diver" || target_type == "obstacle"
            || target_type == "underground" || target_type == "invisible") {
            if (abs(grid_col - _ccol) <= _crush_r && abs(grid_row - _crow) <= _crush_r) {
                if (ds_list_find_index(_used, id) == -1) {
                    array_push(_cands, { inst: id, dist: point_distance(x, y, other.x, other.y) });
                }
            }
        }
    }
}

// 选择排序取最近 _crush_n 个（不依赖 array_sort 的比较器）
var _n  = array_length(_cands);
var _i  = 0;
var _j  = 0;
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
for (_i = 0; _i < _cnt; _i++) {
    array_push(_targets, { inst: _cands[_i].inst, freeze: false });
}

ds_list_destroy(_used);

// ========== ③ 每只目标投一颗籽 ==========
var _tnum = array_length(_targets);
for (_i = 0; _i < _tnum; _i++) {
    var _e = _targets[_i].inst;
    if (!instance_exists(_e) || _e.hp <= 0) continue;

    var _b = instance_create_depth(_e.x, _e.y - 18, _e.depth - 1, obj_shiliu_bullet);
    _b.sprite_index       = _bspr;
    _b.image_index        = 0;
    _b.target_inst        = _e;
    _b.damage_value       = _atk;
    _b.apply_freeze       = _targets[_i].freeze;
    _b.freeze_ticks       = _freeze;
    _b.slow_ticks         = _slow;
    _b.caster_target_type = _tgt;
    // 多颗籽错开起播，避免同一帧整齐砸下（纯表现，负值 = 延迟若干 tick）
    _b.frame_timer        = -(_i * 2);
}

// ========== 表现 ==========
global.audio.play(snd_coke_bomb_explode, 0, false);
if global.screen_shake {
    Camera_Shock(5, 20);
}

// 标记已引爆；销毁时机交给 Step_0（等爆炸帧播完）
triggered = true;
