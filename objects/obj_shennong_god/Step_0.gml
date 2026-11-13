if (global.is_paused)
    exit;

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

event_inherited();

if (is_frozen || state == CARD_STATE.SLEEP)
    exit;

// === 终转（shape 3）：场上炎帝超过 7 只时，攻击力最高的 1 只每 5 秒追加竖向陨焰 ===
// 规则（数据表）：在 7.5 / 8.5 列 0 行各召唤 1 发竖向子弹向下飞，攻击 7~9 列，
// 三列分别受击 1 / 2 / 1 次。7.5 列的弹覆盖第 7、8 列，8.5 列的弹覆盖第 8、9 列，
// 于是第 8 列被两发各打 1 次 = 2 次，第 7、9 列各 1 次。
// 本段必须放在 cooldown_timer 判断之前：追加陨焰不吃卡片自身攻击间隔。
is_top_attacker = false;

if (shape == 3 && instance_number(obj_shennong_god) > 7)
{
    // 在「已终转」的炎帝里找攻击力最高的那一只；攻击力相同则取 id 最小的，保证只有 1 只出手。
    var _best_id = noone;
    var _best_atk = -1;

    with (obj_shennong_god)
    {
        if (shape != 3) continue;

        if (atk > _best_atk)
        {
            _best_atk = atk;
            _best_id = id;
        }
        else if (atk == _best_atk && (_best_id == noone || id < _best_id))
        {
            _best_id = id;
        }
    }

    is_top_attacker = (id == _best_id);
}

if (is_top_attacker)
{
    vburst_timer++;

    if (vburst_timer >= 300)   // 5 秒
    {
        vburst_timer = 0;

        for (var _vb_i = 0; _vb_i < 2; _vb_i++)
        {
            // _vb_i = 0 → 列坐标 7.0（即 7.5 列那条边界），1 → 8.0（即 8.5 列）
            var _line_x = global.grid_offset_x + (7 + _vb_i) * global.grid_cell_size_x;
            var _line_y = global.grid_offset_y - 120;

            var _vb = instance_create_depth(_line_x, _line_y, depth - 520, obj_shennong_god_bullet_v3);
            _vb.damage = atk;
            _vb.move_speed = 8;
            // 7.5 列覆盖第 7、8 列（0 基 6、7）；8.5 列覆盖第 8、9 列（0 基 7、8）
            _vb.col_left = 6 + _vb_i;
            _vb.col_hits = [1, 1];
            _vb.ash_kill = true;
            _vb.target_type = "all";
        }

        audio_play_sound(snd_shot, 0, 0);
    }
}
else
{
    vburst_timer = 0;
}

// 冷却中则跳过攻击逻辑
if (cooldown_timer > 0)
{
    cooldown_timer--;
    exit;
}

// 检测全屏是否有可攻击的敌人（子弹全屏飞行）
var has_enemy = false;

with (obj_enemy_parent)
{
    if (grid_col >= 0 && grid_col <= (global.grid_cols + 1)
        && can_target_on(other.target_type, target_type))
    {
        has_enemy = true;
        break;
    }
}

var attack_total_frames = attack_anim * current_flash_speed;

if (has_enemy)
{
    attack_timer++;

    // 第19帧发射（索引18），攻击从第14帧（索引13）开始
    // 攻击动画共12帧（索引13~24），第19帧是攻击开始后第6帧（索引18-13=5）
    var fire_frame_in_attack = 5;
    var fire_time = fire_frame_in_attack * current_flash_speed;

    // 开始攻击
    if (attack_timer == 1)
    {
        state = CARD_STATE.ATTACK;
        image_index = idle_anim + 1;
    }

    // 第19帧发射子弹
    if (attack_timer == fire_time)
    {
        event_user(1);
    }

    // 攻击结束，重置冷却
    if (attack_timer >= attack_total_frames)
    {
        attack_timer = 0;
        cooldown_timer = cycle - attack_total_frames;
        state = CARD_STATE.IDLE;
    }
}
else
{
    attack_timer = 0;
    state = CARD_STATE.IDLE;
}
