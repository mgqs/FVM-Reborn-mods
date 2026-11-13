/// @func info_custom(pairs)
/// @desc 卡片注册表里的「自定义数值」容器（2026-11-05 情报岛文案变量配套）
///   ⚠️ 为什么不让直接写 `custom: { 灼烧伤害: [...] }`：GML 结构体字面量的 key 是**标识符**，
///      中文当标识符各版本不一定支持（写错直接编译失败）。这里把「名字」当**字符串**传，绝对安全。
///   用法：custom: info_custom([["灼烧伤害", [0,60,70,...]], ["每跳间隔", 24]])
///   值：数组 = 按星级取（越界取最后一档）；单个数字 = 不随星级变
///   读法：get_plant_data_with_skill(id, shape, lv, skill)[? "灼烧伤害"]；情报岛文案写 {灼烧伤害}
function info_custom(_pairs){
    var _s = {};
    for (var _i = 0; _i < array_length(_pairs); _i++){
        variable_struct_set(_s, string(_pairs[_i][0]), _pairs[_i][1]);
    }
    return _s;
}

function mod_register_plant_lite(arg0, arg1, arg2 = true)
{
    var is_god = arg2;

    if (ds_map_exists(global.plant_registry, arg0))
    {
        show_debug_message("mod植物已注册: " + arg0);
        return false;
    }
    
    var plant_data = ds_map_create();
    ds_map_set(plant_data, "shapes", ds_map_create());
    
    for (var i = 0; i < array_length(arg1); i++)
    {
        var shape_info = arg1[i];
        var shape = shape_info.shape;
        var shape_data = ds_map_create();
        ds_map_set(shape_data, "name", shape_info.name);
        ds_map_set(shape_data, "description", shape_info.description);
        ds_map_set(shape_data, "base_hp", shape_info.hp[0]);
        ds_map_set(shape_data, "base_cost", shape_info.cost[0]);
        ds_map_set(shape_data, "base_atk", shape_info.atk[0]);
        ds_map_set(shape_data, "base_range", shape_info.range[0]);
        ds_map_set(shape_data, "base_cooldown", shape_info.cooldown[0]);
        ds_map_set(shape_data, "base_cycle", shape_info.cycle[0]);
        var upgrades = ds_map_create();
        ds_map_set(shape_data, "upgrades", upgrades);
        var base_upgrade = ds_map_create();
        ds_map_add(base_upgrade, "level", 0);
        ds_map_add(base_upgrade, "hp", shape_info.hp[0]);
        ds_map_add(base_upgrade, "cost", shape_info.cost[0]);
        ds_map_add(base_upgrade, "atk", shape_info.atk[0]);
        ds_map_add(base_upgrade, "range", shape_info.range[0]);
        ds_map_add(base_upgrade, "cooldown", shape_info.cooldown[0]);
        ds_map_add(base_upgrade, "cycle", shape_info.cycle[0]);
        
        if (struct_exists(shape_info, "flame_produce"))
            ds_map_add(base_upgrade, "flame_produce", shape_info.flame_produce[0]);
        
        if (struct_exists(shape_info, "first_produce_delay"))
            ds_map_add(base_upgrade, "first_produce_delay", shape_info.first_produce_delay[0]);

        // 自定义数值（custom）：基础档按第 0 档写，其余档在 add_plant_upgrade_lite 里按 level 取
        if (struct_exists(shape_info, "custom")){
            var _ck = variable_struct_get_names(shape_info.custom);
            for (var _ci = 0; _ci < array_length(_ck); _ci++){
                var _cv = variable_struct_get(shape_info.custom, _ck[_ci]);
                ds_map_add(base_upgrade, _ck[_ci], is_array(_cv) ? _cv[0] : _cv);
            }
        }
        
        ds_map_add(upgrades, "0", base_upgrade);
        // custom 结构体本身也挂一份到形态数据上：情报岛文案变量优先从这里取
        //   （不依赖升级表是否带上 custom，注册完一定读得到）
        if (struct_exists(shape_info, "custom")) ds_map_set(shape_data, "custom", shape_info.custom);

        ds_map_add(ds_map_find_value(plant_data, "shapes"), string(shape), shape_data);
    }
    
    ds_map_add(global.plant_registry, arg0, plant_data);
    
    var max_level = is_god ? 18 : 16;
    for (var i = 1; i <= max_level; i++)
        add_plant_upgrade_lite(arg0, i, arg1);
    
    return true;
}

