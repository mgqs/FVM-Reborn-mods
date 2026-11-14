// 🔴 分类表要最先建：后面的「可用增幅」通道判定、海克斯词条、情报岛分类行全靠它。
//    情报岛的排版不在这里做（注册时卡表还没建），统一在文件末尾的 info_island_compose_all()。
card_category_init();

persistent = true;
noticed = false;
mod_slots_init();
mod_skill_init();
mod_weapons_init();
mod_shop_init();
mod_maps_init();
mod_enemy_init();
gods_goods_registry_init();
gods_shop_init();


mod_boss_init();
mod_cards_init();
// 情报岛放在卡表之后：可用增幅行要读增幅源卡的中文名（get_plant_shape_data），
//   提前注册会把名字写成原始 id（zhanqima → 战旗马）。分类行只依赖文件开头的 card_category_init。
mod_info_island_init();
// 原版 info_island_init() 的那 83 条是在 Game Start 里注册的，那时没有分类表 / 卡表，
//   只能存原文；这里卡表齐了，统一按原文重排一次（分类 / 可用增幅 / 配方才写得出来）
info_island_compose_all();
// 自定义数值（custom）自检：key 撞内置字段 / 撞技能字段 / 形态漏写 / 值类型 / 文案变量取不到
//   只往输出窗口打 [custom] 日志，不改任何数据；要查问题在 F5 输出里搜 [custom] 即可
mod_custom_key_check();
// 转职系统道具（威望）：注册进 material_pool，背包「道具」页才会显示
mod_material_init();
// 转职凭证商店（商店新增「转职凭证」页的商品表）
credit_shop_init();
// 跨服商店的生肖卡名称/描述直接读取 mod_cards_init 注册的卡片形态数据，必须在其后执行
cross_server_shop_init();
// 卡片分类表在文件开头就建好了（情报岛的分类行依赖它），这里不再重复初始化
// 海克斯词条库依赖 card_category_map，必须在它之后
hex_registry_init();
hex_ensure_save_fields();
// 三乘区 / PI 出口先落默认值：任何模式下都必须存在且为 1.0。
// undefined 参与乘法在 GML 里会静默变成 0，比报错更难查（docs 1.2.1）
global.hex_mult       = { atk: 1.0, cycle: 1.0, hp: 1.0 };
global.pi_enemy_mult  = 1.0;
global.pi_elite_extra = 0;
global.pi_boss_escort = false;
global.bond_mult      = 1.0;
global.bond_count     = {};
global.bond_tier      = {};
// 本关是否"通关离场"（CleanUp 用来区分中途退出）
global.hex_level_cleared = false;
// 三选一面板是否打开 / 当前正在累计的序列图（魔塔等）
global.hex_pick_open     = false;
global.hex_series_active = "";
// 本关是否已经掉过海克斯（一关只掉一次）
global.hex_drop_used     = false;
zhiyumiao_config_init();

// 所有卡牌（原版 slots_init + mod mod_slots_init）均已注册进 player_deck 后，清理存档中已不存在的孤儿卡
external_mod_load_all();
cleanup_orphan_cards();

// 融合卡已回退为普卡两转（形态 0/1/2）：老存档若还停在已删掉的三转上，默认夹回二转
var _fusion_ids = ["lizi_god", "youyu_god", "ronghehaixing", "ronghedan_god"];
var _fusion_shape_fixed = 0;
for (var _fi = 0; _fi < array_length(global.save_data.unlocked_cards); _fi++) {
    var _fentry = global.save_data.unlocked_cards[_fi];
    if (!is_struct(_fentry)) continue;
    if (array_get_index(_fusion_ids, _fentry.id) == -1) continue;
    if (variable_struct_exists(_fentry, "max_shape") && _fentry.max_shape > 2) {
        _fentry.max_shape = 2;
        _fusion_shape_fixed++;
    }
    if (variable_struct_exists(_fentry, "shape") && _fentry.shape > 2) {
        _fentry.shape = 2;
        _fusion_shape_fixed++;
    }
}
if (_fusion_shape_fixed > 0) save_file(global.save_slot);
