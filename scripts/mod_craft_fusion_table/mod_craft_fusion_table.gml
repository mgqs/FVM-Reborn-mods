/// =============================================================================
///  mod/craft · 融合表（融合页专用）
///  这个文件 = 融合页的**档位配置 / 主卡要求 / 副卡要求 / 卡片顺序 / 兜底**，
///  obj_craft_bg 只引用，不再自己存表
///
///    mod_fusion_levels()       三档配置（名字 / 产物形态 / 金币 / 融合剂 + 数量）
///    mod_fusion_main_need()    「初融」这一档主卡默认要求形态（0 本体 / 1 一转 / 2 二转）
///    mod_fusion_main_needs()   「初融」档主卡的逐卡覆盖（卡 id → need）
///    mod_fusion_sub_cards()    各档副卡表：[1]=初级 / [2]=深度 / [3]=灵魂
///    mod_fusion_card_order()   「防御卡」列表的收集顺序（= spr_fusion_recipe0 帧号，只能往后接）
///    mod_fusion_need_shape()   兜底：need 超过卡自己的形态上限 → 按上限算
/// =============================================================================

/// @func mod_fusion_levels() 三档配置（name 显示名 / shape 产物形态 / gold 金币 / mat 材料 / mat_n 数量）
function mod_fusion_levels(){
    return [
    	{ name: "初级", shape: 0, gold: 150000, mat: "secret_spices", mat_n: 1000 },
    	{ name: "深度", shape: 1, gold: 320000, mat: "clover_4",      mat_n: 15   },
    	{ name: "灵魂", shape: 2, gold: 560000, mat: "royal_spices",  mat_n: 1000 }
    ];
}

/// @func mod_fusion_main_need() 初融「主卡」默认要求形态（0 本体 / 1 一转 / 2 二转）
function mod_fusion_main_need(){
    return 2;
}

/// @func mod_fusion_main_needs() 「初融」档主卡的逐卡覆盖表（卡 id → need）；没写的才用默认值
function mod_fusion_main_needs(){
    return {};
}

/// @func mod_fusion_sub_cards() 各档副卡表：[1]=初级 / [2]=深度 / [3]=灵魂；"" = 这道食谱没有副卡
///   要求形态（2026-10-27 用户口径）：**能二转的副卡一律 need 2**；唯一例外德芙面包（只有 0/1 转）
///   写 need 2 也不会因为卡没二转而卡死 —— fusion_sub_card_at() 会走 mod_fusion_need_shape() 按卡上限钳
function mod_fusion_sub_cards(){
    return [
    	{   // ① 初级
    		ronghedapao:    { id: "chocolate_pult",    need: 2 },   // 脆心巧克力投手（巧克力投手二转形态名）
    		ronghehaixing:  { id: "melon_shield",      need: 2 },   // 锋芒瓜皮护罩（官方「仙人掌花刺身」的顶替：瓜皮系）
    		youyu_god:      { id: "coal_starfish",     need: 2 },   // 芥末海星刺身（炭烧海星；0 转融合鱿鱼是 8 向齐射 → 取多方向卡）
    		lizi_god:       { id: "spicy_pot",         need: 2 },   // 酱香鱿鱼锅（麻辣香锅二转形态名）
    		ronghedan_god:  { id: "ice_egg_boiler_pult", need: 2 },  // 冰河煮蛋器（冰煮蛋器；0 转煮蛋器是投掷溅射+定身 → 取冰系投手）
    		ronghehuopen:   { id: "sugar_roxburghii",  need: 2 },   // 生腌酸刺梨（糖渍刺梨二转形态名）
    		ronghesanxian:  { id: "wine_bottle_bomb",  need: 2 },   // 子母酒瓶弹（酒瓶炸弹二转形态名）
    		rongheshuanggu: { id: "hotdog_cannon",     need: 2 },   // 热狗榴弹炮（热狗大炮二转形态名）
    		ronghekafei:    { id: "gatlin_long_bao",   need: 2 }    // 格林机枪笼包
    	},
    	{   // ② 深度
    		ronghedapao:    { id: "lightning_baguette", need: 2 },   // 雷电长棍面包（官方「霸王美味电鳗」的顶替：电系）
    		ronghehaixing:  { id: "chocolate_bread",   need: 1 },   // 德芙面包（官方「8周年红丝绒」的顶替）⚠ 唯一例外：巧克力面包只有本体+1转，最高只能 1
    		youyu_god:      { id: "double_water_pipe", need: 2 },   // 合金水管（双向水管二转形态名）
    		lizi_god:       { id: "coke_bomb",         need: 2 },   // 燃烧可乐弹（可乐炸弹二转形态名）
    		ronghedan_god:  { id: "stinky_tofu_pult",  need: 2 },   // 铁板臭豆腐投手（臭豆腐投手二转形态名）
    		ronghehuopen:   { id: "durian",            need: 2 },   // 冰河世纪榴莲（榴莲二转形态名）
    		ronghesanxian:  { id: "sheshou",           need: 2 },   // 射手座星宿（射手座精灵二转形态名；1 转三线是「三行各 3 发」→ 取三行多发卡）
    		rongheshuanggu: { id: "coffee_pot",        need: 2 },   // 红温咖啡喷壶（咖啡喷壶二转形态名）
    		ronghekafei:    { id: "coffee_pot",        need: 2 }    // 红温咖啡喷壶（咖啡喷壶二转形态名）
    	},
    	{   // ③ 灵魂
    		ronghedapao:    { id: "flour_sack",        need: 2 },   // 乾坤分身袋（面粉袋二转形态名）
    		ronghehaixing:  { id: "sugar_ball_pult",   need: 2 },   // 可可糖全能投手（官方「王冠蜜糖陷阱」的顶替：灵融＝变追踪）
    		youyu_god:      { id: "nut_frier",         need: 2 },   // 松塔爆破机（坚果爆炒机二转形态名）
    		lizi_god:       { id: "qingse_shishi",     need: 2 },   // 柿柿如意（青涩柿柿二转形态名）
    		ronghedan_god:  { id: "triple_wine_rack",  need: 2 },   // 终结者酒架（三线酒架二转形态名）
    		ronghehuopen:   { id: "ice_bucket_bomb",   need: 2 },   // 杂果冰桶炸弹（冰桶炸弹二转形态名）
    		ronghesanxian:  { id: "oden_pot",          need: 2 },   // 海鲜关东煮喷锅（关东煮喷锅二转形态名；2 转三线「三行 3 发可穿透」→ 取三行穿透卡）
    		rongheshuanggu: { id: "tang_hu_lu",        need: 2 },   // 七彩糖葫芦弹（糖葫芦炮弹二转形态名）
    		ronghekafei:    { id: "coffee_cup",        need: 2 }    // 骨瓷咖啡杯（咖啡杯二转形态名）
    	}
    ];
}

