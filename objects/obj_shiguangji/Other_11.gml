// obj_shiguangji 用户事件 1：范围内变星（永久生效）
//   一张都没作用到 → 清空自身卡槽的冷却（xlsx：「未作用于任何卡则清空自身CD」）
// 2026-11-13：把蛇蛇酒也排除（互相作用会出现星级残留 / 永久效果被复原覆盖）
var _mb_blacklist = ["brahma", "ice_cream", "magic_chicken", "clotho", "kuileima",
                     "shegengbao", "baibianshe", "xingqiongma", "shiguangji", "sheshejiu", "player"];

var _mc      = grid_col;
var _mr      = grid_row;
var _rc      = sg_range;
var _n       = array_length(sg_off);

// 命中计数必须是实例变量：`with` 里读不到调用方的 var（读 交接 坑 12）
sg_touched = 0;

with (obj_card_parent){
    if (array_get_index(_mb_blacklist, plant_id) != -1) continue;
    if (abs(grid_col - _mc) > _rc) continue;
    if (abs(grid_row - _mr) > _rc) continue;
    if (!variable_instance_exists(id, "current_level")) continue;
    if (hp <= 0) continue;

    // ── 累加掷骰 ──
    var _r   = irandom(99);
    var _acc = 0;
    var _off = 0;

    for (var _i = 0; _i < _n; _i++){
        _acc += other.sg_chance[_i];
        if (_r < _acc){
            _off = other.sg_off[_i];
            break;
        }
    }
    if (_off == 0) continue;

    var _new = clamp(current_level + _off, 0, 16);
    if (_new == current_level) continue;

    var _delta = _new - current_level;         // 先算增量（mod_set_card_level 会改 current_level）
    mod_set_card_level(id, _new);
    other.sg_touched++;
    other.sg_net += _delta;                    // 2026-11-12：累加净星数，Step 用它决定播升星还是降星演出

    // ── 星光演出 ──
    var _eff = instance_create_depth(x, y, depth - 1, obj_clotho_star_effect);
    if (instance_exists(_eff)){
        if (_off < 0)               _eff.sprite_index = spr_clotho_star_drop;
        else if (other.shape >= 2)  _eff.sprite_index = spr_clotho_star_up_1;
        else                        _eff.sprite_index = spr_clotho_star_up;
        _eff.state = clamp(abs(_off) - 1, 0, 4);
    }
}

// ── 没作用到任何卡：把自己这张卡的冷却清空 ──
if (sg_touched <= 0){
    with (obj_card_slot){
        if (card_id == "shiguangji") cooldown_timer = 0;
    }
}
