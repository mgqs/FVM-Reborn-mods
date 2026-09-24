persistent = true;
noticed = false;
mod_slots_init();
mod_skill_init();
mod_weapons_init();
mod_info_island_init();
mod_shop_init();
gods_goods_registry_init();
gods_shop_init();


mod_boss_init();
mod_cards_init();
mod_buff_init();
zhiyumiao_config_init();

// 所有卡牌（原版 slots_init + mod mod_slots_init）均已注册进 player_deck 后，清理存档中已不存在的孤儿卡
cleanup_orphan_cards();
