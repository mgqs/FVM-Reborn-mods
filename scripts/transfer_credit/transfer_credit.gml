/// 转职凭证（transfer credit）数据层
/// 2026-10-25 建立：只做「凭证本体」——id 规则、名字、底板/卡面绘制、持有列表
/// 详细方案见 桌面\fvm的ai\转职系统方案.md
///
/// id 规则：transfer_<card_id>_<shape>，shape 1=一转 / 2=二转（本期只做普卡 1/2）
/// 数量存在 global.save_data.inventory 里（复用 add_material_amount / get_material_amount），
/// 但**不注册进 global.material_pool** —— 否则道具页会被上百个空格子塞满。

/// @function transfer_credit_id(card_id, shape)
function transfer_credit_id(_card_id, _shape) {
    if (_shape <= 0) return "";
    return "transfer_" + string(_card_id) + "_" + string(_shape);
}

/// @function transfer_credit_parse(id)
/// @desc 解析凭证 id → { card_id, shape }；不是凭证返回 undefined
function transfer_credit_parse(_id) {
    if (!is_string(_id)) return undefined;
    if (string_pos("transfer_", _id) != 1) return undefined;

    var _rest = string_delete(_id, 1, 9);           // 去掉 "transfer_"
    var _pos = 0;
    // 从后往前找最后一个下划线（卡 id 里本身可能有下划线）
    for (var _i = string_length(_rest); _i >= 1; _i--) {
        if (string_char_at(_rest, _i) == "_") { _pos = _i; break; }
    }
    if (_pos <= 0) return undefined;

    var _cid = string_copy(_rest, 1, _pos - 1);
    var _sh_s = string_delete(_rest, 1, _pos);
    if (_cid == "" || _sh_s == "") return undefined;
    if (!is_real(real(_sh_s))) return undefined;

    var _sh = real(_sh_s);
    if (_sh < 1) return undefined;
    return { card_id: _cid, shape: floor(_sh) };
}

/// @function transfer_credit_is(id)
function transfer_credit_is(_id) {
    return !is_undefined(transfer_credit_parse(_id));
}

/// @function transfer_credit_tier_name(shape)
function transfer_credit_tier_name(_shape) {
    switch (_shape) {
        case 1: return "一转凭证";
        case 2: return "二转凭证";
        case 3: return "三转凭证";
        case 4: return "四转凭证";
        case 5: return "终转凭证";
    }
    return "转职凭证";
}

/// @function transfer_credit_card_name(card_id)
/// @desc 卡的**本体名（0 转名字）**，不带档位后缀。凭证名 / 商店名 / 抽卡提示用它；
///       转职成功提示也不用这个（提示已统一为「卡片转职成功！」）。
/// ⚠️ 卡名在 global.plant_registry 里（register_plant / register_plant_lite / mod_register_plant_lite
///    都写了 "name"），而 player_deck 的形态数据（register_card）**没有** name 字段，
///    只能当第二来源兜底 —— 顺序别反，否则名字会退回成卡 id。
function transfer_credit_card_name(_card_id) {
    // ① 植物注册表（卡名正源）
    var _meta = get_plant_shape_data(_card_id, 0);
    if (_meta != undefined) {
        var _v = _meta[? "name"];
        if (!is_undefined(_v) && is_string(_v) && _v != "") return _v;
    }

    // ② 卡池形态数据（没有 name 字段，留着兜底）
    var _d = deck_get_card_data(_card_id, 0);
    if (_d != noone && ds_exists(_d, ds_type_map) && ds_map_exists(_d, "name")) {
        var _v2 = _d[? "name"];
        if (!is_undefined(_v2) && is_string(_v2) && _v2 != "") return _v2;
    }

    return string(_card_id);
}

/// @function transfer_credit_shape_name(card_id, shape)
/// @desc 某张卡**某一档**的名字（0 = 本体名，1 = 一转名……）。
///       ⚠️ 2026-10-26 起**没有调用点**：转职成功提示后来统一成「卡片转职成功！」（用户口径），
///          不再区分名字。函数留着备用（图鉴/任务/播报之类要按档位显示名字时能直接用）。
///       查不到该档名 → 退回本体名，再退回卡 id。
function transfer_credit_shape_name(_card_id, _shape) {
    var _meta = get_plant_shape_data(_card_id, _shape);
    if (_meta != undefined) {
        var _v = _meta[? "name"];
        if (!is_undefined(_v) && is_string(_v) && _v != "") return _v;
    }
    return transfer_credit_card_name(_card_id);
}

