/// obj_auth_gate —— 授权码输入窗口（模态）
/// 打开方式：
///   1) 菜单里点「授权」按钮 → 可以关（普通模式）
///   2) 启动时未授权 → 由 obj_game_init 自动弹出，mandatory = true，**不给关**
/// 依赖：SearchBox / font_yuan / auth_client 里的 auth_bind()、auth_label()
///
/// 层级：GML 的 depth 合法范围是 -16000..16000，-16000 就是最顶层。
///       本对象放在 -15999，把 -16000 留给它自己创建的输入框（子实例必须
///       严格压在面板之上，否则输入框会被面板画没，看着像「框没了」）。
///
/// 坐标走 room 空间（和 SearchBox 的 GUI 鼠标坐标在本工程里是同一套，
/// 房间 1920x1080 且未改 gui 尺寸），别混用 draw_gui。

depth = -15999;

// 强制模式：创建方（obj_game_init）在 instance_create 之前置 global.auth_gate_force。
// 必须在 Create 里读——Create 是创建瞬间同步执行的，外面赋值来不及。
// 从菜单按钮打开的没有这个 global，走 false。
mandatory = variable_global_exists("auth_gate_force") && global.auth_gate_force;

// 强制模式要跨房间活着：room_init 弹的窗必须在切到 room_menu 后还在，
// 否则一换房就被销毁，玩家又能操作了。
persistent = mandatory;

t         = 0;      // 入场计时（备用，未做动画）
closing   = 0;      // >0 表示成功，倒计时后自动关闭
msg       = "";     // 状态提示
msg_ok    = false;  // 提示是成功还是失败（决定颜色）
msg_timer = 0;      // 提示自动消失倒计时

// 弹窗期间挡住底层按钮：obj_player_menu_btn 等会读这个全局（第一道防线）
global.auth_gate_open = true;

// 战斗中也能开（比如将来把授权做成掉落入口）；菜单里没有 obj_battle，不会暂停
did_pause = false;
if (instance_exists(obj_battle)) {
    global.is_paused = true;
    did_pause = true;
}

// ───────────────────────── 版面 ─────────────────────────
// 全部尺寸集中在这里，Draw 不再写死数字。改版面只动这一块。
// 竖向节奏（相对面板顶部）：50 / 96 / 128 / 206 / 300 / 底部 -96
panel_w = 860;
panel_h = 470;
pad     = 60;                                   // 左右内边距
panel_x = (room_width  - panel_w) * 0.5;
panel_y = (room_height - panel_h) * 0.5;
inner_w = panel_w - pad * 2;                    // 内容区宽度，左右各留 60

title_y  = panel_y + 50;    // 标题中心线
hint_y   = panel_y + 96;    // 操作说明
hwid_y   = panel_y + 128;   // 本机识别码一行（h = 54）
box_y    = panel_y + 206;   // 输入框（h = 68）
status_y = panel_y + 300;   // 状态 / 错误提示
group_y  = panel_y + panel_h - 26;  // 底部「加群领码」一行（中心线）

// 本机识别码：玩家要把它发给机器人，码才会绑到这台机器上
local_hwid      = auth_hwid();
local_hwid_text = auth_hwid_text();
hwid_x = panel_x + pad;
hwid_w = inner_w;
hwid_h = 54;
hover_hwid = false;
copied     = false;

// 说明文字左边的标签右边界（改这里同时影响绘制，别两处写死）
hwid_label_w = 150;   // 「本机识别码」占的宽度，识别码从它右边开始

// 输入框
box_x = panel_x + pad;
box_w = inner_w;
box_h = 68;

// 底部两个按钮（按左上角算）
// 强制模式没有「稍后再说」，确认按钮居中；坐标算好，Step/Draw 都不用再判分支
btn_w   = 220;
btn_h   = 66;
// 底部留给「加群领码」一行：26(下边距) + 16(文字高) + 40(间距) + 66(按钮高) = 148
btn_y   = panel_y + panel_h - 148;
if (mandatory) {
    btn_ok_x = panel_x + (panel_w - btn_w) * 0.5;
    btn_no_x = -9999;          // 移出屏幕：悬停判定永远为假，也不画
} else {
    btn_ok_x = panel_x + panel_w * 0.5 - btn_w - 24;
    btn_no_x = panel_x + panel_w * 0.5 + 24;
}

hover_ok = false;
hover_no = false;

// ── 输入框：复用 SearchBox（已处理粘贴 / 输入法 / 失焦）──
// 深度取 -16000（比面板再深一层），保证输入框画在面板之上。
var _box = instance_create_depth(box_x, box_y, -16000, SearchBox);
// 强制模式下本窗口跨房间存活，输入框必须跟着一起活。
// 否则换房瞬间它被销毁，input_box 变成野指针，一打字就炸。
if (mandatory) {
    _box.persistent = true;
}
_box.set_position(box_x, box_y);
_box.set_size(box_w, box_h);
_box.set_placeholder("FVM4-XXXXXXXX-XXXXXXXX-XXXXXXXXXX");
_box.set_theme({
    bg:           make_color_rgb(252, 248, 238),
    bg_focus:     make_color_rgb(255, 253, 246),
    border:       make_color_rgb(150, 128, 96),
    border_focus: make_color_rgb(126, 86, 40),
    text:         make_color_rgb(48, 40, 30),
    placeholder:  make_color_rgb(172, 160, 144)
});
// 一开始输入就清掉上次的错误提示，别让人以为新输入的也错
//
// ⚠️ 两个坑，必须用 method({...}, function(){}) 这个写法（全工程一致）：
//   1) SearchBox 用 self.state.on_change(...) 调用，self 会被绑到 state 结构体上。
//      裸 function 里直接写 msg = "" 改的是结构体上的影子字段，改不到本实例。
//   2) **不能靠闭包捕获 var 局部变量**。写成 `var _self_id = id;` 再 `with (_self_id)`
//      在这套 GM 版本里会编译成读实例变量，运行期报
//      「Variable obj_auth_gate._self_id not set before reading it」。
//      用 method 把实例 id 装进结构体，self 绑定是确定的，不依赖局部变量捕获。
_box.set_on_change(method({ owner: id }, function(_text) {
    var _o = self.owner;
    if (instance_exists(_o)) {
        _o.msg       = "";
        _o.msg_timer = 0;
    }
}));
_box.focus();

input_box = _box;
