if (hp <= 0) exit;

var _allowed = damage_type == "ash" || damage_type == "physical" || damage_type == "throw";
if (!_allowed) {
    damage_amount = 0;
    damage_type = "";
    exit;
}

hp -= 40000;
damage_amount = 0;
damage_type = "";
flash_value = 150;
if (hp <= 0) {
    hp = 0;
    if (variable_global_exists("longyuan_bridge_obstacle_" + longyuan_bridge_track)) {
        global[$ "longyuan_bridge_obstacle_" + longyuan_bridge_track] = noone;
    }
    instance_destroy();
}
