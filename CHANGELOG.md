# v2.7.0
## 新内容
- 接入跨服新章节「水火之间 / 巫毒研究所」（2026-11-14）：
  - 关卡 JSON 16 个：`datafiles/level_data/cross/shuihuo_0..7.json`、`wudu_0..7.json`
    （生成器 `tools/shuihuo_wudu_levels.py`）。口径照既有跨服：2 波 × 10 subwave × 5 敌、
    火苗 3000、hp_modify=1、rewards 走徽章档位。地图：水火 _0（上下石板+中段 3 行水域）
    给 0~3 关、_1（上下水域+中段石板）给 4~7 关，熔岩区照 zhuore 用 `object:["lava"]`；
    巫毒全陆地。波次小怪池每关独立配表、总敌数逐关爬升（详见「优化与修复」的水路重排条目）。
  - BOSS 按用户波次表逐关落位（每波 boss+boss2 双 BOSS），`boss_1/2_hp_modify`
    按 register_boss 基础血量反算，已抽查反算=目标血量。变异钢铁侠/变异绿巨人直接用
    `kf_sh_iron_man` / `kf_wd_hulk`，其余复用既有跨服 BOSS id（灼热/梦魇同款）。
  - `mod_maps_init` 新增 `cross_server_water_fire` / `cross_server_voodoo_lab` 两个
    register_map（页签 id 沿用 Create_0 预留位，注册后页签自动点亮）；星级门槛
    `cross_server_star_gate` 按序号通用（8+index）。
  - `cross_server_level_index` 前缀表加 `shuihuo_` / `wudu_`；奖励档位未给表，
    暂落古堡同档兜底（`cross_server_reward` 注释已标注）。
  - `obj_cross_server_bg/Draw_0` 关卡图标：水火按关序选 `spr_shuihuozhijian_0/_1`，
    巫毒用 `spr_wuduyanjiusuo_0..7` 第 k 帧，等比缩放到图标框。
  - 情报岛补注册 9 条（`mod_info_island_init`）：`kf_sh_rowboat` / `kf_sh_dragon_boat` /
    `kf_sh_flagship` / `kf_sh_kof_submarine` / `kf_wd_garbage` / `special_armour_mouse` /
    `soar_mouse` / `kf_sh_iron_man` / `kf_wd_hulk`；拼音检索走全量表无需登记。
- 新增跨服「水火之间 / 巫毒研究所」章节 BOSS 2 只（行为代码照抄本体同名 BOSS，素材为桌面新版画，SWF FrameLabel 分段对齐）：
  变异钢铁侠 `kf_sh_iron_man`（hp 90000，照抄 `obj_iron_man_mouse`）：技能1 摧毁 2 列不变；
  技能2 激光升级为十字范围摧毁（激光体克隆 `obj_kf_sh_iron_man_laser`，命中点 + 上下左右 1 格）；
  技能3 从第一个技能起就可能发射（技能池首轮 [0,1,2]），每次发射 4 枚导弹（发射间隔 25→20 帧，克隆导弹 `obj_kf_sh_iron_man_bullet`）。
  变异绿巨人 `kf_wd_hulk`（hp 120000，照抄 `obj_hulk_mouse`）：技能全部无法被削弱
  （蓄力期不再统计伤害、不弹「削弱」提示、不画伤害进度文字，`skill_dropped` 恒 false）；
  每次使用技能前蓄力时间 480→240→0 帧（8 秒→4 秒→无蓄力，撤退后立即接下一技能）。
  精灵 30 个（钢铁侠 15 身体 + 4 特效，帧数与原版逐段一致：idle32/drop30/launch20/move16/skill_1 12+40/skill_2 94+20+368+60/skill_3 46+10+18/death 14×2；
  绿巨人 9 身体 + 2 特效：appear160/idle18/skill_1 16+14/skill_2 46/skill_3 98/move_fast24/move_slow30/death37），
  同组身体精灵统一锚点（原版同组共用 origin），纹理组 enemy_volcanic。
  注册脚本 `scripts/shuihuo_boss_init` / `wudu_boss_init`（挂在 `mod_boss_init`），
  构建工具 `tools/cross_new_boss_spec.py` + `cross_new_boss_build.py`（幂等可重跑）。
- 新增跨服「水火之间 / 巫毒研究所」章节小怪 5 只（行为代码照抄本体同名鼠，素材为桌面新版画，SWF 分段对齐）：
  划艇僵尸鼠 `kf_sh_rowboat`（hp 2400，速度 15→0.45 / 后退 12→0.36，防爆）、
  龙舟僵尸鼠 `kf_sh_dragon_boat`（hp 5400，速度 20→0.6 / 后退 15→0.45，防爆）、
  旗舰僵尸鼠 `kf_sh_flagship`（hp 18000，速度 20→0.6 / 后退 15→0.45，防爆）、
  拳皇潜艇僵尸鼠 `kf_sh_kof_submarine`（hp 22500，速度 20→0.6，防爆，不攻击时潜水）、
  垃圾车僵尸鼠 `kf_wd_garbage`（hp 2500，速度 20→0.6，防爆，碾压卡片）。
  水潜艇僵尸鼠与古堡现有 `infected_submarine_mouse` 同名同数值，按要求不重复创建。
  精灵 10 个（划艇/龙舟/旗舰 各 main 42 帧 + appear 16 帧；拳皇潜艇 land/water 各 36 帧 + enter 16 帧；
  垃圾车 main 32 帧），origin 按原版参考帧脚底中心迁移，纹理组 enemy_volcanic。
  注册脚本 `scripts/shuihuo_enemy_init` / `wudu_enemy_init`（挂在 `mod_enemy_init`），
  构建工具 `tools/cross_new_mice_spec.py` + `cross_new_mice_build.py`（幂等可重跑）。
- 新增三张跨服新章节的关卡底图精灵（共 18 个，单帧，纹理组 maps，来源 `桌面\跨服`）：
  冰封遗迹 `spr_bingfengyiji_0..7`（冰雪 8~15 星，1114*600）、
  巫毒研究所 `spr_wuduyanjiusuo_0..7`（巫毒 8~15 星，1108*597）、
  水火之间 `spr_shuihuozhijian_0/_1`（8~11 星 / 12~15 星，1108*597，待关卡注册时分派给关卡 0..3 / 4..7）。
  注册三处齐备（精灵 .yy + yyp resources + yyp Folders 章节子文件夹），导入脚本 `tools/cross_new_maps_import.py` 可重复执行。
  关卡 JSON、`mod_maps_init` 注册与章节页签接入为后续步骤。
- 新增卡片「元素蛇 / 烈暴元素蛇 / 流星元素蛇」（直射类·直线穿透类，耗能 290）：
  向本行前方发射 1 发带不同效果的穿透子弹，四色按 黄→紫→蓝→红 循环，发射前蛇眼变成下一发的颜色。
  黄 = 5%/10%/10% 定身 1.5 秒；紫 = 30%/50%/50% 概率 300/450/450 点毒气；
  蓝 = 30%/50%/50% 概率冰冻 2 秒后减速 2 秒；红 = 30%/50%/50% 概率 2/3/3 倍暴击。
  二转改发 2 发（第二发恒红）。子弹可过障碍、不受火盆影响（冰弹不会掉减速），
  被布丁 / 烤盘这类反弹源弹回后原路返回并可再打一次已命中的老鼠。
  新对象 `obj_yuansushe` / `obj_yuansushe_bullet` / `obj_yuansushe_fx`