/// @function transfer_credit_name(card_id, shape)
/// @desc 凭证名 = 本体名 + 档位（「泡椒春笋（一转凭证）」），不带形态名、不带 A/B/C 字母
function transfer_credit_name(_card_id, _shape) {
    return transfer_credit_card_name(_card_id) + "（" + transfer_credit_tier_name(_shape) + "）";
}

/// @function transfer_credit_name_from_id(id)
function transfer_credit_name_from_id(_id) {
    var _p = transfer_credit_parse(_id);
    if (is_undefined(_p)) return "";
    return transfer_credit_name(_p.card_id, _p.shape);
}

/// @function transfer_credit_description(card_id, shape)
function transfer_credit_description(_card_id, _shape) {
    return transfer_credit_name(_card_id, _shape) + "\n"
        + "转职凭证：在合成屋-卡片转职中使用。\n"
        + "持有数量：" + string(get_material_amount(transfer_credit_id(_card_id, _shape)));
}

/// @function transfer_credit_bg_sprite(shape, slot)
/// @desc slot: 0/A = A 底板，1/B = B 底板，2/C = C 底板（一转只有 A/B）
function transfer_credit_bg_sprite(_shape, _slot) {
    if (_shape <= 1) {
        if (_slot == 1) return spr_transfer_bg_1b;
        return spr_transfer_bg_1a;
    }
    switch (_slot) {
        case 1: return spr_transfer_bg_2b;
        case 2: return spr_transfer_bg_2c;
    }
    return spr_transfer_bg_2a;
}

/// @function transfer_credit_face_sprite(card_id, shape)
/// @desc 该卡对应形态的 sprite；拿不到退回本体；再拿不到返回 -1
function transfer_credit_face_sprite(_card_id, _shape) {
    var _sh = _shape;
    while (_sh > 0) {
        var _d = deck_get_card_data(_card_id, _sh);
        if (_d != noone && ds_exists(_d, ds_type_map)) {
            if (ds_map_exists(_d, "sprite")) {
                var _spr = _d[? "sprite"];
                if (_spr != -1) return _spr;
            }
        }
        _sh -= 1;
    }
    var _d0 = deck_get_card_data(_card_id, 0);
    if (_d0 != noone && ds_exists(_d0, ds_type_map) && ds_map_exists(_d0, "sprite")) {
        var _spr0 = _d0[? "sprite"];
        if (_spr0 != -1) return _spr0;
    }

    // ③ 命名约定兜底：只有 plant_registry 名字、没走 register_card 的卡（多数 mod 卡）
    //    顺序：spr_<id>_<shape> → spr_<id>_<shape>_icon → spr_<id> → spr_<id>_icon
    //    （2026-10-25 补后两个 `_icon` 变体：有些卡只导了 icon、没有整卡图，否则槽里只剩底板）
    if (_shape > 0) {
        var _alt = asset_get_index("spr_" + string(_card_id) + "_" + string(_shape));
        if (_alt != -1) return _alt;
        var _alti = asset_get_index("spr_" + string(_card_id) + "_" + string(_shape) + "_icon");
        if (_alti != -1) return _alti;
    }
    var _alt0 = asset_get_index("spr_" + string(_card_id));
    if (_alt0 != -1) return _alt0;
    var _alt0i = asset_get_index("spr_" + string(_card_id) + "_icon");
    if (_alt0i != -1) return _alt0i;

    return -1;
}

