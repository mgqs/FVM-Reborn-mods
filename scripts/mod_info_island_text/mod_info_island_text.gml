/// =====================================================================
/// mod_info_island_text —— 情报岛「文案变量」（2026-11-05）
///   卡片描述里可以写 {变量}，面板按「当前查看的形态 / 星级 / 技能」实时填值：
///     {攻击力} {生命值} {体力} {能量消耗} {攻击间隔}（秒）{冷却时间}（秒）{火苗产量} {范围}
///     {星级} {转职} {技能} {形态名}
///     以及卡片注册里 custom 结构体的任意字段（如 {灼烧伤害} {每秒限伤} {每跳间隔}）
///   🔴 只认大括号：老的 `[攻击力]` / `[喷壶类]` 一律不动（方括号里既有数字占位又有分类标签，没法区分）
///   🔴 支持四则运算，从左到右连算：{攻击力/100}、{攻击力*2/100}（能量喵 atk 存 ×100，靠文案自己 /100）
///   找不到的变量名 → 原样保留 `{xxx}`，方便一看就知道写错了
/// =====================================================================

/// @func info_island_text_num(value)
/// @desc 数值格式化：整数不带小数点，小数最多 2 位；undefined → 无
function info_island_text_num(_v){
    if (is_undefined(_v)) return "无";
    if (is_string(_v)) return _v;
    var _r = round(_v * 100) / 100;
    if (abs(_r - round(_r)) < 0.0001) return string(round(_r));
    return string(_r);
}

/// @func info_island_text_vars(card_id, shape, level, skill)
/// @desc 当前查看状态下可用的变量表（ds_map）。用完记得 ds_map_destroy
///   基础字段来自 get_plant_data_with_skill；custom 结构体里的字段原样带过来
///   当前形态缺的 custom 字段会去同卡其它形态兜底（文案是整卡一份，不分形态）
function info_island_text_vars(_cid, _shape, _level, _skill){
    var _v = ds_map_create();
    var _info = get_plant_data_with_skill(_cid, _shape, _level, _skill);
    if (_info != undefined){
        _v[? "攻击力"]   = _info[? "atk"];
        _v[? "生命值"]   = _info[? "hp"];
        _v[? "体力"]     = _info[? "hp"];
        _v[? "能量消耗"] = _info[? "cost"];
        _v[? "攻击间隔"] = _info[? "cycle"] / 60;      // 面板口径：帧 → 秒
        _v[? "冷却时间"] = _info[? "cooldown"] / 60;
        _v[? "范围"]     = _info[? "range"];
        // 持续时间（计时器 / 电鳗这类）：技能表里叫 duration，存的是**帧**，面板按秒显示
        if (ds_map_exists(_info, "duration")) _v[? "持续时间"] = _info[? "duration"] / 60;
        if (ds_map_exists(_info, "flame_produce")) _v[? "火苗产量"] = _info[? "flame_produce"];

        // custom 透传：注册表里没列进「基础字段」的 key 一律当自定义数值
        var _keys = ds_map_keys_to_array(_info);
        var _skip = ["level", "hp", "cost", "atk", "range", "cooldown", "cycle", "flame_produce", "first_produce_delay"];
        for (var _i = 0; _i < array_length(_keys); _i++){
            var _k = _keys[_i];
            if (array_contains(_skip, _k)) continue;
            _v[? _k] = _info[? _k];
        }
    }
    _v[? "星级"] = _level;
    _v[? "转职"] = _shape;
    _v[? "技能"] = _skill;
    var _sd = get_plant_shape_data(_cid, _shape);
    if (_sd != undefined && ds_map_exists(_sd, "name")) _v[? "形态名"] = string(_sd[? "name"]);

    // custom 结构体（注册时直接挂在形态数据上，比升级表更可靠）：按当前星级取值，覆盖同名项
    // 🔴 2026-11-13 用户口径：卡片和技能表都有同一个 key 时，**以技能表为准**。
    //   get_plant_data_with_skill 最后一句已经把技能值写进 _info（custom 是它的兜底基础值），
    //   这里如果再把 custom 盖回去，就会出现「面板显示 45，实际按技能档 80 在跑」的错位。
    var _skill_key = "";
    if (ds_map_exists(global.skill_registry, _cid)){
        var _se = global.skill_registry[? _cid];
        if (is_array(_se) && array_length(_se) >= 1) _skill_key = string(_se[0]);
    }
    if (_sd != undefined && ds_map_exists(_sd, "custom")){
        var _cs = _sd[? "custom"];
        var _ck = variable_struct_get_names(_cs);
        for (var _ci = 0; _ci < array_length(_ck); _ci++){
            var _key_c = _ck[_ci];
            if (_key_c == _skill_key) continue;      // 技能表优先，_info 里已是技能值
            var _cv = variable_struct_get(_cs, _key_c);
            if (is_array(_cv)) _v[? _key_c] = _cv[clamp(_level, 0, array_length(_cv) - 1)];
            else _v[? _key_c] = _cv;
        }
    }

    // 跨形态兜底（2026-11-06）：文案是「整卡一份」，不分形态，但变量按当前形态取。
    //   某个 key 只写在别的形态上（如菠萝面包只有 1·2 转写了 灼烧伤害）时，当前形态会取不到、
    //   于是原样吐出 `{灼烧伤害}`。这里补一遍：当前形态没有的 custom key，去同卡其它形态找第一份有的。
    //   只补「缺的」，不覆盖已有的（所以当前形态自己的数值永远优先）
    for (var _sh2 = 0; _sh2 < 4; _sh2++){
        if (_sh2 == _shape) continue;
        var _sd2 = get_plant_shape_data(_cid, _sh2);
        if (_sd2 == undefined) continue;
        if (!ds_map_exists(_sd2, "custom")) continue;
        var _cs2 = _sd2[? "custom"];
        var _ck2 = variable_struct_get_names(_cs2);
        for (var _c2 = 0; _c2 < array_length(_ck2); _c2++){
            var _k2 = _ck2[_c2];
            if (ds_map_exists(_v, _k2)) continue;
            var _cv2 = variable_struct_get(_cs2, _k2);
            if (is_array(_cv2)) _v[? _k2] = _cv2[clamp(_level, 0, array_length(_cv2) - 1)];
            else _v[? _k2] = _cv2;
        }
    }
    return _v;
}