- 新增卡片「银河马 / 星渊银河马 / 创世银河马」（灰烬类·轰炸类，耗能 380）：
  有目标才攻击，召唤陨石砸向本行，海陆空全覆盖；本行索敌目标吃全额 [攻击力]，
  其余吃 50% 溅射，伤害无视护盾、击杀留灰烬；无法攻击非主流与未显形幽灵鼠。
  一转攻击力 +25% 并眩晕 2 秒（防爆鼠同样生效）；二转一次 3 颗、索敌扩到 5 行、溅射扩到 3*5。
  新对象 `obj_galaxy_horse` / `obj_galaxy_horse_bullet`
- 新增金卡「星轨神·阿斯特」家族（增幅类·固定轨迹增幅，耗能 345）：
  常驻为 5*5 范围内固定轨迹类卡片增伤，与音盒马 / 浮生茶同乘区取最高、不叠加；
  三转起无需格子（悬浮卡），四转起每多 1 张四转以上星轨神倍率 +0.7（上限 +2.1），
  终转时场上满 4 张即变为全屏增幅并换用终转倍率表（1.7~9 / 3.2~10.5）。
  解锁路径：金卡进化（忘忧浮生茶 + 玲珑音盒马 + 进化凭证）。新对象 `obj_xinggui_god` / `obj_xinggui_god_effect`
- 三张卡的素材精灵共 44 个（形态 / 子弹 / 光环 / 四色分身 / 状态特效）全部按 GMS 导出格式入库，
  yyp 与 folders 三处注册齐备

## 优化与修复
- 优化 Mod 开关与删除：开启只分步检查配置、素材版本和冲突，不重复扫描 PNG；关闭仅在后台保存开关。
  删除先移出安装目录，再后台清理文件；操作结束直接更新列表，保留失败回滚和卡片进度，仍需重启游戏生效。
- 优化大体积 Mod 导入：后台解压并显示阶段、进度和耗时，支持取消；动画校验分步执行，
  复用解压时缓存的 PNG 头部，避免再次逐个打开图片。校验完成后整体安装，失败或取消在后台清理，保留原包格式和重启生效规则。
- 跨服所有关卡不再享受难度等级奖励倍率（2026-11-14 用户口径）：新增唯一出口
  `cross_server_reward_mult()`（`scripts/cross_server_level_index`），只保留海克斯的「关卡奖励倍率」
  （达摩克里斯之剑 ×10 / 搏一搏），非海克斯模式恒 1.0；`obj_battle_pause_manager/Step_2.gml` 的
  4 处跨服结算分支（抽卡礼盒路径首通/重复 + 普通路径首通/重复，共 12 行）由 `reward_multiplier`
  改乘该函数。档位表 `cross_server_reward()` 里的银徽章 / 金徽章 / 金币现在就是实发数，
  不再随 美味1 / 火山1 / 浮空2 / 星际3 / 永恒4 / 不朽7 放大。准备室与结算面板原本显示的就是档位原值，
  改动后「显示 = 实发」，无需再改 UI。
- 跨服「水火之间 / 巫毒研究所」16 关按水路红线重排编队（`tools/shuihuo_wudu_levels.py` 重写，
  2026-11-14）：口径全部照本体既有跨服章节实测（`cross/castle-0..7.json`）——
  ① 总敌数由「每关固定 100」改为逐关爬升 100/120/140/160/180/200/220/250；
  ② 敌种池由「逐关累加至 31 种」改为**每关独立配表**（3~16 种），基础三鼠占 64~85%，新鼠只作少量点缀；
  ③ **水路限制**：`feature == "water"` 的鼠只能落在水行（引擎按 `obj_battle/Create_0.gml:317-386` 强制分派），
  故水鼠仅出现在水火章节、占比固定 15%（原版古堡 12~19%），并按「鸭→纸船→热带鱼→青蛙王子→突袭→蝴蝶→
  潜水→划艇→龙舟→拳皇潜艇→旗舰」逐关解锁；巫毒全陆地 → 水鼠 0 只，生成时断言；
  ④ 全部敌人 `row` 保持 -1，交给引擎按 feature 选行。生成器自带自检（总敌数 / 水鼠占比 / 清单外敌种 / 写死行号）。
  附带纠正：`assault_mouse`（突袭鼠）与 `butterfly_mouse`（蝴蝶鼠）的 `feature` 是 `"water"`，
  不可按名字当陆上鼠投放。
- 修复修理工鼠放梯子时崩溃 `Variable obj_player_character.have_loder not set before reading it`
  （`obj_repairman_mouse/Step_0.gml:39`，2026-11-14 报错日志）：
  同格扫描 `global.grid_plants` 时直接读 `_p.have_loder`，而格子里可能坐着 `obj_player_character`
  —— 它是 `obj_card_parent` 的子对象但 `Create_0` 没有 `event_inherited()`（见 `Other_12.gml:4`
  注释），父 `Create` 里的 `have_loder = false` 在它身上从未执行 → 读字段即崩。
  两处一起改：① `obj_repairman_mouse/Step_0.gml` 与 `obj_undersea_repairman_mouse/Step_0.gml`
  的判定改为 `variable_instance_exists(_p, "have_loder") && _p.have_loder`（与
  `obj_enemy_parent/Step_0.gml:132/154` 的上梯判定同一口径）；② 给
  `obj_player_character/Create_0.gml` 补 `have_loder = false` 默认值（不引入
  `event_inherited()`：父 `Create` 会把 hp/grid/state 等一整套重置，人物用自己的一版数值）。
  顺带给 `obj_repairman_mouse/Step_0.gml:46` 补 `instance_exists(target_plant)`，与水下版本对齐，
  避免拿 `noone.plant_id` 取下标。
- 修正元素蛇子弹口径为「可穿过障碍物，但不穿透老鼠」（2026-11-14 用户口径「元素蛇子弹应该是
  非穿透老鼠的效果」）：`obj_yuansushe_bullet` 命中非障碍目标时置 `ys_stop = true` 并在循环内
  `break`，循环结束后 `instance_destroy()` 自毁；命中障碍物（`target_type == "obstacle"`）继续飞。
  `break` 特意放在死亡结算之后 —— 先 break 会让 `ash_death / image_alpha = 0` 整段跳过，
  老鼠会以 `hp <= 0` 但未死的状态赖在场上。
  保留 2026-11-14 上午那两处真修复：遍历源仍是 `with (obj_enemy_parent)`（不再用残缺的
  `global.enemy_by_type`）、击杀仍走 `ash_death`（不 `instance_destroy(敌人)`）。
  同步改文案：「穿透子弹」→「可穿过障碍物但不穿透老鼠」（`mod_cards_init` 三形态描述、
  `mod_slots_init` 三条卡槽描述、`mod_info_island_init` 情报岛长文本）。
