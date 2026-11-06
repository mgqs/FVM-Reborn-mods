// obj_bbq（街头烤肉大师）Create 事件
// 三形态：0 街头烤肉大师 / 1 户外烤肉大师 / 2 BBQ烤肉大师
// 素材：0shape / 1shape / 2shape 各 22 帧
//       **待机 0~12，攻击 13~21**（13~16 串串顶出、17~18 最长、19~21 回落）
//       父对象按 idle_anim / attack_anim 划段：IDLE 走 0~12，ATTACK 走 13~21
// 数值取自「食神谱金卡融合卡前置补全\基本信息.xlsx」第 216~222 行（街头烤肉大师那一段）。
// 机制：沿本行向右发射穿透串串子弹；**每第 4 发**换成爆辣烤串（见 Other_11 的 _burn_every），并在该行最右 1 格留下灼烧：
//       存在 2 秒，**每 0.5 秒烫一次**（共 4 跳）→ 站满 4 跳（见 bbq_spawn_burn_cell / obj_burn_cell）。
//       2026-11-06 用户改口径：灼烧**每跳伤害**改走注册表 custom["灼烧伤害"]（17 档 = 攻击力 ×2，原来是 atk 原值）。
//       其余节奏（0.5 秒 / 4 跳 / 2 秒）不动，仍写在对象里。
//       灼烧**能烧到场外 1 格**（第 10 格 / BOSS 出生位），但火格特效仍然只铺在第 9 格（不跟着外扩）。
//       火格与**烤串本发出膛同帧**生成（2026-11-04）。
//       一转 +1 发子弹（单行 2 发）；二转同时在上下三路各发。
event_inherited();
plant_id = "bbq";
obj_type = object_index;
current_level = 1;
event_user(0);

if (shape == 0) sprite_index = spr_bbq;
else if (shape == 1) sprite_index = spr_bbq_1;
else sprite_index = spr_bbq_2;

idle_anim = 12;
attack_anim = 9;
flash_speed = 5;
plant_type = "normal";
feature_type = "normal";
is_slowdown = false;
attack_type = ATTACK_TYPE.SHOOTER;
target_type = "normal";
state = CARD_STATE.IDLE;

// 每行子弹数：**0 转 1 发 / 1 转起 2 发**（2026-11-03 用户改口径：一转强化从「伤害翻倍」改成「子弹数量+1」）。
//   实际取值在 Other_11 开头的 _per_row（shape >= 1 ? 2 : 1）；这里不再保存副本。
// 2026-11-04 用户口径：同轮两发**不再同一帧冒出**，第二发要在发射点**晚一点**出膛
//   → 第一发照旧当帧创建，后面的发先存进 bbq_pending，由 Step_0 的 bbq_pending_timer 倒计时到点再创建。
//   两发之间的间距 = 延迟帧数 × 弹速（5.35 px/帧），不再靠 x 偏移硬错开。
bbq_rows = (shape >= 2) ? 3 : 1;
bbq_shot_count = 0;
bbq_pending = [];        // 本轮还没出膛的后几发：[{row, x, y, burn, end_x, end_x_left}]
bbq_pending_timer = 0;   // 还有几帧出膛（0 = 没有待发射）

// 贴图格线与逻辑网格的原点差（36px）。串串飞行高度、灼烧火格都用它抬高，要微调只改这一个数。
bbq_art_up = 36;

// ── 灼烧区每跳伤害：走注册表 custom["灼烧伤害"]（2026-11-06 用户口径）──
//   改 mod_cards_init 里 bbq 那三个形态的 custom 就生效，不用动对象代码。
//   注册表是「攻击力 ×2」的 17 档；取不到时兜底也用 atk × 2。
var _bsk   = variable_instance_exists(id, "skill") ? skill : 0;
var _binfo = get_plant_data_with_skill("bbq", shape, clamp(current_level, 0, 16), _bsk);
burn_damage = atk * 2;
if (_binfo != undefined && ds_map_exists(_binfo, "灼烧伤害")) burn_damage = _binfo[? "灼烧伤害"];

