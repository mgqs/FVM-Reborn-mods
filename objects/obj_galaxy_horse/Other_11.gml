// obj_galaxy_horse 用户事件 1（Other_11）：出陨石
// 一轮 gh_bullet_count 发（0/1 转 1 发、2 转 3 发），落点全部在**本行**（官方：子弹仅落在本行），
// 后几发晚 gh_shot_gap 帧起落（不是同帧一起砸下来）。
//
// 落点列取法：本行前方最近的目标列依次分配；本行没目标时落到卡片右前方 2 / 3 / 4 格，
//   只靠溅射打人（官方：仅对本行索敌目标造成全额伤害，其余 50% 溅射）。
var _own = [];
with (obj_enemy_parent)
{
    if (hp > 0
        && grid_row == other.grid_row
        && grid_col >= other.grid_col
        && grid_col <= global.grid_cols + 1
        && array_get_index(other.gh_hittable, target_type) != -1)
    {
        array_push(_own, grid_col);
    }
}

// 列升序（简单的插入排序，不依赖 array_sort 比较器）
var _n = array_length(_own);
for (var _i = 1; _i < _n; _i++)
{
    var _v = _own[_i];
    var _j = _i - 1;
    while (_j >= 0 && _own[_j] > _v)
    {
        _own[_j + 1] = _own[_j];
        _j--;
    }
    _own[_j + 1] = _v;
}

for (var _k = 0; _k < gh_bullet_count; _k++)
{
    var _col = (_k < _n) ? _own[_k] : min(global.grid_cols, grid_col + 2 + _k);
    var _cell = get_world_position_from_grid(_col, grid_row);

    var _b = instance_create_depth(_cell.x, _cell.y, depth - 600, obj_galaxy_horse_bullet);
    _b.sprite_index     = gh_bullet_spr;
    _b.gh_row           = grid_row;
    _b.gh_col           = _col;
    _b.gh_damage        = atk;
    _b.gh_splash_rows   = gh_splash_rows;
    _b.gh_splash_cols   = gh_splash_cols;
    _b.gh_splash_ratio  = gh_splash_ratio;
    _b.gh_stun          = gh_stun_ticks;
    _b.gh_hittable      = gh_hittable;
    _b.gh_delay         = _k * gh_shot_gap;
}

audio_play_sound(snd_shot, 0, 0);
