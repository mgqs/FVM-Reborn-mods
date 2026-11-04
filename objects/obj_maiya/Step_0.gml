if (global.is_paused) exit;

remove_timer++;

if (remove_timer == 1)
{
    with (obj_card_parent)
    {
        if (grid_row == other.grid_row && grid_col == other.grid_col && plant_id == "maiya" && id != other.id)
        {
            instance_destroy();
        }
    }
}

event_inherited();

anim_t++;

var _trans_ticks = 3 * TRANS_TICKS;

if (anim_t <= _trans_ticks)
{
    image_index = min(TRANS_LAST, (anim_t - 1) div TRANS_TICKS);
}
else
{
    var _broken = (hp <= max_hp * BROKEN_HP);
    var _first = _broken ? BROKEN_FIRST : IDLE_FIRST;
    var _last  = _broken ? BROKEN_LAST  : IDLE_LAST;
    var _span  = _last - _first + 1;
    var _k = anim_t - _trans_ticks - 1;
    image_index = _first + ((_k div IDLE_TICKS) mod _span);
}

plant_type = "coffee";

var _carrying = false;
var _n = instance_number(obj_card_parent);
for (var _i = 0; _i < _n; _i++)
{
    var _p = instance_find(obj_card_parent, _i);
    if (!instance_exists(_p) || _p.id == id) continue;
    if (_p.grid_col == grid_col && _p.grid_row == grid_row)
    {
        _carrying = true;
        break;
    }
}

depth = calculate_plant_depth(grid_col, grid_row, _carrying ? "lilypad" : "coffee");
