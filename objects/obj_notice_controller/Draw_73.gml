var _a = room_transition_alpha()
if (_a <= 0) { exit }
if (instance_exists(obj_menu_manager) && variable_global_exists("preloaded") && !global.preloaded) { exit }

draw_set_alpha(_a)
draw_rectangle_color(0, 0, room_width, room_height, global.room_trans.color, global.room_trans.color, global.room_trans.color, global.room_trans.color, false)
draw_set_alpha(1)
