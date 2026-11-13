random_gift_prepare_selected_deck();
create_battle_slots();

resource_texture_prepare("bullet");
resource_texture_prepare("effects");
if global.map_id == "tower_cake"{
	resource_texture_prepare("enemy_tower")
}
else if global.map_id == "undersea_vortex"{
	resource_texture_prepare("pack_undersea_vortex")
}
resource_texture_prepare("time_god");

external_animation_prewarm_deck();