/// @function transfer_credit_draw(x, y, card_id, shape, size, slot, alpha)
/// @desc 画一张凭证：底板 + 卡面。x,y 是**左上角**（不是中心）
///       size = 凭证外框显示边长（像素）。44 = 原始大小；背包格子用 74/88；商店用 110
///       卡面按**固定缩放 + 精灵原点**画（跟卡列表同款），不用 sprite_get_bbox_*、不查表
/// ⚠️ 三个坑（2026-10-25 修）：
///    ① 底板 sprite 的 origin 是 (22,22)，draw_sprite_ext 以原点定位 → 必须补偿半个身位，
///       否则底板会往左上偏 22*缩放，和卡面对不上。
///    ② 卡面**不用 draw_sprite_part**：工程所有纹理组都开了 autocrop，
///       手册明确说自动裁剪后 part 的区域会取错。改成整幅图缩放平移（含透明留白，看不出来）。
///    ③ 卡面**不用 sprite_get_bbox_***：autocrop 下运行时给的值不可信（实机症状：卡面放大盖满 /
///       整体偏出槽外）。surface 实测也放弃了（GM 渲染目标是栈，set/reset 必须成对）。
///       最终就按卡列表的画法：固定缩放 + 原点，零数据、零运行时风险。
function transfer_credit_draw(_x, _y, _card_id, _shape, _size, _slot = 0, _alpha = 1) {
    if (_size <= 0) _size = 44;
    var _s = _size / 44;

    var _bg = transfer_credit_bg_sprite(_shape, _slot);
    draw_sprite_ext(_bg, 0,
        _x + sprite_get_xoffset(_bg) * _s,
        _y + sprite_get_yoffset(_bg) * _s,
        _s, _s, 0, c_white, _alpha);

    var _spr = transfer_credit_face_sprite(_card_id, _shape);
    if (_spr == -1) return;

    var _cx = _x + 22 * _s;                      // 底板中心
    var _cy = _y + 22 * _s;

    // 卡面：**跟卡列表 / 融合页同一套画法** —— 固定缩放、按精灵原点落笔，不做任何包围盒归一
    //   （用户 2026-10-26 定：宁可顶到框上，也不为几十张异常图维护数据表）
    //   两个常数从 551 张卡面实测统计出来：内容中位数 75×77、内容中心在原点上方约 37px
    //   → k  = 卡面缩放（44 空间）：0.42 时中位内容约 31.5×32.3，基本填满 34 内窗
    //        0.46 起会盖到内框边；0.50 ≈ 正好撑满（再大就压框了）
    //     下移 = 让「内容中心」落在窗口中心，跟着 k 走：offset ≈ 37 × k（0.42 → 15.5，取 15）
    //   个别大画布 / 宽图的卡会偏小或压框，先这样，真碍眼再单独调
    var _k = 0.42 * _s;
    draw_sprite_ext(_spr, 0, _cx, _cy + 15 * _s, _k, _k, 0, c_white, _alpha);
}

/// @function transfer_credit_draw_id(x, y, id, size, slot, alpha)
function transfer_credit_draw_id(_x, _y, _id, _size, _slot = 0, _alpha = 1) {
    var _p = transfer_credit_parse(_id);
    if (is_undefined(_p)) return;
    transfer_credit_draw(_x, _y, _p.card_id, _p.shape, _size, _slot, _alpha);
}

/// @function transfer_credit_owned_ids()
/// @desc 背包里持有的凭证 id 列表（数量 > 0）
///       排序（2026-10-25 用户定，方案 B）：
///         ① 先「一转及以下」一段、再「二转及以上」一段；
///         ② 段内按**获取顺序** —— inventory 是数组，新道具走 array_push 追加到末尾，
///            所以数组下标就是「第一次获得」的先后，遍历一遍天然有序，不用再排字母序。
///            同一份凭证后来再获得只加数量、位置不变。
///         ③ 两段之间**强制换行**（不空行）：绘制端用 transfer_credit_split_index() 算断点。
function transfer_credit_owned_ids() {
    var _one = [];
    var _two = [];
    var _inv = global.save_data.inventory;
    var _n = array_length(_inv);
    for (var _i = 0; _i < _n; _i++) {
        var _id = _inv[_i].id;
        if (!transfer_credit_is(_id)) continue;
        if (_inv[_i].amount <= 0) continue;
        var _p = transfer_credit_parse(_id);
        if (_p.shape <= 1) array_push(_one, _id);
        else array_push(_two, _id);
    }
    var _out = [];
    var _n1 = array_length(_one);
    for (var _a = 0; _a < _n1; _a++) array_push(_out, _one[_a]);
    var _n2 = array_length(_two);
    for (var _b = 0; _b < _n2; _b++) array_push(_out, _two[_b]);
    return _out;
}

/// @function transfer_credit_split_index(list)
/// @desc 列表里「第一段（一转及以下）」的条目数；二转段从这一格之后**换行**开始画
///       （方案 B：分两段但不空行）
function transfer_credit_split_index(_list) {
    var _c = 0;
    var _n = array_length(_list);
    for (var _i = 0; _i < _n; _i++) {
        var _p = transfer_credit_parse(_list[_i]);
        if (!is_undefined(_p) && _p.shape <= 1) _c += 1;
    }
    return _c;
}

// ─────────────────────────────────────────────────────────────
// 购买 / 获取资格判据（2026-10-25 待办 #29）
// ⚠️ 商店置灰、确认弹窗兜底、以后转职界面都调这几个，别各自写 if
// ─────────────────────────────────────────────────────────────

