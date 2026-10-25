if (hp <= 0) exit;
if (zhangaiwu_state == "dead") exit;

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
    zhangaiwu_state = "dead";
    sprite_index = spr_zhangaiwu_dead;
    image_index = 0;
}
