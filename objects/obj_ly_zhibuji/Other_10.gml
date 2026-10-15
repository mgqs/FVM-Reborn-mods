if (hp <= 0 || ly_mode == "dead") exit;
if (invincible) exit;

var _before = hp;
event_inherited();
var _loss = max(0, _before - hp);
{
    ly_damage_accum += _loss;
    var _threshold = max(1, maxhp * ly_shot_loss);
    while (ly_damage_accum >= _threshold) { ly_damage_accum -= _threshold; ly_pending_shots++; }
}