/// @function transfer_credit_card_max_shape(card_id)
/// @desc 玩家把这张卡**练到过**的最高形态（读存档 max_shape）；没拥有返回 -1
function transfer_credit_card_max_shape(_card_id) {
    var _uc = global.save_data.unlocked_cards;
    var _n = array_length(_uc);
    for (var _i = 0; _i < _n; _i++) {
        if (_uc[_i].id == _card_id) {
            if (variable_struct_exists(_uc[_i], "max_shape")) return _uc[_i].max_shape;
            return 0;
        }
    }
    return -1;
}

/// @function transfer_credit_card_shapes_max(card_id)
/// @desc 这张卡**注册了**的最高形态序号（0 起算），查不到返回 -1。
///       ⚠️ 不能只用 card_max_available_shape()：它只读 plant_registry（get_plant_shape_data），
///          而 `yanyantu` / `12yinliao` / `blueberry_tower` / `baiyang` / `athena` / `shuangzi` / `war_god`
///          这类卡在植物注册表里只有 shape 0，转职界面就会误报「这张卡已经转满了」（2026-10-25 待办 #30 C）。
///       正源 = 卡池形态表 global.player_deck[卡id][? "shapes"]（register_card 写的那份），
///       与 plant_registry 取较大值兜住上游 native 注册风格。
function transfer_credit_card_shapes_max(_card_id) {
    var _max = card_max_available_shape(_card_id);

    if (is_undefined(global.player_deck) || !ds_exists(global.player_deck, ds_type_list)) return _max;
    var _n = ds_list_size(global.player_deck);
    for (var _i = 0; _i + 1 < _n; _i += 2) {
        if (global.player_deck[| _i] != _card_id) continue;
        var _card = global.player_deck[| _i + 1];
        var _shapes = _card[? "shapes"];
        if (is_undefined(_shapes) || !ds_exists(_shapes, ds_type_list)) break;
        var _sn = ds_list_size(_shapes);
        for (var _j = 0; _j < _sn; _j++) {
            var _sd = _shapes[| _j];
            var _v = _sd[? "shape"];
            if (!is_undefined(_v) && is_real(_v)) _max = max(_max, _v);
        }
        break;
    }
    return _max;
}

/// @function transfer_credit_has(card_id, shape)
/// @desc 背包里**还有**这一档凭证（买了没用也算持有）
function transfer_credit_has(_card_id, _shape) {
    return (get_material_amount(transfer_credit_id(_card_id, _shape)) > 0);
}

/// @function transfer_credit_progress(card_id)
/// @desc 这张卡的「进度」= max(练到的形态, 背包里持有的最高档凭证)，最低 0。
///       拿凭证不转职也算进度 —— 防止「囤着凭证导致还能再买一次同一档」
///       ⚠️ 2026-10-26 起商店**没有调用点**了（跳档限制按用户要求去掉）；
///          留着给抽卡「按进度发凭证」(#28) 和以后的门槛/CD 用。
function transfer_credit_progress(_card_id) {
    var _p = max(0, transfer_credit_card_max_shape(_card_id));
    for (var _s = 1; _s <= 5; _s++) {
        if (transfer_credit_has(_card_id, _s)) _p = max(_p, _s);
    }
    return _p;
}

/// @function transfer_credit_tower_done_key()
/// @desc 已通关的**最高魔塔关**，编码成整数 = 层 × 100 + 小关（1-1 → 101，12-2 → 1202），0 = 一层没打。
///       魔塔关卡 id 形如 `tower_cake_<层>_<小关>`，普通与精英都算，取最大的一关。
///       用整数是为了直接比大小（"12-2" 比 "9-2" 大），显示时用 transfer_credit_tower_key_text()。
function transfer_credit_tower_done_key() {
    var _best = 0;
    var _lists = [];
    if (variable_struct_exists(global.save_data, "completed_levels")) array_push(_lists, global.save_data.completed_levels);
    if (variable_struct_exists(global.save_data, "completed_elite_levels")) array_push(_lists, global.save_data.completed_elite_levels);

    var _prefix = "tower_cake_";
    var _plen = string_length(_prefix);
    for (var _li = 0; _li < array_length(_lists); _li++) {
        var _arr = _lists[_li];
        if (!is_array(_arr)) continue;
        for (var _i = 0; _i < array_length(_arr); _i++) {
            var _id = _arr[_i];
            if (!is_string(_id)) continue;
            if (string_copy(_id, 1, _plen) != _prefix) continue;

            // 前缀后两段数字：层、小关（tower_cake_12_3 → 12 / 3）
            var _rest = string_delete(_id, 1, _plen);
            var _dash = string_pos("_", _rest);
            if (_dash <= 0) continue;
            var _f_s = string_copy(_rest, 1, _dash - 1);
            var _s_s = string_delete(_rest, 1, _dash);
            if (!is_real(real(_f_s)) || !is_real(real(_s_s))) continue;
            var _key = floor(real(_f_s)) * 100 + floor(real(_s_s));
            if (_key > _best) _best = _key;
        }
    }
    return _best;
}

