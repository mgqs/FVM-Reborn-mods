/// obj_pufferfish Step
/// 48 帧分段（0-based）：0..22 待机+膨胀+转场 / 23..34 蓝色爆炸(炸老鼠) / 37..45 红色爆炸(清卡)
/// 结算时机：**进入爆炸段的第一帧立即生效**，之后的爆炸帧只是特效（播完即销毁，不再结算）。
///   - 到 3/3/2 倍数 → 走【蓝色爆炸】→ 对全屏老鼠造成 900 灰烬伤害
///   - 未到倍数     → 走【红色爆炸】→ 随机清除场上 10/5/5 个有卡格子上的卡
/// 可取消窗口 = 前段帧 0..22（此时铲掉河豚 → 直接销毁、不结算）；
/// 一旦进入爆炸帧：效果已生效，且 can_shovel_remove = false → 铲不掉、也取消不了。
if (global.is_paused) exit;

timer++;
if (timer >= flash_speed) {
    timer = 0;

    if (puffer_phase == 0) {
        // ===================== 前段：待机 + 膨胀 + 转场 =====================
        image_index++;
        if (image_index > puffer_pre_end) {
            // 前段播完 → 判定走哪个爆炸特效，并**立即结算**
            var _need = (shape == 2) ? 2 : 3;   // 0转/1转：每 3 次；2转：每 2 次
            puffer_is_blast = (puffer_place_index mod _need == 0);

            if (puffer_is_blast) {
                // ---- 蓝色爆炸：全屏 900 灰烬伤害（只造成伤害，不额外秒杀）----
                with (obj_enemy_parent) {
                    if (hp > 0) {
                        damage_amount = 900;
                        damage_type = "ash";
                        event_user(0);
                    }
                }
                puffer_phase = 1;
                image_index = puffer_blue_start;
            }
            else {
                // ---- 红色爆炸：随机清 10/5/5 个「有卡格子」（0转 10 格，1转/2转 5 格）----
                // 规则：
                //   · 按「格子」计：一格多张卡（主卡 + 瓜皮等附着）整格一次清光，只算 1 格
                //   · 同一格绝不重复清
                //   · 河豚自己（pufferfish）不清 —— 否则会把自己炸掉、爆炸特效消失、清卡半途中断
                //   · 承载类卡（棉花糖、苏打气泡、木盘子、软糖）不能被清除
                var _clear_num = (shape == 0) ? 10 : 5;
                var _no_clear = ["player", "cotton_candy", "soda_bubble", "wooden_plate", "lingrong_god", "pufferfish"];
                var _keys = [];   // "r,c" 用于按格子去重
                var _rows = [];
                var _cols = [];

                // 1) 先收集场上所有「有可清除卡」的格子（同一格只记一次）
                with (obj_card_parent) {
                    if (array_get_index(_no_clear, plant_id) == -1) {
                        var _k = string(grid_row) + "," + string(grid_col);
                        if (array_get_index(_keys, _k) == -1) {
                            array_push(_keys, _k);
                            array_push(_rows, grid_row);
                            array_push(_cols, grid_col);
                        }
                    }
                }

                // 2) 随机抽 _clear_num 格整格清空（场上有效格不足就全清）
                var _pick = min(_clear_num, array_length(_rows));
                repeat (_pick) {
                    var _idx = irandom(array_length(_rows) - 1);
                    var _r = _rows[_idx];
                    var _c = _cols[_idx];
                    array_delete(_rows, _idx, 1);
                    array_delete(_cols, _idx, 1);

                    // 清除该格全部非承载卡（含瓜皮等附着卡，不留残余）
                    // 损卡：满血卡在此补计一次（掉血卡由 obj_card_parent/Destroy_0 自动计）
                    with (obj_card_parent) {
                        if (grid_row == _r && grid_col == _c
                            && array_get_index(_no_clear, plant_id) == -1) {
                            if (hp >= max_hp) obj_task_manager.card_loss++;
                            instance_destroy();
                        }
                    }
                }

                puffer_phase = 2;
                image_index = puffer_red_start;
            }

            // 效果已生效 → 不能被铲除（后续爆炸帧只是特效）
            can_shovel_remove = false;
            // 爆炸音效（进入爆炸段第一帧播放）
            audio_play_sound(snd_coke_bomb_explode, 0, false);
        }
    }
    else {
        // ===================== 爆炸段：纯特效，播完即销毁 =====================
        image_index++;
        var _seg_end = (puffer_is_blast) ? puffer_blue_end : puffer_red_end;
        if (image_index > _seg_end) {
            instance_destroy();
        }
    }
}
