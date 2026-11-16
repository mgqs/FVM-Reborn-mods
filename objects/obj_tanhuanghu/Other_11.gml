/// 弹簧虎 开火事件：本行直线弹（可越过岩浆/障碍），命中后 3×3 溅射
// 2026-11-17 用户口径：子弹 = **air 类型**（同时打空中 + 陆地），不再做纯对空弹；
//   「优先对空」只体现在**炮口高度**（本行有空军就对到空军身体中心），子弹本身两种都打，
//   所以空军清掉之后同一串子弹仍能打到陆地（下一轮的索敌也会自动转成打地面）
var _hittable = get_hittable_enemy_types("air");

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
_b.target_type    = "air";
_b.hittable_types = _hittable;
_b.splash_ratio   = th_splash_ratio;
_b.splash_cells   = th_splash_cells;

// 1/2 转贴图：Create 时 shape 还没赋（=0），只能建完再换（同雪球兔写法）
if (shape == 1)      _b.sprite_index = spr_tanhuanghu_bullet_1;
else if (shape == 2) _b.sprite_index = spr_tanhuanghu_bullet_2;

audio_play_sound(snd_shot, 0, 0);
