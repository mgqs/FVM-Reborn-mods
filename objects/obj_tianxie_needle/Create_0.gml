// obj_tianxie_needle Create 事件
// 天蝎座「猩红毒针」的**打击演出 + 逐格伤害**（2026-11-09 从「纯视觉」改成结算载体）
//   素材 23 帧 = 帧 1~6 飞针 / 7~16 依次冒白烟 / 17~22 四针立住 / 23 消失
//   流程：以**平射子弹速度**从出弹口（fx_from_x）飞到目标格（fx_land_x）→ 播落地段 →
//         每根针「钉住」那一帧结算对应格
//
// ── 素材对齐（2026-11-09 像素量出来的，改缩放别改这几个数）────────────
//   精灵 332×125、原点 (20,62)；四针中心 x = 105.5 / 171 / 231.5 / 296（均值间隔 63.5px）
//   针底 y = 96 → 相对原点 +34
//   缩放 = 格宽 107 / 63.5 ≈ 1.685（卡侧 tianxie_needle_scale 传进来）→ 针距刚好 = 一格
//   落点：针 1 中心对齐「目标格中心」，所以 实例x = 格心 - 85.5 × 缩放
//        纵向：针底踩在 格心 + 40（老鼠脚底线 +38 附近）→ 实例y = 格心 + 40 - 34 × 缩放
image_speed = 0;
image_index = 0;

fx_row      = 0;          // 打哪一行
fx_col0     = 0;          // 从哪一格开始（最左敌人所在列）
fx_cells    = 4;          // 打几格（卡侧 tianxie_needle_cells）
fx_dmg      = 0;          // 每格伤害 = 卡的 atk（卡侧传，已吃增幅）
fx_dmg_type = "pierce";   // 伤害类型
fx_from_x   = x;          // 出弹口 x（飞行段起点）
fx_land_x   = x;          // 针 1 的落点 x（卡侧算好）
fx_ground_y = y;          // 演出的纵向位置（卡侧算好）

fx_t     = 0;             // 落地段已推进帧数
fx_ready = false;         // 第一次 Step 时按 fx_cells 建数组

// ── 飞行段（2026-11-09 用户：按正常平射口径，别一帧滑一百多像素）──
//   实体定在素材第 6 帧（针最长那张）直线飞向落点，速度与平射子弹同量级；
//   到达后再从第 7 帧开始播「依次冒白烟 → 四针立住」。
fx_move_speed = 8;        // 每 tick 前进像素（小笼包 / 披萨子弹都是 8，法师蛇 6.5）
fx_fly_anim   = 5;        // 飞行段定格帧（0 基索引 5 = 素材第 6 帧）
fx_land_anim  = 6;        // 落地段起始帧（0 基索引 6 = 素材第 7 帧，第一根针冒白烟）
fx_fly_x      = x;        // 飞行段当前 x（Step 里从 fx_from_x 起步）
fx_arrived    = false;

// 每根针「钉住」的那一帧（0 基索引，量自素材冒白烟的先后）：
//   帧 7 → 第一根（最左格）、帧 11 → 第二根、帧 13 → 第三根、帧 15 → 第四根
fx_stick_frames = [6, 10, 12, 14];

fx_landed = array_create(fx_cells, false);   // 每格是否已经结算过
fx_hit    = ds_list_create();                // 已经吃过的敌人 id（防止同一只被相邻格打两次）

/// 结算一格：_col 格里所有能被「穿透」打到的老鼠，各吃一次 fx_dmg
///   🔴 走敌人自己的 event_user(0)（护盾 / 减伤 / 统计都在这条路上），与卡侧原来那段同口径
fx_hit_cell = function(_col)
{
    var _n = instance_number(obj_enemy_parent);
    for (var _i = 0; _i < _n; _i++)
    {
        var _e = instance_find(obj_enemy_parent, _i);
        if (!instance_exists(_e) || _e.hp <= 0) continue;
        if (_e.grid_row != fx_row) continue;
        if (_e.grid_col != _col) continue;
        if (ds_list_find_index(fx_hit, _e.id) != -1) continue;
        if (!can_target_on("pierce", _e.target_type)) continue;

        ds_list_add(fx_hit, _e.id);
        with (_e)
        {
            damage_amount        = other.fx_dmg;
            damage_type          = other.fx_dmg_type;
            damage_source_object = other.object_index;
            // 钻地中的龙渊地精会吃掉伤害 → 结算前放行（同旋转喷壶）
            if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
            event_user(0);
        }
    }
};
