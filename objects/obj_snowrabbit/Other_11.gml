/// 雪球兔 开火事件：挑最靠前的 N 个目标，各砸一颗雪球
///   1 转起「集火」：目标不够攻击上限时，多余的雪球全部堆到**主目标**上（冷萃机 2 转同款）
///   一颗雪球对一个目标；集火时会有多颗砸同一只
var _list = ds_priority_create();
// ⚠️ 主目标要用**实例变量**：`with` 里读不到调用方的 var（交接 坑 12）
sr_main       = noone;        // 主目标（BOSS 优先，其次最靠前）
sr_main_score = 999999;

with (obj_enemy_parent){
    // ⚠️ 这里必须是 continue：GML 里 with 内写 exit 会直接跳出整个事件，
    //    第一只老鼠不合格就一个目标都选不出来（2026-11-13 修）
    if (hp <= 0) continue;
    if (target_type == "obstacle") continue;
    if (!can_target_on(other.target_type, target_type)) continue;
    // 越靠前（grid_col 越小）越优先，BOSS 加权
    var _score = grid_col * 1000 + random(99);
    if (is_boss) _score -= 100000;
    ds_priority_add(_list, id, _score);
    if (_score < other.sr_main_score){
        other.sr_main_score = _score;
        other.sr_main       = id;
    }
}

// ── 组发射列表 ──
//   1 转起（shape >= 1）：雪球数固定 = 攻击上限（5 / 8），目标不够就把剩下的堆给主目标
//   0 转：有几个目标打几颗（不集火）
var _targets = [];
var _have    = ds_priority_size(_list);
var _n       = min(sr_target_max, _have);

for (var _i = 0; _i < _n; _i++){
    array_push(_targets, ds_priority_delete_min(_list));
}

if (shape >= 1 && _have > 0 && _have < sr_target_max && instance_exists(sr_main)){
    var _extra = sr_target_max - _have;
    for (var _k = 0; _k < _extra; _k++){
        array_push(_targets, sr_main);    // 集火：多余的雪球砸同一只
    }
}

for (var _j = 0; _j < array_length(_targets); _j++){
    var _t = _targets[_j];
    if (!instance_exists(_t)) continue;

    // 2026-11-13：直接生在目标脚底 —— 精灵 spr_snowrabbit_bullet 自带「从天而降 → 砸中 → 碎冰」动画
    //   （旧版从卡片位置斜飞，会在半路撞到别的小老鼠，看着就是「天上冒一下老鼠就掉血」）
    var _bx = _t.x;
    var _by = _t.y;
    var _b = instance_create_depth(_bx, _by, depth - 500, obj_snowrabbit_bullet);
    // 2026-11-13：同类加成已经折进 base_atk（→ atk），这里直接用 atk，别再乘一次
    _b.damage         = round(atk);
    _b.base_atk       = atk;
    _b.shape          = shape;
    _b.row            = _t.grid_row;
    _b.target_type    = target_type;
    _b.hittable_types = get_hittable_enemy_types(target_type);
    _b.target_id      = _t.id;
    _b.tx             = _t.x;
    _b.ty             = _t.y;
    _b.splash_ratio   = sr_splash_ratio;
    _b.splash_cells   = sr_splash_cells;
    _b.move_speed     = 14;
    _b.fall_delay     = 0;          // 2026-11-13 用户口径：同时落下，不要依次错帧（同冷萃机）
    _b.start_y        = _by;

    // 三形态共用同一张冰球（_1/_2 与本体相同，2026-11-13 已删）
    _b.sprite_index = spr_snowrabbit_bullet;
}

ds_priority_destroy(_list);

audio_play_sound(snd_shot, 0, 0);
