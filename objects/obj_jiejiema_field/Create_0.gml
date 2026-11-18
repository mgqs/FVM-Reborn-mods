// obj_jiejiema_field（结界本体）Create 事件
// 由 obj_jiejiema 的领队创建，一块结界对应「场上全部结界马」这一个整体。
//   格集 / 顶点 / 边 → scripts/jiejiema_field
//   伤害结算       → 本对象 Step
//   结界图形       → 本对象 Draw_0（4 张特效图）
// 图层：结界特效必须**压在卡片之下**（2026-11-18 用户口径）。
//   卡片的 depth = -10 - row*45 - col*5 - 层偏移（scripts/card_depth），永远 ≤ -10；
//   obj_battle 的地图背景在 +50。所以「-10 ~ 0」这一段正好是「地面之上、卡片之下」。
//   这里先给个安全初值（第 0 行的行基准），真正的值在 Step 里按场上最上一行的行号重算。
depth = -9;

jj_owner   = noone;      // 领队马（创建后由它回填）
jj_refresh = 0;          // 「结界重新成形」计数：命中递增计数靠它清零
jj_cells   = [];         // [{col,row}]
jj_verts   = [];
jj_edges   = [];
jj_mode    = "grid";     // grid / line / poly

jj_hit_timer = 0;        // 到 0 就结算一次
jj_cycle     = 120;      // 攻击间隔帧（取自结界马的 cycle）
jj_atk       = 0;
jj_use_mult  = false;
jj_mult      = [1];
jj_mult_tail = 1;
jj_can_hit_types = ["normal", "air", "underground"];

jj_anim = 0;             // 特效帧推进（两张 20 帧 / 一张 10 帧，统一按 20 帧循环）
jj_count = 0;            // 场上马的数量（决定画哪种形状）

image_speed = 0;
visible = true;
