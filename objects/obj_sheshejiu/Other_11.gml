// obj_sheshejiu 用户事件 1：3*3 变星（顺便把原值记进 ss_snap，持续时间到点由 Other_12 复原）
//   非实体卡走黑名单（同美味计时器那套）+ 自身 + player
//   星级上下限 0~16；2 转表里没有负数 → 天然「只升不降」
var _mb_blacklist = ["brahma", "ice_cream", "magic_chicken", "clotho", "kuileima",
                     "shegengbao", "baibianshe", "xingqiongma", "sheshejiu", "player"];

var _mc = grid_col;
var _mr = grid_row;
var _n  = array_length(ss_off);

with (obj_card_parent){
    if (array_get_index(_mb_blacklist, plant_id) != -1) continue;
    if (abs(grid_col - _mc) > 1) continue;
    if (abs(grid_row - _mr) > 1) continue;
    if (!variable_instance_exists(id, "current_level")) continue;
    if (hp <= 0) continue;

    // ── 累加掷骰（百分数表）──
    var _r   = irandom(99);
    var _acc = 0;
    var _off = 0;

    for (var _i = 0; _i < _n; _i++){
        _acc += other.ss_chance[_i];
        if (_r < _acc){
            _off = other.ss_off[_i];
            break;
        }
    }
    if (_off == 0) continue;

    var _old = current_level;
    var _new = clamp(_old + _off, 0, 16);
    if (_new == _old) continue;

    mod_set_card_level(id, _new);

    // ── 记原值（同一张卡只记第一次，复原时写回这一份）──
    var _recorded = false;
    for (var _j = 0; _j < ds_list_size(other.ss_snap); _j++){
        var _e = other.ss_snap[| _j];
        if (_e.inst == id){
            _recorded = true;
            break;
        }
    }
    if (!_recorded){
        ds_list_add(other.ss_snap, {
            inst: id,
            lv:   _old,
            pid:  plant_id,
            col:  grid_col,
            row:  grid_row
        });
    }

    // ── 星光演出（复用 obj_clotho 那套）──
    var _eff = instance_create_depth(x, y, depth - 1, obj_clotho_star_effect);
    if (instance_exists(_eff)){
        if (_off < 0)               _eff.sprite_index = spr_clotho_star_drop;
        else if (other.shape >= 2)  _eff.sprite_index = spr_clotho_star_up_1;
        else                        _eff.sprite_index = spr_clotho_star_up;
        _eff.state = clamp(abs(_off) - 1, 0, 4);
    }
}
