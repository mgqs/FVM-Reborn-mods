if not obj_tower_cake_bg.is_submenu_opened{
	global.audio.play(snd_button,0,0)
	global.gui_stack.pop()
	global.menu_screen = true
}