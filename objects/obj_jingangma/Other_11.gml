/// 金刚马 开火事件（用户事件 1）
/// 全屏索敌「最远目标」= x 最大的那只，发射追踪穿透音波
var _hittable = get_hittable_enemy_types(target_type);
var _target   = noone;
var _best_x   = -999999;

if (variable_global_exists("enemy_by_type")){
    for (var _t = 0; _t < array_length(_hittable); _t++){
        var _key = _hittable[_t];
        if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
        var _arr = global.enemy_by_type[$ _key];
        for (var _i = 0; _i < array_length(_arr); _i++){
            var _e = _arr[_i];
            if (!instance_exists(_e)) continue;
            if (_e.hp <= 0) continue;
            if (_key == "underground" && !is_digging_dijing(_e)) continue;
            if (_e.x > _best_x){
                _best_x = _e.x;
                _target = _e;
            }
        }
    }
}

if (_target == noone) exit;

var _bx = x + 40;
var _by = y + jg_art_up;

var _b = instance_create_depth(_bx, _by, depth - 500, obj_jingangma_bullet);
_b.damage         = atk;
_b.base_atk       = atk;
_b.shape          = shape;
_b.row            = grid_row;
_b.target_id      = _target.id;
_b.hittable_types = jg_hittable;
_b.stun_chance    = jg_stun_chance;
_b.stun_frames    = jg_stun_frames;
_b.kill_normal    = jg_kill_normal;

// 1/2 转贴图：Create 时 shape 还没赋（=0），只能建完再换（同雪球兔写法）
if (shape == 1)      _b.sprite_index = spr_jingangma_bullet_1;
else if (shape == 2) _b.sprite_index = spr_jingangma_bullet_2;

// 初始朝向目标
var _dx = _target.x - _bx;
var _dy = (_target.y - 30) - _by;
var _len = point_distance(0, 0, _dx, _dy);
if (_len > 0.001){
    _b.move_x = (_dx / _len) * _b.move_speed;
    _b.move_y = (_dy / _len) * _b.move_speed;
    _b.image_angle = point_direction(0, 0, _b.move_x, _b.move_y);
}

audio_play_sound(snd_shot, 0, 0);
