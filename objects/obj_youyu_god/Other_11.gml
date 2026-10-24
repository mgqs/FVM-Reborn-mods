// 开火：按形态换「方向表」发射，同一方向错帧连发（delay = 0 / 4 / 8）
// shape0：8 个方向各 2 发（0 / ±45 / 90 / 135 / 180 / 225 / 270 / 315）—— 共 16 发
// shape1：中路（0°/180°）各追加 1 发 —— 共 18 发，且只有中路子弹可被火盆 / 火神 / 金牛增幅
// shape2：前方两条斜线 ±45° 拆成 ±30° / ±60°（前方 4 路），其余不变 —— 共 22 发
//   - 方向表与索敌脚本 Step_0.gml 必须同源
//   - 只有中路（0°/180°）子弹会置 can_burn（同一行才算过火，见三份 Collision）

// 只打陆地鼠（无对空 / 幽灵能力）
var _hittable = ["normal"];

var _bullet_spr = spr_youyu_god_bullet;
if (shape == 1) _bullet_spr = spr_youyu_god_bullet_1;
else if (shape >= 2) _bullet_spr = spr_youyu_god_bullet_2;

var _my_row = 0;
if (variable_instance_exists(self, "grid_row")) _my_row = grid_row;

// 弹口 = 鱿鱼本体中心（精灵 96×86、origin(52,77)、战斗内由父对象按 1.8 倍绘制）
// 实测口径：环心 ≈ (x+7, y-44)，与海星那族 (x, y-45) 同级；八方向相对本体对称
var _muzzle_x = x + 7;
var _muzzle_y = y - 44;

var _volley_delay = 4;

// ===== 方向表：shape2 起 ±45° → ±30° / ±60° =====
var _angles = (shape >= 2)
    ? [0, 30, 60, 90, 135, 180, 225, 270, 300, 330]
    : [0, 45, 90, 135, 180, 225, 270, 315];

for (var _a = 0; _a < array_length(_angles); _a++)
{
    var _angle = _angles[_a];
    var _is_center = (_angle == 0 || _angle == 180);
    var _shots = 2 + ((_is_center && shape >= 1) ? 1 : 0);

    for (var _v = 0; _v < _shots; _v++)
    {
        var _b = instance_create_depth(_muzzle_x, _muzzle_y, depth - 20, obj_youyu_god_bullet);
        _b.damage = atk;
        _b.base_atk = atk;
        _b.shape = shape;
        _b.target_id = noone;
        _b.hittable_types = _hittable;
        _b.move_x = lengthdir_x(_b.move_speed, _angle);
        _b.move_y = lengthdir_y(_b.move_speed, _angle);
        _b.image_angle = _angle;
        _b.sprite_index = _bullet_spr;
        _b.row = _my_row;
        _b.delay = _v * _volley_delay;
        _b.can_burn = (_is_center && shape >= 1);
    }
}

audio_play_sound(snd_shot, 0, 0);
