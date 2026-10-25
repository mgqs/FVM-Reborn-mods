// 第 3 个按钮（卡片转职）看的是 craft_top_tab，前两个看 button_select（且只在强化页高亮）
if (button_index == 2){
	image_index = (obj_craft_bg.craft_top_tab == 2) ? 1 : 0
}
else if (obj_craft_bg.craft_top_tab == 0 && obj_craft_bg.button_select == button_index){
	image_index = 1
}
else{
	image_index = 0
}