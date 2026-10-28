// ============================================================
// 龙渊老鼠 / BOSS 机制数值集中宏区（调参只改这里）
// ============================================================

// 1. 东风鼠
#macro LY_DONGFENG_TRIGGER_COL 7   // 到达第8列（0-based=7）时释放一次全屏加速 wind
#macro LY_DONGFENG_DROP_COL 1      // 到达第2列（0-based=1）时强制落地（掉扇）
#macro LY_DONGFENG_SPEED_MULT 2    // 全场空中单位速度倍率（多只东风为赋值取定值，不累乘）

// 3. 开路鼠
#macro LY_KAILU_DASH_DIST 3        // 单次冲刺格数
#macro LY_KAILU_DASH_DAMAGE 100    // 冲刺撞到第一张卡片的啃咬伤害
#macro LY_KAILU_BITE_DAMAGE 10     // 冲刺结束后的普通啃咬伤害
#macro LY_KAILU_SOUL_REDUCTION 0.1 // 夜魂体受伤系数（减伤90%）

// 4. 药罐鼠
#macro LY_YAOGUAN_FIRE_COUNT 3     // 初始魂火数
#macro LY_YAOGUAN_FIRE_RED_PER 0.2 // 每团魂火减伤
#macro LY_YAOGUAN_FIRE_RED_MAX 0.6 // 减伤上限（3团=60%）
#macro LY_YAOGUAN_HEAL_TRIGGER 0.3 // 血量低于30%触发回血
#macro LY_YAOGUAN_HEAL_RATIO 0.7   // 单次回血占最大生命比例（占位，待游戏内调）
#macro LY_YAOGUAN_HEAL_DONE_SPEED 0.3 // 回血结束后移动速度

// 5. 织布机鼠
#macro LY_SHUTTLE_DAMAGE 10        // 织丝穿透：整行每张卡伤害

// 7. 高跷鼠（舞步 1:1 非主流鼠：20 帧固定区间）
#macro LY_GAOQIAO_DANCE_FRAMES 20   // 舞步帧数（精灵第11-30帧，0-based 10-29）
#macro LY_GAOQIAO_DANCE_START 10    // 正常形态舞步起始 image_index（0-based）
#macro LY_GAOQIAO_DANCE_HURT_START 55 // 破损形态舞步起始 image_index（0-based，对应1-based 56-75）

// 6. 执念鼠
#macro LY_ZHINIAN_SOUL_REDUCTION 0.1 // 夜魂体受伤系数（减伤90%）
#macro LY_ZHINIAN_SOUL_ATK 50        // 魂体普通攻击伤害（用户要求 50）
#macro LY_ZHINIAN_SOUL_ATK_COUNT 3   // 几次普攻后放大
#macro LY_ZHINIAN_RUSH_DIST 2        // 大招前移格数（销毁途经卡片）

// 8. 蜘蛛精鼠（步数 @60fps）
#macro LY_SPIDER_WARN 120          // 出现预警等待 2 秒
#macro LY_SPIDER_STEAL_WAIT 120    // 落地后等待 2 秒再偷卡
#macro LY_SPIDER_WEB_LIFE 1200     // 蛛网存在 20 秒
#macro LY_SPIDER_RETRY 30          // 场上无卡时重新选目标间隔

// 9. 谛听鼠
#macro LY_DITING_PRISON_HP 10000   // 钟基础血量
#macro LY_DITING_PRISON_COUNT 7    // 技能3随机生成钟的数量
#macro LY_DITING_PRISON_FUSE 180   // 被引信后 3 秒自毁
#macro LY_DITING_PRISON_LIFE 600   // 钟存在 10 秒后摧毁罩住的卡片
#macro LY_DITING_SKILL1_DMG 400    // 遁地突袭 3×3 每卡伤害
#macro LY_DITING_SOUNDWAVE_DPS 400 // 音波驻留每秒伤害（占位，待游戏内调）
#macro LY_DITING_SOUNDWAVE_LIFE 1200 // 音波驻留 20 秒

// 10. 哼哈二将
#macro LY_HENGHA_BELL_RING_DMG 40  // 敲钟对铃周 3×3 伤害
#macro LY_HENGHA_SLAM_DMG 400      // 牛头跳跃砸击十字每格伤害
#macro LY_HENGHA_SPIRIT_HP 5000    // 美食灵体基础血量
#macro LY_HENGHA_SPIRIT_TAKE 0.2   // 美食灵体受伤系数（减伤80%）

