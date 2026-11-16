// obj_task_claim_all_btn Draw 事件
// 三帧底板：0 常态 / 1 按下 / 2 禁用（底板不带文字，见 tools/make_task_claim_all_btn.py）。
// 文字用 font_yuan 叠画：待领条数是动态的，烘进图里就没法变。
if (disabled)      image_index = 2;
else if (on_click) image_index = 1;
else               image_index = 0;
draw_self();

var _txt = "一键领取";
if (claim_count > 0) _txt = "一键领取（" + string(claim_count) + "）";

draw_set_font(font_yuan);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
if (disabled) draw_set_colour(c_dkgray);
else          draw_set_colour(c_white);
// 文字跟着面板入场动画的透明度走（不调的话按钮还在淡入时文字已经全亮了）
ui_anim_text_alpha(id);
// 0.85 缩放：font_yuan 16 号，9 个全角字符约 122px，156 宽的底板左右还留得住边
draw_text_transformed(x, y, _txt, 0.85, 0.85, 0);

// 复位，避免影响面板后续的 draw_text（事件之间共享绘制状态）
draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
