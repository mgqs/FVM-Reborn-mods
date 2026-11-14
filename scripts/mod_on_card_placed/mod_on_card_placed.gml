function mod_on_card_placed(arg0, arg1)
{
    if (card_is_copy_src(arg0))
    {
        show_debug_message("已记录" + string(arg0) + string(arg1));
        global.last_placed_card_id = arg0;
        global.last_placed_card_shape = arg1;

        // 百变蛇（2026-11-03）：待机中的百变蛇在「玩家从手牌放下下一张卡」时才变身，多张同帧一起变。
        //   · 只认玩家手动放置（obj_card_slot 放卡时打的 from_player_hand）——
        //     幻幻鸡 / 梵天 / 百变蛇自己复制出来的卡不算「放下下一张卡」
        //   · 只认比它晚放下的卡（id 更大），避免 5 帧轮询把「上一张卡」误当下一张
        //   · 0 转只认本卡 5x5 范围内落下的卡；1 转起全屏（与本卡复制范围同口径）
        var _from_hand = variable_instance_exists(self, "from_player_hand") && self.from_player_hand;
        if (_from_hand)
        {
            var _src_id  = self.id;
            var _src_col = self.grid_col;
            var _src_row = self.grid_row;
            with (obj_baibianshe)
            {
                if (tb_waiting && id < _src_id)
                {
                    if (shape != 0 || (abs(grid_col - _src_col) <= 2 && abs(grid_row - _src_row) <= 2))
                    {
                        target_card  = arg0;
                        target_shape = arg1;
                        tb_waiting   = false;
                        timer        = 0;               // 重置动画计时 → 多张百变蛇帧步完全同步
                        image_index  = tb_anim_start;   // 变身段从头播
                        idle_anim    = tb_anim_end;     // 放开父对象循环上界，否则 15 > 14 会被立刻拽回 0
                    }
                }
            }
        }
    }

}
