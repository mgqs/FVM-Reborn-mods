// Animation End 事件（当前父对象手动推 image_index，最多到 idle_anim=11、永远到不了贴图末帧，
// 所以这段实际不会被触发）；出弹高度与 Other_11 保持一致，避免哪天被启用后再出现偏低。
var inst = instance_create_depth(x + 60, y - 80, depth - 500, obj_corn_shooter_bullet);

if (shape >= 1)
    inst.sprite_index = spr_corn_shooter_bullet_2;

inst.damage = atk;
inst.move_speed = 8;
inst.row = grid_row;