/// @func info_island_text_eval(expr, vars)
/// @desc 算一个 {…} 里的内容：变量名 + 若干「运算符 + 数字」。不认识的变量返回 undefined
/// 🔴 变量名 / 数字里的**所有空白都要跳过**：半角空格、全角空格、`\n`、`\r`、`\t`。
///    2026-11-06 踩过：`{灼烧伤害*5}` 被编辑器/手改塞进了换行变成 `{灼烧伤害\n*5}`，
///    只跳空格不跳换行 → 变量名成了「灼烧伤害\n」→ 查不到 → 整串原样显示。
/// @func info_island_text_is_number(tok)
/// @desc 纯数字判断（只认 0-9 和一个小数点），避免 real() 把写错的串当成 0
function info_island_text_is_number(_s){
    if (!is_string(_s) || _s == "") return false;
    var _len = string_length(_s);
    // 2026-11-13：支持「35%」这种百分比写法（末尾一个 %），换算成 0.35
    if (string_char_at(_s, _len) == "%"){
        _len--;
        if (_len <= 0) return false;
    }
    var _dot = 0;
    for (var _d = 1; _d <= _len; _d++){
        var _dc = string_char_at(_s, _d);
        if (_dc == "."){
            _dot++;
            if (_dot > 1 || _d == _len) return false;   // 多点 / 结尾是点 → 不算数字
            continue;
        }
        if (_dc < "0" || _dc > "9") return false;
    }
    return true;
}

