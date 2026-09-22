/// @function precise_bbox_collision(inst_a, inst_b)
/// @param {instance} inst_a - 子弹实例（使用精确未缩放的碰撞遮罩）
/// @param {instance} inst_b - 目标实例（使用其内置 bbox）
/// @return {bool} 是否发生碰撞
/// @description 检测 inst_a 的精确碰撞遮罩（1:1 原始尺寸，不受 image_xscale/image_yscale 影响）是否与 inst_b 的 bbox 重叠。
///              考虑 image_angle 旋转。适用于保持视觉缩放但碰撞使用精确遮罩的场景。
function precise_bbox_collision(_inst_a, _inst_b) {
    var _spr = _inst_a.sprite_index;
    if (_spr < 0) return false;

    var _bl = sprite_get_bbox_left(_spr);
    var _br = sprite_get_bbox_right(_spr);
    var _bt = sprite_get_bbox_top(_spr);
    var _bb = sprite_get_bbox_bottom(_spr);
    var _xo = sprite_get_xoffset(_spr);
    var _yo = sprite_get_yoffset(_spr);

    var _ang = _inst_a.image_angle * pi / 180;
    var _c = cos(_ang);
    var _s = sin(_ang);

    // 计算 bbox 四个角在精灵本地坐标（以原点为基准）
    var _lx1 = _bl - _xo;
    var _lx2 = _br - _xo;
    var _ly1 = _bt - _yo;
    var _ly2 = _bb - _yo;

    // 将四个角旋转并转换到世界坐标
    var _x1 = _lx1 * _c - _ly1 * _s + _inst_a.x;
    var _y1 = _lx1 * _s + _ly1 * _c + _inst_a.y;

    var _x2 = _lx2 * _c - _ly1 * _s + _inst_a.x;
    var _y2 = _lx2 * _s + _ly1 * _c + _inst_a.y;

    var _x3 = _lx2 * _c - _ly2 * _s + _inst_a.x;
    var _y3 = _lx2 * _s + _ly2 * _c + _inst_a.y;

    var _x4 = _lx1 * _c - _ly2 * _s + _inst_a.x;
    var _y4 = _lx1 * _s + _ly2 * _c + _inst_a.y;

    // 计算轴对齐 bbox
    var _a_left = min(min(_x1, _x2), min(_x3, _x4));
    var _a_right = max(max(_x1, _x2), max(_x3, _x4));
    var _a_top = min(min(_y1, _y2), min(_y3, _y4));
    var _a_bottom = max(max(_y1, _y2), max(_y3, _y4));

    return _a_right >= _inst_b.bbox_left && _a_left <= _inst_b.bbox_right
        && _a_bottom >= _inst_b.bbox_top && _a_top <= _inst_b.bbox_bottom;
}
