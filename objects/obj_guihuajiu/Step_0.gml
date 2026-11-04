if (global.is_paused) exit;

if (cap_timer <= 0)
{
    cap_timer = 60;
    cap_used = 0;
}
cap_timer--;

var _loss = max(0, last_hp - hp);
var _room = max(0, cap_per_sec - cap_used);

if (_loss > _room)
{
    hp = last_hp - _room;
    _loss = _room;
}

cap_used += _loss;
last_hp = hp;

event_inherited();
