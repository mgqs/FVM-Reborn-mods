// 覆盖父类Destroy：不掉金币，并从敌人类型索引中注销。
if (instance_exists(decoy_card) && variable_instance_exists(decoy_card, "zodiac_decoy")
    && decoy_card.zodiac_decoy == id) {
    decoy_card.zodiac_decoy = noone;
}

if (enemy_registered && variable_global_exists("enemy_by_type")
    && variable_struct_exists(global.enemy_by_type, enemy_registered_type)) {
    var _list = global.enemy_by_type[$ enemy_registered_type];
    var _idx = array_get_index(_list, id);
    if (_idx != -1) array_delete(_list, _idx, 1);
    enemy_registered = false;
}
