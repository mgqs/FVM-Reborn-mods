// obj_caihongshe Destroy：1 转 3×3 灰烬 900 / 2 转 5×5 灰烬 900（0 转不炸）
// 2026-11-06：护罩泡泡已停用（那套帧其实是死亡特效），shield_obj 恒为 noone，不用再销毁
// 2026-11-07：条件从「hp <= 0」改成「只要不是铲除就炸」—— 战神齿轮 / 木鸭木轮 / 滚木、
//   洞君、阿诺这类都是满血直接 instance_destroy()，按 hp <= 0 判会整片不炸。
var _shoveled = variable_instance_exists(id, "is_shoveled") && is_shoveled;

if (shape >= 1 && !_shoveled){
    // 🔴 2026-11-06 补爆炸特效：素材第 65~71 帧（炸开那 7 帧）单独做成了
    //    spr_caihongshe_shield / _1 / _2，之前当「护罩」用错了地方，现在拿来当死亡爆炸。
    //    3×3 放大 1.6 倍（≈320px ≈ 3 格）、5×5 放大 1.3 倍（≈530px ≈ 5 格）
    var _fx = instance_create_depth(x, y - 45, depth - 20, obj_caihongshe_shield);
    _fx.standalone = true;
    _fx.parent_plant = noone;
    if (shape == 1)      _fx.sprite_index = spr_caihongshe_shield_1;
    else if (shape >= 2) _fx.sprite_index = spr_caihongshe_shield_2;
    var _fs2 = (shape >= 2) ? 1.3 : 1.6;
    _fx.image_xscale = _fs2;
    _fx.image_yscale = _fs2;

    var _r = (shape >= 2) ? 2 : 1;
    with (obj_enemy_parent){
        if (hp > 0 && abs(grid_row - other.grid_row) <= _r && abs(grid_col - other.grid_col) <= _r){
            hp -= other.boom_damage;
            event_user(0);
        }
    }
}
event_inherited();