// 11. 游神鼠
#macro LY_YOUSHEN_MIST_DPS 10      // 毒雾每秒每卡伤害（穿护罩）
#macro LY_YOUSHEN_MIST_LIFE 600    // 毒雾持续 10 秒
#macro LY_YOUSHEN_SLEEP_DUR 900    // 催眠持续 15 秒

// 12. 无常鼠
#macro LY_WUCHANG_CHAIN_HP 10000      // 拘魂锁链基础血量
#macro LY_WUCHANG_YUANBAO_WAIT 120    // 元宝落地到爆炸 2 秒
#macro LY_WUCHANG_SEAL_DUR 1500       // 献宝封印（禁用武器宝石/吸火苗）持续 25 秒

/// 每个动作使用SWF标签对应的闭区间，不依赖move_anim等固定偏移。
function longyuan_play(_action, _once = false) {
    if (ly_action == _action) return;
    if (!variable_struct_exists(ly_anims, _action)) {
        show_debug_message("龙渊缺少动作: " + ly_kind + "/" + _action);
        return;
    }
    ly_action = _action;
    ly_frame = 0;
    ly_done = false;
    ly_hit = false;
    ly_once = _once;
    var _clip = ly_anims[$ _action];
    sprite_index = _clip[0];
    image_index = _clip[1] - 1;
}

function longyuan_animate() {
    if (ly_action == "") return;
    var _clip = ly_anims[$ ly_action];
    var _count = _clip[2] - _clip[1] + 1;
    ly_frame += 10 / game_get_speed(gamespeed_fps) / (is_slowdown ? 2 : 1);
    ly_done = ly_frame >= _count;
    image_index = _clip[1] - 1 + (ly_once ? min(floor(ly_frame), _count - 1) : floor(ly_frame) mod _count);
}

function longyuan_variant(_normal, _hurt) {
    return hp <= maxhp * hurt_rate ? _hurt : _normal;
}

function longyuan_is_night() {
    // 优先级：level_file.level_time_feature → level_file.map_sprite 后缀 → level_id 后缀
    if (variable_global_exists("level_file")) {
        var _lf = global.level_file;
        if (variable_struct_exists(_lf, "level_time_feature")) {
            var _tf = string(_lf.level_time_feature);
            if (_tf == "night" || string_pos("night", _tf) > 0 || string_pos("_ye", _tf) > 0) return true;
            if (_tf == "daytime" || string_pos("day", _tf) > 0) return false;
        }
        if (variable_struct_exists(_lf, "map_sprite")) {
            var _ms = string(_lf.map_sprite);
            if (string_pos("_ye", _ms) > 0) return true;
            if (string_pos("_ri", _ms) > 0) return false;
        }
    }
    if (variable_global_exists("level_id")) {
        var _level = string(global.level_id);
        if (string_pos("night", _level) > 0 || string_pos("_ye", _level) > 0) return true;
        if (string_pos("_ri", _level) > 0) return false;
    }
    return false;
}

// ------------------------------------------------------------
// 四张「无视魂体减伤」的卡片：烤串机 / 护法神 / 灯影花糕 / 炎帝（神农氏）
// 对魂系（符咒鼠、符咒随从鼠、开路鼠魂体、执念鼠魂体）+ 药罐鼠：
//   1) 完全不吃 90% 魂体减伤，也不吃药罐鼠的魂火减伤；
//   2) 按下面的倍率额外增伤。
// 倍率只有这一处出处，卡片侧不要另写数字。
// ------------------------------------------------------------
#macro LY_SOUL_BONUS_KAOCHUAN 1.3  // 烤串机
#macro LY_SOUL_BONUS_HUFA     1.8  // 护法神
#macro LY_SOUL_BONUS_HUAGAO   1.5  // 灯影花糕
#macro LY_SOUL_BONUS_SHENNONG 2.0  // 炎帝

/// 卡片对象 → 魂系额外倍率（不是这四张卡返回 1.0）
function longyuan_soul_bonus_mult(_src) {
	if (_src == obj_hongliukaochuan) return LY_SOUL_BONUS_KAOCHUAN;
	if (_src == obj_hufa_god)        return LY_SOUL_BONUS_HUFA;
	if (_src == obj_huagao)          return LY_SOUL_BONUS_HUAGAO;
	if (_src == obj_shennong_god)    return LY_SOUL_BONUS_SHENNONG;
	return 1.0;
}

