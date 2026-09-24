var _enemies = [];

with (obj_enemy_parent)
{
    if (can_hit("all", target_type) && hp > 0)
        array_push(_enemies, id);
}

var _ec = array_length(_enemies);
fire_queue = [];
burst_idx = 0;

if (_ec == 0)
    exit;

array_sort(_enemies, function(arg0, arg1)
{
    return arg0.x - arg1.x;
});
var n = bullet_count;
var _alloc = array_create(_ec, 0);

if (_ec >= n)
{
    for (var i = 0; i < n; i++)
        _alloc[i] = 1;
}
else
{
    var _base = n div _ec;
    var _rem = n % _ec;
    
    for (var i = 0; i < _ec; i++)
        _alloc[i] = _base + ((i < _rem) ? 1 : 0);
}

for (var i = 0; i < _ec; i++)
{
    for (var j = 0; j < _alloc[i]; j++)
        array_push(fire_queue, _enemies[i]);
}
