if (global.is_paused) exit;

// 2026-11-06 用户口径（按素材实际分段，一颗子弹走完全程，不再另建火格对象）：
//   0~9   帧 = 飞行过程图（10 张）
//   10~16 帧 = 落地炸开（7 张；第 17 帧是空帧，跳过免得闪一下）
//   18~27 帧 = 火焰，循环到 2 秒；**火焰期间才结算伤害**，到点直接消失（不淡出）
// 伤害节奏：tick_gap（12 帧 = 0.2 秒）一跳 × tick_count（10 跳）= 2 秒
// 注意：obj_dangdanghu_fire 用的是同一张精灵，位置一致，所以合并到子弹里不会跑位。

// ── 阶段 0：飞行 ──
if (phase == 0){
    t++;
    var _p = min(1, t / max(1, T));
    x = lerp(sx, tx, _p);
    y = lerp(sy, ty, _p) - sin(_p * pi) * arc;
    image_angle += 8;
    image_index = min(9, floor(t * 10 / max(1, T)));   // 10 张飞行图均分整段飞行时间

    if (_p >= 1){
        phase   = 1;
        x = tx;
        y = ty;
        image_angle = 0;
        burn_t  = 0;
        image_index = 10;
        image_xscale = 1.8;      // 与原来 obj_dangdanghu_fire 一致，火焰铺满 3×3
        image_yscale = 1.8;
    }
    exit;
}

// ── 阶段 1：落地炸开（10~16，每 3 帧一张，共 21 帧）──
if (phase == 1){
    burn_t++;
    image_index = 10 + min(6, burn_t div 3);
    if (burn_t >= 21){
        phase   = 2;
        burn_t  = 0;
        ticks   = 0;
        tick_timer = 0;
        image_index = 18;
        audio_play_sound(snd_bullet_burnt, 0, 0);   // 2026-11-13 补：落地起火音（只响这一次，后续每跳不重复）
    }
    exit;
}

// ── 阶段 2：火焰循环（18~27）+ 结算伤害 ──
image_index = 18 + ((burn_t div 4) mod 10);
burn_t++;

tick_timer++;
if (tick_timer >= tick_gap){
    tick_timer = 0;
    ticks++;

    // 每跳伤害 = 攻击力本身（单次伤害，不是「总计 ÷ 跳数」）
    var _per = damage;

    var _cross = (shape < 2);      // 0/1 转 3×3 十字；2 转 3×3 方块
    var _gc = col;
    var _gr = row;
    with (obj_enemy_parent){
        if (hp <= 0) continue;
        // 🔴 2026-11-06：原来只看格子，空军 / 非主流 / 幽灵 / 障碍站在火格里也会被烧。
        //   照生煎锅 / 糖炒栗子（obj_tangchaolizi_bullet_effect）的做法按可命中类型过滤：
        //   投掷类 = 陆 + 潜水鼠，别的类型一脚都不吃。
        if (!can_hit(other.target_type, target_type)) continue;
        var _dr = grid_row - _gr;
        var _dc = grid_col - _gc;
        var _in = false;
        if (abs(_dr) <= 1 && abs(_dc) <= 1){
            if (_cross){
                _in = (abs(_dr) + abs(_dc) <= 1);
            }
            else{
                _in = true;
            }
        }
        if (_in){
            damage_amount = _per;
            // 🔴 2026-11-06：原来写 "ash"，但龙渊魂体（ly_kailu / ly_zhinian / 符咒魂鼠）会
            //   对 damage_type == "ash" 的伤害**整额退还** → 灼烧对魂系鼠等于 0 伤害。
            //   糖炒栗子/生煎锅都是 "throw"，这里跟它们对齐。
            damage_type = "throw";
            event_user(0);
        }
    }
}

if (ticks >= tick_count) instance_destroy();
