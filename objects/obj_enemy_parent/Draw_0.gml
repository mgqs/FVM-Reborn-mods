if(climb_stage==1){
	y = climb_y
}
if (sprite_index != -1) draw_self()
if flash_value >0 && sprite_index != -1{
	// 受击闪光（2026-11-14 修）：原来是 shader 把整只鼠的 rgb 直接换成纯色剪影，
	// 再以 flash_value/200（最高 0.75）的 alpha 用 bm_normal 盖在自己身上 —— 等于用一块
	// 不透明的白色形状**替换**掉原画。连续命中时 Other_10 每帧把 flash_value 拉回 150，
	// 而衰减只有 -10/帧，于是大体积敌人（变异特种鼠 spr_kuafu_armour 283x198 × image_yscale 1.8
	// = 屏幕高 356px）会长时间变成一整块泛白的半透明幽灵，观感就是「满血走着走着突然闪成残血/脱甲」。
	// 现在改成加法混合：白量只做叠加提亮，不再覆盖原画的明暗与色相，性格从「变成白影」变成「被照亮」；
	// 同时按屏幕体积衰减（大怪少吃一点白）+ 跟随 image_alpha（死亡淡出时不再残留白影）。
	var _flash_h = max(1, sprite_get_height(sprite_index) * abs(image_yscale));
	var _flash_a = clamp(flash_value / 200 * image_alpha * clamp(120 / _flash_h, 0.2, 1), 0, 0.3);
	shader_set(shader_hit);
	gpu_set_blendmode(bm_add);
	draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,flash_color,_flash_a);
	gpu_set_blendmode(bm_normal);
	shader_reset();
	//draw_self()
	//var progress = 1 - flash_value / 150 // 计算进度
    
    //// 设置混合模式为加法混合
    //gpu_set_blendmode(bm_add);
    
    //// 启用Shader
    
    //shader_set_uniform_f(u_progress, progress);
    //shader_set_uniform_f(u_flashColor, flash_color[0], flash_color[1], flash_color[2]);
	//shader_set(shader_hit);
    
    //// 只绘制精灵的非透明部分
    //draw_self();
    
    //// 重置渲染状态
    //shader_reset();
    //gpu_set_blendmode(bm_normal);
}
if is_slowdown{
	image_blend = merge_color(c_white,c_blue,0.5)
	//draw_self()
}
else{
	image_blend = c_white
	//draw_self()
}

if is_frozen{
	draw_sprite_ext(ice_sprite,0,x,y+50,1.8,1.8,0,c_white,1)
}
if is_scare{
	draw_sprite_ext(spr_mouse_scared,0,x-45,y-125,1.8,1.8,0,c_white,1)
}
if is_stun{
	draw_sprite_ext(stun_sprite,sprite_get_number(stun_sprite)-(floor(stun_timer/5) mod sprite_get_number(stun_sprite)),x-20,y-150,1.8,1.8,0,c_white,1)
}
// 海克斯「食指的指令」：被标记的鼠军头顶挂标记图案
if (hex_enabled() && variable_global_exists("hex_state") && is_struct(global.hex_state)
    && variable_struct_exists(global.hex_state, "b3_mark_on") && global.hex_state.b3_mark_on
    && variable_struct_exists(global.hex_state, "b3_mark_enemy")
    && global.hex_state.b3_mark_enemy == id) {
    hex_b3_mark_icon(x, y - 110, 40);
}
if(climb_stage==1){
	y = climb_base_y
}