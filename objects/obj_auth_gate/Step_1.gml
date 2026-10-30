/// 模态输入拦截 —— 必须放在 Begin Step（不能放 Step）
///
/// GML 一帧内的事件顺序是：
///     Begin Step → 键盘 → 鼠标事件 → 各对象 Step → Draw
/// Mouse 事件会发给**所有**实例，全屏遮罩根本不消费点击，所以「画一层黑的盖住」
/// 挡不住任何人。而工程里有 76 个对象用 Mouse 事件做按钮、19 个对象在 Step 里
/// 自己轮询 mouse_check_button_pressed()，逐个加判断既改不完也容易漏——漏一个
/// 就等于没锁。
///
/// 这里换个思路：在最早的时刻把「落在面板外」的按键状态抹掉。
/// 之后不管底层用 Mouse 事件还是轮询函数，读到的都是「没按下」，自然全部失效。
/// 只抹鼠标、不动键盘——输入框在本层，键盘必须照常工作。
///
/// 注意判定范围是**面板矩形**，不是全屏：点在面板内的要放行，否则自己的
/// 输入框和按钮也会失灵。
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

var _inside = point_in_rectangle(_mx, _my,
    panel_x, panel_y, panel_x + panel_w, panel_y + panel_h);

if (!_inside) {
    // mb_any：一次清掉左右中三个键。官方文档明确「清除后按住检查不再返回 true，
    // 直到玩家松手再按」——所以这一次点击对底层就是彻底不存在。
    mouse_clear(mb_any);
}
