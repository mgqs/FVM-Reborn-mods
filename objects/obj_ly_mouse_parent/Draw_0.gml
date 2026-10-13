event_inherited();
if (ly_fire > 0 && hp > 0) {
    var _start = ly_fire == 3 ? 7 : (ly_fire == 2 ? 13 : 19);
    var _frame = _start - 1 + floor(timer / 6) mod 6;
    draw_sprite_ext(spr_ly_soul_fire, _frame, x - 15, y - 100, 1.8, 1.8, 0, c_white, image_alpha);
}