- 修复大体积敌人受击闪光「闪一下变残血」：`obj_enemy_parent/Draw_0.gml` 的受击高亮原来用
  `hit_effect_2` 把整只鼠的 rgb 换成纯色剪影、再以 `flash_value/200`（最高 0.75）按 `bm_normal`
  叠在自己身上 —— 等于用一块不透明白色形状**替换**原画。普通小鼠体积小看不出来，但变异特种鼠
  `spr_kuafu_armour`（283×198 × `image_yscale` 1.8 ≈ 屏幕高 356 像素）在连续命中时
  会被刷成一整块泛白半透明幽灵，观感就是「满血走着走着突然闪成残血/脱甲」（用户 2026-11-14 报）。
  改法三处：① 白量改成 `gpu_set_blendmode(bm_add)` 加法叠加，只提亮不覆盖原画的明暗与色相；
  ② 按屏幕体积衰减（`clamp(160/屏幕高, 0.3, 1)`）并跟随 `image_alpha`，大怪少吃一点白、死亡淡出不留白影；
  ③ `obj_enemy_parent/Other_10.gml` 的 `flash_value = 150` 从事件首行移到扣血结算之后，
  只在 `_hp_real_lost > 0` 时按伤害量点亮（60~150，`max` 保留未褪尽的余量），
  不再让被无敌/护盾完全挡掉的假命中把白度重置回顶。
- 修复终转炎帝中路子弹「倒着飞」：`obj_shennong_god` 出弹时三发朱雀分别是上路左→右、
  中路右→左、下路左→右，但三发都只写了 `image_xscale = 1.5`、没写朝向 ——
  `spr_shennong_god_bullet_3` 的原点在鸟头（242,50），中路那发由右向左飞时整只鸟是屁股朝前的
  （用户 2026-11-14 报「终转炎帝中间行子弹朝向不对，倒着飞的应当反转180度」）。
  改法：出弹时按 `_from_right[_i2]` 写 `image_angle = 180 : 0`。
  这里**必须用 `image_angle` 而不是 `image_xscale = -1`**：① `obj_bullet_parent/BeginStep_0`
  每帧把 `image_xscale` 夹回 1（只把值留进 `visual_scale_*` 供绘制），写负数会在下一帧被吃掉；
  ② `precise_bbox_collision` 会按 `image_angle` 旋转判定框，但**不读缩放与翻转** ——
  用角度转向，贴图和判定框才一起转头。
  同时给 `obj_shennong_god_bullet_h/Create_0.gml` 补 `image_angle = 0; image_alpha = 1;
  image_blend = c_white;`：该子弹走对象池（`obj_pool_acquire` 走 `instance_change(obj, true)`
  会重跑 Create，但不替我们清上一个宿主的角度），不归零的话被回收复用时会带着 180° 出生。
  `objects/obj_shennong_god/Other_11.gml:122-131`、`objects/obj_shennong_god_bullet_h/Create_0.gml:13-22`。
- 修复星轨神 5*5 范围特效「和贴图一样静止」：`obj_xinggui_god` 创建光环时写的是 `xg_hold_frame = 10`，
  播到第 10 帧就把 `image_speed` 置 0 永久定格 —— 这是 2026-11-13 为治「循环播到淡出帧导致一闪一闪」
  下的猛药，代价是范围框彻底没有动画（用户 2026-11-14 报）。光环四套精灵的结构都是
  0~2 淡入 / 3~13 常亮 / 14~16 淡出 / 末帧全透明，且**第 13 帧与第 3 帧像素完全相同**
  （四套精灵均验过 MD5：shape0 `AD8E7C54` / shape1 `EB846758` / shape2 `9729E34A` / shape3 `A0815735`），
  所以改成**只在常亮段内循环**：`obj_xinggui_god_effect` 新增 `xg_loop_start` / `xg_loop_end`
  参数（Step 里 `[start, end)` 右开区间回卷，`xg_hold_frame` 保留给真·一次性脉冲），
  光环实例写 `image_index = 3; xg_loop_start = 3; xg_loop_end = 13;`。
  既不会闪（永远播不到淡出与全透明帧），又恢复常亮段内部的呼吸 / 旋转动画。
  `objects/obj_xinggui_god/Create_0.gml`、`objects/obj_xinggui_god_effect/Create_0.gml`、`Step_0.gml`。
- 修复银河马陨石不秒杀、且能打到非主流鼠（2026-11-14 用户口径「银河马应秒杀不防爆，应无法攻击非主流」）：
  ① 伤害口径：原来陨石一律照 `gh_damage` 结算，非防爆鼠吃不满一击必杀。现按官方 A116
  「均秒杀不防爆」改为——非防爆且非 BOSS 的目标按 `max(伤害, 当前血量)` 结算，一击必杀；
  防爆鼠（`immune_to_ash`）与 BOSS 只吃原本那笔数值伤害。BOSS 判定用双通道：
  实例字段 `is_boss`，再拿 `mouse_id` 查 `global.boss_list` 兜底（抄 `obj_hufa_god_bullet/Step_0.gml:93-100`）。
  `objects/obj_galaxy_horse_bullet/Step_0.gml`。
  ② 非主流鼠：`gh_hittable` 白名单原本排除 `dance`，但非主流三兄弟（`obj_non_mainstream_mouse` /
  `obj_ly_gaoqiao` / `obj_kf_zr_nonmain`）**啃食时会把 `target_type` 从 `"dance"` 改回 `"normal"`
  （各自 `Step_0.gml:3-8`）**，那一瞬间排除就失效，卡片照常索敌并命中。现新增全局判定
  `is_non_mainstream(_inst)`（`scripts/can_target_on/can_target_on.gml`，按 `object_index` 三只 +
  `mouse_id` 兜换皮/派生），在**索敌（`gh_has_target`）、候选收集（`Other_11`）、落地结算
  （`Step_0`）、单实例入口 `gh_can_hit`）四处统一调用**，三处口径一致。
- 修复银河马吃不到宴飨女神（塔利亚）增伤：它在增幅表 `global.plant_buff_map` 里**没有任何条目**。
  数值表 115 行脚注写的是「受精灵龙&宴飨女神增幅」，但 `card_category_data()` 把它归在
  「灰烬类·轰炸类」，而 `mod_apply_category_buff_map()` 只给投掷/追踪/多向/喷壶四个组写条目，
  银河马既不在追踪类名单里、也没被任何一处显式挂名 → `mod_get_buff_type("galaxy_horse")`
  返回 `"normal"` → `obj_mod_battle_manager` 的 switch 落到 `default`，倍率恒为 1。
  改法（2026-11-14 用户口径「不用新建 type，归到追踪类」）：在 `mod_apply_category_buff_map()`
  末尾直接 `ds_map_set(global.plant_buff_map, "galaxy_horse", "tracker")`，吃追踪类这一格
  （`tracker` + `tracker_advanced` 与莓果点心 / 香料虎 / 塔利亚同格，是用户明确要的口径）。
  不新增 type、不改 `build_buff_grid()` 的 `types` 数组、不改 `obj_mod_battle_manager` 的 switch。
  生效链：`tracker` 这一格由 `build_buff_grid()` 在 `obj_mod_battle_manager/Create_0.gml:15` 建好，
  `plant_buff_map` 在建格前已由 `mod_apply_category_buff_map()` 填好，无需新建键或加重置逻辑。