// ═════════════════════════════════════════════════════════════════════════
//  自定义数值（custom）自检 —— 2026-11-06
//  为什么要有：custom 写错**不会报错**，只会静默失效，或者面板上多出一个
//  没被替换的 `{变量名}`，等你看到才知道。这个函数在启动时扫一遍打日志：
//    ① key 撞内置字段   → ds_map_add 返回 false 不覆盖，值写了也不生效
//    ② key 撞技能字段   → get_plant_data_with_skill 最后一句会把它覆盖成技能值
//    ③ 同卡形态漏写     → 该形态走跨形态兜底，取到的是别的形态的值
//    ④ 值类型不对       → 只能写「数字」或「按星级取值的数组」
//    ⑤ 文案 {变量} 取不到 → 情报岛原样显示 `{变量名}`
//  只打日志、不改任何数据。出问题时在输出窗口搜 `[custom]` 就能定位。
// ═════════════════════════════════════════════════════════════════════════

/// @func info_island_text_brace_names(raw)
/// @desc 抽出文案里所有 `{…}` 用到的**变量名**（自检用）
///   2026-11-13 修：原来遇运算符就截断，只取第一个操作数 → `{2*攻击力}` 被当成变量名 "2"，
///   自检报「取不到 {2}」。现在按运算符切分，**把所有操作数都收进来、纯数字跳过**，
///   与 info_island_text_eval 的语法保持一致。
function info_island_text_brace_names(_raw){
    var _out = [];
    if (!is_string(_raw)) return _out;
    var _n = string_length(_raw);
    var _i = 1;
    while (_i <= _n){
        if (string_char_at(_raw, _i) != "{"){ _i++; continue; }

        var _expr = "";
        var _j = _i + 1;
        while (_j <= _n){
            var _c = string_char_at(_raw, _j);
            if (_c == "}") break;
            _expr += _c;
            _j++;
        }
        _i = _j + 1;

        // 按 + - * / 切操作数
        var _tok = "";
        var _len = string_length(_expr);
        for (var _k = 1; _k <= _len + 1; _k++){
            var _ch = (_k <= _len) ? string_char_at(_expr, _k) : "+";
            if (_ch == "+" || _ch == "-" || _ch == "*" || _ch == "/"){
                if (_tok != "" && !info_island_text_is_number(_tok)) array_push(_out, _tok);
                _tok = "";
                continue;
            }
            if (_ch != " " && _ch != "　" && _ch != "\n" && _ch != "\r" && _ch != "\t") _tok += _ch;
        }
    }
    return _out;
}

