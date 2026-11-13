// 角色信息栏「变装特效」按钮（2026-11-13）
// 素材：spr_attire_fx_help（从「转职说明」按钮底图抠掉文字重做的 3 帧：0 常态 / 1 悬停 / 2 按下）
// 位置由 obj_package_bg 的 Create 传入：面板内容坐标 (x-513, y-372)，即右上角空白处
image_xscale = 1.6;
image_yscale = 1.6;
image_speed = 0;
depth = -9000;              // 盖在背包面板与所有子控件之上
open = false;               // 说明弹窗是否打开
hover = false;

// 面板 spr_package_bg（473×487，origin 居中）在 (1380, 540) 以 1.8 倍绘制；
// 截图实测绿框中心 = 屏幕 (1718, 237) → 相对面板锚点 (+338, -303)
// 这里把「按钮半宽/半高」算出来供判定用（sprite 88×33，1.6 倍 = 140.8×52.8）
btn_half_w = sprite_get_width(spr_attire_fx_help) * image_xscale * 0.5;
btn_half_h = sprite_get_height(spr_attire_fx_help) * image_yscale * 0.5;

// 弹窗互斥标志（obj_package_bg 的点击会一起读）
global.attire_fx_help_open = false;
global.attire_fx_help_latch = 0;
