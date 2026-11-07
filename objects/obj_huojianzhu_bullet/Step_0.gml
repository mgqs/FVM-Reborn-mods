// obj_huojianzhu_bullet Step 事件
// 2026-11-08 用户口径重写：导弹**直接落在老鼠那一格**，靠精灵自己的「从上往下落」帧表现下落，
//   贴图落完就炸 —— 不再从高空慢慢飘（原来会挂在出生高度抽搐，上一轮改成直线飞又显得很久）。
//   素材 11 帧：0 空 / 1~3 导弹下落 / 4~10 爆炸（爆炸交给 obj_huojianzhu_boom 播）。
if (global.is_paused) exit;

// 二转 3 枚错开起飞
if (launch_delay > 0)
{
    launch_delay--;
    exit;
}

// 下落期间贴住目标（还活着才跟），保证落点始终是它脚下那格
if (instance_exists(target_enemy) && target_enemy.hp > 0)
{
    x = target_enemy.x;
    y = target_enemy.y - 45;
    grid_row = target_enemy.grid_row;
    grid_col = target_enemy.grid_col;
}

timer++;

// ── 下落段：素材第 2~4 帧，每帧停 3 tick（共 9 帧 ≈ 0.15 秒）──
var _per = 3;
if (timer <= (fly_frame_to - fly_frame_from + 1) * _per)
{
    image_index = fly_frame_from + min(fly_frame_to - fly_frame_from, (timer - 1) div _per);
    exit;
}

// ── 落地：3×3 伤害 + 定身 + 爆炸 ──
var _r    = grid_row;
var _c    = grid_col;
var _dmg  = damage;
var _stun = stun_frames;

with (obj_enemy_parent)
{
    if (hp <= 0) continue;
    if (abs(grid_row - _r) > 1) continue;
    if (abs(grid_col - _c) > 1) continue;
    // 追踪口径：普通 / 潜水 / 空军（2026-11-08 用户口径：范围伤害也要按类型过滤）
    if (!can_target_on("track", target_type)) continue;

    damage_amount = _dmg;
    damage_type   = "normal";
    event_user(0);

    if (_stun > 0 && stun_timer < _stun) stun_timer = _stun;
}

// 爆炸就画在导弹落点（同一张素材的第 5~11 帧），不要再往上抬
var _fx = instance_create_depth(x, y, depth - 20, obj_huojianzhu_boom);
_fx.sprite_index = sprite_index;

audio_play_sound(snd_fire_hit, 0, 0);
instance_destroy();
