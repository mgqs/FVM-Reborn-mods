// 抽卡模式（含欧皇）：卡片本体 / 进化凭证 / **初融菜谱**不能买；
//   **深度融合 / 灵魂融合菜谱可以买**，转职凭证本来就能买（2026-10-28 用户口径）
//   随机礼盒模式不在此列（用户 2026-10-27：随机礼盒照原逻辑）
var _gacha_block = ((btn_type == "evo" || btn_type == "card"
    || (btn_type == "recipe" && recipe_shape == 0))
    && is_eternal_gacha_mode());
if (is_disabled || _gacha_block)
    image_blend = c_gray;

draw_self();
draw_set_font(font_yuan);
draw_set_color(c_black);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (btn_type == "card")
    draw_text(x, y - 106, goods_name);
else
{
    // 食谱类名字长（深度融合菜谱（xxx））→ 按宽度自动缩，别顶出格子
    var _nsc = 0.9;
    var _nw = string_width(goods_name);
    if (_nw * _nsc > 360) _nsc = 360 / _nw;
    draw_text_ext_transformed(x, y - 106, goods_name, 25, 1920, _nsc, _nsc, 0);
}

// 价格行**始终画**（2026-10-28 用户要求）：已售完 / 抽卡模式禁买的商品也要能看到价格，
//   否则整页只剩「兑换」按钮、不知道要多少（之前这段被 is_disabled / _gacha_block 包住就整行消失了）
draw_set_color(c_white);
draw_text(x - 8, y - 58, "消耗" + string(cost) + "个");
// 神石图标 90 → 64：给右边的小箭头腾位置
//   卡片那条深蓝价格条在按钮坐标里是 x -115..+116；图标 35 宽（46..82）、箭头 25 宽（中心 +100 → 87.5..112.5）
draw_sprite_ext(spr_gods_hall_reward, 1, x + 64, y - 59, 0.8, 0.8, 0, c_white, 1);

// 转职凭证：价格行最右边的小箭头 = 「自定义购买数量」入口
//   点按钮本体买 1 个（老确认框），点箭头才开数量窗；置灰商品不画箭头（点了也没用）
if (btn_type == "tvoucher" && !is_disabled && !_gacha_block) credit_price_arrow_draw_at(x + 100, y - 58);

// 悬停提示的命中判定在 Draw_64（Draw GUI）里做，这里不再算 tooltip 布尔。
//   卡片几何（相对按钮）：卡片 227×90 压 1.8 → 408.6×162，中心在按钮**左侧 80、上方 57**
//     → 范围 x-284 .. x+124 / y-138 .. y+24（建按钮 +77/+60、卡片画在 -618/-248）
//   ⚠️ 别按「按钮就在卡片中心」估：偏 80px 就会压到邻格，出现「提示显示的是隔壁那张卡」。