/// 卡片 id（字符串）→ 魂系额外倍率（不是这四张卡返回 1.0）
function longyuan_soul_bonus_mult_id(_id) {
	if (!is_string(_id)) return 1.0;
	if (_id == "hongliukaochuan") return LY_SOUL_BONUS_KAOCHUAN;
	if (_id == "hufa_god")        return LY_SOUL_BONUS_HUFA;
	if (_id == "huagao")          return LY_SOUL_BONUS_HUAGAO;
	if (_id == "shennong_god")    return LY_SOUL_BONUS_SHENNONG;
	return 1.0;
}

/// 该来源（对象索引或卡片 id 字符串）是否属于「无视魂体减伤」的四张卡
function longyuan_soul_pierce_source(_src) {
	if (_src == obj_hongliukaochuan || _src == obj_hufa_god
	 || _src == obj_huagao         || _src == obj_shennong_god) return true;
	return (longyuan_soul_bonus_mult_id(_src) > 1.0);
}

/// 当前这次命中是否由「无视魂体减伤」的卡片造成。
/// 两条独立通道任一成立即算：damage_source_object（对象）/ damage_source_card_id（卡片 id）。
function longyuan_hit_pierces_soul_reduction() {
	if (variable_instance_exists(id, "damage_source_object")
		&& longyuan_soul_pierce_source(damage_source_object)) return true;
	if (variable_instance_exists(id, "damage_source_card_id")
		&& is_string(damage_source_card_id)
		&& longyuan_soul_bonus_mult_id(damage_source_card_id) > 1.0) return true;
	return false;
}

/// 这四张卡的「魂系目标」范围：魂系敌人 + 药罐鼠（药罐鼠本体不是魂系，但按魂系口径吃增伤）
function longyuan_is_soul_bonus_target(_e) {
	if (!instance_exists(_e)) return false;
	if (longyuan_is_soul_enemy(_e)) return true;
	return (variable_instance_exists(_e, "mouse_id") && _e.mouse_id == "longyuan_yaoguan");
}

function longyuan_apply_soul_damage_reduction(_factor = 0.1) {
	// 被灯影花糕的魂虫命中后「现形」：等效已显形，不再吃魂体减伤。
	if (variable_instance_exists(id, "huagao_reveal") && huagao_reveal) return;
	// 烤串机 / 护法神 / 灯影花糕 / 炎帝：对魂系不减伤（额外倍率已在攻击侧结算）。
	if (longyuan_hit_pierces_soul_reduction()) return;
	damage_amount *= _factor;
}

function longyuan_air_speed_multiplier() {
    var _multiplier = 1;
    with (obj_ly_dongfeng) {
        // ly_wind_active 在第8列锁存、一生只施法一次；这里是赋定值而非累乘，
        // 多只东风同时在场仍只返回固定倍率，天然满足“东风不与东风叠加”。
        // 不要求 ly_fan：扇子掉落 / 被电风扇吹落后，已经生成的全场风场依旧有效，东风鼠存活即生效。
        if (hp > 0 && ly_wind_active && !is_frozen && !is_stun && !is_scare) _multiplier = LY_DONGFENG_SPEED_MULT;
    }
    return _multiplier;
}

function longyuan_card_in_cell(_col, _row) {
    if (_col < 0 || _col >= global.grid_cols || _row < 0 || _row >= global.grid_rows) return noone;
    var _list = ds_grid_get(global.grid_plants, _col, _row);
    for (var _i = 0; _i < ds_list_size(_list); ++_i) {
        var _card = _list[| _i];
        if (instance_exists(_card) && _card.hp > 0 && _card.plant_id != "player" && _card.plant_type != "coffee") return _card;
    }
    return noone;
}

function longyuan_diting_trigger_umbrella(_col, _row) {
    with (obj_paratrooper_mouse_shield) {
        if (is_diting_umbrella && grid_col == _col && grid_row == _row && hp > 0) {
            hp = 0;
        }
    }
}