/// @func info_island_text_operand(tok, vars)
/// @desc 取一个操作数：纯数字直接转 real，否则当变量名查表（必须数值型）。取不到返回 undefined
function info_island_text_operand(_tok, _v){
    if (!is_string(_tok) || _tok == "") return undefined;
    if (info_island_text_is_number(_tok)){
        // 2026-11-13：`35%` → 0.35，方便直接写 {35%*攻击力}
        if (string_char_at(_tok, string_length(_tok)) == "%")
            return real(string_copy(_tok, 1, string_length(_tok) - 1)) / 100;
        return real(_tok);
    }
    if (!ds_map_exists(_v, _tok)) return undefined;
    var _raw = _v[? _tok];
    if (!is_real(_raw)) return undefined;              // 形态名这类字符串不参与运算
    return _raw;
}

/// @func info_island_text_eval(expr, vars)
/// @desc 算一个 {…} 里的内容：操作数 + 若干「运算符 + 操作数」，**从左到右连算**
///   操作数 = 变量名 **或** 纯数字 → 变量之间也能算：
///     {攻击力/100}、{攻击力*2/100}（原来就支持）
///     {毒雾持续*毒雾次数}、{120/毒雾次数}、{毒雾持续/毒雾次数}（2026-11-08 新增）
///   不认识的变量返回 undefined（调用方把 `{…}` 原样吐回去，方便看错在哪）
/// 🔴 变量名 / 数字里的**所有空白都要跳过**：半角空格、全角空格、`\n`、`\r`、`\t`。
///    2026-11-06 踩过：`{灼烧伤害*5}` 被编辑器/手改塞进了换行变成 `{灼烧伤害\n*5}`，
///    只跳空格不跳换行 → 变量名成了「灼烧伤害\n」→ 查不到 → 整串原样显示。
function info_island_text_eval(_expr, _v){
    var _n = string_length(_expr);
    var _i = 1;

    // ── 第一个操作数 ──
    var _tok = "";
    while (_i <= _n){
        var _c = string_char_at(_expr, _i);
        if (_c == "+" || _c == "-" || _c == "*" || _c == "/") break;
        if (_c != " " && _c != "　" && _c != "\n" && _c != "\r" && _c != "\t") _tok += _c;
        _i++;
    }
    if (_tok == "") return undefined;

    // 字符串型变量（形态名之类）直接原样返回，不能参与运算
    if (!info_island_text_is_number(_tok)){
        if (!ds_map_exists(_v, _tok)) return undefined;
        var _raw0 = _v[? _tok];
        if (!is_real(_raw0)) return string(_raw0);
    }
    var _val = info_island_text_operand(_tok, _v);
    if (is_undefined(_val)) return undefined;

    // ── 后续「运算符 + 操作数」 ──
    while (_i <= _n){
        var _op = string_char_at(_expr, _i);
        _i++;
        var _tok2 = "";
        while (_i <= _n){
            var _c2 = string_char_at(_expr, _i);
            if (_c2 == "+" || _c2 == "-" || _c2 == "*" || _c2 == "/") break;
            if (_c2 != " " && _c2 != "　" && _c2 != "\n" && _c2 != "\r" && _c2 != "\t") _tok2 += _c2;
            _i++;
        }
        var _num = info_island_text_operand(_tok2, _v);
        if (is_undefined(_num)) return undefined;
        switch (_op){
            case "+": _val += _num; break;
            case "-": _val -= _num; break;
            case "*": _val *= _num; break;
            case "/":
                if (_num == 0) return undefined;
                _val /= _num;
                break;
            default: return undefined;
        }
    }
    return info_island_text_num(_val);
}