- 修复银河马陨石「索敌存在问题」：陨石会砸在本行空地、锁定的老鼠打不掉。
  三个原因：① `obj_galaxy_horse/Other_11.gml` 的候选只收**卡片本行**的敌人，可
  `gh_has_target()` 是按 `gh_search_rows`（±1 / ±2 行）判开火的 → 场上只有邻行老鼠时卡照样开火、
  候选却是空的（对照截图：卡片 col2、老鼠在 col8 的相邻行，陨石却落在 col4 / col5 空地）；
  ② 候选为空时用 `grid_col + 2 + _k` 兜底落点 → 直接砸在卡片右前方 2/3/4 格空地上，
  既没有全额目标，离真正的老鼠也远得连溅射都够不着；
  ③ `obj_galaxy_horse_bullet/Step_0.gml` 落地时**无条件**按「本行最近」重算全额目标，
  锁到邻行时全额伤害糊给本行一只无辜老鼠，真目标只吃 50%。
  改法：候选口径与开火条件统一（目标行 = 出弹时锁定的那只所在行，列取它的 `grid_col`），
  排序键 = 行距 → 列距，第 k 颗陨石锁第 k 个候选；击杀目标改走 `ash_death = true; image_alpha = 0;`
  而非 `instance_destroy()`（原来绕过 `obj_enemy_parent/Step_0.gml:427` 的海克斯击杀结算，MISTAKES B18）。
- 修复元素蛇子弹「提前一格受击」：命中判据删掉 `|| 横向包围盒重叠`，只保留「同行 + 同列」。
  实测原因：敌人自己 `image_xscale/yscale = 1.8`（`obj_enemy_parent/Create_0.gml:2-3`），
  `spr_normal_mouse` 的声明 bbox 3..101 是**全帧并集**（含 32~36 帧倒地动作向外伸的像素），
  相对原点 [-51,+47] → 1.8 倍下宽 176px = **1.65 格**；敌人出生点又是格心 +30
  （`obj_battle/Create_0.gml:413`），左沿落在 x-91.8，正好探进**上一格最后 8px**。
  子弹尖端比中心领先 37.7px（60px 宽 ×1.3 ÷2），两者一叠 → 子弹中心还在上一格时就置了命中，
  也就是 col3 的子弹打到 col4 的老鼠。改后被命中时机 = 子弹中心进入目标所在格，
  此时尖端已扎进身体约 38px，视觉与判定一致；同屏多鼠按各自 `grid_col` 分列判，不串格。
  这一改也彻底不再读精灵尺寸 / 原点 / 帧数，宽体鼠瘦体鼠一视同仁。
- 修复「只穿神装时装、没带对应宝石也在播变身立绘」：`attire_transformation.gml` 的 `player_has_gem()`
  原来只扫三个武器槽的 `gems` 数组，不看槽位是否真空着武器。而 `remove_weapon()` 卸武器时
  刻意保留 `gems` 数组（为了装回同一把武器时宝石原样还在），于是「卸掉武器 / 换成别的武器」
  之后旧宝石ID仍躺在数组里，判定照样返回 true —— 9 组神装变装全部会误触发（星之耀只是最容易撞上的那套）。
  现在加两条前置：① 该槽 `id` 必须非空字符串；② 必须 `gem_fits_weapon(宝石, 该槽武器, 该槽名)` 通过
  （同槽位 + `allowed_weapons` 命中），与换武器时 `weapon_gems_reconcile` 用的是同一个判据。
  `player_has_weapon()` 不动：星之神杖本体入场特效按原口径只看武器、与宝石/套装无关。
- 神装横版变装立绘（前 5 组：魔影圣衣男 / 魔影迅疾男 / 魔影迅疾女 / 天神之影男 / 天神之影女）放大 2 倍并居中：
  原来 `attire_fx_play()` 只给 sprite，`obj_12yinliao_effect` 走 `draw_self()` 按精灵原点 1:1 画在 (0,0)，
  而横幅画布 1332 宽、可见内容只有中间 1021 宽且**贴底**（垂直方向不以画布中心对称）→ 观感偏小、垂直也不同心。
  现在 `obj_12yinliao_effect` 新增 `center_screen` 绘制分支：按 `center_src_*` 内容框用
  `draw_sprite_part_ext` 等比放大 `scale_multiplier` 倍（= `attire_fx_banner_scale()` 返回 2），
  中心对齐 `room_width/2, room_height/2`（战斗房 1920×1080，view 固定全屏，不用相机坐标）。
  9 组配置表 `attire_fx_table()` 的 5 行 banner 填实测内容框 `[155, top, 1021, h]`：
  圣衣男 59/266、迅疾男 6/262、迅疾女 15/359、之影男 0/239、之影女 0/241。
  放大后宽 2042，左右各溢出 61px，只裁到纯色渐变边、不裁角色。
  星之焕 / 星之耀那 4 组（`left_half` 铺左半屏）不受影响。
- 元素蛇命中遍历由 `global.enemy_by_type` 分桶表改为 `with (obj_enemy_parent)` 全量扫描，
  每只现场 `can_hit(target_type, 敌人 target_type)` 过滤。实测：`obj_enemy_parent` 的 296 个直接子对象里
  有 102 个重写 `Step_0` 却没写 `event_inherited()`，其中 `obj_beverage_skill_1_bullet` /
  `obj_beverage_skill_3_bullet` / `obj_ly_mengpo_mushroom` / `obj_travel_record_moon` 四个
  **既不继承也不自己注册** —— 它们永远不在表里，按表遍历的子弹从它们身上飞过去毫无反应。
  改为全量扫描后，命中不再依赖「每个敌人对象是否老老实实注册过自己」这套隐式约定，
  也与精灵尺寸 / `image_xscale` 缩放 / 精灵原点位置彻底解耦。
  进 `with` 前用 `variable_instance_exists` 兜 `hp` / `grid_col` / `grid_row` / `target_type` 四项
  （GML 读未定义实例变量是硬崩，不是静默 false；上述 `obj_*_bullet` 就缺 `target_type`）。
- 元素蛇命中后清掉目标的 `frozen_timer` / `ice_timer` / `stun_timer` / `scare_timer` 再置 `ash_death`：
  `obj_enemy_parent/Step_0.gml:106` 是 `if (is_frozen || is_scare || is_stun) exit;`，
  挂着冰冻/定身被打死的老鼠走不到 `:427` 的死亡分支，会顶着 0 透明度在场上多站 2 秒，
  看起来像「打死了没死 / 子弹穿过没效果」。
- 元素蛇暴击只归红弹：之前不分颜色一律 `random < ys_crit_chance`，黄紫蓝也常数暴击，
  反而把「红色才是暴击弹」的辨识度冲掉了（情报岛原文：红 = 30% 概率 2/3 倍）。
- 修复元素蛇穿透后「打死的老鼠不结算」：命中致死时不再 `instance_destroy()` 敌人，改为
  `ash_death = true` + `image_alpha = 0`，交给 `obj_enemy_parent/Step_0.gml` 的死亡分支
  （`hex_batch2_on_enemy_death` / `hex_on_kill` / `hex_try_drop`）走完再注销销毁。
