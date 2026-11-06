if (global.is_paused) exit;
event_inherited();

if (is_frozen) exit;

// ── 帧机（分段见 Create_0，2026-11-06 用户口径）──
//   0 不在动画里 → 待机 0~11
//   1 咬住 26~30（编辑器 27~31，31 帧落地）
//   2 消化 31~46（编辑器 32~47）循环 —— 🔴 只循环这一段，不能把 26~30 再放一遍
//   3 咽下 47~51（编辑器 48~52）
if (eat_phase > 0){
    if (digest_timer > 0) digest_timer--;
    eat_t++;
    if (eat_phase == 1){
        var _fb = TUN_BITE_FIRST + (eat_t div flash_speed);
        if (_fb > TUN_BITE_LAST){          // 用 > 才会把「落地」那一帧（30）也画出来
            eat_phase = 2; eat_t = 0;
            image_index = TUN_CHEW_FIRST;
        }
        else image_index = _fb;
    }
    else if (eat_phase == 2){
        if (digest_timer <= 0){
            eat_phase = 3; eat_t = 0;
            image_index = TUN_SWALLOW_FIRST;
        }
        else image_index = TUN_CHEW_FIRST + ((eat_t div flash_speed) mod TUN_CHEW_LEN);
    }
    else{
        var _fs2 = TUN_SWALLOW_FIRST + (eat_t div flash_speed);
        if (_fs2 > TUN_SWALLOW_LAST){      // 同理：52 帧（咽完）也要画出来
            eat_phase = 0; eat_t = 0;
            image_index = 0;
        }
        else image_index = _fs2;
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
    // 障碍（铁锅 / 路障这类）**不能吞**（2026-11-06 用户口径）：
    //   原来没做类型过滤，不防爆的障碍会被 instance_destroy 直接「吃掉」，防爆的白扣 3000。
    if (target_type == "obstacle") continue;
    if (target_type == "air") continue;              // 飞行鼠不吞
    if (target_type == "underground") continue;      // 地鼠军（钻地 / 地下）不吞
    if (target_type == "diver") continue;            // 潜水鼠不吞
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
            // 地面 · 不防爆的普通鼠 → **直接没了**（照汉堡包 obj_hamburger/Other_11 的 instance_destroy）
            //   🔴 别再用 hp = 0 + event_user(0)：那会走敌人自己的死亡流程，播完死亡动作**留一具尸体在原地**，
            //      看起来像没秒杀掉。吞掉的语义就是「整只消失」。
            instance_destroy();
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
// 吞噬动画从「咬住」段起播（26 = 编辑器第 27 帧），31 帧落地后进消化循环
eat_phase = 1;
eat_t = 0;
image_index = TUN_BITE_FIRST;
event_user(1);       // 播吞咽用的音效 / 表现
