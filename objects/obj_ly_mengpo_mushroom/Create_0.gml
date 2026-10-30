// 孟婆鼠：降雨滋生的蘑菇（占据格子、摧毁该格卡片）
// 作为 obstacle 类敌人，可被旋风牛 / 炸炸菇 / 爆爆鸡 等清障卡片摧毁
event_inherited();
image_speed = 0;

hp = 3000; maxhp = 3000;
move_speed = 0;
target_type = "obstacle";
mouse_id = "ly_mengpo_mushroom";

ly_kind = "mengpo_mushroom";
ly_anims = longyuan_animation_table("mengpo_mushroom");
ly_action = "";
ly_frame = 0;
ly_done = false;
ly_hit = false;

// 动画：出生（一次性）→ 待机（循环）
fx_loop = false;
fx_next_action = "待机";
fx_loop_after = true;
timer = 0;
longyuan_clip_set("出生");

image_alpha = 1;