- 修复元素蛇判定盒退化成原生 60×28：`obj_bullet_parent/BeginStep_0.gml` 每帧把
  `image_xscale/yscale` 夹回 1（只把原值拷进 `visual_scale_*`），所以只在 `Create` 里设 1.3 无效。
  现在 `obj_yuansushe_bullet/Step_0.gml` 每帧跟随飞行方向重设 `image_xscale = ±1.3` / `image_yscale = 1.3`，
  视觉与 bbox 都是 1.3，边缘命中不再漏判。
- 元素蛇穿透白名单改为直接调 `get_hittable_enemy_types("pierce")`，不再手抄一份
  `["normal","dance","obstacle","invisible"]`，避免 `can_target_on` 改口径后两边不同步。
- 修复星轨神常驻光环盖住手牌：光环深度由 `-2500` 改为 `0`，与海洋女神 / 丰饶神 / 时间神的光环同层，
  落在手牌卡槽（`depth = -slot_index - 1000`）与卡片本体（`-10 ~ -330`）之下
- 桌面纹理预加载持续跟进显存就绪状态，避免首次使用时在精灵绘制中临时加载纹理页。
- 测试关 F2 / F4 临时召唤敌人时补充资源预热；尚未就绪的精灵暂缓绘制，切换场景时清除过期加载请求。
- 修复后羿神地火精灵帧表缺少分隔符导致桌面构建失败的问题。
- 元素蛇子弹的命中 / 伤害字段改用子弹体系约定名（`row` / `damage` / `move_speed` / `hitted`），
  从而直接复用 `bullet_hazard_rebound` 的反弹与「回程清空命中表」，不再另写一套
- 元素蛇子弹命中口径**两次修订，以最后一次为准**：2026-11-13 曾改成「不穿透老鼠、可穿透障碍物」
  （命中非障碍目标即置 `ys_stop`、双层 `break`、当帧自毁）；2026-11-14 按用户反馈
  「只是穿透障碍，并不穿透攻击」**退回初版的全行真穿透**：`ys_stop` 整条链路删除，
  命中老鼠与障碍物都不停、整行一路打到底，每只只吃一次（`hitted` 去重），
  被布丁 / 烤盘弹回时 `bullet_hazard_rebound` 清空 `hitted`、回程能再打一遍。
- 修复元素蛇「四色子弹效果有时候不生效」（三处原因，都是静默的）：
  ① **附加效果原来包在 `if (hp > 0)` 里**：元素蛇攻击力 120~2700，命中基本都是秒杀，老鼠一死
     `hp <= 0` 就直接跳过效果与特效，等于绝大多数命中都看不到定身 / 毒气 / 冰冻 / 暴击闪。
     改为命中即判定（已死目标写状态无害；毒气照放，它会在原地毒到周围其它老鼠）。
  ② **判定盒比画出来的小 30%**：`bbox` 只看 `image_xscale`，而绘制走 `visual_scale_*`（1.3），
     原来 `image_xscale = 1` → 边缘命中被静默漏掉。现在 `image_xscale/yscale` 也设 1.3，
     画多大判定就多大（绘制仍取 `visual_scale_*`，不会双倍放大）。
  ③ **特效只闪一瞬间**：`obj_yuansushe_fx` 原来用 `image_speed = 1`，而素材帧数差距极大
     （暴击闪 5 帧 / 冰晶 6 帧 / 眩晕 20 帧）→ 短特效只有 0.08~0.1 秒，肉眼看不到。
     改为 `image_speed = 0` + 每帧停留 `fx_frame_ticks`（暴击 3 / 冰晶 4 / 眩晕 6），
     按帧数自动算寿命，每种特效都能看清。
  ④ 毒气的命中类型由 `"normal"` 改成 `"pierce"`：原来 `can_target_on("normal", "dance"/"invisible")`
     为 false，非主流鼠与未显形幽灵吃不到毒。
- 星轨神共用 `obj_mod_battle_manager` 的 `track_buff_mult` 乘区：
  `max(音盒马, 浮生茶, 星轨神)`，新增加成只在这一处取最高，卡片对象里不再重复相乘
- `can_place_at_position` 增加星轨神「同格只能有一张」的规则（与海洋女神 / 战旗马同一段判定）
- 修复「焚天炎凰马」二转攻击力没提升：`mod_cards_init` 里白炽炎凰马（一转）误填了二转的攻击力表，
  导致一转 / 二转两档数值一模一样（224~4200）。按情报岛口径「一转只加竖向炎凰轨迹、二转才是攻击提升」，
  一转攻击力已回落到本体值 150~2800，二转保留 224~4200（本体 ×1.5）＋击杀化灰烬。
- 修复「石榴爆爆冰」三个形态的精灵帧顺序：素材导出顺序是 `[生长 9 帧][爆炸][成熟待机]`，
  爆炸被夹在生长和成熟之间，而卡片实际应当是 **先生长 → 再成熟 → 最后爆炸**。
  旧实现还把「生长段」当待机播（待机时果实一直在长大再缩回、真正的成熟循环从没播过）。
  现已重排 `spr_shiliu_0/1/2` 为 `[生长 idx0..8][成熟 idx9..21][爆炸 idx22..]`（成熟取完整 13 帧闭环），
  帧表最后一段一定是爆炸，不会出现「最后一帧是一颗完好果实」的错位；
  `obj_shiliu_baobao_bing` 的 `idle_anim` = 21、`attack_anim` = 3/10/11 同步修正，
  并加「生长段只播一次」的锁（播到成熟段后回卷目标改为成熟段首帧，果实不会突然缩回幼苗）。
  重排脚本 `tools/fix_shiliu_sprite_order.py`（原地重写每帧 PNG，GUID / 原点 / 帧总数不变）。
- **修复精灵帧序改动不生效的根因**：GMS 精灵目录里有两套图，`sprites/<名>/layers/<帧GUID>/<图层GUID>.png`
  是图层源图，`sprites/<名>/<帧GUID>.png` 是**顶层合成图（运行时与 IDE 预览实际读的是这一张）**。
  `tools/fix_shiliu_sprite_order.py` 之前只覆盖了前者，所以游戏里播的还是旧顺序。
  现已两套同时写（单图层无偏移时内容相同），`--check` 也两边都校验。
- 石榴「有敌才生长」的判定放宽：原来用 `can_hit_ash(card_target, enemy_target)` 当索敌条件，
  而 `can_target_on("all", "diver"/"underground")` 都返回 false（那两类只对 `throw` / `track` 放行），
  导致卡片对着潜水鼠 / 钻地鼠永远停在幼苗（表现为「idle 静止、帧序像没生效」）。
  现在只判「目标类型是否属于本卡的作用对象」（陆 / 地 / 非主流 / 障碍 / 幽灵），
  能不能打（防爆 / 免疫）留给爆炸时的 `can_hit_ash` 过滤。