/// @func info_island_text_render(raw, card_id, shape, level, skill)
/// @desc 把描述里的 {…} 全部换成当前状态的值；没有闭合的 `{` 原样吐回去
///   ⚠️ 需要「数值变色」时用 info_island_text_spans + info_island_text_draw（单串无法区分颜色）
function info_island_text_render(_raw, _cid, _shape, _level, _skill){
    if (!is_string(_raw)) return string(_raw);
    var _v = info_island_text_vars(_cid, _shape, _level, _skill);
    var _out = "";
    var _n = string_length(_raw);
    var _i = 1;
    while (_i <= _n){
        var _ch = string_char_at(_raw, _i);
        if (_ch != "{"){
            _out += _ch;
            _i++;
            continue;
        }
        var _j = _i + 1;
        var _expr = "";
        while (_j <= _n && string_char_at(_raw, _j) != "}"){
            _expr += string_char_at(_raw, _j);
            _j++;
        }
        if (_j > _n){                       // 没有闭合括号 → 剩下的原样输出
            _out += string_copy(_raw, _i, _n - _i + 1);
            break;
        }
        var _val = info_island_text_eval(_expr, _v);
        if (is_undefined(_val)) _out += "{" + _expr + "}";
        else _out += string(_val);
        _i = _j + 1;
    }
    ds_map_destroy(_v);
    return _out;
}
// ─────────────────────────────────────────────────────────────────────────────
//  正文绘制：自己排版 + 数值上色
//  ─ 整段描述只能一种颜色，想给数字上色就必须拆段、逐段画，于是 x/y 也得自己排。
//  ─ 2026-11-14（S4）：折行**只在这里做**，不再去对齐引擎的行数 ——
//    ① 宽度由调用方给（`obj_info_island_bg/Draw_0` 传 720），按像素排；
//    ② 数字串连单位、`[占位符]` 整体不断开；只在行宽 ≥80% 之后吃收尾标点；标点不顶行首；
//    ③ 文案在注册端已合并手写软换行（`info_island_unwrap`），所以这里排出来就是最终结果。
//  ─ 结果按「卡 id + 形态 + 星级 + 技能 + 宽度」缓存在 global.iit_cache，每帧不重算。
// ─────────────────────────────────────────────────────────────────────────────

/// @func info_island_text_spans(raw, card_id, shape, level, skill)
/// @desc 把描述切成段，供「数值上色」用：[[文本, 类型], …]
///   类型 0 = 普通文字（白） 1 = {变量} 算出来的数值（金） 2 = 全角【 】
///   只认全角【】；老的 [攻击力] / [喷壶类] 半角方括号当普通文字
function info_island_text_spans(_raw, _cid, _shape, _level, _skill){
    if (!is_string(_raw)) return [[string(_raw), 0]];
    var _v = info_island_text_vars(_cid, _shape, _level, _skill);
    var _out = [];
    var _buf = "";
    var _n = string_length(_raw);
    var _i = 1;
    while (_i <= _n){
        var _ch = string_char_at(_raw, _i);

        // 全角括号单独成段
        if (_ch == "【" || _ch == "】"){
            if (_buf != ""){ array_push(_out, [_buf, 0]); _buf = ""; }
            array_push(_out, [_ch, 2]);
            _i++;
            continue;
        }
        if (_ch != "{"){
            _buf += _ch;
            _i++;
            continue;
        }

        // {…} → 数值段
        var _j = _i + 1;
        var _expr = "";
        while (_j <= _n && string_char_at(_raw, _j) != "}"){
            _expr += string_char_at(_raw, _j);
            _j++;
        }
        if (_j > _n){                       // 没闭合：剩下的当普通文字
            _buf += string_copy(_raw, _i, _n - _i + 1);
            break;
        }
        var _val = info_island_text_eval(_expr, _v);
        if (is_undefined(_val)){
            _buf += "{" + _expr + "}";      // 取不到就原样留着（一眼能看出写错）
        }
        else{
            if (_buf != ""){ array_push(_out, [_buf, 0]); _buf = ""; }
            array_push(_out, [string(_val), 1]);
        }
        _i = _j + 1;
    }
    if (_buf != "") array_push(_out, [_buf, 0]);
    ds_map_destroy(_v);
    if (array_length(_out) == 0) array_push(_out, ["", 0]);
    return _out;
}