function longyuan_diting_dense_cell() {
    var _best = [], _max_count = -1;
    for (var _col = 0; _col < global.grid_cols; ++_col) {
        for (var _row = 0; _row < global.grid_rows; ++_row) {
            var _count = 0;
            for (var _dx = -1; _dx <= 1; ++_dx) {
                for (var _dy = -1; _dy <= 1; ++_dy) {
                    var _c = _col + _dx, _r = _row + _dy;
                    if (_c >= 0 && _c < global.grid_cols && _r >= 0 && _r < global.grid_rows
                        && instance_exists(longyuan_card_in_cell(_c, _r))) _count++;
                }
            }
            if (_count > _max_count) { _best = [{col: _col, row: _row}]; _max_count = _count; }
            else if (_count == _max_count) array_push(_best, {col: _col, row: _row});
        }
    }
    return _best[irandom(array_length(_best) - 1)];
}

/// 谛听技能1专用：在指定行内找 3×3 最密集的列（只搜 ≤_max_col 的列，保证向左横移能到达），返回列号。
function longyuan_diting_dense_col_in_row(_row, _max_col) {
    var _best = [], _max_count = -1;
    for (var _col = 0; _col <= _max_col && _col < global.grid_cols; ++_col) {
        var _count = 0;
        for (var _dx = -1; _dx <= 1; ++_dx) {
            for (var _dy = -1; _dy <= 1; ++_dy) {
                var _c = _col + _dx, _r = _row + _dy;
                if (_c >= 0 && _c < global.grid_cols && _r >= 0 && _r < global.grid_rows
                    && instance_exists(longyuan_card_in_cell(_c, _r))) _count++;
            }
        }
        if (_count > _max_count) { _best = [_col]; _max_count = _count; }
        else if (_count == _max_count) array_push(_best, _col);
    }
    if (array_length(_best) == 0) return max(0, _max_col);
    return _best[irandom(array_length(_best) - 1)];
}

function longyuan_diting_damage_3x3(_col, _row, _damage) {
    for (var _c = _col - 1; _c <= _col + 1; ++_c) {
        for (var _r = _row - 1; _r <= _row + 1; ++_r) {
            if (_c < 0 || _c >= global.grid_cols || _r < 0 || _r >= global.grid_rows) continue;
            var _cards = ds_grid_get(global.grid_plants, _c, _r);
            for (var _i = ds_list_size(_cards) - 1; _i >= 0; --_i) {
                var _card = _cards[| _i];
                if (instance_exists(_card) && _card.plant_id != "player" && _card.plant_type != "coffee") longyuan_damage_plant(_card, _damage);
            }
        }
    }
}

/// 游神夜巡毒雾专用：3×3 直扣 hp，无视无敌/护罩/减伤（仍跳过 player/coffee）
function longyuan_damage_3x3_direct(_col, _row, _damage) {
    for (var _c = _col - 1; _c <= _col + 1; ++_c) {
        for (var _r = _row - 1; _r <= _row + 1; ++_r) {
            if (_c < 0 || _c >= global.grid_cols || _r < 0 || _r >= global.grid_rows) continue;
            var _cards = ds_grid_get(global.grid_plants, _c, _r);
            for (var _i = ds_list_size(_cards) - 1; _i >= 0; --_i) {
                var _card = _cards[| _i];
                if (instance_exists(_card) && _card.hp > 0
                    && _card.plant_id != "player" && _card.plant_type != "coffee") {
                    _card.hp -= _damage;
                    with (_card) event_user(2);
                }
            }
        }
    }
}

/// 引信单个格子内的谛听钟（技能3音波路径用）
function longyuan_diting_prison_fuse_cell(_col, _row) {
    with (obj_ly_diting_prison) {
        if ((ly_mode == "birth" || ly_mode == "idle") && hp > 0 && grid_col == _col && grid_row == _row) {
            ly_mode = "fuse";
            ly_timer = 0;
            longyuan_play("激活", true);
        }
    }
}

/// 引信以(_col,_row)为中心 3×3 内所有谛听钟（技能1钻出用）
function longyuan_diting_prison_fuse_3x3(_col, _row) {
    with (obj_ly_diting_prison) {
        if ((ly_mode == "birth" || ly_mode == "idle") && hp > 0
            && abs(grid_col - _col) <= 1 && abs(grid_row - _row) <= 1) {
            ly_mode = "fuse";
            ly_timer = 0;
            longyuan_play("激活", true);
        }
    }
}

