// obj_caihongshe Step 事件
if (global.is_paused){
    exit
}
event_inherited();

if (is_frozen){
    exit
}

var _fs = flash_speed;
if (is_slowdown) _fs *= 2;

// 🔴 2026-11-06 图层调低：父对象按 plant_type = "shield_outer" 算的 depth 会排在普通卡**前面**，
//   蛇盘成的环会挡住自己格 / 边上格里的卡片。这里每帧在父对象算完之后再往后退 6
//   （父对象每帧都会重算一次 depth，所以这里 += 不会累积）。
depth += 6;

// ---------- 反伤：被咬掉多少血，就 100% 弹给正在啃它的老鼠 ----------
if (current_hp > hp){
    var _loss = current_hp - hp;
    current_hp = hp;
    if (_loss > 0){
        with (obj_enemy_parent){
            if (hp > 0 && target_plant == other.id){
                damage_amount = _loss;
                damage_type = "true";
                event_user(0);
            }
        }
    }
}

// ---------- 帧机 + 子弹 ----------
// 索敌：本行右前方有敌人才开火（弹道只有「向前 1 发」）
var _has = false;
with (obj_enemy_parent){
    if (hp > 0 && grid_row == other.grid_row && grid_col >= other.grid_col
        && can_target_on(other.target_type, target_type)){
        _has = true;
    }
}

// 分段（image_index 0 起算，括号=编辑器第几帧）——见 Create_0 的注释
//   健康待机 0~13 / 虚弱待机 14~27 / 健康开火 28~40 / 虚弱开火 41~54 / 爆炸 55~63
var _weak    = (hp <= max_hp * 0.5);
var _idle_s  = _weak ? 14 : 0;          // 待机段起点
var _atk_s   = _weak ? 41 : 28;         // 开火段起点
var _atk_len = _weak ? 14 : 13;         // 开火段帧数
var _fire_step = 7;                     // 开火段第 8 帧张嘴出弹（健康 = 第 36 帧 / 虚弱 = 第 49 帧）

// 冷却照常攒（没敌人也攒，出弹节奏不会乱）
shoot_timer = min(shoot_timer + 1, 600);

// 攒满 + 有目标 → 起一段开火动画
if (cai_atk_t < 0 && _has && shoot_timer >= max(30, cycle)){
    shoot_timer = 0;
    cai_atk_t = 0;
    fired_this_attack = false;
    state = CARD_STATE.ATTACK;
}

if (cai_atk_t >= 0){
    var _step = cai_atk_t div _fs;      // 每 _fs 帧推一帧（被减速时 _fs 翻倍 → 动画一起变慢）
    if (_step >= _atk_len){
        // 播完回待机（这一帧不再 ++，否则 -1 会被推回 0 → 开火段无限循环）
        cai_atk_t = -1;
        fired_this_attack = false;
        cai_idle_t = 0;
        state = CARD_STATE.IDLE;
        image_index = _idle_s;
    }
    else{
        image_index = _atk_s + _step;
        if (!fired_this_attack && _step >= _fire_step){
            fired_this_attack = true;
            event_user(1);
        }
        cai_atk_t++;
    }
}
else{
    // 待机：健康 0~13 / 虚弱 14~27 各自循环，永远不走进开火段和爆炸段
    cai_idle_t++;
    image_index = _idle_s + ((cai_idle_t div _fs) mod 14);
}

// ---------- 错帧连射（2 转 3 发）：Other_11 只打第一发，后面几发在这里补 ----------
if (burst_left > 0){
    burst_timer++;
    if (burst_timer >= burst_gap){
        burst_timer = 0;
        burst_left--;
        cai_fire_one();
    }
}
