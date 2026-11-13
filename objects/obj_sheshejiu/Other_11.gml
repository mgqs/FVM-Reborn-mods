// obj_sheshejiu 用户事件 1：3*3 变星（把**这次实际加减了几星**记进 ss_snap，持续时间到点由 Other_12 反向复原）
//   非实体卡走黑名单（同美味计时器那套）+ 自身 + player
//   星级上下限 0~16；2 转表里没有负数 → 天然「只升不降」
// 2026-11-13：把时光机也排除 —— 两卡互相作用会出现「星级图标留在原地」，
//   而且时光机是**永久**改星、蛇蛇酒有计时，混在一起会被复原覆盖掉。
var _mb_blacklist = ["brahma", "ice_cream", "magic_chicken", "clotho", "kuileima",
                     "shegengbao", "baibianshe", "xingqiongma", "sheshejiu", "shiguangji", "player"];

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

    var _old   = current_level;
    var _new   = clamp(_old + _off, 0, 16);
    var _delta = _new - _old;      // **实际**加减了几星（撞到 0 / 16 时会被吃掉一部分）
    if (_delta == 0) continue;

    mod_set_card_level(id, _new);

    // ── 记「这次实际加减了几星」──
    //   2026-11-13 用户口径：复原按**加减数**反向来（+2 到期就 -2），不看复原时是多少星，
    //   所以中途被别的卡改过也不影响；同一张卡被多轮命中就累加。
    var _found = -1;
    for (var _j = 0; _j < ds_list_size(other.ss_snap); _j++){
        if (other.ss_snap[| _j].inst == id){
            _found = _j;
            break;
        }
    }
    if (_found >= 0){
        var _snap_e = other.ss_snap[| _found];   // 结构体是引用，改字段就等于改列表里那条
        _snap_e.off += _delta;
    } else {
        ds_list_add(other.ss_snap, {
            inst: id,
            off:  _delta,
            pid:  plant_id,
            col:  grid_col,
            row:  grid_row
        });
    }

    // ── 星光演出（复用 obj_clotho 那套）──
    var _eff = instance_create_depth(x, y, depth - 1, obj_clotho_star_effect);
    if (instance_exists(_eff)){
        if (_delta < 0)             _eff.sprite_index = spr_clotho_star_drop;
        else if (other.shape >= 2)  _eff.sprite_index = spr_clotho_star_up_1;
        else                        _eff.sprite_index = spr_clotho_star_up;
        _eff.state = clamp(abs(_delta) - 1, 0, 4);
    }
}