function longyuan_damage_cell(_col, _row, _damage, _destroy = false) {
    if (_col < 0 || _col >= global.grid_cols || _row < 0 || _row >= global.grid_rows) return;
    var _cards = ds_grid_get(global.grid_plants, _col, _row);
    for (var _i = ds_list_size(_cards) - 1; _i >= 0; --_i) {
        var _card = _cards[| _i];
        if (!instance_exists(_card) || _card.plant_id == "player" || _card.plant_type == "coffee") continue;
        if (_destroy) longyuan_destroy_card(_card);
        else longyuan_damage_plant(_card, _damage);
    }
}

function longyuan_damage_cross(_col, _row, _damage) {
    for (var _offset = -2; _offset <= 2; ++_offset) {
        longyuan_damage_cell(_col + _offset, _row, _damage);
        if (_offset != 0) longyuan_damage_cell(_col, _row + _offset, _damage);
    }
}

function longyuan_sleep_area(_col, _row, _cols, _rows, _duration) {
    var _cards = [];
    var _left = _col - floor(_cols / 2);
    var _top = _row - floor(_rows / 2);
    for (var _c = _left; _c < _left + _cols; ++_c) {
        for (var _r = _top; _r < _top + _rows; ++_r) {
            if (_c < 0 || _c >= global.grid_cols || _r < 0 || _r >= global.grid_rows) continue;
            var _list = ds_grid_get(global.grid_plants, _c, _r);
            for (var _i = 0; _i < ds_list_size(_list); ++_i) {
                var _card = _list[| _i];
                if (!instance_exists(_card) || _card.plant_id == "player" || _card.plant_type == "coffee") continue;
                array_push(_cards, {id: _card, previous_state: _card.state});
                with (_card) state = CARD_STATE.SLEEP;
            }
        }
    }
    return _cards;
}

function longyuan_destroy_card(_card, _no_effect = false) {
    if (!instance_exists(_card) || _card.hp <= 0 || _card.invincible) return;
    var _pos = {x: _card.x, y: _card.y};
    with (_card) {
        no_revive_record = true;
        is_shoveled = true;
        instance_destroy();
    }
    if (_no_effect) return;
    var _effect = instance_create_depth(_pos.x, _pos.y, -800, obj_coke_bomb_explode);
    _effect.sprite_index = spr_coke_bomb_explode;
}

/// 龙渊「魂系」敌人判定：执念鼠/开路鼠魂体、符咒鼠、符咒魂鼠等
function longyuan_is_soul_enemy(_e) {
    if (!instance_exists(_e)) return false;
    if (variable_instance_exists(_e, "is_soul") && _e.is_soul) return true;
    if (variable_instance_exists(_e, "ly_soul") && _e.ly_soul) return true;
    if (variable_instance_exists(_e, "mouse_id")) {
        var _id = _e.mouse_id;
        if (_id == "longyuan_fuzhou" || _id == "longyuan_fuzhou_minion") return true;
    }
    return false;
}

/// 药罐鼠回血的受益范围：全体魂系鼠
/// （魂系状态的开路鼠、执念鼠魂体、符咒鼠、药罐鼠自身、符咒随从鼠）。
/// 药罐鼠本体不在 longyuan_is_soul_enemy 的判定里，单独按 mouse_id 收进来。
function longyuan_is_soul_pack_member(_e) {
    if (!instance_exists(_e)) return false;
    if (variable_instance_exists(_e, "mouse_id") && _e.mouse_id == "longyuan_yaoguan") return true;
    return longyuan_is_soul_enemy(_e);
}

/// 按各自身最大生命的 _ratio 给场上全体魂系鼠回血（药罐鼠回血技能专用）
/// 注意：龙渊的鼠全部直接继承 obj_enemy_parent，obj_ly_mouse_parent 下没有任何子对象，
/// 遍历它等于空转（药罐鼠自己都回不到）。必须遍历 obj_enemy_parent，再用成员判定过滤。
function longyuan_heal_soul_pack(_ratio) {
    with (obj_enemy_parent) {
        if (hp <= 0 || hp >= maxhp) continue;
        if (!longyuan_is_soul_pack_member(id)) continue;
        hp = min(maxhp, hp + maxhp * _ratio);
        if (variable_instance_exists(id, "image_alpha")) image_alpha = 1;
    }
}

