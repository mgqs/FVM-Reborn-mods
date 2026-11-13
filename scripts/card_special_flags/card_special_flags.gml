/// =====================================================================
/// card_special_flags —— 卡片「特殊身份」事实表（2026-11-14 定稿）
///   结构：**按身份分组登记**（card_flag_add 批量写入），不是一张一张抄行。
///         新卡 = 往对应那组的 id 数组里加一个，所有读名单的地方一起生效。
///
///   三列 + 一个例外开关：
///     no_entity        —— 非实体卡：不吃「对卡片生效」类效果（变星 / 缩冷却）
///                          **变星卡、缩 CD 卡、复制类卡 本身都算非实体**
///     no_copy          —— 不能当「复制 / 变身 / 读上一张 / **复活**」的源卡
///     no_death_record  —— 死了不进 global.dead_cards（炸弹 / 一次性 / 辅助 / 复制类 等）
///     cd_reducer       —— 缩 CD 的施放者本身（互不影响；2 转极寒冰沙也不缩它们）
///     copy_ok（例外）  —— 放行复制 / 复活（当前只有时间神：它虽是施放者但可被复制）
///
///   🔴 不要在各对象里另抄名单，也别新建第二张表。
///   🔴 唯一写在对象里的例外：**极寒冰沙（冰激凌 2 转）刷新全体卡槽** ——
///      那是它自己 shape==2 分支的范围例外，不在本表标记。
/// =====================================================================

/// @func card_flag_data()
/// @desc 卡片特殊身份总表：card_id → { 列名: true }（首次调用建好，之后走缓存）
function card_flag_data(){
    if (variable_global_exists("card_flag_cache")) return global.card_flag_cache;

    var _t = {};

    // 一、非实体：变星卡 / 缩 CD 卡 / 复制类 / 一次性变身 / 替身 本身
    card_flag_add(_t, [
        "brahma", "magic_chicken", "ice_cream", "shegengbao", "baibianshe", "xingqiongma", "kuileima",
        "zhuanlonghu", "meiweijishiqi", "time_god", "clotho", "sheshejiu", "shiguangji",
    ], ["no_entity"]);
    // 二、复制类 + 一次性变身 + 替身：不能当复制源，也不记死亡
    card_flag_add(_t, [
        "brahma", "magic_chicken", "ice_cream", "shegengbao", "baibianshe", "xingqiongma", "kuileima",
    ], ["no_copy", "no_death_record"]);
    // 三、缩 CD 的施放者本身
    card_flag_add(_t, [
        "ice_cream", "meiweijishiqi", "time_god", "zhuanlonghu",
    ], ["cd_reducer"]);
    //   唯一例外：时间神虽然是施放者，但可以被复制 / 复活
    card_flag_add(_t, ["time_god"], ["copy_ok"]);
    // 四、其余只影响死亡记录（time_god / clotho 已在一、三联过）
    card_flag_add(_t, [
        "12yinliao", "anranxiaohunfan", "aquarius_elve", "baiyang", "baobaoji", "bull_firework", "chili_powder",
        "chongsheng_god", "chunsun", "clotho", "coffee_grounds", "coke_bomb", "cotton_candy", "dandantu",
        "delicacy_firework", "dragon_fruit", "durian", "firework_dragon", "firework_dragon_real", "flour_sack", "heian_god",
        "hundun_god", "ice_bucket_bomb", "kettle_bomb", "mojie", "mouse_clip", "nizhuanniu", "panduola_god",
        "pufferfish", "qingse_shishi", "rabbit_lantern", "save_god", "shiliu_baobao_bing", "shuiping", "skewer_bomb",
        "steel_wool", "time_god", "ventilation_fan", "wanpilong", "whisky_bomb", "wine_bottle_bomb", "wooden_cork",
        "xuanfengniu", "yeziguo", "zhanqima", "zhiyumiao",
    ], ["no_death_record"]);

    global.card_flag_cache = _t;
    return _t;
}

/// @func card_flag_add(_t, _ids, _flags)
/// @desc 把一批卡按同一组标记写进表（id 一律走字符串 key，12yinliao 这种也能用）
///   同一个 id 分多次登记 = 合并标记，不会互相覆盖
function card_flag_add(_t, _ids, _flags){
    for (var _i = 0; _i < array_length(_ids); _i++){
        var _id  = _ids[_i];
        var _row = variable_struct_exists(_t, _id) ? _t[$ _id] : {};
        for (var _j = 0; _j < array_length(_flags); _j++)
            variable_struct_set(_row, _flags[_j], true);
        variable_struct_set(_t, _id, _row);
    }
}

/// @func card_has_flag(_id, _flag)
/// @desc 查某张卡有没有某个特殊身份；卡不在表里 / 没有这一列 → false
function card_has_flag(_id, _flag){
    var _t = card_flag_data();
    if (!variable_struct_exists(_t, _id)) return false;
    var _row = _t[$ _id];
    if (!variable_struct_exists(_row, _flag)) return false;
    return _row[$ _flag];
}

/// @func card_no_entity(_id)
/// @desc 非实体卡（空 id 与 player 永远算非实体：它们不是「对卡生效」的目标）
function card_no_entity(_id){
    if (_id == "" || _id == "player") return true;
    return card_has_flag(_id, "no_entity");
}

/// @func card_is_copy_src(_id)
/// @desc 能不能当「复制 / 变身 / 读上一张 / 被记成上一张 / 复活」的源卡
///   排除：no_copy（复制类 / 一次性变身 / 替身 自身）+ cd_reducer（缩 CD 类也不能被复制）
///   例外：`copy_ok` 放行 —— 目前只有时间神（time_god）
///   复活视为复制的一种，所以不另开函数
function card_is_copy_src(_id){
    if (_id == "" || _id == "player") return false;
    if (card_has_flag(_id, "no_copy")) return false;
    if (card_has_flag(_id, "copy_ok")) return true;
    if (card_has_flag(_id, "cd_reducer")) return false;
    return true;
}

/// @func card_cd_target_ok(_id, _allow_no_entity = false)
/// @desc 「缩减冷却」能不能作用到这张卡
///   默认口径 = 非实体无效；`_allow_no_entity = true` 时放行非实体（极寒冰沙 2 转用），
///   但**缩 CD 施放者自己一律不缩**（`cd_reducer`）
function card_cd_target_ok(_id, _allow_no_entity = false){
    if (_id == "" || _id == "player") return false;
    if (card_has_flag(_id, "cd_reducer")) return false;
    if (_allow_no_entity) return true;
    return !card_no_entity(_id);
}

/// @func card_records_death(_id)
/// @desc 这张卡死亡时要不要记进 global.dead_cards（星穹马复活就从这里取）
function card_records_death(_id){
    if (_id == "") return false;
    return !card_has_flag(_id, "no_death_record");
}
