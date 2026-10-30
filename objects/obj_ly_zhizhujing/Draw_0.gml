/// 白天下降/停留/吊起期间，从屏顶到本体绘制一根蛛丝 spr_zhizhujing_xian。
if (!ly_soul && y > 0 && (ly_mode == "descend" || ly_mode == "steal" || ly_mode == "fly")) {
    draw_sprite_ext(spr_zhizhujing_xian, 0, x - 3, 0, 1.8, y / 184, 0, c_white, image_alpha);
}
// 保留父对象对本体精灵的绘制。
event_inherited();
