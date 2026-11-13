/// @function mod_set_card_level(_inst, _level)
/// @description 把一张已放下的卡改到指定星级：等级 + 属性 + 星级图标一起刷新
///   从 obj_clotho/Other_11.gml 的升降星段抽出来，蛇蛇酒 / 时光机 共用（省得两边各抄 120 行）
///   ⚠️ 只做 0~16 星（金卡 17/18 的 spr_star_17/18 那套留在 obj_clotho 里，变星类用不到）
/// @param {id}   _inst  目标卡实例
/// @param {real} _level 目标星级（会被 clamp 到 0~16）
/// @returns {bool} 是否成功
function mod_set_card_level(_inst, _level)
{
    if (!instance_exists(_inst)) return false;
    if (!variable_instance_exists(_inst, "plant_id")) return false;
    if (!variable_instance_exists(_inst, "current_level")) return false;

    var _lv = clamp(round(_level), 0, 16);
    _inst.current_level = _lv;

    var _sk   = variable_instance_exists(_inst, "skill") ? _inst.skill : 0;
    var _info = get_plant_data_with_skill(_inst.plant_id, _inst.shape, _lv, _sk);
    if (_info == undefined) return false;

    if (ds_map_exists(_info, "hp")){
        _inst.hp     = _info[? "hp"];
        _inst.max_hp = _inst.hp;
    }
    if (ds_map_exists(_info, "cost")) _inst.cost = _info[? "cost"];
    if (ds_map_exists(_info, "atk")){
        _inst.atk      = _info[? "atk"];
        _inst.base_atk = _inst.atk;
    }
    if (ds_map_exists(_info, "range"))    _inst.range    = _info[? "range"];
    if (ds_map_exists(_info, "cooldown")) _inst.cooldown = _info[? "cooldown"];
    if (ds_map_exists(_info, "cycle"))    _inst.cycle    = _info[? "cycle"];

    if (ds_map_exists(_info, "flame_produce") && variable_instance_exists(_inst, "flame_produce"))
        _inst.flame_produce = _info[? "flame_produce"];
    if (ds_map_exists(_info, "first_produce_delay") && variable_instance_exists(_inst, "first_produce_delay"))
        _inst.first_produce_delay = _info[? "first_produce_delay"];

    // ── 星级图标（4 星起才有，规格照 obj_clotho）──
    var _spr = -1;
    switch (_lv)
    {
        case 4:  _spr = spr_star_4;  break;
        case 5:  _spr = spr_star_5;  break;
        case 6:  _spr = spr_star_6;  break;
        case 7:  _spr = spr_star_7;  break;
        case 8:  _spr = spr_star_8;  break;
        case 9:  _spr = spr_star_9;  break;
        case 10: _spr = spr_star_10; break;
        case 11: _spr = spr_star_11; break;
        case 12: _spr = spr_star_12; break;
        case 13: _spr = spr_star_13; break;
        case 14: _spr = spr_star_14; break;
        case 15: _spr = spr_star_15; break;
        case 16: _spr = spr_star_16; break;
    }

    var _has = variable_instance_exists(_inst, "banding_star_obj")
               && instance_exists(_inst.banding_star_obj);

    // 2026-11-13：**不可见的卡不挂星级图标**。
    //   蛇蛇酒那种一次性卡播完就 visible = false、实例留在后台计时；
    //   这时如果被时光机 / 别的变星效果改了星级，原逻辑会新建一颗星 → 场上孤零零一颗星留在原地。
    if (!_inst.visible){
        if (_has) instance_destroy(_inst.banding_star_obj);
        _inst.banding_star_obj = noone;
    }
    else if (_has){
        if (_lv < 4) instance_destroy(_inst.banding_star_obj);
        else _inst.banding_star_obj.sprite_index = _spr;
    }
    else if (_lv >= 4){
        var _st = instance_create_depth(_inst.x, _inst.y - 5, _inst.depth, obj_stars);
        _st.sprite_index = _spr;
        _st.parent_card = _inst;
        _inst.banding_star_obj = _st.id;
    }

    // 2026-11-13：星级版本号 —— 蛇蛇酒记快照时记下它，复原时对不上就说明中途被永久改过（时光机 / 克洛托），不覆盖
    _inst.star_ver = (variable_instance_exists(_inst, "star_ver") ? _inst.star_ver : 0) + 1;

    // 属性变了 → 让护盾 / 增幅格子重算（同 obj_clotho 结尾两行）
    if (variable_instance_exists(_inst, "shield_buffed")) _inst.shield_buffed = false;
    if (variable_instance_exists(_inst, "buff_cells_refreshed")) _inst.buff_cells_refreshed = false;

    return true;
}
