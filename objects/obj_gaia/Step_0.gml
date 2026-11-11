if (global.is_paused)
    exit;

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

event_inherited();

if (is_frozen || state == 4)
    exit;

if (cooldown_timer > 0)
{
    cooldown_timer--;
    state = 0;
    exit;
}

var has_enemy = false;
var target_enemy = -4;

if (!attacking)
{
    // 2026-11-11：索敌口径改为「咖喱龙虾炮(find_priority_enemy)」——
    //   旧逻辑是「本行 ±row_offset 行内、列坐标最靠左的敌人」，
    //   新逻辑与龙虾炮一致：任意行，只看存活(hp>0)、已进屏(y>0)、
    //   命中类型通过(can_hit_ash)，优先 maxhp 最高的，maxhp 相同取最左(x 最小)。
    //   行限制 row_offset 因此取消 —— 巨石会直接飞到目标所在格落点爆炸，
    //   3*3 / 5*5 的爆炸范围仍由 obj_gaia_bullet 自己按 shape 决定。
    //   唯一保留的是「已进地图」这一条（grid_col <= 列数+1）：龙虾炮没有这条，
    //   但巨石是落点即爆，锁到还在屏幕外很远的鼠（含刚生成、占位 99 的实例）
    //   等于白发一发；这一条不影响「不限行 / 血上限优先」的改动。
    var _best_hp = -1;
    var _best_x = room_width;

    with (obj_enemy_parent)
    {
        if (hp > 0 && y > 0 && grid_col <= (global.grid_cols + 1)
            && can_hit_ash(other.target_type, target_type))
        {
            if (maxhp > _best_hp || (maxhp == _best_hp && x < _best_x))
            {
                _best_hp = maxhp;
                _best_x = x;
                target_enemy = id;
                has_enemy = true;
            }
        }
    }
}

if (has_enemy)
{
 target_x = target_enemy.x;
 target_y = target_enemy.y;
 target_row = target_enemy.grid_row;
 attacking = true;
}

if (attacking)
{
    state = 1;
    attack_timer++;
    
    if (attack_timer == ((attack_anim - 10) * current_flash_speed))
        event_user(1);
    
    if (attack_timer == ((attack_anim - 8) * current_flash_speed))
        event_user(1);
    
    if (attack_timer == ((attack_anim - 6) * current_flash_speed))
        event_user(1);
    
    if (attack_timer >= (attack_anim * current_flash_speed))
    {
        attacking = false;
        cooldown_timer = cycle - attack_timer;
        attack_timer = 0;
        target_x = -4;
    }
}