/// @func info_island_text_break_after(s)
/// @desc 这一串的最后一个字是「可以在它后面断行」的收尾标点
function info_island_text_break_after(_s){
    if (_s == "") return false;
    // 丨（增幅分段）和 +（配方）后面也是天然断点
    return (string_pos(string_char_at(_s, string_length(_s)), "，。、；：！？）】》」』…丨+") > 0);
}

/// @func info_island_text_no_head(s)
/// @desc 这一串不能停在行首（标点不顶行首）
function info_island_text_no_head(_s){
    if (_s == "") return false;
    return (string_pos(string_char_at(_s, 1), "，。、；：！？）】》」』%…") > 0);
}

/// @func info_island_text_is_numchar(ch)
/// @desc 数字/英文串的组成字符（. % * / + - x × 也算在内）
function info_island_text_is_numchar(_c){
    var _o = ord(_c);
    if (_o >= 48 && _o <= 57) return true;
    if (_o >= 65 && _o <= 90) return true;
    if (_o >= 97 && _o <= 122) return true;
    return (string_pos(_c, ".%*/+-x×") > 0);
}

/// @func info_island_text_is_numstart(ch)
/// @desc 这一段是不是数字/英文串的开头
function info_island_text_is_numstart(_c){
    var _o = ord(_c);
    return (_o >= 48 && _o <= 57) || (_o >= 65 && _o <= 90) || (_o >= 97 && _o <= 122);
}

/// @func info_island_text_units(spans)
/// @desc 切「最小断行单位」：`[占位符]` 整体、数字串连同紧跟的一个汉字整体（15%概率 / 1.5秒 / 3发）、其余按字
function info_island_text_units(_spans){
    var _u = [];
    for (var _s = 0; _s < array_length(_spans); _s++){
        var _txt  = _spans[_s][0];
        var _kind = _spans[_s][1];
        var _n    = string_length(_txt);
        var _i    = 1;
        while (_i <= _n){
            var _ch = string_char_at(_txt, _i);
            if (_ch == "["){
                var _close = string_pos("]", string_copy(_txt, _i, _n - _i + 1));
                if (_close > 1){
                    array_push(_u, [string_copy(_txt, _i, _close), _kind]);
                    _i += _close;
                    continue;
                }
            }
            if (info_island_text_is_numstart(_ch)){
                var _j = _i;
                while (_j <= _n && info_island_text_is_numchar(string_char_at(_txt, _j))) _j++;
                // 数字后面紧跟的汉字一起带走，别把「15%概率」拆成两半
                if (_j <= _n && ord(string_char_at(_txt, _j)) > 255) _j++;
                array_push(_u, [string_copy(_txt, _i, _j - _i), _kind]);
                _i = _j;
                continue;
            }
            array_push(_u, [_ch, _kind]);
            _i++;
        }
    }
    return _u;
}