/// @function transfer_credit_tower_key_text(key)
/// @desc 把「层×100+小关」还原成 `12-2` 这种文本（给提示词用）
function transfer_credit_tower_key_text(_key) {
    if (_key <= 0) return "";
    return string(_key div 100) + "-" + string(_key mod 100);
}

/// @function transfer_credit_tower_key_from(value)
/// @desc 商品字段 `tower_floor` 的两种写法统一成 key：
///       `12`      → 12-1（第 12 层第一小关）
///       `"12-2"`  → 12-2
///       0 / "" / 非法 → 0（不限制）
function transfer_credit_tower_key_from(_v) {
    if (is_string(_v)) {
        var _v2 = string_replace_all(_v, " ", "");      // 容忍 "12 - 2" 这种写法
        if (_v2 == "") return 0;
        var _dash = string_pos("-", _v2);
        if (_dash > 0) {
            var _f_s = string_copy(_v2, 1, _dash - 1);
            var _s_s = string_delete(_v2, 1, _dash);
            if (!is_real(real(_f_s)) || !is_real(real(_s_s))) return 0;
            if (real(_f_s) <= 0) return 0;              // "0-1" / "0" 都当不限制
            return floor(real(_f_s)) * 100 + floor(real(_s_s));
        }
        if (real(_v2) <= 0) return 0;                    // "0" = 不限制
        return floor(real(_v2)) * 100 + 1;
    }
    // ⚠️ 0 必须原样返回 0 —— 之前漏了这层判断，0 被算成 key=1（= 0-1），
    //    结果写了 tower_floor: 0 的商品也一直提示「魔塔通关层数不足」（2026-10-26 用户实测抓到的 bug）
    if (is_real(_v)) {
        if (_v <= 0) return 0;
        return floor(_v) * 100 + 1;
    }
    return 0;
}

/// @function transfer_credit_tower_floor_req(card_id, shape)
/// @desc 该档凭证在**商店注册表**里的爬塔门槛，返回 key（层×100+小关）；0 = 不限制。
///       懒扫 `global.goods_map` 里 `type == "credit"` 且带 `tower_floor` 的商品，缓存到 `global._tc_tower_req`。
function transfer_credit_tower_floor_req(_card_id, _shape) {
    if (!variable_global_exists("_tc_tower_req")) {
        var _map = {};
        if (variable_global_exists("goods_map") && ds_exists(global.goods_map, ds_type_map)) {
            var _key = ds_map_find_first(global.goods_map);
            while (!is_undefined(_key)) {
                var _g = global.goods_map[? _key];
                if (variable_struct_exists(_g, "type") && _g.type == "credit"
                    && variable_struct_exists(_g, "credit_shape") && _g.credit_shape > 0
                    && variable_struct_exists(_g, "tower_floor")) {
                    var _tk = transfer_credit_tower_key_from(_g.tower_floor);
                    if (_tk > 0) {
                        var _p = transfer_credit_parse(_g.unlock_item_id);
                        if (!is_undefined(_p)) {
                            _map[$ string(_p.card_id) + "_" + string(_p.shape)] = _tk;
                        }
                    }
                }
                _key = ds_map_find_next(global.goods_map, _key);
            }
        }
        global._tc_tower_req = _map;
    }

    var _k = string(_card_id) + "_" + string(_shape);
    var _t = global._tc_tower_req;
    if (variable_struct_exists(_t, _k)) return _t[$ _k];
    return 0;
}

