/// obj_hex_hud —— 战斗内海克斯 HUD：压力表 + 羁绊栏
/// 只在海克斯模式存在；其它模式连实例都不创建

depth = -2900;
force_pi_refresh = true;
bond_timer = 0;
tick_timer = 0;
bond_rows = [];

// 羁绊栏布局（Create / Step / Draw 共用，改位置只改这里）
bond_bx    = 26;    // 左边界
bond_by    = 300;   // 第一行 y
bond_row_h = 34;    // 行高
bond_hit_w = 230;   // 鼠标命中宽度
bond_hover = -1;    // 当前悬停行，-1 = 无

// 开局提示（8 秒）：告诉玩家对局内怎么触发选卡
hint_timer = 480;

if (!hex_active()) {          // 非海克斯模式 / 测试关卡：HUD 不该存在
    instance_destroy();
    exit;
}
if (!variable_global_exists("hex_state")) hex_state_init();
