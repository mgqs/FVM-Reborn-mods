// 米线连接线：从卡片脚下连到龙柱脚下
// spr_mixian_xian：1-4 连接动画 -> 5-7 循环；断裂时播放 spr_mixian_disxian
owner_card = noone;
owner_pillar = noone;
link_state = "connect";
anim_tick = 0;
image_speed = 0;
image_index = 0;
sprite_index = spr_mixian_xian;

// spr_mixian_xian 画布 403 宽、原点 x=27，线条可见部分只到 x≈305，
// 即完整一帧的可见长度约 278，用它做拉伸基准线才能正好搭到龙柱脚下。
line_base_len = 278;
