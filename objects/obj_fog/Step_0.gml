if global.is_paused{
	exit
}

var dis_list = []
with obj_oil_lamp{
	var dis = abs(grid_row - other.row) + abs(grid_col - other.col)
	if shape >= 1{
		array_push(dis_list,0)
	}
	else{
		array_push(dis_list,dis)
	}
}
with obj_brazier{
	var dis = abs(grid_row - other.row) + abs(grid_col - other.col)
	if dis == 0{
		array_push(dis_list,3)
	}
	else if dis == 1{
		array_push(dis_list,4)
	}
}


var min_dis = 10
for(var i = 0 ; i < array_length(dis_list) ; i++){
	if dis_list[i] < min_dis{
		min_dis = dis_list[i]
	}
}
if min_dis <= 3{
	light_level = 2
}
else if min_dis == 4{
	light_level = 1
}
else{
	light_level = 0
}

var pos = get_grid_position_from_world(x,y)
col = pos.col

if light_level == 2 && image_alpha > 0{
	image_alpha -= 0.05
}
if light_level == 1 && image_alpha > 0.75{
	image_alpha -= 0.05
}
if light_level == 1 && image_alpha < 0.75{
	image_alpha += 0.05
}
if light_level == 0 && image_alpha < 1{
	image_alpha += 0.05
}
if is_blow_away{
	timer ++ 
	if timer >= blow_time{
		is_blow_away = false
		timer = 0
	}
	if x < (xstart+room_width){
		x += 50
	}
}
else{
	if x > xstart{
		x -= 3
	}
	else{
		x = xstart
	}
	
}