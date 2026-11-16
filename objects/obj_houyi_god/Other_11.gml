var fire_flags = [fire_up, fire_mid, fire_down];
var row_offsets = [-1, 0, 1];

// 出膛点：地图最左沿往左 0.5 格（同 bbq / 法师蛇的 fashishe_start_cells = -0.5），不跟卡片位置走
var houyi_start_x = global.grid_offset_x - 0.5 * global.grid_cell_size_x;
var houyi_art_up  = 36;   // 贴图格线比逻辑网格高 36px（同 bbq_art_up / fashishe_art_up）

// 伤害倍率：压缩后的单发值已经写进 atk 表，这里只剩「同一形态内行与行不同」的差值
//   表口径：0/三转 = 官方 ×3，四转 = ×4，终转 = ×5（= 每行 1 发代表原来 3/4/5 发）
//   三转中路多 1 发 → 中路 = 侧路 × 4/3
var dmg_mul_mid = 1;
var dmg_mul_side = 1;
// 该行「原版发数」：只用来判第 3n 发（压缩后 1 发代表 N 发）
var shots_mid = 3;
var shots_side = 3;
var ash_kill = false;

switch (shape)
{
    case 0:
        break;
    case 1: // 三转：中路子弹+1（4 发压 1）
        dmg_mul_mid = 4.0 / 3.0;
        shots_mid = 4;
        break;
    case 2: // 四转：侧路两行子弹+1，击杀灰烬
        shots_mid = 4;
        shots_side = 4;
        ash_kill = true;
        break;
    case 3: // 终转：每行子弹+1，叠加次数提高
        shots_mid = 5;
        shots_side = 5;
        ash_kill = true;
        break;
}

// 永远只创建3颗子弹（上、中、下各1发）
for (var i = 0; i < 3; i++)
{
    if (fire_flags[i])
    {
        var target_row = grid_row + row_offsets[i];
        if (target_row < 0 || target_row >= global.grid_rows) target_row = grid_row;

        // 每发都从最左沿出生、走本行中线（不再从卡片高度斜插过去）
        var start_x = houyi_start_x;
        var start_y = global.grid_offset_y + target_row * global.grid_cell_size_y
                    + global.grid_cell_size_y * 0.5 - houyi_art_up;
        var is_mid = (i == 1);
        var dmg_mul = is_mid ? dmg_mul_mid : dmg_mul_side;
        var shots_n  = is_mid ? shots_mid : shots_side;

        // 每行独立累计「原版发数」：跨过 3 的倍数就补一份地火
        //   本体 N=3 → 每轮 1 份；三转中路 N=4 → 1/1/2（12 发 4 次）；终转 N=5 → 1/2/2（15 发 5 次）
        var _prev = burn_acc[i];
        var _now  = _prev + shots_n;
        burn_acc[i] = _now;
        var _added = floor(_now / 3) - floor(_prev / 3);
        for (var _k = 0; _k < _added; _k++) houyi_burn_at(target_row, dmg_mul);

        var inst = instance_create_depth(start_x, start_y, depth - 500, obj_houyi_god_bullet);
        inst.damage = atk * dmg_mul;
        inst.move_speed = 8;
        inst.row = target_row;
        inst.target_row = target_row;
        inst.start_y = start_y;
        inst.shape = shape;
        inst.ash_kill = ash_kill;

        switch (shape)
        {
            case 0:
                inst.sprite_index = spr_houyi_god_bullet;
                break;
            case 1:
                inst.sprite_index = spr_houyi_god_bullet_1;
                break;
            case 2:
                inst.sprite_index = spr_houyi_god_bullet_2;
                break;
            case 3:
                inst.sprite_index = spr_houyi_god_bullet_3;
                break;
        }
    }
}

if (fire_up || fire_mid || fire_down)
    audio_play_sound(snd_shot, 0, 0);
