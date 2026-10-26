/// obj_hex_list —— 「已有词条」面板（滚轮列表）
/// 入口：设置页按钮；对局内暂停面板「词条」页复用同一个对象

depth = -7000;

w      = 1040;
h      = 680;
px     = x - w / 2;
py     = y - h / 2;

view_x = px + 20;
view_y = py + 112;
view_w = w - 40;
view_h = h - 112 - 48;   // 底部留出"收集进度"一行，别把最后一项压在文字下面
item_h = 80;             // 名字一行 + 效果一行

// 页签几何：Draw 与 Step 共用一套，避免两处硬编码越改越偏
tab_w   = 130;
tab_gap = 12;
tab_y0  = py + 62;
tab_y1  = py + 96;
tab_x0  = px + (w - (tab_w * 2 + tab_gap)) / 2;
tab_x1  = tab_x0 + tab_w + tab_gap;

// 主菜单进来默认看「已解锁」，对局内暂停进来默认看「本局」
tab          = instance_exists(obj_battle) ? 1 : 0;
scroll_y     = 0;
scroll_target = 0;
rows         = [];
tab_hover_0  = false;
tab_hover_1  = false;
close_hover  = false;
bar_drag     = false;
bar_drag_off = 0;
view_surf    = -1;      // 列表离屏表面（视口裁剪用），首次 Draw 时创建

if (!hex_active()) {          // 测试关卡不提供词条查看
    instance_destroy();
    exit;
}

/// @function hex_list_build()
/// @desc 按当前页签重建行数据
function hex_list_build() {
    rows = [];
    if (tab == 0) {
        // 已解锁页只列真正解锁过的词条：通关一条加一条，没解锁的绝不出现
        for (var i = 0; i < array_length(global.hex_ids); i++) {
            var _id = global.hex_ids[i];
            var _d  = hex_get(_id);
            if (is_undefined(_d)) continue;
            var _times = hex_unlocked_times(_id);
            if (_times <= 0) continue;
            array_push(rows, {
                id: _id, name: _d.name, tier: _d.tier, form: _d.form,
                card_desc: _d.card_desc, enemy_desc: _d.enemy_desc,
                unlocked: true, times: _times, impl: _d.impl,
                approx: (variable_struct_exists(_d, "approx") && _d.approx)
            });
        }
    } else {
        if (variable_global_exists("hex_state") && is_struct(global.hex_state)) {
            // 先列永久生效的（来自存档「已解锁」），再列本局新抽到的
            if (variable_struct_exists(global.hex_state, "persist")) {
                for (var q = 0; q < array_length(global.hex_state.persist); q++) {
                    var _pq = global.hex_state.persist[q];
                    var _dq = hex_get(_pq.id);
                    if (is_undefined(_dq)) continue;
                    array_push(rows, {
                        id: _pq.id, name: _dq.name, tier: _dq.tier, form: _dq.form,
                        card_desc: _dq.card_desc, enemy_desc: _dq.enemy_desc,
                        unlocked: true, times: _pq.stack, persist: true, impl: _dq.impl,
                        approx: (variable_struct_exists(_dq, "approx") && _dq.approx)
                    });
                }
            }
            for (var j = 0; j < array_length(global.hex_state.picked); j++) {
                var _p = global.hex_state.picked[j];
                var _d2 = hex_get(_p.id);
                if (is_undefined(_d2)) continue;
                array_push(rows, {
                    id: _p.id, name: _d2.name, tier: _d2.tier, form: _d2.form,
                    card_desc: _d2.card_desc, enemy_desc: _d2.enemy_desc,
                    unlocked: true, times: _p.stack, impl: _d2.impl,
                    approx: (variable_struct_exists(_d2, "approx") && _d2.approx)
                });
            }
        }
    }
    scroll_y = 0;
    scroll_target = 0;
}

hex_list_build();

audio_play_sound(snd_button, 0, 0);
