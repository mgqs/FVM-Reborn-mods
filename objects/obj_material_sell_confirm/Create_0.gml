bg = spr_battle_escape_menu
width = sprite_get_width(bg)
height = sprite_get_height(bg)

// 按钮定义：[x偏移, 文字, 点击宽度, 点击高度]
buttons = [
    [-110, "最大", 70, 32],
    [0, "确定", 70, 32],
    [110, "取消", 70, 32]
]

selected_button = -1
sell_material_id = ""
sell_material_name = ""
sell_material_icon = 0
sell_material_spr = spr_craft_material
max_amount = 0
unit_price = 0
input_quantity = 1
cursor_blink = 0

// 布局参数（便于统一维护）
layout_title_y = -105        // 标题 Y 偏移
layout_icon_x = -170         // 材料图标 X 偏移
layout_icon_y = -25          // 材料图标 Y 偏移
layout_icon_scale = 0.85     // 材料图标缩放
layout_text_x = -100         // 文字起始 X 偏移
layout_name_y = -45          // 材料名称 Y 偏移
layout_amount_y = -15        // 持有数量 Y 偏移
layout_price_y = 15          // 单价 Y 偏移
layout_qty_label_y = 25      // "出售数量"标签 Y 偏移
layout_input_y = 52          // 输入框 Y 偏移
layout_input_w = 160         // 输入框宽度
layout_input_h = 36          // 输入框高度
layout_total_y = 90          // 总计金额 Y 偏移
layout_btn_y = 120           // 按钮 Y 偏移

x = room_width / 2
y = room_height / 2

keyboard_string = "1"
keyboard_lastchar = ""

// ── 凭证买卖（2026-10-27 新增；这几个字段留默认值 = 原来的「出售材料」行为，别处调用不受影响）──
//   同一个窗三用：① 道具页卖材料（默认）② 凭证回收 ③ 凭证购买（威望商店 / 诸神商店）
mode = "sell"                 // "sell" 卖/回收；"buy" 买
trade_credit_id = ""          // 非空 = 交易的是转职凭证 → 图标改画「底板 + 卡面」
pay_kind = "gold"             // 付款/收款货币："gold" 金币 / "prestige" 威望 / "oracle" 神谕之石
unit_suffix = "G"             // 单价 / 总计后面的单位（"G" / "威望" / "神石"）
held_amount = -1              // 「持有：」显示的数量（-1 = 直接用 max_amount）
input_lock = 2                // 开窗头 2 帧锁输入：防止「按下」开窗、「松开」正好落在确定按钮上（误买）

// 标题 / 「持有」/ 数量标签 / 单价单位 这些文案在 scripts/transfer_credit 的 credit_trade_ui_words()
//   （凭证域的东西别在对象里再写一份）

/// @func trade_close() 关窗：复位来源界面的「子菜单开着」并刷新它的列表
function trade_close(){
    if (instance_exists(obj_package_bg)){
        obj_package_bg.is_submenu_opened = false;
    }
    if (instance_exists(obj_shop_bg)){
        obj_shop_bg.is_submenu_opened = false;
        with (obj_shop_bg) shop_list_recharge();
    }
    if (instance_exists(obj_gods_store_bg)){
        obj_gods_store_bg.is_submenu_opened = false;
        with (obj_gods_store_bg) gods_shop_list_recharge();
    }
}

/// @func trade_confirm() 「确定」：购买凭证 / 回收凭证 / 出售材料（Step_0 调）
///   三种落账都在 scripts/transfer_credit：credit_trade_buy / transfer_credit_recycle
///   「出售材料」是道具页的老路子，仍在本对象里直接落账
function trade_confirm(){
    if (input_quantity <= 0 || input_quantity > max_amount || max_amount <= 0) return;

    if (mode == "buy"){
        credit_trade_buy(trade_credit_id, unit_price, pay_kind, input_quantity);
        trade_close();
        instance_destroy();
        return;
    }

    if (trade_credit_id != ""){
        var _rec = transfer_credit_recycle(trade_credit_id, input_quantity);
        if (_rec.ok){
            show_notice("回收 " + string(_rec.amount) + " 个凭证，获得 " + string(_rec.gain) + " 威望", 80);
            save_file(global.save_slot);
        }
        trade_close();
        instance_destroy();
        return;
    }

    // 出售材料（原行为）
    global.save_data.player.gold += input_quantity * unit_price;
    add_material_amount(sell_material_id, -input_quantity);
    trade_close();
    instance_destroy();
}
