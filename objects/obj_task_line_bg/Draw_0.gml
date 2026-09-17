draw_self()
draw_set_font(font_yuan)
draw_set_colour(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_middle)
draw_text(x-200,y,task_title)
if obj_task_bg.target_task_index == btn_index{
	image_index = 1
}
else{
	image_index = 0
}

var task_id = obj_task_bg.current_task_list[btn_index].id
state = get_task_state(task_id)

var state_index = 0

if state == "new"{
	state_index = 0
}
else if state == "viewed"{
	state_index = 1
}
else if state == "completed"{
	state_index = 2
}
else if state == "claimed"{
	state_index = 3
}

draw_sprite_ext(spr_task_state,state_index,x+225,y,1.8,1.8,0,c_white,1)
draw_sprite_ext(spr_task_split,1,x,y+sprite_height/2,1.8,1.8,0,c_white,1)