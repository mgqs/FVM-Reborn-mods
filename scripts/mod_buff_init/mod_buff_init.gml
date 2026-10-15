function mod_buff_init()
{
    // 增幅分组不再手工维护，统一由卡片分类模块按 docs/卡片分类.md 生成。
    // 这里只保留「分类体系之外」的特殊通道。
    global.plant_buff_map = ds_map_create();

    // 附加类（海洋女神 5x1 范围增幅目标）——不属于「增幅类」卡片的分类，单独保留。
    // 注意：护法神 / 红柳烤串机随后会被分类模块改写为 tracker（追踪类），
    //       海洋女神对这两张卡仍走 "both" 特判，不受影响。
    ds_map_set(global.plant_buff_map, "magic_chicken", "attach");
    ds_map_set(global.plant_buff_map, "coke_bomb", "attach");
    ds_map_set(global.plant_buff_map, "xuanfengniu", "attach");
    ds_map_set(global.plant_buff_map, "nizhuanniu", "attach");
    ds_map_set(global.plant_buff_map, "soda_bubble", "attach");
    ds_map_set(global.plant_buff_map, "firework_dragon", "attach");
    ds_map_set(global.plant_buff_map, "hufa_god", "attach");
    ds_map_set(global.plant_buff_map, "hongliukaochuan", "attach");

    // 按分类写入 thrower / tracker / five_dir / sprayer 四个增幅分组
    // （会覆盖上面冲突的 attach 条目，如 hufa_god、hongliukaochuan）
    mod_apply_category_buff_map();

    // 第二 buff 类型映射：分类驱动后不再需要跨分类的第二类型，保留空表以兼容既有查询逻辑。
    global.plant_buff_map_2 = ds_map_create();
}
