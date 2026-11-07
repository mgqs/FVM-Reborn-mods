var _is_hv = (direction % 90) == 0;
var _can_bounce = _is_hv ? (row == other.grid_row) : true;

if (!bounced && _can_bounce)
{
    move_speed *= -1;
    bullet_rebound_bonus(id, other.atk);
    image_angle += 180;
    bounced = true;
}
