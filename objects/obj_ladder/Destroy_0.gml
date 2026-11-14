// 宿主可能是不带 have_loder 的 obj_card_parent 子孙（如 obj_player_character），写前先判字段
if (host_plant != noone && instance_exists(host_plant) && variable_instance_exists(host_plant, "have_loder")) {
	host_plant.have_loder = false;
}
