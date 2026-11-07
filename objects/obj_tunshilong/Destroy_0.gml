// obj_tunshilong（吞噬龙）Destroy 事件
// 一转起死亡才炸：起一个 obj_tunshilong_boom 播素材尾部爆炸段 53~62。
//   3×3 灰烬伤害在那个对象里结算（播到「炸开」那一帧才扣），避免本体已经没了伤害才落地。
// 2026-11-07：条件从「hp <= 0」改成「只要不是铲除就炸」—— 战神齿轮 / 木鸭木轮 / 滚木、
//   洞君、阿诺这类都是**满血直接 instance_destroy()**，按 hp <= 0 判会整片不炸（处女座能炸就是因为没这个判断）。
//   铲除 / 龙渊偷卡（都会置 is_shoveled）仍然不炸，避免拿铲子刷伤害。
var _shoveled = variable_instance_exists(id, "is_shoveled") && is_shoveled;

if (shape >= 1 && !_shoveled){
    var _boom = instance_create_depth(x, y, depth, obj_tunshilong_boom);
    _boom.sprite_index = sprite_index;
    _boom.grid_row = grid_row;
    _boom.grid_col = grid_col;
}

event_inherited();