/// @func info_island_text_lines(spans, wrap)
/// @desc 唯一的折行实现：按像素宽度排。返回行数组，每行是若干 [文本, 类型] 段。
///   ① 占位符 / 数字串不断开 ② 只在行宽 ≥80% 之后才吃收尾标点 ③ 标点不顶行首
function info_island_text_lines(_spans, _wrap){
    var _units = info_island_text_units(_spans);
    var _lines = [];
    var _cur   = [];
    var _w     = 0;

    for (var _u = 0; _u < array_length(_units); _u++){
        var _unit = _units[_u][0];
        if (_unit == "\n"){
            array_push(_lines, _cur);
            _cur = [];
            _w = 0;
            continue;
        }
        var _uw = string_width(_unit);

        if (_w + _uw <= _wrap || array_length(_cur) == 0){
            array_push(_cur, _units[_u]);
            _w += _uw;
            continue;
        }

        // 断点：靠右 80% 之后的最后一个收尾标点
        var _cut = -1;
        var _acc = 0;
        for (var _k = 0; _k < array_length(_cur); _k++){
            _acc += string_width(_cur[_k][0]);
            if (_acc >= _wrap * 0.8 && info_island_text_break_after(_cur[_k][0])) _cut = _k;
        }
        if (_cut >= 0 && _cut < array_length(_cur) - 1){
            var _rest = [];
            var _rest_w = 0;
            for (var _r = _cut + 1; _r < array_length(_cur); _r++){
                array_push(_rest, _cur[_r]);
                _rest_w += string_width(_cur[_r][0]);
            }
            if (_rest_w + _uw <= _wrap){
                var _head = [];
                for (var _h = 0; _h <= _cut; _h++) array_push(_head, _cur[_h]);
                array_push(_lines, _head);
                _cur = _rest;
                _w = _rest_w;
                array_push(_cur, _units[_u]);
                _w += _uw;
                continue;
            }
        }

        // 标点不顶行首：把上一行最后一个单位带下来陪它
        if (info_island_text_no_head(_unit) && array_length(_cur) > 1){
            var _last = _cur[array_length(_cur) - 1];
            array_delete(_cur, array_length(_cur) - 1, 1);
            array_push(_lines, _cur);
            _cur = [_last];
            _w = string_width(_last[0]);
        } else {
            array_push(_lines, _cur);
            _cur = [];
            _w = 0;
        }
        array_push(_cur, _units[_u]);
        _w += _uw;
    }

    if (array_length(_cur) > 0) array_push(_lines, _cur);
    if (array_length(_lines) == 0) array_push(_lines, []);
    return _lines;
}

/// @func info_island_text_draw_lines(x, y, lines, line_h, col_normal, col_value, col_bracket, bold)
/// @desc 逐行逐段绘制（左上对齐）。bold = 金色数字再横向错开 0.6px 画一遍，伪加粗
function info_island_text_draw_lines(_x, _y, _lines, _line_h, _cn, _cv, _cb, _bold){
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    var _cy = _y;
    for (var _l = 0; _l < array_length(_lines); _l++){
        var _line = _lines[_l];
        var _cx = _x;
        for (var _s = 0; _s < array_length(_line); _s++){
            var _txt  = _line[_s][0];
            var _kind = _line[_s][1];
            draw_set_color((_kind == 1) ? _cv : ((_kind == 2) ? _cb : _cn));
            draw_text(_cx, _cy, _txt);
            if (_bold && _kind == 1 && _txt != ""){
                draw_text(_cx + 0.6, _cy, _txt);     // 伪加粗
            }
            _cx += string_width(_txt);
        }
        _cy += _line_h;
    }
    draw_set_color(c_white);
}

/// @func info_island_text_draw_rich(px, py, raw, cid, shape, level, skill, wrap, line_h, cn, cv, cb, bold)
/// @desc 情报岛正文的唯一绘制入口：自己排版 + 数值上色。
///   折行宽度由调用方给（obj_info_island_bg/Draw_0 传 720），不再反解引擎行数。
///   结果按「卡 + 形态 + 星级 + 技能 + 宽度」缓存，换卡才重排。
///   返回 true = 已画；false = 调用方自己兜底（只有文案缺失时才会 false）
function info_island_text_draw_rich(_px, _py, _raw, _cid, _shape, _level, _skill, _wrap, _line_h, _cn, _cv, _cb, _bold){
    if (!is_string(_raw) || _raw == "") return false;
    draw_set_font(font_yuan);

    if (!variable_global_exists("iit_cache") || !ds_exists(global.iit_cache, ds_type_map)){
        global.iit_cache = ds_map_create();
    }
    var _key = _cid + "|" + string(_shape) + "|" + string(_level) + "|" + string(_skill)
             + "|" + string(_wrap) + "|" + string(string_length(_raw));

    var _entry;
    if (ds_map_exists(global.iit_cache, _key)){
        _entry = global.iit_cache[? _key];
    }
    else{
        _entry = info_island_text_lines(info_island_text_spans(_raw, _cid, _shape, _level, _skill), _wrap);
        global.iit_cache[? _key] = _entry;
    }

    info_island_text_draw_lines(_px, _py, _entry, _line_h, _cn, _cv, _cb, _bold);
    return true;
}