- 石榴爆爆冰机制补全（`obj_shiliu_baobao_bing`）：
  ① **范围内有老鼠才开始生长**：用碾压索敌范围（5*5 / 7*7 / 7*7）感知，没有目标时停在幼苗帧、
  引信也不走（原来放下就开始倒计时，空放）。开长后锁 `shiliu_armed`，老鼠中途走掉也把这一发走完。
  ② **碾压改用实体石榴籽**：爆炸后对每只目标各投一颗 `obj_shiliu_bullet`（素材 `spr_shiliu_bullet_0/1/2`，
  按形态选图），籽从空中落下、落地帧才结算 `damage_type = "ash"` 的碾压伤害；
  目标存活附冰冻 4s / 减速 20s + 冰晶迸发，目标死亡则**只播** `spr_shiliu_ash_effect` 碎冰。
  ③ 死亡不再 `instance_destroy` 硬删：改为置 `ash_death = true` + `image_alpha = 0`，
  由 `obj_enemy_parent` 走完击杀结算（`hex_on_kill` / `hex_try_drop` / 塔之诅咒）后自行销毁，
  避免直接销毁漏掉掉落与海克斯结算。
  新对象 `obj_shiliu_bullet`（籽）、`obj_shiliu_ash_fx`（碎冰），生成脚本 `tools/make_shiliu_bullet_objects.py`。
- 修复「星轨神·阿斯特」的范围框（**形态越高框越小**）：光环精灵是四角括号框（中间空），
  四角各挂一颗星芒，所以 `bbox` 比玩家眼里的「框」大一圈，而且**形态越高撑得越多**
  （shape0 多 5%、shape1 多 6%、shape2 多 28%/16%）。前两版分别按画布尺寸、按 bbox 换算，
  结果 shape2 只有 4.2 格、shape1 5.0 格、shape0 5.2 格 —— 单看四转的框就明显比 5*5 小一圈。
  现在改为按**括号视觉框**换算：把常亮帧摊成 alpha 掩码，不透明像素最多的那一行 / 那一列就是
  四条臂所在位置，臂跨度即视觉框（0 转 295x313、三转 307x324、四转以上 306x319）。
  三个形态的臂跨度本来几乎相同，按它缩放后**三者视觉大小完全一致**，且严格等于 5*5 格
  （`xg_range*2+1`，臂外沿压在格线上；星芒溢出格线属正常）。
  光环中心仍取**格心**而非卡片 x/y（卡片原点在脚底、悬浮卡还有偏移，用卡片坐标会整体错位半格）。
  量测脚本 `tools/measure_xinggui_halo.py`（换素材后重跑，把常量表更新掉）。
- 修复「星轨神·阿斯特」终转全屏特效：改为**四个角**，与海洋女神 / 战旗马 / 时间神同一套做法 ——
  用 `spr_xinggui_god_effect_3_full`（左上角单角装饰）翻转铺到另外三角，位置按
  「内容角点贴网格角点」反推（`x = 边 - bbox_left*s` / `y = 边 - bbox_top*s`），与素材留白和原点无关。
  四角整体再往外各扩半格（同时间神 `half_cell` 口径）。
  特效图层由 `-3100 / -3000` 调到 **`-2500`**：仍然盖在卡片之上，但落在 ESC 暂停菜单
  （`obj_battle_pause_manager` depth = -3000）之下，不再糊住暂停界面。
- 修复「星轨神·阿斯特」特效闪烁：
  ① 本体光环的四张精灵（`spr_xinggui_god_effect` / `_1` / `_2` / `_3`）是「淡入 → 常亮 → 淡出 → 末帧全透明」
  的一次性脉冲，循环播就是一遍遍消失再淡入。给 `obj_xinggui_god_effect` 加 `xg_hold_frame`
  （播到第 10 帧常亮段即锁定），光环放下后就一直亮着；终转全屏时也不再隐藏本体光环（与海洋女神一致）。
  ② 终转四角装饰改为**全局单套**：原来每张满足条件的星轨神都各建一套（4 张终转 = 角落叠 16 层，
  且数量抖动时整批销毁重建、`image_index` 归零）→ 改为只由 `xg_corner_owner` 一个实例创建维护，
  主人被铲掉或条件失效时才收，4 张条件满足后全屏装饰持续存在。
- 修复任务栏 / 背包的红点被按钮贴图盖住：红点原来画在 `obj_player_menu_bg` 的 Draw 里，
  而按钮实例是 bg 的 `depth-1`（在 bg 之上），所以红点整个被按钮压住看不见。
  现在红点改由 `obj_player_menu_btn` 自己「先 `draw_self()` 再画红点」，
  位置按贴图像素 + `sprite_get_xoffset/yoffset` + `image_xscale` 换算（任务 (68,26) / 背包 (70,24)），
  红点必然压在按钮贴图上面；判定仍是 `task_red_dot("task")` / `("package")`。
  红点样式同步简化为**纯红实心点**（半径 9），去掉原来外圈那圈白色描边。
- 修复「已完成的任务在情报岛重复弹『任务完成』」：
  ① `card_info_task_prune()` 原来把 `get_task_data(tid) == undefined` 也当孤儿判据，而动态任务
  `info_view_*` 的 task_pool 条目是 `card_info_task_sync` 现场注册的（`task_init` 只注册 90 条静态任务）。
  启动时 prune 跑在 sync 之前 → 池里还没有 info_view_* → **所有**卡片情报任务被删、随后按 `new` 重建，
  已完成（未领奖）的任务每局退回待办。现改为只看「卡是否还在解锁列表」，并把启动顺序改成**先补发再清理**。
  ② `card_info_task_complete` 判「完成过」的判据改成三重：`completed_tasks` 记过 / state 是 completed·claimed /
  进度已满（脏数据兜底），并在完成时**立即落盘**——原来完成不存档，看完卡片直接退游戏会丢掉状态，下次又弹一次。

# v2.6.0
## 新内容
- 新增「宝石冷却就绪提示」：需要手动点击触发的 6 颗宝石（激光 / 轰炸 / 冰冻 / 神圣 / 星光 / 猫眼）冷却读完的那一帧，
  在人物处播放一次闪光（3 格 × 3 格约 321×348，持续 3 秒，12 帧均摊到 180 帧），冷却期间不会重复触发。
  入口 `scripts/gem_cooldown_hint`，新对象 `obj_gem_cooldown_flash`，贴图 `spr_gem_cooldown_flash`
- 新增「神装变装」9 组：宝石 + 套装**同时满足**才在进场（放下人物）时播放变身立绘。
  配置表唯一事实源 `scripts/attire_transformation` 的 `attire_fx_table()`，判定 `attire_fx_find()`：
  魔影圣衣男 / 魔影迅疾男 / 魔影迅疾女 / 天神之影男 / 天神之影女 / 星之焕男 / 星之焕女 / 星之耀男 / 星之耀女
- 新增 6 套时装（普通商店时装页，各 50000G）：魔影圣衣男、魔影迅疾男、天神之影男、星之焕男、星之耀男、星之耀女
- 角色信息面板右上角新增「变装特效」按钮（复用「转职说明」按钮底图，文字改为变装特效），
  点开列出 9 组「宝石 + 套装 → 变装」的对应关系（含双方图标），改表即改弹窗
