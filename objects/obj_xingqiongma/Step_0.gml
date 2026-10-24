if (global.is_paused) exit;
event_inherited();
if (hp <= 0) exit;

// 种下72帧（1.2秒）后复活并消失（前摇固定，不受冻结影响）
zodiac_age++;
if (zodiac_age >= 72) {
    // 先把自己从网格移除：死卡原格与星穹马同格时，复活占格判定才能通过
    card_destroyed(id);
    // 单体复活特效 effect1（原尺寸，不做5×5拉伸）
    var xq1_spr = spr_xingqiongma_effect1;
    if (shape == 1) xq1_spr = spr_xingqiongma_effect1_1;
    else if (shape >= 2) xq1_spr = spr_xingqiongma_effect1_2;
    var xq_e1 = instance_create_depth(x,y,-3000,obj_zodiac_effect);
    xq_e1.sprite_index = xq1_spr;
    xq_e1.life = max(1,sprite_get_number(xq1_spr)*5);
    xq_e1.image_index = 0;
    xq_e1.image_speed = 0.5;
    // 0/1转：复活5×5范围内最近1张死亡的卡；2转：复活至多3张（铲除的除外，一次性/特殊卡不记录死亡无法复活）
    var limit = 1;
    if (shape >= 2) limit = 3;
    var done = 0;
    var death_count = variable_global_exists("dead_cards") && ds_exists(global.dead_cards,ds_type_list) ? ds_list_size(global.dead_cards) : 0;
    for (var i = death_count-1; i >= 0 && done < limit; i--) {
        var d = global.dead_cards[| i];
        if (!ds_exists(d,ds_type_map)) continue;
        if (d[? "death_cause"] == "shovel") continue;
        var card_id = d[? "plant_id"];
        if (array_contains(["brahma","baibianshe","magic_chicken","kuileima","xingqiongma"],card_id)) continue;
        var col = d[? "grid_col"], row = d[? "grid_row"];
        if (abs(col-grid_col) > 2 || abs(row-grid_row) > 2) continue;
        var card = deck_get_card_data(card_id,d[? "shape"]);
        if (card == noone || !revive_cell_can_place(col,row,card,card_id)) continue;
        var previous_context = variable_global_exists("random_gift_spawn_context") ? global.random_gift_spawn_context : undefined;
        global.random_gift_spawn_context = {card_id:card_id,shape:d[? "shape"],level:d[? "level"],skill:d[? "skill"]};
        var pos = get_world_position_from_grid(col,row);
        var p = instance_create_depth(pos.x,pos.y,0,card[? "obj"]);
        global.random_gift_spawn_context = previous_context;
        card_created(p,col,row);
        p.depth = calculate_plant_depth(col,row,p.plant_type);
        // 被复活卡片身上播放单体effect1；effect2是种下时的5×5范围特效，不能在复活位置使用
        var xq_e2 = instance_create_depth(pos.x,pos.y,-3000,obj_zodiac_effect);
        xq_e2.sprite_index = xq1_spr;
        xq_e2.life = max(1,sprite_get_number(xq1_spr)*5);
        xq_e2.image_index = 0;
        xq_e2.image_speed = 0.5;
        ds_list_delete(global.dead_cards,i);
        ds_map_destroy(d);
        done++;
    }
    if (shape >= 1) {
        // 1/2转：5×5范围内卡片（含刚复活的）获得减伤，减伤时间内抵挡指定次数老鼠攻击（含致命伤）
        for (var gi = 0; gi < instance_number(obj_card_parent); gi++) {
            var gp = instance_find(obj_card_parent,gi);
            if (!instance_exists(gp) || gp.hp <= 0 || gp.id == id
                || abs(gp.grid_col-grid_col) > 2 || abs(gp.grid_row-grid_row) > 2) continue;
            gp.zodiac_guard_time = zodiac_guard_duration;
            gp.zodiac_guard_hits = skill == 8 ? 2 : 1;
            gp.zodiac_guard_hp = gp.hp;
        }
    }
    instance_destroy();
}
