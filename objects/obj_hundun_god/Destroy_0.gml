event_inherited();

var _exp_range = explosion_range;
var _ash_count = 5;
var _center_x = x + global.grid_cell_size_x;

var _effect_spr = spr_hundun_god_effect;
if (shape == 1)
	_effect_spr = spr_hundun_god_effect_1;
else if (shape >= 2)
	_effect_spr = spr_hundun_god_effect_2;

var _effect_inst = instance_create_depth(_center_x, y, depth - 1, obj_hundun_god_effect);
if (instance_exists(_effect_inst))
{
	_effect_inst.sprite_index = _effect_spr;
	_effect_inst.is_one_shot = true;
	_effect_inst.frame_counter = 0;
	_effect_inst.flash_speed = 3;
	_effect_inst.image_xscale = 1;
	_effect_inst.image_yscale = 1;
}

for (var i = 0; i < _ash_count; i++)
{
	var _angle = (360 / _ash_count) * i;
	var _dist = random_range(0, _exp_range * 0.5);
	var _ex = _center_x + lengthdir_x(_dist, _angle);
	var _ey = y + lengthdir_y(_dist, _angle);
	instance_create_depth(_ex, _ey, depth, obj_mouse_ash_death);
}

with (obj_enemy_parent)
{
	if (hp > 0)
	{
		var dx = x - _center_x;
		var dy = y - other.y;
		if (abs(dx) <= _exp_range && abs(dy) <= _exp_range)
		{
			damage_amount = other.elite_damage;
			damage_type = "normal";
			event_user(0);
		}
	}
}