- 「变装特效」弹窗每行右侧新增「穿戴」按钮（2026-11-14）：先校验武器 / 宝石 / 套装三件是否都在手，
  缺一件只提示「缺少所需的套装或神器」不改存档；三件齐则一键把武器装到对应武器槽、镶上对应宝石、换上对应套装并保存。
  按钮三态：已穿戴（绿字）/ 可穿戴（亮蓝）/ 缺件（灰蓝，点了只弹提示）。
  武器 id 由宝石的 `allowed_weapons[0]` 反查（不写死在表里）；槽位 4 颗宝石已满时替换最后一颗并在提示里说明。
  实现：`scripts/attire_transformation` 的 `attire_fx_own_all` / `attire_fx_is_worn` / `attire_fx_wear`，几何 `attire_fx_row_rect`
## 优化与修复
- 时装改名：守护之神 → 魔影迅疾女，天神之影（版本三）→ 天神之影女，星之焕变身3 → 星之焕女
  （`attire_init` 的 name 与 `shop_init` 的 display_name/description 两处副本同步；存档 id 不变，已购玩家不掉时装）
- 修复星之神杖入场特效的判定：`spr_ruchang` 入场圈改为**只看是否装备星之神杖**，
  与携带什么宝石、穿什么套装无关（此前挂在「星之焕/星之耀 + 宝石」分支里，导致没带杖也播、换了套装带杖反而不播）
- 修正变身立绘的宝石/套装对应关系：天神之影女改用 `spr_bianshen2`（原来挂在守护之神 + 天神之刃上，图文不符）
- 修正星之焕男女立绘归属：`DefineSprite_799_...StarRadianceGirlSkillEffectMovie` 是**女版**，与工程原有 `spr_huan_bianshen2` 逐像素一致，
  故星之焕女沿用 `spr_huan_bianshen2`；星之焕男改用新建 `spr_bianshen_xingzhihuan_nan`（原误命名为 `_nv`，已按内容改名，yyp 与文件夹注册同步）
- 魔影迅疾男 / 天神之影男 两套时装改用真实美术：14 帧 128×128 角色贴图 + `head.png` 图标，逐帧与素材源一致
  （此前美术缺位，临时复用了魔影圣衣一级 / 天神之影（版本一）的帧；现为独立精灵）

# v2.5.0
## 新内容
- 新增「卡片情报任务」：每解锁一张新卡，自动生成一个任务「查看【卡名】的情报」，去情报岛点开这张卡即完成，
  奖励 5000 金币。任务看板新增第 4 页签「卡片情报」，列表按待办优先排序（待查看 → 待领奖 → 已查看），
  一次最多显示 9 行、滚轮翻页。看板 / 背包 / 任务按钮三处红点同源判定：有新任务或未看的卡亮任务栏与背包，
  只有 5000 金币待领时亮任务栏。老存档首次进入时按已解锁卡批量补发，已领奖的不会重复发（不刷金币）；
  启动时会清掉指向「已卸载 mod 卡 / 已清理孤儿卡」的残留情报任务，领奖与关面板都会立即落盘
- 新增青涩柿柿卡片
- 新增旋风牛卡片
- 新增12周年饮料卡片
- 新增蛋蛋兔卡片（目前不能吸附子弹，等修复）
- 新增黯然销魂饭卡片
- 新增烈火虎卡片
- 新增赖皮蛇卡片
- 新增双刃蛇卡片
- 新增逆转牛卡片
- 新增蛇羹煲卡片
- 新增顽皮龙卡片
- 新增爆爆鸡卡片
- 新增治愈喵卡片
- 新增浮生茶卡片（本体为松露大厅（夜）首通奖励，一转在魔塔1-2、二转在魔塔24-1解锁）
- 新增猪猪加强器卡片（本体普通商店 15wG，一转在魔塔3-2、二转在魔塔31-1解锁）
- 新增石榴爆爆冰卡片（灰烬类-瞬发类-爆炸类）：本体商城 75000G，一转凭证 11250 威望（魔塔13-1）、二转凭证 50625 威望（魔塔25-2）。
  落地引爆做 3*3 / 3*3 / 5*5 灰烬爆炸，未死亡目标附加冰冻 4 秒、减速 20 秒；
  同时对 5*5 / 7*7 / 7*7 内最近 2 / 2 / 4 个陆、地目标造成攻击力伤害碾压；死亡时播放碎冰效果
- 炎帝·神农氏新增终转形态「至尊炎帝」：左右对向召唤三只朱雀神焰贯穿全场，单只神焰伤害范围扩大到 3 行，
  攻击沿途上中下 5 行分别受击 1/2/3/2/1 次；场上炎帝超过 7 只时，攻击力最高的 1 只每 5 秒召唤竖向陨焰，
  在 7.5、8.5 列各落 1 发，轰击 7~9 列分别受击 1/2/1 次。贴边站位走边路倍率（第 1 行 5/3/1、第 2 行 3/3/2/1）
## 优化与修复
- 修正四张诸神卡的「星级/技能」成长口径（情报岛数值面板与实战同步）：潘多拉冷却随星级 50→7 秒；
  混沌神攻击间隔随星级、冷却随技能 35→7 秒，并去掉开局内置冷却（下卡即可吞噬）；
  光明神冷却固定 21 秒、攻击间隔随技能 3.5→2.8 秒；重生神冷却随星级、攻击间隔随技能 2.5→3.5 秒，
  减伤BUFF持续 15→20 秒且不再随施法者消失，复活瞬间追加同长度无敌
- 龙渊系列关卡不再发放等级奖励（原本每关直送 30 级，会跳过火山岛 22~30 整段成长；改为关卡数据 player_level = 0，与深渊/魔塔等关卡同口径）
- 背包「解锁信息」页新增技能 1~8 级各自的解锁关卡（曲奇岛 → 香料飞船）
- 背包道具悬停提示新增「最低获取方式」（香料 / 四叶草 / 强化水晶）
- 修复勇士天妇罗最后一排死亡BUG
- 修复金蛋复制后生成到地形外面BUG
- 修复丰饶增幅范围显示不跟着地形移动而变化的问题
- 修复丰饶能增幅后羿的BUG
- 修复海星不吃丰饶神增幅BUG
- 修复百变蛇复制需要底座的卡时不会销毁底卡的问题
- 修复关卡通关后延迟报错BUG
- 修复情报岛长文本冲出面板：注册时按 35 字自动折行（文案不用再手数格子）
- 修复归元马送回空中单位时的数组越界崩溃
- 修复进主菜单时黑体描边字体烘焙显存不足导致的崩溃（改为按字形数自动计算烘焙纹理尺寸）
- 鼠标输入限频（mouse_limit_hz）默认关闭：旧版默认写死 500Hz，会把比它快的移动事件吞掉再用 SendInput 绝对坐标补发，
  表现为「移动鼠标时有人跟着抢鼠标」且手部位移残差持续累积；现在默认 0（不限频），老配置里仍是旧默认 500 的会自动归零，
  自己改过的值保留。需要限频可手改 config.ini 的 mouse_limit_hz（1~1000，建议 250~500），改完即时生效
- 终转宴飨女神 / 终转丰饶神的「同类叠加」文案改为实际口径：宴飨（至尊宴飨女神）倍率最高叠到原有加成倍率的 2 倍，
  丰饶（至尊丰饶神）倍率最高叠到原有加成倍率的 3 倍；丰饶终转的叠加层数同步从 2 层提高到 3 层（buff_max_stacks 3），
  三张终转丰饶神覆盖同一格时倍率真正累加到原倍率的 3 倍
