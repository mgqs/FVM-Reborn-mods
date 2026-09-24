event_inherited();
plant_id = "shegengbao";
event_user(0);

if (shape == 1)
    sprite_index = spr_shegengbao_1;
else if (shape == 2)
    sprite_index = spr_shegengbao_2;
else
    sprite_index = spr_shegengbao;

plant_type = "shegengbao";
feature_type = "shegengbao";
is_slowdown = false;
refund_multiplier = (shape == 2) ? 2 : 1;
recycled = false;