// 出生高度：普通子弹 -30；对空弹按「本行空军敌人的 bbox 中心」对齐（2026-11-06）
//   🔴 原来写死 -128：那是按「空中航母」那种 bbox 在原点上方很高的大体型空军调的，
//      普通体型空军（电鳗鼠 148×98、原点在底部）会差一截打空 → 改成按目标实测对齐。
var _oy = -30;
if (target_t == "air_only"){
    _oy = -60;                                   // 兜底：本行扫不到空军时用半个身位
    with (obj_enemy_parent){
        if (target_type == "air" && grid_row == other.grid_row && hp > 0){
            _oy = ((bbox_top + bbox_bottom) * 0.5) - other.y;
            break;
        }
    }
}
var inst = instance_create_depth(x + 20, y + _oy, depth - 45, obj_donut_bullet);
inst.damage = atk;
inst.move_speed = 6;
inst.row = grid_row;
inst.target_type = target_t;
inst.hittable_types = get_hittable_enemy_types(inst.target_type);
inst.shape = shape;
var spr = spr_donut_bullet;

switch (shape)
{
    case 0:
        spr = spr_donut_bullet;
        break;
    
    case 1:
        spr = spr_donut_bullet_1;
        break;
    
    case 2:
        spr = spr_donut_bullet_2;
        break;
}

inst.sprite_index = spr;