- 后羿神补齐四形态「地火」：每发子弹首次命中时，在该行命中格起往右铺地面火焰（0/1/2/3 转分别为 3/5/5/5 格），
  持续 0.5 秒，格内每只敌人整段只烧一次、单次 700 伤害（火焰真实伤害，只扣血不碰护盾），
  同时在该敌人身上挂 0.5 秒的同形态着火特效。新增地面火对象 obj_houyi_god_ground_fire 与四套 17 帧地火精灵
  spr_houyi_god_ground_fire/_1/_2/_3（铺格按实心内容框缩放撑满一格，火格贴在敌人脚下）
## 开发文档
- 契约新增 §1.6 输出语言：与用户对话一律简体中文，仅标识符/路径/命令/日志原文保持原样。
- 全仓搜索提速：`rg` 判定出「排除大目录（剪枝）+ 文本白名单」两条必须同时满足，全仓列 `.gml` 1232 ms → **162 ms**，全仓搜词 2232 ms → **181 ms**；两条命令写进 AGENTS.md §0.0、INDEX.md 与错题本 A13。
- 新增仓库根 `AGENTS.md`：工程契约（目录地图、唯一事实源表、编码与校验规则、GML 红线、工具链、存档结构、外部 Mod API、常见任务触点）
- `AGENTS.md` §0.0 开场确认（强制）：任何 agent 动手前必须完整读取本文件，并在第一条回复以「已读取 AGENTS.md（实测行数 行 / 实测字节 B，UTF-8 无 BOM）」开头；涉及数值/关卡/敌人再补一行「触点：文件」
- 新增项目技能 `.dsh/skills/fvm-project-contract/SKILL.md`：把「读契约 → 回报确认 → 按 §4 定位 → 改 → verify_gml」固化成四步流程，加载即生效
- 新增 `tools/check_contract.ps1`：一条命令打印「已读取」确认行 + 行数/字节/sha256 指纹 + 记忆档案与技能在位状态，供会话开场自证
- 新增本地知识档案 `.workbuddy/memory/topics/`：cards / enemies-bosses / levels-maps / economy-craft / info-island-hex 五份行号级调研（配套既有 gml-pitfalls / hex / fonts / infected-zhanshen）
- `AGENTS.md` 新增 §10.1「新卡先找同类（强制）」：分类唯一数据源 `card_buff_category.gml` 的 `card_category_data()`（212 张卡/三级分类）+ 19 行「大分类 → 代表卡对象 → 照抄哪几行」对照表 + 共用骨架 + 新卡自检四问
- 新增仓库根 `MISTAKES.md` 犯错日志（18 条速查表 + A 工具与环境 / B 判断与定位 / C 机制与数值 / D 契约与流程 四区约 45 条，每条含症状·错路·正确路径·证据），并接进契约：`AGENTS.md` §0.0 / §0 / 新增 §1.5「错题本」/ §12 索引，`SKILL.md` 增第五步；规则是「动手前扫、出错后当场记、不凑数」
- 新增仓库根 `INDEX.md`（34 行「主题 → 文件:行」索引 + 关卡目录分布 + 事件文件命名）与 `tools/lookup.ps1`（一条命令吐出某名字的注册/数值/对象/精灵全部触点，实测 1.4 s，替代 4~6 次 grep）；`AGENTS.md` §0.0 增「跳读协议 / 三跳定位 / 禁止递归列举 / 路径公式」，并记入 `MISTAKES.md` A11（全仓 `Get-ChildItem -Recurse` 实测 15.8~21.7 s）
- 契约瘦身（方案 B）：`AGENTS.md` 的三段明细（经济/养成线表、情报岛与海克斯细节、19 类卡对照表与共用骨架）切到 `docs/REFERENCE.md`（10.5 KB，入库、按需读），`AGENTS.md` 只留决策与指针；§0.0 由「完整读取本文件」改为「必读 §0.0 / §0 / §1 / §4 四个核心区（约 6 KB）」，其余章节与 REFERENCE 按需再读，常驻体积 40.6 KB → 33.5 KB（注入体积同比降约 17%）；`tools/check_contract.ps1` 增「细节参考」行，`SKILL.md` 与 `INDEX.md` 同步指向 `docs/REFERENCE.md`
- 工具链接入 ripgrep 15.2.0（`%LOCALAPPDATA%\fvm-tools\rg.exe` 主副本 + 写入用户 PATH；另放一份到 `%LOCALAPPDATA%\Microsoft\WindowsApps\rg.exe` 让现有 shell 立即可用）：`AGENTS.md` §0.0 的「禁止递归列举」改为「找文件一律用 rg」并给出三条命令式，§8 工具表增一行，§0「先索引后开文件」补 rg 入口；`tools/lookup.ps1` 改为一次 rg 扫已知文件清单（不再是逐行正则），`MISTAKES.md` A11 与速查表、`INDEX.md`、`SKILL.md` 同步。实测：列 `objects scripts` 下 3966 个 `.gml` **55~64 ms**（原 `Get-ChildItem -Recurse` 15 762~21 733 ms），搜一个名字 **135~309 ms**（原 `lookup.ps1` 1.4 s），全仓排除大目录搜中文 **0.96~1.5 s**
---
# v2.4.0
## 新内容
- 新增了6个火山遗迹关卡和5个勇士关卡
- 新增了食神谱系统
- 新增了迷你披萨炉和全能糖球投手卡片
## 优化与修复
- 修复了移动板块上的卡片行列判定不正确的问题
- 修复了BOSS使用催眠技能时旋转咖啡喷壶贴图不正确的问题
- 修复了加载时可以点击UI元素的问题
- 将部分贴图高清化
- 现在可以点击未解锁的魔塔关卡进行预览
- 修复了巧克力投手无法命中水中敌人的问题
- 操作优化：魔塔蛋糕可以记忆页数，选卡界面可以按鼠标右键退出，结算界面可以按鼠标左键继续
## 平衡性调整
- 炭烧海星：重新调整数值，现在9-13星的攻击力相比之前增强了10%~17%，同时能量消耗降低至175/175/225
- 钢鱼刺：生命值增加至5400，可以摧毁6次车辆
- 焦油喷壶：二转效果调整为50%攻击力加成
## 其他调整
- 现在钢铁侠鼠从第3个技能开始就有概率使用导弹技能，解体技能概率由67%降低至50%
- 增加了勇士天妇罗的掉落物奖励
---
# v2.4.1
## 新内容
- 新增了3种新武器和2张新卡片
## 优化与修复
- 修复了游戏运行时无法打开微信的问题
- 修复了二转关东煮喷锅攻击范围异常的问题
- 现在迷你披萨炉命中敌人时不再播放受击音效
- 修复了雷神横向激光技能会摧毁右侧卡片的问题
- 修复了难度描述文本异常的问题
## 平衡性调整
- 水瓶座精灵：二转效果改为减少33%冷却时间
- 可乐炸弹：二转的火焰总伤害改为炸弹本身伤害的一半，而非固定300点
- 开水壶炸弹：二转新增在原地留下一片减速区域的效果