/// @function transfer_credit_buyable_locked(card_id, shape)
/// @desc 是不是「**永久锁**」（置灰 + 售完罩 + 点不动）——只有这三条：
///       ① 形态不存在 ② 背包已持有该档凭证 ③ 已经转职到该形态。
///       爬塔门槛、余额不足属于「临时不满足」：**不置灰、不盖售完**，点购买时才弹提示拦住
///       （用户 2026-10-26 定：这些点一下会变，不该看起来像“卖完了”）
function transfer_credit_buyable_locked(_card_id, _shape) {
    if (_shape > transfer_credit_card_shapes_max(_card_id)) return true;
    if (transfer_credit_has(_card_id, _shape)) return true;
    if (transfer_credit_card_max_shape(_card_id) >= _shape) return true;
    return false;
}

/// @function transfer_credit_buyable(card_id, shape)
/// @desc 商店能不能买这一档 → 返回 "" = 可买；否则返回**不可买原因**（直接拿去 show_notice）
///       2026-10-26 用户改口径：
///         ① 形态不存在 → 「该形态不存在」
///         ② 已持有该档凭证 / 已转职到该形态 → 统一「不满足购买条件」（不告诉玩家是哪种）
///         ③ **「只能买下一档」已去掉** —— 任何档位都能直接买，不要求先有前一档
///         ④ 爬塔门槛 → 「魔塔通关层数不足」
function transfer_credit_buyable(_card_id, _shape) {
    // 形态是否存在：走 transfer_credit_card_shapes_max()，别用 get_plant_shape_data ——
    // 只注册 shape 0 的那批卡会被判「该形态不存在」，一转/二转凭证全部买不了（2026-10-25 待办 #30 C）
    if (_shape > transfer_credit_card_shapes_max(_card_id)) return "该形态不存在";

    // 已持有 / 已转职：合并成一句
    if (transfer_credit_has(_card_id, _shape)) return "不满足购买条件";
    if (transfer_credit_card_max_shape(_card_id) >= _shape) return "不满足购买条件";

    // 爬塔门槛（商品级 tower_floor；不写 / 0 = 不限制）
    var _need_key = transfer_credit_tower_floor_req(_card_id, _shape);
    if (_need_key > 0 && transfer_credit_tower_done_key() < _need_key) return "魔塔通关层数不足";

    return "";
}
// ─────────────────────────────────────────────────────────────────────────────
// 「威望」标签绘制（2026-10-26）
//   素材：原版 SWF 导出 转职系统素材\images\567.png（32x18，深蓝底已抠成透明）。
//   ⚠️ 只用于**底部余额条**（原版写法「[威望]1573」）。
//      商店凭证价格行**不用**它 —— 用户 2026-10-26 定：价格和「威望」两字自写、同色（见
//      obj_shop_buy_btn/Draw_0 的 `draw_text(x, y-62, string(cost) + "威望")`）。
// ─────────────────────────────────────────────────────────────────────────────

/// @function ui_prestige_tag_w(scale)
/// @desc 「威望」标签宽
function ui_prestige_tag_w(_scale) {
    return sprite_get_width(spr_ui_prestige_tag) * _scale;
}

/// @function ui_prestige_tag_h(scale)
/// @desc 「威望」标签高
function ui_prestige_tag_h(_scale) {
    return sprite_get_height(spr_ui_prestige_tag) * _scale;
}

/// @function ui_prestige_tag_draw(x, cy, scale)
/// @desc 画「威望」标签：x = 左端、cy = 垂直中心
function ui_prestige_tag_draw(_x, _cy, _scale) {
    draw_sprite_ext(spr_ui_prestige_tag, 0, _x, _cy - ui_prestige_tag_h(_scale) * 0.5,
        _scale, _scale, 0, c_white, 1);
}
/// @function credit_shop_sort_key(goods_id)
/// @desc 凭证页列表的排序键（2026-10-26 用户口径）：
///       ① **同一张卡的凭证必须挨在一起**；② 卡内**先一转后二转**；③ 不做全局「先所有一转再所有二转」。
///       所以键 = 「卡id|档位」，按字符串升序即可（档位是单字符，1 一定在 2 前面）。
///       兑换项（`credit_shape == 0`，如「威望 x1000」）没有卡 → 键前缀用 `~`（ASCII 126，排在所有字母后）→ 垫底。
function credit_shop_sort_key(_gid) {
    var _g = global.goods_map[? _gid];
    if (!variable_struct_exists(_g, "credit_shape") || _g.credit_shape <= 0) {
        return "~|" + string(_gid);                       // 兑换项：排最后，内部按 id
    }
    var _p = transfer_credit_parse(_g.unlock_item_id);
    var _cid = is_undefined(_p) ? string(_gid) : string(_p.card_id);
    return _cid + "|" + string(_g.credit_shape);
}
