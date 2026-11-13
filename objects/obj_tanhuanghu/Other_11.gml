/// 弹簧虎 开火事件：本行直线弹（穿透，可越过岩浆/障碍），命中后溅射
// 命中桶：**这一发打谁就只认谁**（2026-11-13 用户口径：空地区分，同多拿滋）
//   本行有空军 → 这一发是「对空弹」，只打 air，路过地面老鼠不打
//   本行没空军 → 「对地弹」，只打 normal + obstacle，路过空军不打
var _air_volley = (th_target_t == "air_only");
var _hittable = _air_volley ? ["air"] : ["normal", "obstacle"];

// 出弹点：优先空军时按本行空军**身体 bbox 中心**对齐（同多拿滋 2026-11-06 写法）
//   固定 y-26 永远够不到空军，表现就是「索敌了但打不中」
var _oy = th_art_up;
if (th_target_t == "air_only"){
    _oy = th_air_muzzle_dy;
    with (obj_enemy_parent){
        if (target_type == "air" && grid_row == other.grid_row && hp > 0){
            _oy = ((bbox_top + bbox_bottom) * 0.5) - other.y;
            break;
        }
    }
}

var _b = instance_create_depth(x + th_muzzle_x, y + _oy, depth - 500, obj_tanhuanghu_bullet);
_b.damage         = atk;
_b.base_atk       = atk;
_b.move_speed     = 11;
_b.shape          = shape;
_b.row            = grid_row;
_b.target_type    = th_target_t;
_b.hittable_types = _hittable;
_b.is_air_volley  = _air_volley;
_b.splash_ratio   = th_splash_ratio;
_b.splash_cells   = th_splash_cells;

// 1/2 转贴图：Create 时 shape 还没赋（=0），只能建完再换（同雪球兔写法）
if (shape == 1)      _b.sprite_index = spr_tanhuanghu_bullet_1;
else if (shape == 2) _b.sprite_index = spr_tanhuanghu_bullet_2;

audio_play_sound(snd_shot, 0, 0);
