event_inherited();
plant_id = "baibianshe";
obj_type = object_index;
current_level = 1;
event_user(0);
sprite_index = spr_baibianshe;

if (shape == 1)
    sprite_index = spr_baibianshe_1;
else if (shape == 2)
    sprite_index = spr_baibianshe_2;

attack_anim = 0;
idle_anim = 14;                               // 待机段 f0~f14（素材 f15~f25 是变身段，三形态都是 26 帧）
image_speed = 0;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
current_hp = hp;
can_mouse_list = ["can_mouse"];
is_derivative = false;
copied = false;

// 2026-11-03：放下后**不再立刻变身**——先待机，等玩家从手牌放下下一张卡才进变身段。
//   触发写在 scripts/mod_on_card_placed：它会写 target_card / target_shape、把 tb_waiting 置 false，
//   并把 image_index 拨到 tb_anim_start、idle_anim 抬到 tb_anim_end（不抬的话父对象 IDLE 分支
//   `image_index < idle_anim ? ++ : 0` 会把刚拨到 15 的帧立刻拽回 0）。
tb_waiting    = true;                         // true = 待机中（等下一张卡）
tb_anim_start = 15;                           // 变身段起始帧
tb_anim_end   = 25;                           // 变身段末帧（播到这帧才出卡）
target_card   = "";
target_shape  = 0;
