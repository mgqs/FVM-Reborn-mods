// obj_tunshilong（吞噬龙）Destroy 事件
// 一转起死亡（hp 归零，被老鼠啃死）才炸：起一个 obj_tunshilong_boom 播素材尾部爆炸段 53~62。
//   3×3 灰烬伤害在那个对象里结算（播到「炸开」那一帧才扣），避免本体已经没了伤害才落地。
//   铲除 / 清格不算死亡，不炸。
var _shoveled = variable_instance_exists(id, "is_shoveled") && is_shoveled;

if (shape >= 1 && hp <= 0 && !_shoveled){
    var _boom = instance_create_depth(x, y, depth, obj_tunshilong_boom);
    _boom.sprite_index = sprite_index;
    _boom.grid_row = grid_row;
    _boom.grid_col = grid_col;
}

event_inherited();
