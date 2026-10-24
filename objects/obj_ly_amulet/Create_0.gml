owner = noone;
lane = -1;
image_speed = 0;
image_xscale = 1.8; image_yscale = 1.8;
timer = 0;
mode = "fly";
target = noone;
hp = 100; maxhp = 100;
damage_amount = 0; damage_type = "";

// 状态效果变量（longyuan_animate/其他脚本会读，amulet 不继承父类所以必须自己初始化）
is_slowdown = false;
is_frozen = false;
is_stun = false;
is_scare = false;
invincible = false;

// 用动画表驱动 fly(spr_fuzhou_bullet_fly 6帧循环) / bianxing(spr_fuzhou_bullet_bianxing 12帧一次性) / disappear(spr_fuzhou_bullet_disapper 7帧一次性)
ly_anims = longyuan_animation_table("amulet");
ly_action = "";
ly_frame = 0;
ly_done = false;
ly_once = false;

longyuan_play("飞行", false);