/// @func mod_fusion_need_shape(id, need) 要求形态按这张卡自己的上限兜底
///       例：need 2 但卡只有 0/1 转（card_max_available_shape = 1）→ 按 1 转算，不会永远凑不齐
function mod_fusion_need_shape(_id, _need){
    var _max = card_max_available_shape(_id);
    if (_max < 0) return _need;
    return min(_need, _max);
}

/// @func mod_fusion_card_order() 融合页「防御卡」列表的收集顺序
///   ⚠️ 顺序 = spr_fusion_recipe0 的帧号，**只能往后接、不能插队**
///   返回 [{id, pre}]：id = 融合卡；pre = 它的**前置主卡**（mod_fusion_main_prereq_map，别手写）
function mod_fusion_card_order(){
    var _ids = [
        "ronghedapao",      // 融合巧克力炮
        "ronghehaixing",    // 融合海星
        "youyu_god",        // 融合鱿鱼
        "lizi_god",         // 融合栗子
        "ronghedan_god",    // 融合煮蛋器
        "ronghehuopen",     // 融合火盆
        "ronghesanxian",    // 融合三线
        "rongheshuanggu",   // 融合双菇
        "ronghekafei"       // 融合咖啡杯
    ];
    var _out = [];
    for (var _i = 0; _i < array_length(_ids); _i++){
        array_push(_out, { id: _ids[_i], pre: mod_fusion_main_prereq(_ids[_i]) });
    }
    return _out;
}

/// @func mod_fusion_main_prereq_map() 融合卡 → **前置主卡** id（例：融合栗子 ← 生煎锅）
///   ⚠️ 这里的「主卡」是**融合主卡 = 前置主卡**，不是融合档位里的「初融」（初级/深度/灵魂）：
///      不管抽到的是初级 / 深度 / 灵魂哪一档菜谱，附赠的永远是这张前置主卡
///   融合页「防御卡」列表的 pre 列、抽到菜谱时的附赠，都读这张；与金卡表无关（靠 is_fusion 区分）
function mod_fusion_main_prereq_map(){
    return {
        ronghedapao:    "chocolate_cannon",     // 融合巧克力炮 ← 死神大炮
        ronghehaixing:  "coal_starfish",        // 融合海星   ← 炭烧海星
        youyu_god:      "takoyaki",             // 融合鱿鱼   ← 章鱼烧
        lizi_god:       "pan_fried_bun",        // 融合栗子   ← 生煎锅
        ronghedan_god:  "egg_boiler_pult",      // 融合煮蛋器 ← 煮蛋器投手
        ronghehuopen:   "brazier",              // 融合火盆   ← 火盆
        ronghesanxian:  "triple_wine_rack",     // 融合三线   ← 三线酒架
        rongheshuanggu: "shuanggu",             // 融合双菇   ← 蚝油双菇
        ronghekafei:    "coffee_cup"            // 融合咖啡杯 ← 骨瓷咖啡杯
    };
}

/// @func mod_fusion_main_prereq(fusion_id) 这张融合卡的前置主卡（查不到返回 ""）
function mod_fusion_main_prereq(_id){
    var _m = mod_fusion_main_prereq_map();
    if (variable_struct_exists(_m, _id)) return _m[$ _id];
    return "";
}