// 灼烧**能烧到场外 1 格**（第 10 格 / BOSS 出生位），火格特效仍铺在第 9 格不动。
//   要改能烧出去几格就改这一个数（0 = 只烧第 9 格，回到老行为）。
bbq_burn_extra_col = 1;

// 灼烧区（爆辣烤串铺的火格）：**跟烤串那一发「出膛的同一帧」铺**，不再跟本轮第一发。
//   0 转烤串就是当帧那发 → Other_11 里立刻调；1 转起烤串通常是延迟出膛的第二发 → 等 Step_0 补发时再调。
//   2026-11-04 用户口径：以前是「本轮有烤串就先铺」，导致第三发（普通串）一出膛火就有了，比烤串早 14 帧。
//   参数：_row = 该行（二转三行各铺一次）。
bbq_spawn_burn_cell = function(_row)
{
    var _bc = global.grid_cols - 1;
    var _cell = get_world_position_from_grid(_bc, _row);
    // 🔴 贴图 112×141 的画布里只有中间一块是火：按画布缩放只会铺出一小块，必须按**实心火**的内容框放大。
    //   _fw/_fh/_fcx/_fcy = 20 帧并集里 alpha≥128 的实心区域（x 28~84 / y 48~114，中心 (56,81)）；
    //   之前用的 70×99 是按画布中心估的，竖向只铺到格子的 6 成，所以「没占满格子」。
    var _fw = 56, _fh = 66, _fcx = 56, _fcy = 81;
    // 火格画面本身比贴图格子略偏左下，单独补：_fire_dx 往右、_fire_dy 往上（负 = 上）
    var _fire_dx = 9, _fire_dy = -10;
    var _sx = global.grid_cell_size_x / _fw;
    var _sy = global.grid_cell_size_y / _fh;
    var _bx = (_cell.x + _fire_dx) - (_fcx - sprite_get_xoffset(spr_bbq_burn_ground)) * _sx;
    var _by = (_cell.y - bbq_art_up + _fire_dy) - (_fcy - sprite_get_yoffset(spr_bbq_burn_ground)) * _sy;
    // 图层：压在老鼠和卡片后面（跟 calculate_plant_depth 同一套行距，但取「行首之外」的值）
    var _b = instance_create_depth(_bx, _by, -10 - _row * 45, obj_burn_cell);
    _b.sprite_index = spr_bbq_burn_ground;
    // 只播「火最旺」的 3~16 段：0/1/18/19 帧几乎全透明（烧起来前 / 灭掉后），
    //   整段循环会看到火格「闪一下没了」，2026-10-31 用户反馈的问题
    _b.frame_start = 3;
    _b.frame_end = 16;
    _b.anim_loop_frames = 42;      // 14 帧 × 3 = 20fps，1 秒不到一轮，一直有火
    // 每跳伤害 = custom["灼烧伤害"]（= 攻击力 ×2），火格存在 2 秒、每 30 帧（0.5 秒）一跳 → 站满 4 跳
    _b.damage = burn_damage;
    _b.life = 120;
    _b.tick_interval = 30;
    // 灼烧能烧到场外 1 格（第 10 格 / BOSS 出生位）；火格特效仍铺在第 9 格（_bc），不跟着外扩
    //   → 只在判定上放宽，位置 / 缩放都不动（2026-11-06 用户口径）
    _b.extra_col_right = bbq_burn_extra_col;
    _b.lock_grid = true;
    _b.grid_col = _bc;
    _b.grid_row = _row;
    // 地面单位全烧：普通 / 非主流 / 幽灵 / 潜水 / 障碍；空军、钻地不烧
    _b.hittable_types = ["normal", "dance", "invisible", "diver", "obstacle"];
    // 被烧到的老鼠身上挂辣椒燃烧特效
    _b.mouse_fx_spr = spr_bbq_burn_mouse;
    // 铺满整格（按内容缩放，per-axis 保证不溢到上下行）
    _b.image_xscale = _sx;
    _b.image_yscale = _sy;
};
// 本次攻击是否已经出弹（攻击动画第 17 帧出一次，见 Step_0）
bbq_fired = false;

// 开局不要等满一个冷却
attack_timer = cycle - 30;