/// @func mod_custom_key_check()
/// @desc 扫全部卡片 × 全部形态的自定义 key 与情报岛文案变量，把问题打到控制台
/// @returns {real} 问题条数（0 = 全部正常）
function mod_custom_key_check(){
    var _tag = "[custom] ";
    var _bad = 0;

    // 调用时机不对（注册表还没建）就直接退出，别刷一屏假报错
    if (!variable_global_exists("plant_registry") || !ds_exists(global.plant_registry, ds_type_map)){
        show_debug_message(_tag + "跳过：plant_registry 还没初始化");
        return 0;
    }

    var _builtin = ["level", "hp", "cost", "atk", "range", "cooldown", "cycle",
                    "flame_produce", "first_produce_delay", "name", "description", "shape"];

    var _ids = ds_map_keys_to_array(global.plant_registry);
    for (var _i = 0; _i < array_length(_ids); _i++){
        var _id = _ids[_i];
        var _pd = global.plant_registry[? _id];
        if (!is_struct(_pd) && !ds_exists(_pd, ds_type_map)) continue;
        var _shapes = _pd[? "shapes"];
        var _sk = ds_map_keys_to_array(_shapes);
        if (array_length(_sk) == 0) continue;

        for (var _s = 0; _s < array_length(_sk); _s++){
            var _shape_s = _sk[_s];
            var _sd = _shapes[? _shape_s];
            if (!ds_map_exists(_sd, "custom")) continue;
            var _cs = _sd[? "custom"];
            var _keys = variable_struct_get_names(_cs);
            for (var _k = 0; _k < array_length(_keys); _k++){
                var _key = _keys[_k];
                var _val = variable_struct_get(_cs, _key);

                if (array_contains(_builtin, _key)){
                    show_debug_message(_tag + "✗ 撞内置字段 " + _id + " shape" + string(_shape_s) + " [" + _key + "]：ds_map_add 静默失败，这个值不会生效");
                    _bad++;
                }
                // 2026-11-13 用户口径：以下两类不再报——它们都有兜底、不影响运行
                //   ① 自定义 key 与技能字段同名：技能值按档位覆盖，属预期用法（春笋「准备时间」就是）
                //   ② 某形态漏写某个 key：运行时会有跨形态兜底（info_island_text_vars 里补一遍）
                if (!is_real(_val) && !is_array(_val)){
                    show_debug_message(_tag + "✗ 值类型 " + _id + " shape" + string(_shape_s) + " [" + _key + "]：只能写数字或按星级取值的数组");
                    _bad++;
                }
            }
        }
    }

    // ⑤ 情报岛文案里的 {变量} 取不到
    //   ⚠️ 这里**不能**调 info_island_text_vars / get_plant_data_with_skill：
    //      后者会把技能值 `upgrade_data[? info_id] = ...` 写回注册表第 0 档，
    //      启动时扫一遍等于偷偷改了 0 星数值。所以只做只读的名字存在性判断。
    if (variable_global_exists("info_island") && ds_exists(global.info_island, ds_type_map)){
        var _tids = ds_map_keys_to_array(global.info_island);
        for (var _t = 0; _t < array_length(_tids); _t++){
            var _cid = _tids[_t];
            var _txt = global.info_island[? _cid];
            if (!is_string(_txt) || string_pos("{", _txt) <= 0) continue;
            var _names = info_island_text_brace_names(_txt);
            if (array_length(_names) == 0) continue;

            // 可用变量名：固定几个 + 第 0 档升级表的所有 key（含 custom）+ 各形态 custom
            var _avail = {};
            var _fixed = ["攻击力", "生命值", "体力", "能量消耗", "攻击间隔", "冷却时间", "范围",
                          "火苗产量", "星级", "转职", "技能", "形态名"];
            for (var _f = 0; _f < array_length(_fixed); _f++) variable_struct_set(_avail, _fixed[_f], true);

            var _sd0 = get_plant_shape_data(_cid, 0);
            if (_sd0 == undefined) continue;              // 不在卡表里的（纯文案条目）跳过
            if (ds_map_exists(_sd0, "upgrades")){
                var _up0 = _sd0[? "upgrades"];
                if (ds_map_exists(_up0, "0")){
                    var _uk = ds_map_keys_to_array(_up0[? "0"]);
                    for (var _u = 0; _u < array_length(_uk); _u++) variable_struct_set(_avail, _uk[_u], true);
                }
            }
            for (var _sh = 0; _sh < 4; _sh++){
                var _sd2 = get_plant_shape_data(_cid, _sh);
                if (_sd2 == undefined) continue;
                if (!ds_map_exists(_sd2, "custom")) continue;
                var _cs2 = _sd2[? "custom"];
                var _ck2 = variable_struct_get_names(_cs2);
                for (var _c2 = 0; _c2 < array_length(_ck2); _c2++) variable_struct_set(_avail, _ck2[_c2], true);
            }

            // 技能字段名：运行时 get_plant_data_with_skill 会把技能值并进数据表，
            //   情报岛文案直接能用（蛇蛇酒「持续时间」、时光机/转龙壶「前摇」都是这条路）
            if (ds_map_exists(global.skill_registry, _cid)){
                var _se3 = global.skill_registry[? _cid];
                if (is_array(_se3) && array_length(_se3) >= 1) variable_struct_set(_avail, string(_se3[0]), true);
                // 技能表里叫 duration 的，情报岛显示成「持续时间」（见 info_island_text_vars 的换算）
                if (is_array(_se3) && array_length(_se3) >= 1 && string(_se3[0]) == "duration")
                    variable_struct_set(_avail, "持续时间", true);
            }

            for (var _n = 0; _n < array_length(_names); _n++){
                if (!variable_struct_exists(_avail, _names[_n])){
                    show_debug_message(_tag + "✗ 文案变量取不到 " + _cid + " {" + _names[_n] + "}：情报岛会原样显示这段大括号");
                    _bad++;
                }
            }
        }
    }

    if (_bad == 0) show_debug_message(_tag + "自检通过：自定义数值 / 文案变量全部正常");
    else show_debug_message(_tag + "自检发现 " + string(_bad) + " 条问题（往上翻找 ✗ 开头的行）");
    return _bad;
}
