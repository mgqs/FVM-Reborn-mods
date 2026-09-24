function mod_on_card_placed(arg0, arg1)
{
    if (arg0 != "brahma" && arg0 != "ice_cream" && arg0 != "magic_chicken" && arg0 != "baibianshe")
    {
        show_debug_message("已记录" + string(arg0) + string(arg1));
        global.last_placed_card_id = arg0;
        global.last_placed_card_shape = arg1;
    }

    // 光明神与黑暗神联动：放置黑暗神时触发光明神光影爆炸
    if (arg0 == "heian_god")
    {
        // 找出所有光明神实例
        var guangming_list = ds_list_create();
        var heian_shape = arg1;

        with (obj_guangming_god)
        {
            if (hp > 0 && shape >= 1)
            {
                var dist = point_distance(x, y, other.x, other.y);
                var data = ds_map_create();
                ds_map_add(data, "id", id);
                ds_map_add(data, "dist", dist);
                ds_map_add(data, "shape", shape);
                ds_list_add(guangming_list, data);
            }
        }

        // 按距离排序
        var n = ds_list_size(guangming_list);
        for (var i = 0; i < n - 1; i++)
        {
            for (var j = 0; j < n - i - 1; j++)
            {
                var d1 = guangming_list[| j];
                var d2 = guangming_list[| j + 1];
                if (d1[? "dist"] > d2[? "dist"])
                {
                    guangming_list[| j] = d2;
                    guangming_list[| j + 1] = d1;
                }
            }
        }

        // 根据形态决定触发数量和爆炸参数
        var max_count = 0;
        var explosion_dmg = 0;
        var explosion_range_x = 0;
        var explosion_range_y = 0;

        // 确定爆炸参数（取最高形态的光明神来决定参数不现实，应该每个光明神按自己的形态）
        // 实际上应该遍历每个选中的光明神，按各自形态产生不同的爆炸

        // 先确定需要触发的数量
        // 三转(shape1):最近5个；四转(shape2)/终转(shape3):最近7个
        // 由于列表里都是shape>=1的，我们取最近的7个，每个按自己的形态计算

        var trigger_count = min(7, ds_list_size(guangming_list));

        for (var k = 0; k < trigger_count; k++)
        {
            var gm_data = guangming_list[| k];
            var gm_id = gm_data[? "id"];
            var gm_shape = gm_data[? "shape"];

            if (!instance_exists(gm_id))
                continue;

            // 根据光明神形态和黑暗神形态确定爆炸参数
            var exp_dmg = 0;
            var exp_range_x = 0;
            var exp_range_y = 0;

            if (gm_shape == 1)
            {
                // 三转：3x3范围，1100伤害
                exp_dmg = 1100;
                exp_range_x = 1; // 3x3 = 左右各1格
                exp_range_y = 1;
            }
            else if (gm_shape == 2)
            {
                // 四转：5x5范围，1500伤害
                exp_dmg = 1500;
                exp_range_x = 2; // 5x5 = 左右各2格
                exp_range_y = 2;
            }
            else if (gm_shape == 3)
            {
                // 终转：默认5x7范围，2000伤害
                exp_dmg = 2000;
                exp_range_x = 2; // 5列
                exp_range_y = 3; // 7行

                // 如果黑暗神也是终转，升级为7x7，3000伤害
                if (heian_shape >= 3)
                {
                    exp_dmg = 3000;
                    exp_range_x = 3; // 7x7
                    exp_range_y = 3;
                }
            }

            // 跳过数量限制（三转只触发最近5个）
            if (gm_shape == 1 && k >= 5)
                continue;

            // 产生爆炸效果
            var gm_x = gm_id.x;
            var gm_y = gm_id.y;
            var gm_row = gm_id.grid_row;
            var gm_col = gm_id.grid_col;

            // 爆炸特效
            var boom = instance_create_depth(gm_x, gm_y - 30, gm_id.depth - 100, obj_guangming_god_effect);
            boom.sprite_index = spr_guangming_god_effect;
            boom.is_one_shot = true;
            boom.frame_counter = 0;
            boom.image_xscale = 2.5;
            boom.image_yscale = 2.5;

            // 对范围内敌人造成伤害
            with (obj_enemy_parent)
            {
                if (hp > 0)
                {
                    var _row_diff = abs(grid_row - gm_row);
                    var _col_diff = abs(grid_col - gm_col);

                    if (_row_diff <= exp_range_y && _col_diff <= exp_range_x)
                    {
                        // 灰烬非精英鼠
                        var _is_elite = false;
                        if (variable_instance_exists(id, "is_elite"))
                            _is_elite = is_elite;

                        if (hp <= exp_dmg && !_is_elite)
                        {
                            instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                            instance_destroy();
                        }
                        else
                        {
                            damage_amount = exp_dmg;
                            damage_type = "explosion";
                            event_user(0);
                        }
                    }
                }
            }
        }

        // 清理
        for (var c = 0; c < ds_list_size(guangming_list); c++)
        {
            var m = guangming_list[| c];
            if (ds_exists(m, ds_type_map))
                ds_map_destroy(m);
        }
        ds_list_destroy(guangming_list);
    }
}