/// 冲撞类效果（猫眼宝石 / 金牛烟花 / 救世神灵鱼 / 白羊座）的秒杀豁免判定：
/// true = 冲撞撞不死，只吃伤害。判据**只有** BOSS 与魂系鼠
/// （魂系开路、魂系执念、符咒、符咒随从、药罐鼠），其余敌人一律被撞死。
/// 不能用 `immune_to_ash` 当判据：那是「防爆/灰烬免疫」的标记，龙渊里一大片鼠都带着，
/// 会把几乎所有敌人变成「冲撞只吃伤害」，表现为冲撞卡秒杀集体失效。
function crash_immune_enemy(_e) {
    if (!instance_exists(_e)) return true;
    if (variable_instance_exists(_e, "is_boss") && _e.is_boss) return true;
    return longyuan_is_soul_pack_member(_e);
}

/// 地精鼠「提前出土」判定用的龙渊卡片集合：烤串机 / 浮生茶 / 桥头米线 / 灯影花糕 / 泡椒春笋。
function longyuan_dijing_is_food_card(_plant_id) {
    return (_plant_id == "hongliukaochuan" || _plant_id == "fushengcha" || _plant_id == "mixian"
         || _plant_id == "huagao"         || _plant_id == "chunsun");
}

/// 取指定卡片所在格最外层的可伤害卡：被瓜皮护罩 / 赫拉 / 处女座罩住时优先返回保护卡本体。
function longyuan_outer_card_of(_card) {
    if (!instance_exists(_card)) return noone;
    var _r = _card.grid_row;
    var _c = _card.grid_col;
    var _best = _card, _best_layer = 0;
    with (obj_card_parent) {
        if (hp <= 0 || plant_id == "player" || grid_row != _r || grid_col != _c) continue;
        var _layer = 0;
        if (plant_type == "shield_outer") _layer = 2;
        else if (plant_type == "shield") _layer = 1;
        if (_layer > _best_layer) { _best = id; _best_layer = _layer; }
    }
    return _best;
}

function longyuan_damage_plant_piercing(_plant, _damage) {
    if (!instance_exists(_plant) || _plant.hp <= 0 || _plant.invincible) return;
    with (_plant) {
        hp -= _damage;
        event_user(2);
    }
}

/// 在指定格生成蜘蛛精蛛网（同格已有蛛网则不重复生成），返回蛛网实例
function longyuan_web_make(_col, _row, _depth = -500) {
    if (_col < 0 || _col >= global.grid_cols || _row < 0 || _row >= global.grid_rows) return noone;
    if (!variable_global_exists("longyuan_web_cells"))
        global.longyuan_web_cells = array_create(global.grid_rows * global.grid_cols, false);
    var _idx = _row * global.grid_cols + _col;
    if (global.longyuan_web_cells[_idx]) return noone;
    var _pos = get_world_position_from_grid(_col, _row);
    var _web = instance_create_depth(_pos.x, _pos.y, _depth, obj_ly_web, {web_col: _col, web_row: _row});
    return _web;
}

// 触发铃铛 fx 进入“摇晃→飞走”（牛头敲铃特效同步）
function longyuan_hengha_bell_ring(_bell) {
    if (instance_exists(_bell)) _bell.fx_bell_ring = true;
}

function longyuan_find_plant(_heavy_only = false) {
    var _best = noone, _priority = 999, _distance = 1000000000;
    with (obj_card_parent) {
        if (hp <= 0 || plant_id == "player" || plant_type == "coffee") continue;
        var _dx = x - other.x;
        // Match obj_enemy_parent: positive attack_range faces left, negative faces right.
        var _in_front = other.attack_range > 0
            ? (_dx < 0 && -_dx < other.attack_range)
            : (_dx > 0 && _dx < -other.attack_range);
        if (grid_row != other.grid_row || !_in_front) continue;
        if (_heavy_only && plant_id != "chocolate_bread" && !(variable_instance_exists(id, "blocks_vault") && blocks_vault)) continue;
        if (feature_type == "dwarf" && !other.giant_type) continue;
        var _order = ds_list_find_index(global.eat_order, plant_type);
        if (_order < 0) continue;
        if (_order < _priority || (_order == _priority && _dx < _distance)) {
            _best = id; _priority = _order; _distance = _dx;
        }
    }
    return _best;
}

