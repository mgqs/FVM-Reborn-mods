if (global.is_paused) exit;
event_inherited();

if (is_frozen) exit;

// ── 帧机（分段见 Create_0）──
//   消化中 → 吞噬段 26~52 循环（27 帧里含「咬」和「嘴里有老鼠」）
//   待机   → 0~11；父对象兜底推到 12 的话这里再拉回来
if (digest_timer > 0){
    digest_timer--;
    if (digest_timer <= 0){
        eat_t = -1;             // 消化完毕 → 回待机
        image_index = 0;
    }
    else{
        if (eat_t < 0) eat_t = 0;
        eat_t++;
        image_index = TUN_EAT_FIRST + ((eat_t div flash_speed) mod TUN_EAT_LEN);
    }
    exit;
}

if (image_index > TUN_IDLE_LAST || image_index < 0) image_index = 0;

// 索敌：以右边第 1 格为中心的矩形范围内，取最近的一只可吞目标
var _cc = grid_col + 1;
var _tgt = noone;
var _best = 99999;

with (obj_enemy_parent){
    if (hp <= 0) continue;
    if (is_boss) continue;
    if (target_type == "air") continue;              // 飞行鼠不吞
    // 2026-11-06 按表：神风 / 深渊幽灵鼠不吞。深渊那只在本工程里没有单独 mouse_id
    //   （未显形幽灵统一是 target_type = "invisible"），这里按类型再挡一道。
    if (target_type == "invisible") continue;
    if (abs(grid_col - _cc) > other.range_col) continue;
    if (abs(grid_row - other.grid_row) > other.range_row) continue;
    if (array_get_index(other.no_eat, mouse_id) != -1) continue;

    var _d = abs(grid_col - _cc) + abs(grid_row - other.grid_row);
    if (_d < _best){
        _best = _d;
        _tgt = id;
    }
}

if (_tgt == noone) exit;

if (instance_exists(_tgt)){
    with (_tgt){
        if (!immune_to_ash){
            // 地面 · 不防爆的普通鼠 → 直接吞掉
            //   damage_amount 先清 0：event_user(0) 会再按 damage_amount 扣一次，
            //   不清的话会叠加玩家上一发子弹的伤害值（原来就带着这个隐患）
            damage_amount = 0;
            hp = 0;
            event_user(0);
        }
        else{
            // 防爆鼠 → 不吃秒杀，只按 custom["防爆伤害"] 打一下（默认 3000）
            //   走正常受伤流程（damage_amount + event_user(0)），这样海克斯减伤 / 护盾 / 伤害统计都算得上
            damage_amount = other.ash_proof_damage;
            damage_type = "normal";
            event_user(0);
        }
    }
}

digest_timer = digest_time;
swallow_t = 1;
// 吞噬动画从「咬」那一帧起播（26 = 编辑器第 27 帧）
eat_t = 1;
image_index = TUN_EAT_FIRST;
event_user(1);       // 播吞咽用的音效 / 表现
