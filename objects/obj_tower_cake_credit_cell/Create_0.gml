/// 魔塔蛋糕 · 本层解锁的转职凭证格（2026-11-08）
/// 一格 = 商品表里一条 type=="credit" 且 tower_floor 等于本关卡的凭证商品
/// 位置/分页由 obj_tower_cake_bg.refresh_credit_grid() 统一算，本对象只管画 + 点
///
/// 复用字段（obj_shop_buy_confirm 确认后会 `with banding_buy_btn` 照着扣钱发货）：
///   btn_type = "credit" / target_item / cost / coin_type / reward_prestige
goods_id         = "";
card_id          = "";
card_shape       = 1;
label_text       = "";
credit_size      = 110;          // 卡片边长（跟 red box 的 3×3 排版一起定）
slot_index       = 0;            // 底板槽位 A/B/C（0/1/2）——商店格一律 0

btn_type         = "credit";
target_item      = "";
goods_name       = "";           // 购买确认窗上显示的名字（obj_shop_buy_confirm/Draw_0.gml:23 读它）
cost             = 0;
coin_type        = "prestige";
reward_prestige  = 0;

hovered          = false;

image_speed = 0;
