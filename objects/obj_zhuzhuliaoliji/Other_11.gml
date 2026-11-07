// obj_zhuzhuliaoliji 开火（event_user(1)）
// 5 个方向：右下 (±35°)、右上、正下、正上、正后（180°）；**没有正前 0°**
// 2 转的「每方向 2 发」由**卡片隔帧再调一次本事件**实现（隔 burst_gap 帧，见 Step_0），
//   🔴 别再在这一次里造 10 颗、把第二颗冻在枪口等 delay —— 那 5 帧看起来就是一颗刀片卡住不动再突然飞出去。
var _dirs = [
    [-8,  0, 180, 1],   // 正后（背面弹：伤害取 back_atk）
    [ 0,  8,  90, 0],   // 正下
    [ 0, -8, -90, 0],   // 正上
    [ 5, -3, -31, 0],   // 右上
    [ 5,  3,  31, 0]    // 右下
];

for (var _d = 0; _d < 5; _d++){
    var _vx = _dirs[_d][0];
    var _vy = _dirs[_d][1];
    var _ang = point_direction(0, 0, _vx, _vy);   // 朝向按速度算，不再手写角度常量
    var _is_back = _dirs[_d][3];

    var _b = instance_create_depth(x + _vx * 2, y - 45 + _vy * 2, depth - 500, obj_zhuzhuliaoliji_bullet);
    _b.vx = _vx;
    _b.vy = _vy;
    _b.image_angle = _ang;
    // 背向弹：基础值取「背面攻击」表，但要跟着**本体攻击的增幅倍率**一起涨
    //   （五行蛇 five_dir / 丰饶 multi_dir / 香水… 都是改卡片的 atk，不改 back_atk）
    //   → 用 atk / base_atk 当倍率，表值 × 倍率，等价于「背面攻击也吃到五向增幅」
    var _atk_mult = 1;
    if (variable_instance_exists(id, "base_atk") && base_atk > 0) _atk_mult = atk / base_atk;
    _b.damage = _is_back ? round(back_atk * _atk_mult) : atk;
    _b.row = grid_row;
    _b.slow_frames = slow_frames;
    // 过火只给「正后」那一发（_is_back = 1）；其余方向 can_burn 恒 false
    _b.can_burn = (_is_back == 1);
    // 🔴 2026-11-06 修：这里原来每发都补一句 `_b.kind = "star"`（照星星兔抄的），
    //   会把子弹 Create 里「不设 kind、走过火通用判定」的决定又改回去 → 一碰融合火盆就报
    //   「move_y not set」，哪一发都过不了火。刀片没有 kind 这个说法，删掉。
    // 三个形态**共用同一颗子弹精灵**（spr_zhuzhuliaoliji_bullet），不再按形态换图
    // （原有的 _1 / _2 两颗素材已删，别再写回来）。
}
