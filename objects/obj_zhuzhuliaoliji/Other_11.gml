// obj_zhuzhuliaoliji 开火（event_user(1)）
// 5 个方向：右下 (±35°)、右上、正下、正上、正后（180°）；**没有正前 0°**
// 二转每方向 2 发、第二发延后 5 帧（子弹自己的 delay 字段）
var _dirs = [
    [-8,  0, 180, 1],   // 正后（背面弹：伤害取 back_atk）
    [ 0,  8,  90, 0],   // 正下
    [ 0, -8, -90, 0],   // 正上
    [ 5, -3, -31, 0],   // 右上
    [ 5,  3,  31, 0]    // 右下
];
var _shots = (shape >= 2) ? 2 : 1;

for (var _d = 0; _d < 5; _d++){
    var _vx = _dirs[_d][0];
    var _vy = _dirs[_d][1];
    var _ang = _dirs[_d][2];
    var _is_back = _dirs[_d][3];

    for (var _k = 0; _k < _shots; _k++){
        var _b = instance_create_depth(x + _vx * 2, y - 45 + _vy * 2, depth - 500, obj_zhuzhuliaoliji_bullet);
        _b.vx = _vx;
        _b.vy = _vy;
        _b.image_angle = _ang;
        _b.damage = _is_back ? back_atk : atk;
        _b.row = grid_row;
        _b.slow_frames = slow_frames;
        _b.delay = _k * 5;
        // 过火只给「正后」那一发（_is_back = 1）；其余方向 can_burn 恒 false
        _b.can_burn = (_is_back == 1);
        // 🔴 2026-11-06 修：这里原来每发都补一句 `_b.kind = "star"`（照星星兔抄的），
        //   会把子弹 Create 里「不设 kind、走过火通用判定」的决定又改回去 → 一碰融合火盆就报
        //   「move_y not set」，哪一发都过不了火。刀片没有 kind 这个说法，删掉。
        // 三个形态**共用同一颗子弹精灵**（spr_zhuzhuliaoliji_bullet），不再按形态换图
        // （原有的 _1 / _2 两颗素材已删，别再写回来）。
    }
}
