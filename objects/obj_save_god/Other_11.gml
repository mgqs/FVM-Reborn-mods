var _eff_obj = obj_save_god01_e;
if (shape >= 2)
    _eff_obj = obj_save_god23_e2;

for (var i = 0; i < 4; i++)
{
    var inst = instance_create_depth(x, y, depth - 1, _eff_obj);
    inst.grid_row = grid_row;
    inst.atk = atk;
}