function longyuan_damage_plant(_plant, _damage) {
    if (!instance_exists(_plant) || _plant.hp <= 0 || _plant.invincible || _damage <= 0) return;
    with (_plant) {
        hp -= _damage;
        event_user(2);
    }
    // 龙渊鼠啃咬音效：仅老鼠本体触发（BOSS 技能、梭子等不吃卡片音）。
    if (variable_instance_exists(id, "mouse_id") && mouse_id != ""
        && !(variable_instance_exists(id, "is_boss") && is_boss)) {
        if (!variable_global_exists("ly_last_chomp_time")) global.ly_last_chomp_time = 0;
        // 80ms 节流，避免冲刺/多卡同时命中时音效叠爆。
        if (current_time - global.ly_last_chomp_time > 80) {
            global.ly_last_chomp_time = current_time;
            global.audio.play(ds_list_find_value(obj_battle.chomp_sound_list, irandom_range(0, 2)), 0, 0);
        }
    }
}

/// BOSS 范围伤害：对本体所在行的指定列造成 atk 伤害（网格火焰等）
function ly_damage_col(_col) {
    var _row = grid_row;
    var _list = ds_grid_get(global.grid_plants, _col, _row);
    var _count = ds_list_size(_list);
    for (var _i = 0; _i < _count; ++_i) {
        longyuan_damage_plant(_list[| _i], atk);
    }
}

/// BOSS 范围伤害：对指定行的所有植物造成 atk 伤害（音波、迷雾、下雨、火轮等）
function ly_damage_row(_row) {
    for (var _c = 0; _c < global.grid_cols; ++_c) {
        var _list = ds_grid_get(global.grid_plants, _c, _row);
        var _count = ds_list_size(_list);
        for (var _i = 0; _i < _count; ++_i) {
            longyuan_damage_plant(_list[| _i], atk);
        }
    }
}

/// BOSS 寻敌列：返回本行最靠左（最前）的有植物列；本行无植物则返回最右列
function ly_target_col() {
    for (var _c = 0; _c < global.grid_cols; ++_c) {
        if (ds_list_size(ds_grid_get(global.grid_plants, _c, grid_row)) != 0) return _c;
    }
    return global.grid_cols - 1;
}

/// ===== 龙渊 BOSS 动作剪辑控制 =====
/// BOSS 使用「单只大精灵 + 子图区间」表示动作，下面三个函数负责按 ly_anims 表驱动。
/// 切换当前动作：写入 ly_action、切换 sprite_index 并复位到动作首帧，返回该动作帧数。
function longyuan_clip_set(_action) {
    ly_action = _action;
    ly_frame = 0;
    ly_done = false;
    ly_hit = false;
    if (!variable_struct_exists(ly_anims, _action)) {
        show_debug_message("龙渊BOSS缺少动作: " + ly_kind + "/" + _action);
        return 0;
    }
    var _clip = ly_anims[$ _action];
    sprite_index = _clip[0];
    image_index = _clip[1] - 1;
    return _clip[2] - _clip[1] + 1;
}

/// 动作总帧数（swf 标签闭区间长度）
function longyuan_clip_length(_action) {
    if (!variable_struct_exists(ly_anims, _action)) return 0;
    var _clip = ly_anims[$ _action];
    return _clip[2] - _clip[1] + 1;
}

/// 按本地计时器 _t 驱动当前动作帧。_rate = 每帧停留步数，_loop = 是否循环。
function longyuan_clip_frame(_t, _rate = 5, _loop = true) {
    var _n = longyuan_clip_length(ly_action);
    if (_n <= 0) return;
    var _clip = ly_anims[$ ly_action];
    var _f = floor(max(0, _t) / max(1, _rate));
    _f = _loop ? (_f mod _n) : min(_f, _n - 1);
    ly_frame = _f;
    image_index = _clip[1] - 1 + _f;
}

/// 非循环动作是否已播完
function longyuan_clip_done(_t, _rate = 5) {
    var _n = longyuan_clip_length(ly_action);
    if (_n <= 0) return true;
    return _t >= _n * max(1, _rate);
}

