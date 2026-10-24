
// 防御：精灵无效直接跳过（原本 sprite_index = -1 会在这里崩）
if (!sprite_exists(sprite_index)) exit;
// 防御：帧号越界（special_ash 时精灵来自敌人，回退默认图后帧数会变少）
if (image_index >= sprite_get_number(sprite_index)) image_index = 0;

draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_white,image_alpha)
if special_ash{
	shader_set(hit_shader);
	draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_black,image_alpha);
	shader_reset();
}