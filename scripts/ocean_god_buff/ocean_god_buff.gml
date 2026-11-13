/// @desc 按目标卡的逻辑坐标计算海洋增幅，不依赖放置顺序或格子列表缓存。
function get_ocean_buff_multiplier(card)
{
    var multiplier = 1;
    if (card.grid_col < 0 || card.grid_col >= global.grid_cols
        || card.grid_row < 0 || card.grid_row >= global.grid_rows)
        return multiplier;

    var _t = mod_get_ocean_buff_type(card.plant_id);
    if (_t == "none")
        return multiplier;

    // 仅统计当前战场上有效的海洋女神，排除跨局残留的来源列表。
    var sources = [];
    with (obj_haiyang_god)
    {
        if (hp > 0 && grid_col >= 0 && grid_col < global.grid_cols
            && grid_row >= 0 && grid_row < global.grid_rows)
            array_push(sources, id);
    }
    var count = array_length(sources);
    var max_buff = 1;
    for (var i = 0; i < count; i++)
    {
        var source = sources[i];
        var dc = abs(card.grid_col - source.grid_col);
        var dr = abs(card.grid_row - source.grid_row);
        var in_range = (source.shape == 3 && count >= 4);
        if (!in_range)
        {
            // 范围（对上官方 4.增幅 r113：5×5 旋喷 / 5×5 直线 / 本行 咖啡 / 5×1 附加）
            switch (_t)
            {
                case "sprayer": in_range = (dc <= 2 && dr <= 2);  break;   // 5×5（旋转喷壶类 + 金刚马/红柳/护法神）
                case "coffee":  in_range = (dr == 0);             break;   // 本行整行（咖啡喷壶类）
                case "attach":  in_range = (dc <= 2 && dr == 0);  break;   // 5×1（汽水 + 真·附加类）
            }
        }
        // 多个海洋女神的增幅不叠加，取最高倍率。
        if (in_range && source.ocean_buff_value > max_buff)
            max_buff = source.ocean_buff_value;
    }
    return max_buff;
}

/// @desc 重建海洋增幅，并触发攻击力更新。
function rebuild_ocean_buff()
{
    with (obj_card_parent)
        ocean_buff_multiplier = get_ocean_buff_multiplier(id);
    global.ocean_buff_dirty = false;
    global.buff_apply_id++;
}

/// @desc 获取战旗马对卡片的倍率（增幅所有卡片，多个战旗马取最高倍率，不叠加）。
function get_zhanqima_buff_multiplier(card)
{
    // 谁吃战旗马：目标表里的 zhanqima 档（8 个攻击大分类，排除战旗马自己）
    if (!buff_channel_ok(card.plant_id, "zhanqima"))
        return 1;

    var best = 1;
    with (obj_zhanqima)
    {
        if (hp > 0 && grid_col >= 0 && grid_col < global.grid_cols
            && grid_row >= 0 && grid_row < global.grid_rows)
        {
            var dc = abs(card.grid_col - grid_col);
            var dr = abs(card.grid_row - grid_row);
            var in_range = (shape >= 2) || (dc <= 2 && dr <= 2);
            if (in_range && zhanqima_buff_value > best)
                best = zhanqima_buff_value;
        }
    }
    return best;
}

/// @func mod_get_ocean_buff_type(_id)
/// @desc 海洋女神的增幅分组：直接读目标表 —— 吃哪条喷壶通道，就是海洋的哪一组
///   sprayer 5×5 / coffee 本行整行 / attach 5×1（名单与范围都只在 scripts/buff_target 里维护）
/// @param {string} _id 卡片 plant_id
/// @return {string} "sprayer" / "coffee" / "attach" / "none"
function mod_get_ocean_buff_type(_id)
{
    if (buff_channels_has(_id, "sprayer"))        return "sprayer";
    if (buff_channels_has(_id, "sprayer_coffee")) return "coffee";
    if (buff_channels_has(_id, "sprayer_attach")) return "attach";

    return "none";
}
