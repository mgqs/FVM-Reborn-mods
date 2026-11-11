/// 雪球兔 开火事件：挑最靠前的 N 个目标，各砸一颗雪球
///   目标不足 N 时按实际数量发；一颗雪球对一个目标
var _list = ds_priority_create();

with (obj_enemy_parent){
    if (hp <= 0) exit;
    if (target_type == "obstacle") exit;
    if (!can_target_on(other.target_type, target_type)) exit;
    // 越靠前（grid_col 越小）越优先，BOSS 加权
    var _score = grid_col * 1000 + random(99);
    if (is_boss) _score -= 100000;
    ds_priority_add(_list, id, _score);
}

var _n = min(sr_target_max, ds_priority_size(_list));

for (var _i = 0; _i < _n; _i++){
    var _t = ds_priority_delete_min(_list);
    if (!instance_exists(_t)) continue;

    var _bx = x;
    var _by = y - sr_art_up;
    var _b = instance_create_depth(_bx, _by, depth - 500, obj_snowrabbit_bullet);
    _b.damage         = round(atk * sr_atk_mult);
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
    _b.fall_delay     = _i * 4;      // 错帧下落
    _b.start_y        = _by;

    // 按 shape 换图
    if (shape == 1)      _b.sprite_index = spr_snowrabbit_bullet_1;
    else if (shape == 2) _b.sprite_index = spr_snowrabbit_bullet_2;
    else                 _b.sprite_index = spr_snowrabbit_bullet;
}

ds_priority_destroy(_list);

audio_play_sound(snd_shot, 0, 0);
