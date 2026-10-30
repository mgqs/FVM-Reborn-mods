/// obj_12yinliao_effect / Draw
///
/// 【重要，2026-10-28】本对象此前 **没有在 .yy 的 eventList 里注册 Draw 事件**，
/// 所以这个 Draw_0.gml 一直是孤儿文件、从未执行过，特效全靠 GameMaker 的默认绘制
/// （对象没有 Draw 事件时引擎自动 draw_self()，按 x/y + sprite 原点画）。
/// 现在事件已注册，因此下面的兜底分支**必须显式 draw_self()**，
/// 否则 obj_12yinliao 的饮料回血特效、幻之耀变身等所有走本对象的实例都会直接消失。
///
/// left_half：把「内容框」贴满屏幕左半边（0 .. room_width/2 × 0 .. room_height）。
/// 只看 half_src_*，不看 sprite 原点、也不看 x/y ——
/// spr_yao_bianshen2 的画布是 1811x2044，而 xorigin/yorigin 是裁图时留下的残值 (-160,488)，
/// 按原点定位会整体偏出屏幕，所以这里整块按「源矩形 → 目标矩形」直接映射。
if (left_half) {
    var _tw = room_width * 0.5;
    var _th = room_height;
    var _sx = half_src_x, _sy = half_src_y, _sw = half_src_w, _sh = half_src_h;
    if (_sw <= 0 || _sh <= 0) {
        // 调用方没给内容框 → 退回 sprite 自身的 bbox
        _sx = sprite_get_bbox_left(sprite_index);
        _sy = sprite_get_bbox_top(sprite_index);
        _sw = sprite_get_bbox_right(sprite_index) - _sx + 1;
        _sh = sprite_get_bbox_bottom(sprite_index) - _sy + 1;
    }
    if (_sw > 0 && _sh > 0) {
        // 源框 → 目标框分别缩放（不是 min 等比）：这样才算真正「铺满」，
        // 518x603 → 960x1080 的拉扯比例约 1.853 : 1.791（横向多 3.4%），肉眼几乎看不出。
        // 目标矩形就是 0.._tw，天然不会越过中线，不需要 surface 裁剪。
        draw_sprite_part_ext(sprite_index, image_index, _sx, _sy, _sw, _sh,
            0, 0, _tw / _sw, _th / _sh, c_white, image_alpha);
    }
} else {
    // 与「没有 Draw 事件」时的引擎默认行为完全一致，保证其余用法零变化
    draw_self();
}
