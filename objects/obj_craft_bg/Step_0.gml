if close_timer > 0{
	close_timer --
}
if close_timer == 0{
	instance_destroy()
}