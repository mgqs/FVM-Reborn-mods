if global.is_paused{
	exit
}
x += 15
timer++
if timer < 5*5{
	image_index = floor(timer/5)
}
else{
	image_index = floor(timer/5) mod 7+5
}

// 边界检查
if x > 2200 or y > 1200 or x < 0 or y < 0 {
    instance_destroy();
}