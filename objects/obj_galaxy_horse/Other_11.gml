// obj_galaxy_horse 用户事件 1（Other_11）：出陨石
// 一轮 gh_bullet_count 发（0/1 转 1 发、2 转 3 发），后几发晚 gh_shot_gap 帧起落。
//
// ── 落点口径（2026-11-14 修「索敌存在问题」）──────────────────────────────
// 情报岛原文：「有目标时才会攻击，每隔[攻击间隔]秒召唤1颗陨石砸向本行……
//   陨石只落在本行，仅对本行索敌目标造成[攻击力]点伤害，其余目标受到50%溅射伤害。」
//   这里的「本行」= 被锁定的那只老鼠所在的行（陨石一次只砸**一行**，不是散砸多行），
//   「索敌目标」= 出弹时锁定的那一只；周围 gh_splash_rows × gh_splash_cols 吃 50%。
//   「索敌 3/3/5 行」是开火条件（本行 ±1 / ±2 行内有目标就打），不是落点范围。
//
// 旧实现的两条 bug，合起来就是「陨石砸空地、砸不到老鼠」：
//   ① 候选只收**卡片本行**的敌人，可 gh_has_target() 是按 ±1/±2 行判开火的
//      → 场上只有邻行老鼠时卡照样开火，候选却是空的（截图现场：卡片 col2、老鼠 col8
//        在相邻行，两发陨石却砸在 col4 / col5 的空地上）；
//   ② 候选为空时用 `grid_col + 2 + _k` 兜底 → 陨石落在卡片右前方 2/3/4 格，
//      既没有全额目标，也离真正的老鼠远得连溅射都够不着。
// 现在：候选 = 本行 ±gh_search_rows 行内、卡片前方、gh_hittable 命中的目标；
//   排序键 = 行距（本行优先）→ 列号（离卡片近的优先）；第 k 颗锁第 k 个候选，
//   落点 = 该候选的真实 x/y（敌人生成点比格心右 30px、行走时也不在格心）。
//   候选为空干脆不出弹，不再白放一发空地陨石。
var _cand = [];
with (obj_enemy_parent)
{
    // 命中类型直接查数组。口径与 Create 里的 gh_can_hit() 保持一致
    // （那边是给外部/单实例判定用的入口，这里在 with 里内联，省一次跨实例方法调用）。
    // variable_instance_exists 兜 target_type：obj_enemy_parent 的 297 个直接子对象里有
    // obj_beverage_skill_1_bullet / _3_bullet 这类压根没写 target_type 的，直接读会硬崩。
    if (hp > 0 && variable_instance_exists(id, "target_type")
        // 卡面「无法攻击非主流」：三只非主流家族啃食时 target_type 变回 "normal"，
        // gh_hittable 白名单拦不住，这里按身份再排一次（见 is_non_mainstream）。
        && !is_non_mainstream(id)
        && array_get_index(other.gh_hittable, target_type) != -1)
    {
        if (grid_col >= other.grid_col && grid_col <= global.grid_cols + 1
            && abs(grid_row - other.grid_row) <= other.gh_search_rows)
        {
            var _drow = abs(grid_row - other.grid_row);
            var _dcol = grid_col - other.grid_col;

            // 同一格只算一个候选（否则 3 发全砸同一格，看起来像只出 1 发）
            var _dup = false;
            for (var _q = 0; _q < array_length(_cand); _q++)
            {
                if (_cand[_q].col == grid_col && _cand[_q].row == grid_row)
                {
                    _dup = true;
                    break;
                }
            }
            if (!_dup)
            {
                array_push(_cand, {
                    inst: id,
                    col:  grid_col,
                    row:  grid_row,
                    x:    x,
                    y:    y,
                    drow: _drow,
                    dcol: _dcol
                });
            }
        }
    }
}

// 行距升序 → 列距升序（插入排序，项数最多几十，够用）
var _n = array_length(_cand);
for (var _i = 1; _i < _n; _i++)
{
    var _v = _cand[_i];
    var _j = _i - 1;
    while (_j >= 0)
    {
        var _a = _cand[_j];
        var _before = (_a.drow < _v.drow) || (_a.drow == _v.drow && _a.dcol <= _v.dcol);
        if (_before) break;
        _cand[_j + 1] = _a;
        _j--;
    }
    _cand[_j + 1] = _v;
}

// 没候选就不出弹
if (_n <= 0)
{
    attack_timer = 0;
    state = CARD_STATE.IDLE;
    exit;
}

for (var _k = 0; _k < gh_bullet_count; _k++)
{
    var _pick = _cand[min(_k, _n - 1)];

    // 横向跟目标的真实 x（敌人生成点比格心右 30px、走路时也不在格心），
    // 纵向用该行的格心 —— 精灵原点是「落地炸点」，摆在格心才不压到下一行。
    var _cell = get_world_position_from_grid(_pick.col, _pick.row);

    var _b = instance_create_depth(_pick.x, _cell.y, depth - 600, obj_galaxy_horse_bullet);
    _b.sprite_index     = gh_bullet_spr;
    _b.gh_row           = _pick.row;
    _b.gh_col           = _pick.col;
    _b.gh_target        = _pick.inst;    // 只有它吃全额，其余吃 gh_splash_ratio
    _b.gh_damage        = atk;
    _b.gh_splash_rows   = gh_splash_rows;
    _b.gh_splash_cols   = gh_splash_cols;
    _b.gh_splash_ratio  = gh_splash_ratio;
    _b.gh_stun          = gh_stun_ticks;
    _b.gh_hittable      = gh_hittable;
    _b.gh_delay         = _k * gh_shot_gap;
}

audio_play_sound(snd_shot, 0, 0);