/// 桥头米线本体及连接线均可设置此标记；线段也可直接注册在global.longyuan_bridge_lines。
function longyuan_bridge_contact(_x1, _y1, _x2, _y2, _row) {
    var _found = noone;
    with (obj_card_parent) {
        if (hp > 0 && grid_row == _row && variable_instance_exists(id, "longyuan_bridge_connected") && longyuan_bridge_connected
            && x >= min(_x1, _x2) - 20 && x <= max(_x1, _x2) + 20) _found = id;
    }
    if (_found != noone) return _found;
    if (variable_global_exists("longyuan_bridge_lines")) {
        var _lines = global.longyuan_bridge_lines;
        for (var _i = 0; _i < array_length(_lines); ++_i) {
            var _l = _lines[_i];
            if (!instance_exists(_l.owner) || _l.owner.hp <= 0) continue;
            if (collision_line(_l.x1, _l.y1, _l.x2, _l.y2, id, false, false) != noone
                || (_row == _l.owner.grid_row && min(_x1, _x2) <= max(_l.x1, _l.x2) && max(_x1, _x2) >= min(_l.x1, _l.x2))) return _l.owner;
        }
    }
    return noone;
}

function longyuan_bridge_clear_cell(_col, _row) {
    var _cards = ds_grid_get(global.grid_plants, _col, _row);
    for (var _i = ds_list_size(_cards) - 1; _i >= 0; --_i) {
        var _card = _cards[| _i];
        if (!instance_exists(_card)) continue;
        if (_card.plant_id == "player" || _card.plant_id == "cotton_candy" || _card.plant_id == "lingrong_god") continue;
        with (_card) {
            no_revive_record = true;
            is_shoveled = true;
            instance_destroy();
        }
    }
}

function longyuan_bridge_update(_wave, _stage) {
    if (global.level_id != "longyuan_6") return;
    // 轨道 1：小兵波第 3 波（0-based wave == 2）触发
    if (_wave >= 2 && !global.longyuan_bridge_red_active) {
        global.longyuan_bridge_red_active = true;
    }
    // 轨道 2：首次进入 BOSS 波触发（obj_ludi.Step 检测标记后统一下沉）
    if (_stage == "boss" && !global.longyuan_bridge_yellow_active) {
        global.longyuan_bridge_yellow_active = true;
    }

    var _tracks = ["red", "yellow"];
    for (var _i = 0; _i < array_length(_tracks); ++_i) {
        var _track = _tracks[_i];
        var _active = _track == "red" ? global.longyuan_bridge_red_active : global.longyuan_bridge_yellow_active;
        if (!_active) continue;
        var _obstacle_key = "longyuan_bridge_obstacle_" + _track;
        var _timer_key = "longyuan_bridge_obstacle_timer_" + _track;
        if (instance_exists(global[$ _obstacle_key])) continue;
        global[$ _timer_key]++;
        if (global[$ _timer_key] < 1200) continue;
        // 障碍物移动路径（0-based [col,row]，从轨迹起点 (1,6)/(1,2) 出发依次经过每格）
        var _path = _track == "red"
            ? [[5, 0], [5, 1], [5, 2], [4, 2], [3, 2], [3, 3], [3, 4], [3, 5], [3, 6]]
            : [[1, 0], [1, 1], [1, 2], [1, 3], [1, 4], [2, 4], [3, 4], [4, 4], [5, 4], [6, 4], [7, 4], [7, 5], [7, 6]];
        var _first = _path[0];
        var _start = get_world_position_from_grid(_first[0], _first[1]);
        var _inst = instance_create_depth(_start.x, _start.y - 35, -1300, obj_longyuan_bridge_obstacle);
        _inst.longyuan_bridge_track = _track;
        _inst.longyuan_bridge_path = _path;
        _inst.longyuan_bridge_path_index = 0;
        global[$ _obstacle_key] = _inst;
        global[$ _timer_key] = 0;
    }
}

/// 创建并启动龙渊 BOSS 特效实例（按动作表驱动）
function longyuan_boss_fx_start(_inst, _kind, _action, _loop = false, _rate = 5, _next = "", _next_loop = true) {
    with (_inst) {
        ly_kind = _kind;
        ly_anims = longyuan_animation_table(_kind);
        fx_kind = _kind;
        fx_rate = _rate;
        fx_loop = _loop;
        fx_loop_after = _next_loop;
        fx_next_action = _next;
        timer = 0;
        longyuan_clip_set(_action);
        fx_ready = true;
    }
}
