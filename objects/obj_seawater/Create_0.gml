image_alpha = 0
image_xscale = global.grid_cell_size_x/2
image_yscale = global.grid_cell_size_y/2
image_blend = c_blue

row = 0
col = 0
timer = 0
has_bubble = false
non_undersea_card = false
// 海底卡名单：这些 plant_id 在海水格内不受伤（海水伤害逻辑见 obj_seawater/Step_0）
// ronghehaixing（融合海星刺身）官方描述为「可直接在海底生存」，必须在此名单内
ignore_list = ["coal_starfish","ronghehaixing","curry_lobster_cannon","soda_bubble","takoyaki","horseshoe_crab_bread","ghost_god","poseidon","haiyang_god"]