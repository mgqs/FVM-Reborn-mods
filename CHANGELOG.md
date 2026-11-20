# v2.9.0
## 优化与修复
- **猫猫枪一次命中就换行（2026-11-20）**：
  - 症状：有时要打两三发才把老鼠赶去另一行。
  - 原因：换行的位移要 30 帧才走完一格，而 `obj_enemy_parent/Step_0` 每帧按 `y` 反推
    `grid_row`。这 30 帧里再挨一发会拿「还没走完的旧行」重新掷方向，来回抵消。
  - 改法：`objects/obj_catgun_bullet/Step_0.gml` 惊吓期间（`scare_timer > 0`）不再重新决定方向；
    并且只挑「同地形」的相邻行，避免把陆鼠推进水里。
- **椰子果索敌并进攻空军（2026-11-20）**：
  - `objects/obj_yeziguo/Step_0.gml` 的索敌与落地结算都补上 `target_type == "air"`。
    卡面 `target_type` 仍是 `"normal"`（类型表不动，只放宽这张卡的判定）。
- **多 BOSS 关卡打完 BOSS 不切回精英鼠军 BGM（2026-11-20）**：
  - 原因：BOSS 阵亡把 `level_stage` 写回 `"pre"`，但没有任何地方把 BOSS 曲切回去
    （`music_picked` 已为真，精英段的抽歌块整段跳过）。
  - 口径：**随机 BOSS 音乐开着 → 全程不切**（随机曲从精英段一直播到通关，BOSS 出现/死亡都不切）；
    **关着 → BOSS 出现播关卡自带 `boss_music`，BOSS 死亡还原成切之前那首**。
  - 改法：`obj_battle_music_controller` 新增 `music_restore_sound` / `music_boss_phase`；
    进 BOSS 阶段时**仅在 `!music_random_active` 分支**记下 `music_restore_sound = battle_music`
    并置 `music_boss_phase`；`obj_battle/Step_2` 在 `level_stage == "pre"` 时消费该标记，
    还原 `new_battle_music` 并重放 `event_user(10)`（自清零，只触发一次；第二只 BOSS 再置）。
- **变异中尉的熊猫改为 2~6 列随机（2026-11-20）**：
  - `obj_kuafu_boss_buzz` 每次放技能把 `panda_col_order = [1..5]` 洗牌后按次序取列，
    不再固定从第 1 列开始（第 1 列会直接触发猫猫枪）。情报岛文案同步为「第2-6列的随机行」。
- **终转炎帝子弹不再只打一行（2026-11-20）**：
  - 原因：`bullet_sap_type_list` 的纵向裁剪只对缝隙制放宽，3 行目标根本不进候选集；
    就算进了，`precise_bbox_collision` 对 ±1 行也永远判不相交。
  - 改法：`obj_shennong_god_bullet_h/Step_0` 对「3 行模式」单独放宽裁剪边距（2 格）
    并用水平区间判定替代 bbox。
- **一转/二转结界马、阴阳蛇的选卡名（2026-11-20）**：
  - `mod_cards_init` + `mod_slots_init` 两处同源改名：结界马 → 虚空结界马 / 镜反结界马，
    阴阳蛇 → 伯仲阴阳蛇 / 龙虎阴阳蛇（情报岛读的就是这张表，一并生效）。
- **阴阳蛇黑白弹重叠且间隔太大（2026-11-20）**：
  - `obj_yinyangshe/Create_0`：出膛口由 -0.74H / -0.76H（只差 2 像素，两线重叠）
    改为 -0.46H / -0.66H（按蛇头口腔红色像素重心量出来的），连发间隔 `yy_shot_gap` 6 → 4。
- **魔镜鼠吸走的火苗死后不返还（2026-11-20）**：
  - `obj_mirror_mouse/Step_0` 吸收时记 `capture_owner`；`Destroy_0` 先把仍在飞、
    归属于自己且带速度的火苗计入返还数量并销毁，再统一生成`is_capture = false` 的返还火苗。
- **换气扇不再击退跨服重量级 BOSS（2026-11-20）**：
  - `obj_ventilation_fan/Create_0` 的 `ignore_list` 追加 `kf_zrb_cap`（变异美队）、
    `kf_zrb_cap_rainbow`（美队彩虹）、`kf_zrb_cap_shield`、`kf_sh_iron_man`（变异钢铁侠），
    换气扇及其一转/二转一律不吹。
- **天神 / 亡灵套装有 3 枚宝石没有星级、其余角标过大（2026-11-20）**：
  - 没星级的原因：`obj_zeus_ren_gem` / `obj_ghost_caijue_gem` / `obj_divine_shenji_gem`
    的 `.yy` 里 Draw 事件被写成 `eventNum: 8, eventType: 0`（两个字段反了），
    事件表里没有合法的 Draw，`Draw_0.gml` 成了孤儿文件，星级整段从不执行。
  - 角标过大的原因：天神/亡灵系 `Draw_0` 用 `spr_star_slot` 时写的是 `1.5, 1.5`，
    其它宝石是 `0.75, 0.75`。全部统一为 0.75。
- **石榴爆爆冰没有索敌时静止、且看起来完全没伤害（2026-11-20）**：
  - 待机被父对象推帧后又被压回幼苗帧，观感是「静止画面」；伤害全挂在籽落地那一环，
    爆炸本身不结算，籽一异常整张卡就没伤害。
  - 改法：`obj_shiliu_baobao_bing` 的爆炸段（`Other_11`）改成爆炸当场结算伤害 + 冰冻，
    籽继续负责落地碾压；`Step_0` 的帧锁定改到成熟段首帧。
- **跨服地图预览底图太小（2026-11-20）**：
  - 原因：`obj_level_preview/Draw_0` 直接 `draw_sprite(..., 0, 0)`，而各关卡底图尺寸不一
    （梦魇天空 1109×597，城堡 2005×1080），小图就等于缩在一个角上。
  - 改法：按视口尺寸等比放大铺满并居中。
- **焦油喷壶打不到出图的潜水鼠（2026-11-20）**：
  - 潜水鼠起身/啃食时 `target_type` 从 `diver` 变回 `normal`，但仍站在画面外，
    子弹的行列判定与 bbox 都对不上。`obj_tarsprayer_bullet/Step_0` 放宽命中判定。
- **「血魔的渴血」不回血、也不加生命上限（2026-11-20）**：
  - 原因：吸血需要一个「这一下是哪张卡打的」归属。归属只在 `obj_bullet_parent/BeginStep`
    里做，而它的「出生点回查」注释写了、代码却从未实现；没有父类的技能弹/召唤弹
    只能落到「命中时补认领」，那条路径会被判为不可信而直接丢弃 —— 于是永远不回血。
  - 改法：新增 `hex_b3_src_card()` 统一回溯归属（卡片本体 → 火苗来源卡 →
    出生认领 → **出生点**半径内最近的卡，出生点用 `hex_org_x/y` 而不是命中点）；
    新增 `hex_b3_tag_pending_bullets()` 每帧给刚出生的飞行物补出生归属，
    由 `obj_mod_battle_manager` 调用；最后再加一层「同行唯一开火者」兜底，
    只有一行里仅一张卡在开火时才认，避免重演「给别人加血」。
  - 上限口径：`b3_lifesteal_cap` 是倍率，卡面写 +300% 就必须传 4.0（原来缺省 3.0 只有 +200%）。
    与「取长补短」同选时，上限涨多少攻击就跟到多少（原有逻辑已覆盖，上限生效后自动同步）。
- **「Hana 的四卦」选完人物被放到鼠标格（2026-11-20）**：
  - 原因：面板上点「选择」的那一下同时触发了人物的全局左键放置事件，而那条路径只挡了
    暂停菜单，没挡选牌面板（卡片侧一直有 `hex_place_locked()` 挡着）。
  - 改法：`obj_player_character/Mouse_53` 增加「面板在 / 放置被锁 / 全局暂停」三重早退。
- **转转档位改为 1 / 5 / 50 抽（2026-11-20）**：
  - `zz_pull_count()` 中间档 10 → 5，按钮文案同步；三档单价统一 2 万/抽
    （1 抽 2 万 / 5 抽 10 万 / 50 抽 100 万），保底仍按抽数计，节奏不变。
- **魔导士软糖只在放下时判一次地形（2026-11-20）**：
  - 原来每帧按脚下地形重选 `lingrong_god_sprite()`，地形一变就换立绘并重播变身。
    现在第一次拿到合法格子坐标的那一帧锁下 `lr_water_form`，之后只认锁定的形态。
- **抽卡 / 欧皇模式下转转的兑换能用（2026-11-20 用户报）**：
  - 症状：在「金马盛典 → 兑换商城」里点购买，弹的是**商城**的
    「抽卡模式无法购买卡片」，幸运星根本花不出去。
  - 原因：兑换页的版式是照商城**逐像素抄**的（4×4 格、按钮同在「格心 +77/+60」、
    同一个 `spr_shop_buy_btn`）。商城面板关闭时 `menu_type` 在播收缩动画前就被清零，
    于是「商城还在、转转却能打开」这一小段里，商城的 `obj_shop_buy_btn`
    与兑换页按钮判定框完全重合；GMS 的鼠标事件**先于** Step 执行，
    点击先被商城按钮吃掉 → 抽卡 / 欧皇模式正好命中它的禁售分支。
  - 改法：① `obj_shop_buy_btn/Mouse_4` 顶部加守卫：只要 `obj_zz_bg` /
    `obj_zz_shop_bg` / `obj_zz_buy_confirm` 任一存在就直接 `exit`（与玩法模式无关，
    普通模式防误触同理）；② `obj_zz_enter/Mouse_4` 补 `instance_exists(obj_shop_bg)` 早退，
    不许转转叠在商城上打开。`zz_buy_shop` 本身**不加任何模式门禁**（已在注释里写死口径）。

# v2.8.1
## 优化与修复
- **阴阳蛇过火后换成火弹贴图（2026-11-18）**：
  - 症状：被火盆点燃后伤害与倍率都对（附毒也跟着乘了倍率），但画面上仍是蛇弹原图。
  - 原因：`bullet_hazard_fire` 的「普通火源」分支只改倍率 / 尺寸 / 播个音效，
    **不换贴图**（只有「冰火弹被更高倍率再点燃」那一支才写 `sprite_index`）。
    换成火球是每颗子弹自己 Step 里做的事（bbq / 法士蛇 / 玉米子弹都是这个写法），阴阳蛇漏了。
  - 改法：`objects/obj_yinyangshe_bullet/Step_0.gml` 新增过火外观段 —— `burnt > 0` 时换
    `spr_fire_bullet`（41×14，4 帧火苗，按 `yy_life div 4` 轮播）、`image_speed = 0`、
    尺寸放到 1.8；朝向继续跟随 `move_speed` 的正负镜像。
    融盆二转的冰弹让路（`brazier_list` 带哨兵 `-9999` 时不换），否则会每帧被改回火球。
  - `Create_0`：`hazard_fire` 由 `true` 改为 `{ scale: 0 }`，尺寸完全由自己管 ——
    父类普通分支写的是**无符号**的 `image_xscale = 1.8`，被布丁弹回朝左飞的那一帧会被掰正、闪一下。
- **阴阳蛇改成「攻击动作播到第 18 帧才真的出弹」（2026-11-18）**：
  - 症状：到了 `cycle` 就先创建子弹，攻击动画随后才播 —— 看起来像「先有子弹、后有动作」，
    和美术做的「低头蓄力 → 抬头张嘴 → 甩头吐出」对不上。
  - 定出弹帧：素材攻击段（第 13~22 帧）逐帧差分 + 头部放大，16 帧低头蓄力（嘴闭合）、
    17 帧抬头张嘴起手、**18 帧甩头吐出**（相邻帧差分 2960 像素，是攻击段最大峰值；
    非透明区域右缘从 77 一下扩到 91）。所以定在素材第 18 帧 = `image_index 17`。
  - 改法：`objects/obj_yinyangshe/Step_0.gml` 新增「起手」阶段 —— 计时到点只设 `yy_charge`，
    然后盯着 `image_index`（父对象每 `flash_speed` 帧推一格），播到 17 才 `event_user(1)` 排弹；
    发弹时才把「攻击段剩余帧」补进 `yy_anim_hold`，不会出现「吐完又做一遍起手」。
    `yy_fire_delay = 90` 是兜底（减速态要 60 帧才到 17），动画被卡也不会整轮空转。
    起手期间继续攒 `attack_timer`，**整体攻击周期不变，只是出弹晚了半拍**。
  - `Other_11` 里补 `yy_charge = 0`：海克斯「疑神疑鬼」的父对象空放会直接调这个事件，
    不清标记的话起手到点会再排一轮、同一轮打两遍。
- **结界马的多边形特效不再「糊成一个方框」（2026-11-18）**：
  - 症状：3 只以上围出的结界，内部雾按**顶点包围盒** `draw_sprite_ext` 拉伸，而 `spr_jiejiema_fx_inside`
    是方形贴图、四个角也带 alpha（均值 56/255）→ 雾铺成一个方框、跑到连线外面；
    再叠上每格一块的 `spr_jiejiema_fx_grid`，整体观感是「一堆方格」而不是「一整片结界」。
  - 改法：`objects/obj_jiejiema_field/Draw_0.gml` 的多边形分支改成**凸包三角扇 + 纹理 uv 映射**
    （新函数 `jiejiema_draw_fog_fan`，在 `scripts/jiejiema_field`）：几何本身就是多边形，
    超出连线范围的部分**根本不会被画出来**，不需要 surface / stencil 也能裁干净。
    两层叠加 —— 外层铺满（uv inset 2%、alpha 0.88）、内层把贴图中央亮斑放大（inset 32%、alpha 0.32），
    总浓度与原来的 0.85 相当，但边缘不再外溢。
  - 多边形模式不再画逐格底光（`spr_jiejiema_fx_grid`），格子感随之消失；
    1 只（`grid` 两格）与 2 只（`line` 一条连线带）**保留**方块，因为那两档本来就没有围合区域。
- **地精鼠钻地时不再是「散点攻击」的目标（2026-11-18）**：
  - 症状：龙渊地精鼠钻地期间照样被雪球兔的雪球砸（雪球兔 `target_type = "all"`，`can_target_on("all","underground")` 恒真），
    而且 `obj_snowrabbit_bullet` 命中前主动把 `ly_dig_hittable` 置 true，绕过 `obj_ly_dijing/Other_10` 的钻地免疫，直接扣血；
    冰块冷萃机 / 典伊神使虽然打不掉血，但仍会为它浪费一发（典伊还会把 `ice_timer` 冻住它）。
  - 改法：新增 `scripts/can_target_on` 的 `scatter_target_blocked(inst)`（= `is_digging_dijing`），
    三张散点追踪卡在**索敌阶段**直接跳过钻地中的地精鼠，按「不攻击类型」处理：
    雪球兔 `objects/obj_snowrabbit/Step_0.gml`（索敌）/ `Other_11.gml`（选目标）/ `obj_snowrabbit_bullet/Step_0.gml`（去掉
    `ly_dig_hittable` 放行 + 2 转 3×3 溅射跳过）、冰块冷萃机 `obj_cold_drew/Step_0.gml` + `obj_cold_drew_bullet/Step_0.gml`（溅射）、
    典伊神使 `obj_ice_god/Other_11.gml`。
  - 未动旋转喷壶 / 地火 / 灰烬等原有白名单：那些**仍可**命中钻地中的地精鼠（口径见 `obj_ly_dijing/Other_10`）。
- **商店「角色皮肤」页改为按注册顺序稳定排序（2026-11-18）**：
  - 症状：新上的「星之耀男B」在商城里找不到（同批的男A / 女A / 女B 也散落各处）。
  - 成因不是注册缺失——`goods_map` 与 `attire_pool` 两边都有这 178 件时装，id 一一对应，
    8 个精灵（4 本体 14 帧 + 4 图标）也完整；问题在 `shop_list_recharge` 的列表序：
    `ds_map_keys_to_array(global.goods_map)` 是**哈希遍历序**，加上每页 16 个（178 件 = 12 页），
    同一批写入的商品会被打散到不同页，玩家翻完 12 页也未必看见某一件。
  - 改法：页签 5（角色皮肤）在分页前按 `global.goods_id_pool` 的下标（= `shop_init` 书写顺序）
    做一次插入排序（`objects/obj_shop_bg/Create_0.gml:186-212`）。顺序从此稳定可预期，
    新注册的时装自然排在末段、同批写入的彼此相邻 —— 星之耀六件现在连在 **第 11 页末四格 + 第 12 页头两格**。
  - 只动页签 5，卡片 / 武器宝石 / 道具 / 卡牌皮肤 / 凭证页顺序不变（凭证页本来就有自己的排序）。
  - 另：搜索框输入「星之耀」可一次列出全部 6 件，是这类「找不到某件」最快的自查方式。

# v2.8.0
## 新内容
- **跨服·水火之间 新增 4 类僵尸鼠（2026-11-18）**：素材为桌面 `sprites` 下 SWF 导出
  （`0x80100A` 忍者 / `0x80109D` 蜗牛 / `0x801109` 突袭 / `0x801171` 潜艇）。父类 `obj_enemy_parent`
  按 `move*2 + attack*2 + death` 索引，段序固定「正常行走 / 受伤行走 / 正常攻击 / 受伤攻击 / 死亡」，
  目标帧数严格等于原版同名鼠精灵帧数——帧数一变就播错段。
  - 打击潜艇僵尸鼠 `kf_sh_submarine`（照抄 `obj_submarine_mouse`）：hp 4500、速度 20→0.6、防爆；
    main / land 各 36（行走 8×2 + 攻击 4×2 + 死亡 12）、enter 16（入水 8 + 受伤入水 8）。
    新素材没有陆地形态，land 复用同一批水上帧。
  - 突袭僵尸鼠 `kf_sh_assault`（照抄 `obj_assault_mouse`，本体 + 头盔两段血）：hp 720（先破 280 头盔）、
    速度 12→0.36、防爆；main / helmet / land / land_helmet 各 32（行走 8×2 + 进食 4×2 + 下沉 8）、appear 7（钻出）。
  - 忍者首领僵尸鼠 `kf_sh_ninja`（照抄 `obj_ninja_mouse`）：hp 860、冲撞 1.2（表 40）/ 行走 0.257（表 8.57）、防爆；
    撞卡扣 10 血（原版 Step 写死），召唤改为新做的僵尸小喽啰鼠，四向各 1 只；
    main 94（行走 12×2 + 攻击 29×2 + 死亡 12）、summon 44（出场 6×2 + 召唤 16×2）。
  - 僵尸小喽啰鼠 `kf_sh_minion`（照抄 `obj_minion_mouse`）：hp 100、速度 8.57→0.257、**不防爆**；
    main 95（行进 12×2 + 攻击 29×2 + 死亡 13）、summon 10（出场）。
  - 蜗牛僵尸鼠 `kf_sh_snail`（照抄 `obj_snail_mouse`）：hp 5400、速度 10→0.3、防爆，碾压 2000 + 留润滑黏液；
    精灵 41 帧与原版同构（前进 8×2 + 技能 8 / 8 + 爆炸 9）；黏液 `obj_kf_sh_snail_mucus` 精灵 10 帧
    （出现 8 + 持续 2），Step 的 `mod` / 锁帧 / 阈值同步为 10。
  - 共 14 个精灵、6 个对象；`shuihuo_enemy_init` 扩到 9 只，情报岛补 5 条；纹理组 `enemy_volcanic`，
    同一只鼠的所有精灵共用同一 origin（潜艇 land 与 main 一致、突袭 5 个精灵一致）。
  - `tools/cross_new_mice_build.py` 扩展：素材支持绝对路径、每只独立 `ash_proof`、非敌人对象（`enemy=False`）、
    `obj_map`（召唤物替换）、`text_patch`（头盔血量等）；新增 `tools/kf_zombie_sheet.py` 出核验图。
- **新增两张卡：结界马（jiejiema · 连携 / 结界多边形）与阴阳蛇（yinyangshe · 直射 / 5 连毒弹）（2026-11-18）**：
  素材源 `res/res1118/11月份做卡11.14`（数据 xlsx + 精灵图 + swf），按 17 档（0~16）注册。

  **结界马 · 非远程类 / 连携类**（耗能 180、冷却 25s、体力 350、攻击间隔 2s、射程 1）：
  - 攻击力（0/1 转）`70/80/90/120/140/160/180/220/260/300/340/380/450/520/590/660/730`；
    2 转整体 ×2（`140 … 1460`）。
  - **结界成形规则**（`scripts/jiejiema_field/jiejiema_field.gml` 纯几何、无实例依赖，可离线验算）：
    1 只 = 本格 + 前方 1 格（`mode="grid"`）；2 只 = 两只之间 Bresenham 连线（`mode="line"`，**不要求同行**）；
    ≥3 只 = 取所有马格子的**凸包**当顶点围多边形（`mode="poly"`），再逐格心射线法判定内部格，只打
    空 / 陆 / 地鼠军（`jj_can_hit_types = ["normal","air","underground"]`）。凹边形按凸包填平，
    符合「以最外圈为顶点围多边形」的口径。
  - 攻击节奏：结界对象 `obj_jiejiema_field` 每 `cycle`（120 帧）结算一次，**每格各自判定**；
    不防爆（`immune_to_ash` 为假）且非精英 → 直接 `hp = 0` 秒杀；否则吃 `攻击力 × 倍率`（`damage_type = "normal"`）。
  - 倍率表（1 转起）：前 7 次受击 `1 / 1.2 / 1.4 / 1.6 / 1.8 / 2 / 2.5`，第 8 次起固定 `3`；
    **结界每次重新成形（格集变化）就清零重数**（`jj_refresh` 递增 → 逐次计数 `jj_stage` 复位）。
  - 持续时间走技能键 `duration`：`1500/1560/1620/1680/1800/1980/2160/2400/2700` 帧
    （= 25/26/27/28/30/33/36/40/45 秒）。`obj_jiejiema` 只负责计时，最后 90 帧 `image_alpha` 闪烁预告；
    结界图形由「id 最小的那只马」唯一持有，马 → 结界是 1 对 N 的领队关系，领队死/被铲就销毁结界。
  - 二转 `plant_type = "gridless"`（**悬浮，可被铲掉**，与其它悬浮卡一致）。
  - 视觉：每格 `spr_jiejiema_fx_grid` 按格大小缩放；`line` 模式按 `point_distance + cell*0.5` 拉伸 xscale +
    `point_direction` 旋转；`poly` 模式按顶点包围盒铺 `spr_jiejiema_fx_inside`，再逐边拉伸 `spr_jiejiema_fx_side`。

  **阴阳蛇 · 直射类 / 传统直线类**（耗能 295、体力 50、冷却 7s、射程 10）：
  - 攻击力三形态同表 `10/12/14/16/18/20/22/26/32/40/55/70/85/100/115/130/145`。
  - 攻击间隔走技能键 `cycle`：`132/129/126/120/114/108/102/96/90` 帧（= 2.2 … 1.5 秒）。
  - 出弹：阴蛇 5 发、1 转起再加阳蛇 5 发（`yy_shot_count_yin=5` / `yy_shot_count_yang=(shape>=1)?5:0`），
    每 6 帧一发（`yy_shot_gap`），阴/阳交替。**首发（每 5 发的第 1 发）阴蛇附带毒伤**
    = `round(攻击力 × 过火倍率 × 3/3/4.5)`（按 shape 取系数），3 跳、每 20 帧一跳，跳在宿主身上。
  - **阴蛇可打未照明幽灵**：`target_type = "pierce"`（`card_attack_target` 注册 + 场上判定走
    `can_target_on`），阳蛇同表但命中即停。
  - 二转阳蛇**穿透**（`yy_pierce = (shape>=2)`，命中不销毁继续飞）。
  - 子弹 `obj_yinyangshe_bullet` 走 `obj_bullet_parent` 体系：自带 `hazard_fire=true` / `hazard_rebound=true`
    （**可过火盆、可反弹**，`card_special_flags` 过火组 + 反弹组都登记了 `yinyangshe`），
    `hitted` / `brazier_list` 名字与父类约定一致（`bullet_hazard_rebound` 的 reset_hits 只清 `hitted`）。

  **精灵**（13 个，按「每张卡单独一个文件夹」放 `mod/Cards/jiejiema` 与 `mod/Cards/yinyangshe`）：
  - 结界马 `spr_jiejiema 21 帧 / _1 21 / _2 24` + 特效 `fx_grid 20 / fx_line 20 (721×84) /
    fx_side 20 (721×109) / fx_inside 10 (485×455)`。
  - 阴阳蛇 `spr_yinyangshe 22 / _1 22 / _2 22` + `bullet_yin 7 (25×12) / bullet_yang 7 (24×13) /
    fx_poison 20 (61×57)`。
  - **素材全是待机帧，没有抬手/张嘴出弹帧** → `idle_anim = 帧数-1`、`attack_anim = 0`，攻击表现完全交给
    结界图形与子弹，`image_speed` 恒 0，帧由父对象 `timer / flash_speed` 推。

  **注册（9 处）**：`mod_cards_init`（17 档数值）、`mod_skill_init`（`duration` / `cycle`）、
  `mod_slots_init`（各 3 条卡槽）、`mod_info_island_init`（情报岛文案）、`card_buff_category`（非远程/连携、
  直射/传统直线）、`card_attack_target`（`pierce` + 索敌文案）、`card_special_flags`（过火 + 反弹）、
  `credit_shop_init`（凭证：结界马 2850/10-1、20500/22-2；阴阳蛇 6000/13-1、22000/24-1）、
  `mod_shop_init`（商城 95000 / 105000）。
  - 工具：`tools/make_nov_cards_1118_sprites.py`（PNG 自带解码、alpha 包围盒定原点、精灵 + 文件夹三处注册）、
    `tools/register_nov_cards_1118.py`（对象/脚本注册 + 自检：源码里每个 `obj_*` / `spr_*` 都必须在 yyp 里存在）。
  - 索引页：`docs/newcard_index_20261118.html`（文件夹树 / 精灵清单 / 数值对照 / 注册触点 / 已定口径）。

## 优化与修复
- **两张新卡的待机 / 攻击帧分段修正（2026-11-18 用户报「阴阳蛇的 IDLE 帧和发射子弹的帧不对」）**：
  - 事实：三份素材的 SWF 里都带 `FrameLabelTag`，段位是明确写死的 ——
    阴阳蛇 22 帧 = 待机 1~12 + 攻击 13~22（0/1/2 转完全一致）；
    结界马 21 帧 = 待机 1~10 + 技能 11~21，二转 24 帧 = 待机 1~12 + 技能 13~24。
  - 之前误判「素材全是待机帧」，写成 `idle_anim = 帧数-1` / `attack_anim = 0`，结果待机循环里每圈都
    把施法姿势当待机播一遍、真正的攻击段永远不播。
  - 现在按 `obj_card_parent/Step_0:281-289` 的口径填：`idle_anim` = 待机段末下标、`attack_anim` = 攻击段长
    → 阴阳蛇 `11 / 10`；结界马 `9 / 11`（0/1 转）、`11 / 12`（2 转）。
  - 阴阳蛇：开火那一帧置 `yy_anim_hold = attack_anim * flash_speed`（= 攻击段一整轮 50 帧），
    队列没吐完或动画没走完都保持 `CARD_STATE.ATTACK`，全结束才回 IDLE。
  - 结界马：本身不出弹，改由 `obj_jiejiema_field` 每次结算那一帧给场上所有马点亮 `jj_skill_timer`
    （= `attack_anim * flash_speed`），马据此播一遍「技能」段再回待机。
  - 顺带把阴阳蛇的出膛口从写死常数改成按画布比例算（`-0.28W / -0.74H` 与 `+0.31W / -0.76H`），
    三个形态（93×70 / 108×84 / 114×95）的弹都落在嘴边，二转不再从脖子以下冒出来。
- **结界马二转不再同格无限叠加 / 结界特效压到卡片之下（2026-11-18 用户口径）**：
  - 二转是 `plant_type = "gridless"`，`can_place_at_position` 的 gridless 分支对悬浮卡一律 `return true`
    → 同一格能拖多少张叠多少张。现在按「参考海洋女神」的口径，在 `place_mutex_class` 登记
    `jiejiema → "jiejiema_self"`：该检查在放置判定里跑得比 gridless 分支更早，同格已有结界马直接判不可放，
    升级替换（`global.replace_placement`）仍然放行。0/1 转本来就是 `normal`，行为不变。
  - 结界特效原来 `depth = -400`。这个工程里 **depth 越小越靠前**，而卡片是
    `-10 - row*45 - col*5 - 层偏移`（`scripts/card_depth`，全在 -10 ~ -330），-400 等于把结界糊在卡片脸上。
    改成取场上最上一行的行基准再 +1（`depth = -10 - row_min*45 + 1`，与 `obj_bbq` 的地面火同一套行距），
    **压在卡片之下、地图背景（`obj_battle` 的 +50）之上**；+1 是为了不跟同格 gridless 卡同深度。

# v2.7.2
## 新内容
- **新增「星之耀男A / 男B / 女A / 女B」四套玩家时装（2026-11-18）**：
  - 素材来自 `res/res1118/星之耀男女AB/0x14D17110|1120|1210|1220.swf`。四个 SWF 都是 14 帧纸娃娃
    时间轴（FrameLabel：待机 / 射出），位图是散件，必须用 FFDec 导「frame」合成帧；舞台 720×576、
    底色 `#666666`，另有一圈 131×131 点击外框线（抠色去不掉，按内缩 4px 抹除）。
  - 成品按 `res/套装/女角色/打工兔妹` 的形式给出：`01.png`..`14.png` + `head.png`，全部 128×128 RGBA，
    目录 `output/xingzhiyao_attire/星之耀男A|男B|女A|女B/`。
  - 对齐口径与同系列 `spr_player_attire_xingzhiyao_nan/nv` 一致：角色 bbox 中心 x=64、脚底 y=122，
    换装不会出现上下错位；图标取头部特写放大后横向裁到 128，构图对齐其它时装图标。
  - 工程侧：新增 8 个精灵（4 本体 14 帧 origin=7 64,128 + 4 图标 1 帧 origin=4 64,64，纹理组 `player`，
    父文件夹 `folders/精灵/Player/attire`）；`attire_init` 注册 4 条时装、`shop_init` 上架 4 件
    （各 50000 金币，与星之耀男/女同价）。
  - 工具：`tools/import_xingzhiyao_attire.py`（SWF→帧→抠色→128 裁切→精灵三处注册，可重跑，缺 FFDec 自动下载）；
    `tools/make_multi_frame_sprite.build` 新增可选 `origin` 参数（默认 4，旧调用不变）。

# v2.7.1
## 优化与修复
- **跨服商店抽卡模式放开香料 / 跨服金币吃难度倍率 / 商店补神圣宝石 / 转转入口换图 / 变异蝙蝠不出（2026-11-18 用户报）**：
  - **抽卡模式可以买香料**：`obj_cross_server_shop` 的 `_is_credit`（Mouse_4 判定 + Draw_0 置灰）
    补上 `type == "material"` —— 皇室 / 魔幻 / 精灵 / 天使 / 圣灵香料本来就是抽卡模式的养成材料，
    之前被「抽卡模式只能购买转职凭证」一刀切拦掉。提示文案改为「抽卡模式只能购买转职凭证与香料」。
  - **跨服关卡金币改回吃难度奖励倍率**：新增 `cross_server_coin_mult()`（= 海克斯倍率 ×
    `difficulty_get_reward_multiplier_for(global.difficulty)`），4 处结算（首通/重复 × 普通/精英）
    的金币改用这个出口；**徽章仍只吃海克斯倍率**。结算面板与准备界面的金币预览同步按实发数显示。
    别改成 `difficulty_get_reward_multiplier()`——它内部已含海克斯，会双计。
  - **商店补「神圣宝石」**：`holy_gem` 只在 `weapons_init` 里 `register_gem` 注册了本体，
    从来没有 `register_goods` → 商店「武器/宝石」页永远不显示。`shop_init` 补上架条目
    （150000 金币，主武器槽，描述与宝石本体一致）。
  - **转转入口换成 116.png**：`spr_zz_enter` 换帧（84×70 → 56×47，礼盒 + 「美食活动」），
    `.yy` 的 width/height/bbox 同步；入口位置 `(1010,20)` → `(1010,32)`，与旁边几个入口图标中线齐平。
  - **兑换确认框按钮画错**：`obj_zz_buy_confirm` 之前按 `sprite_get_width`（.yy 声明 78×33）
    自己算尺寸再减半定位，而 `spr_common_button` 贴图实际是 156×66 → 按钮画成两倍大、
    互相压住、文字跑到按钮角上。改成与 `obj_shop_buy_confirm` 同一写法：中心坐标直接交给精灵原点、
    0.75 倍（117×50），命中框 `buttons` 同步 120×52。
  - **变异蝙蝠鼠不出场**（2026-11-18 二次修，用户口径：直接照蝙蝠鼠的形式）：
    `obj_kuafu_bat` 整份对齐 `obj_bat_mouse` —— Create 只管数据（不再自己改 x/y、不再自己随机落点），
    落点/配对 target/出生高度全部交给 Step 里那段「自动补齐」（与蝙蝠鼠逐行同构，只是 target 换成
    `obj_kuafu_bat_target`、x 偏移 +30）；`obj_event_manager` 的 `kuafu_bat_spawn` 改成
    `bat_mouse_spawn` 的同一写法：随机取格 → **成对创建「落点 target + 蝙蝠」**，两只都吊在落点正上方
    `room_height` 处并互相绑定 `banding_target_inst`。关卡 waves 里直接放的 kuafu_bat 走 Step 兜底补齐
    （列随机、行沿用生成器挑的行；出生高度贴到落点上方 80px / target 上方 120px —— 蝙蝠鼠是定时事件刷的，
    有整局时间吊下来，变异蝙蝠编在波次里，出生在屏幕上方 480px 时波次早清完结算了，根本看不到）。
    `wave_ignore`（不参与清场判定）保留不变。

# v2.7.0
## 优化与修复
- **幸运星兑换页整份改成商城的画法：16 格固定 + 翻页箭头 + 商城购买按钮 + 兑换确认框（2026-11-17 用户报）**：
  - `obj_zz_shop_bg` 重写：`spr_shop_bg`（0.9）→ `spr_shop_bg_2`（1.8，`y+58`）→ **4×4 = 16 格
    `spr_shop_goods_bg` 固定绘制**（没商品的格子也画），格坐标逐像素照抄 `obj_shop_bg`
    （`x-618+411*col` / `y-190+165*row` = 342/753/1164/1575 × 350/515/680/845）。
  - 兑换按钮换成**商城原按钮** `spr_shop_buy_btn`（「购买」两字烘焙在图里），位置/缩放同
    `obj_shop_buy_btn`：格心 `+77/+60`、1.8 倍、悬停切 frame 1、不可买时 `c_gray`。
  - 页码两侧补 `spr_shop_page_btn`（1.8 倍；「下一页」用 `image_xscale = -1` 翻转，与
    `obj_shop_page_btn` 同法），位置取商城原坐标 `面板中心 +285 / +485 / +387, +435`；
    `zz_page / zz_max_page` 走 `zz_slot_item()` 分页（每页 16 格）。
  - 新增 `objects/obj_zz_buy_confirm`：与 `obj_shop_buy_confirm` 同一精灵/同一套面板动画
    （`spr_battle_escape_menu` 1.5 倍 + `spr_common_button`），标题「兑换确认」、
    正文「确定以 N 幸运星兑换 X 吗？」，确定后才调 `zz_buy_shop()` 扣星并 `show_notice` 结果。
    按钮按画布中心定位（`spr_common_button` 的 `.yy` 原点 78,32 已被裁切过，不能直接吃）。
  - 删掉页名「幸运星兑换」与底部说明文字（用户 2026-11-17 指定），压暗底图 0.72 → 0.5 与商城一致。
  - `tools/register_zz_assets.py`：`OBJ_YY_TMPL` 的 parent 改用 `FOLDER_NAME/FOLDER_PATH`
    （原来写死「金马盛典」，新对象会挂到不存在的文件夹）；新增 `OBJ_SPRITES` 映射、
    注册 `obj_zz_buy_confirm`。`folders/物体/mod/zhuanzhuan.yy` 一并补齐并挂进 `mod.yy`。
  - `tools/zz_layout_preview.py`：`draw_shop()` 按新版式重画，新增 `draw_confirm()`，
    输出 `gml_shop.png` / `gml_confirm.png` 供离线核对。
- **炎帝（终转前）：子弹改为「夹在两行之间」打上下两行，三行受击 1/2/1（2026-11-17 用户报）**：
  - 旧实现把子弹放在**单行正中**（`grid_offset_y + cell*row + 30`），`Step` 只认 `row == e.grid_row`
    → 每发只打本行，实测三行受击 1/1/0。
  - 改为与炎凰马同构的**缝隙制**：炎帝在第 R 行时，2 发子弹分别落在缝隙 R 与 R+1
    （`grid_offset_y + (gap-0.25)*cell`，夹在 R-1/R 与 R/R+1 之间），每发覆盖上下两行
    → 三行受击 **1/2/1**；场上炎帝 > 7 只时追加缝隙 R+2 → 覆盖到 R+2，受击 1/2/2/1。
    贴边时缝隙 `clamp` 到 `[1, grid_rows-1]`，两条重合即那两行各吃两次（同旧「越界改中路」语义）。
  - `obj_shennong_god_bullet_h` 新增 `cover_a / cover_b`（默认 -1 = 不启用）：命中走「行号匹配 + 水平距离 26px」，
    **不再用 bbox 的 y**（子弹在两行交界，几何上与任何一行都不相交）；同时给
    `bullet_sap_type_list` 传 `y_margin = grid_cell_size_y`，否则 SAP 候选集里没有上下两行的老鼠。
  - 终转（shape 3，`row_hits` 倍率表）与天邪池按行铺的复刻弹走 `cover_a = -1` 分支，行为不变。
  - 情报岛文案同步：「召唤2只沿两行之间缝隙移动的穿透神焰，每只同时覆盖上下2行，三行分别受击1/2/1次」。
- **炎凰马：攻击力换成官方「C. 固定轨迹类」表 + 两侧炎凰不再"折返"（2026-11-17 用户报）**：
  1. `scripts/mod_cards_init` 三形态 `atk` 改为 `75/85/95/110/130/150/170/200/250/300/400/500/650/800/1000/1200/1400`
     （本体与一转同值；二转保持「×1.5 攻击提升」口径同步为 `113~2100`）。
  2. 折返有两个来源，都修了：
     - **镜像跨发残留**：`obj_bullet_parent/BeginStep_0` 只在 `image_xscale != 1` 时把它转存到 `visual_scale_x`，
       而 `obj_pool_acquire` 既不清 `image_xscale` 也不清 `visual_scale_*` → 复用过"朝左镜像弹"的实例
       给朝右那发时，`visual_scale_x` 还是 -1，被画成倒着飞。池子清理块补 `image_xscale/yscale = 1`，
       `instance_change` 之后同步 `visual_scale_*`；炎凰马发射处四项缩放全部显式写死。
     - **方向被反转**：横向炎凰在 Create 留 `phoenix_vx = undefined`，发射处写入初速，Step 每帧
       `move_x = phoenix_vx` 锁死单程；边界销毁按 `move_x` 正负判象限，锁死后一定会命中。
  3. `scripts/mod_tianxie_pool` 的炎凰复刻（天邪）同步。
- **修「我是老曙」的「所有美食冷却 -50%」在卡槽冷却上完全不生效（2026-11-17 用户报）**：
  该词条注册为 `ex: { atk: 2.0, cycle: -0.5 }`、`en: { b3_e_hp_roll: true }`（`scripts/hex_batch3`，
  `hex_234`）。老鼠血量那一半走 `hex_b3_enemy_hp_extra()`（`en` 通道）照常生效；
  卡片侧 `cycle` 只进了 `global.hex_mult.cycle`，而 `hex_card_cooldown()`（卡槽冷却的唯一出口）
  原来只读「按卡 id」（`hex_batch2_id_cycle`）与「按分类」（灰烬类的 `cat_cycle`）两个通道，
  **全局那一条一格都没读** —— 一次性卡片（可乐炸弹 / 冰桶炸弹 / 老鼠夹…）的「冷却」就是卡槽冷却，
  它们的攻击间隔根本不存在，于是整条词条的冷却一半在实机上完全是空转。
  同一类「全部卡片冷却 ±X%」的词条（`hex_010` 快手翻炒 -8%、`hex_041` 冷冻保鲜 +8%、
  `hex_106` 冰封千里 +40%）也一并修好。
  改法：`hex_card_cooldown()` 里乘一次 `global.hex_mult.cycle`，与按分类 / 按卡 id 的倍率
  **一律相乘**（不做加算）：老曙 + 疾风龙魂 = 0.5 × 0.5 = 25% 冷却；
  选乘算而不是加算是因为加算到 -100% 会做出「0 冷却炸弹无限刷」，而 0 冷却在这套系统里
  是「火候观察」（`zero_cd`）独占的通道，不该被两条 -50% 拼出来。
  `hex_effect_rows()` 里这一行的标签同步从「攻击间隔」改成「全队冷却」（它现在同时驱动
  卡槽冷却与攻击间隔，与词条文案「全部卡片冷却」一致）。
  注：`atk: 2.0`（攻击 +200%）那一半复查过链路（`hex_apply_core` → `hex_sync_globals` 的
  `clamp(0.25, 8.0)` → `obj_mod_battle_manager/Step_0` 的 `self.atk *= hex_atk_mult_for_card()`）
  是通的，实机看着"没变"多半是同一词条的鼠军血量 ×3~×729 把攻击涨幅抵掉了。
- **蝙蝠鼠 / 变异蝙蝠鼠不再卡波次与结算（2026-11-17 用户报）**：
  `obj_battle/Step_2` 每帧把场上所有 `obj_enemy_parent`（`target_type != "obstacle"`、`hp > 0`）
  都算进 `current_wave_alive_count` / `current_wave_hp`。蝙蝠鼠（`obj_bat_mouse`，由 `bat_mouse_spawn`
  事件按 `interval` 定时刷）与变异蝙蝠鼠（`obj_kuafu_bat`）会在天上盘旋、吊绳往返好一段时间，
  于是「等清场」的四条分支全部被拖住：`:82` 压时间、`:98` 魔塔秒进下一波、`:152`/`:161` 召唤 BOSS、`:234` 结算。
  改法：
  1. `obj_enemy_parent/Create_0` 新增 `wave_ignore = false`（默认参与统计）；
  2. `obj_bat_mouse` / `obj_kuafu_bat` 各自 Create 里置 `wave_ignore = true`；
  3. `obj_battle/Step_2` 的统计循环跳过它们（`variable_instance_exists` 兜底，避免漏初始化时报错）。
  蝙蝠自身行为不变（照样偷卡、照样能被击杀、`obj_kuafu_bat` 的自动配对标靶逻辑保留）。
  安全性：全量扫过 314 个关卡 JSON，含蝙蝠的 39 个 subwave **没有一个是纯蝙蝠**，
  所以不会出现「波次刚开就被判清空」；不涉及 BOSS 阶段（BOSS 阵亡直接 `battle_finish_win`）。
- **修「Step Event0 崩 `Unable to find instance for object index`」（2026-11-17 用户第三次报）**：
  崩溃点是 `scripts/combat_targets` 里的三段索敌/啃食查询。根因不是判据不够严，而是**取数方式**：
  `combat_targets_row` 的行桶存的是「本 step 首次查询那一瞬间的实例 id 快照」，同一 step 里之后
  被打死的敌人、或被对象池 `instance_change(obj_pool_holder)` 换走的尸体仍留在数组里；
  `instance_exists` 对「同 step 内刚失效」的 id 仍可能返回 true（它只保证跨 step 的死 id 为 false），
  于是 `combat_target_alive` 放行 → 紧跟的 `with (死 id)` 直接抛错，行号报 -1。
  11-14 的 `instance_exists && !object_exists`、11-16 的 `obj_pool_holder` 判死都只挡跨 step 的情况，
  所以连着两次没修掉。现全部改为**直扫活实例**：
  1. `combat_enemy_in_rows`（long bao 系 / 奥丁 / 伊米尔 / 爱神 / 射手等 20 张卡）→ `with (obj_enemy_parent)`；
  2. `combat_enemy_nearest_in_row`（臭豆腐投石车 / 鸡蛋锅 / 冰鸡蛋锅 / 沙拉 / 巧克力 / 烤蜥蜴 / 雷神 8 个调用点）→ 同上；
  3. `combat_enemy_find_plant`（每只老鼠每帧找啃食目标）→ `with (obj_card_parent)`，避免卡片被啃掉的同 step 里读尸体属性。
  语义与重构前一致（原生 `with` 顺序 = 行桶构建顺序，等距优先 / 每层最后一张卡 / 啃食优先级规则都不变）。
  随后按用户口径**把行桶整套删掉**：`combat_targets_state` / `combat_targets_begin_step` /
  `combat_targets_invalidate` / `combat_targets_row` 全部移除，8 处调用点一并清掉
  （`obj_battle/Create_0`、`obj_mod_manager/Step_1`、卡片与敌人父对象的 Create/Destroy 各 2 处、
  `src_hook_function` 的两个 spawn 分支）；`combat_targets_row_value` 保留成只回写 `row` 的兼容入口，
  20 处行赋值调用点（`card_created` / `get_grid_position_from_world` / 猫箱 / 面粉袋 / 孟婆传送 / 平台 / 万辟龙 等）不用改。
- **神器 / 宝石进化：补生命系第 4 支 + 进化凭证上架跨服（2026-11-17 用户报）**：
  1. **神圣之眼（`divine_holy_gem`）此前既没有凭证、跨服也没下架**：`mod_craft_evo_defs()`
     里 `["gods_shield_gem_4", "divine_holy_gem", "divine_forbidden"]` 整条被注释（当时以为末阶
     「狡诈伪装」没实装），导致它不在 `steps` 里 → 诸神商店没有它的凭证，跨服也没被
     `cross_server_hidden` 打标。
  2. **「狡诈伪装」就是「玫瑰之绞」**（用户 2026-11-17 口径）：xlsx / SWF 登记表里那格写
     「狡诈伪装」，mod 里这颗宝石注册名是 `rose_shield_gem_4`「玫瑰之绞」，是同一个东西
     （荆棘玫瑰专属，`allowed_weapons: ["rose_shield"]`）。所以链直接写成
     `["gods_shield_gem_4", "divine_holy_gem", "rose_shield_gem_4"]`，
     **不需要另做 `divine_forbidden`**（那个 id 只有素材、从没 `register_gem` / 建 obj）。
     步数 31 → 33、凭证 31 → 33 张（宝石 12 支 27 步 + 神器 3 支 6 步），
     售价仍走 `mod_gear_evo_credit_price` 的 25/50/75 三档（末阶 75 = 补强宝石档）。
     两颗成品因此自动进跨服下架名单，`cross_server_shop_init` 不再需要任何手写名单。
  3. **进化凭证上架跨服商店黄金页**（`cross_server_shop_init` 注册 `cs_gear_evo_01..33`）：
     价格沿用 `mod_gear_evo_credit_price`（25/50/75，与诸神商店同一份表），一次性商品、
     售罄判据与诸神商店共用 `mod_gear_evo_buyable_locked`。`obj_cross_server_shop` 三处补
     `gear_evo` 分支：图标走 `mod_gear_evo_draw_credit`、发货写 `evo_credit_<目标>`、
     列表排序 rank 3 按登记序号聚在黄金页最后。凭证同时计入「凭证类」→
     抽卡模式下也能买（与诸神商店 2026-10-27 口径一致）。
- **神器 / 宝石进化页三处口径统一（2026-11-16 用户给图）**：
  1. **空槽放原版固定美术**：新增精灵 `spr_gear_evo_label`（4 帧 34×28，素材 = 用户提供的
     `138.png`武器 / `160.png`进化凭证 / `162.png`神器 / `164.png`宝石，`tools/make_gear_evo_label_sprite.py`
     补边成同画布 + 注册）。旧物槽画「神器 / 宝石」、凭证槽画「进化凭证」，比例 1.8（与槽位图纸一致），
     不再用 `font_yuan` 画「放武器 / 放宝石 / 放凭证」。
  2. **底部凭证架只放已拥有的**：`gear_credit_ids()` 加 `credit_count > 0` 过滤
     （原来 31 张全铺，一屏 10 格要翻 4 页且全是 0）。
  3. **删掉凭证架上的「‹ 16/16 ›」页码**（用户红框标出）：绘制与两个隐形翻页点击区一并删除，
     超过一屏时仍可用滚轮翻（`Mouse_60/61` 不变）。
  4. **右侧列表只列「已拥有 且 还能进化」**：`gear_rebuild()` 先求 `steps[].from` 集合（= 有下一形态），
     再按进化链顺序收集；链末形态与链外专属宝石（主宰 / 荆棘玫瑰那几颗）不再出现。
- **修：点「神器进化 / 宝石进化」跳回卡片宝石页**（2026-11-16 用户报）。根因是左侧那三个旧按钮
  `obj_craft_select_btn` 在神级进化页只是 `visible = false` 藏掉、没销毁，而 `visible = false`
  只跳过 Draw 事件、**Mouse 事件照常派发**；它的位置（`x-661, y-50/+100/+250`）和新子页按钮
  （`x-660, y-80/+80/+240`）x 差 1px 全段重叠 → 点击被抢走，`craft_top_tab` 被拽回 0。
  修法：`obj_craft_select_btn/Mouse_4` 开头加 `if (!visible) exit` + 页签拦截（融合页 / 神级进化页直接 exit）；
  顺手给 `obj_closecraft_btn/Mouse_4` 补同样的 `if (!visible) exit`（否则融合确认弹窗期间点隐藏的 X 会关掉合成屋）。
- **凭证售价改口径（2026-11-16 用户纠正）**：不是「按登记表顺序每张 +25」（那会卖到 775），
  而是按**进化档位**三档 —— 新神器/新宝石凭证 25、超神器/超宝石凭证 50、补强宝石凭证 75，
  最贵 75。档位写进 `mod_gear_evo_build()` 的 `step.tier`，售价出口仍是
  `mod_gear_evo_credit_price()` = `25 * (tier + 1)`，只改这一处。
- **跨服商店下架进化后的武器 / 宝石**：判据只读进化表（`mod_gear_evo_build().steps` 的 `.to`），
  在 `cross_server_shop_init()` 末尾统一打 `cross_server_hidden`，`obj_cross_server_shop/Create_0`
  收集列表时跳过 —— 共下架 31 件（6 武器 + 25 宝石）。用打标而非 `ds_map_delete`，
  避免 `required_weapon_id` / `required_gem_id` 指向空键。
- **合成屋神级进化页左侧三格按钮改成无缝拼接**（2026-11-16 用户口径「像卡片宝石页那样无痕」）：
  `gear_left_y` 间距 160 → **147**。精灵 46×85 ×1.8 = 153 高、四角圆角各 3px（×1.8 = 5.4），
  原间距 160 会在两块之间露出 7px 底图纸色（就是用户看到的「缝」）；
  147 时相邻两块重叠 6px，刚好盖住圆角。热区半高同步 80 → 73（≤ 间距/2，否则点接缝会选到下格）。
- **左侧子页按钮全部换成原版固定美术**（字烤在图里，不再有任何自绘文字）：
  `spr_evo_left_on`（金卡进化，1 帧）+ 新增 `spr_evo_left_artifact` / `spr_evo_left_gem`
  （各 2 帧：0 = 浅底选中 / 1 = 深底未选中，素材来自 `合成屋.swf` 的 DefineSprite_681 / 686）。
  热区宽度从 ±41 放宽到 ±60（按钮本体只有 83 宽，贴边点会漏判成「点了没反应」），并加了悬停增亮反馈。

## 新内容
- 神器 / 宝石进化凭证上架**诸神商店**（2026-11-16，第 1 页「进化凭证」页，货币神谕之石）：
  31 张凭证按**进化档位**定价（25 / 50 / 75，最贵 75），见上方「优化与修复」。
  - 注册走 `gods_shop_init` 的 `gods_shop_register_gear_evo()` **循环**完成
    （id `gear_evo_01..31` 两位补零，商店按 id 字母序收集，补零后顺序 = 登记表顺序），
    一条不写死，以后改链自动跟着变。
  - 售价唯一出口 `mod_gear_evo_credit_price()` = `25 × (tier + 1)`；换档只改这一处，商店读同一个函数。
  - `sort_tier: 3` 让它们排在本页「融合卡 / 金卡 / 普卡与卡凭证」之后；
    售价与名字都实时反查（`gods_goods_name` / `mod_gear_evo_shop_tip`），不硬编码。
  - 售罄口径 `mod_gear_evo_buyable_locked()`：背包已有一张、或这一阶已经进化出来 → 售罄
    （Create 的 `is_disabled` 与 Draw 的售罄罩共用）。抽卡模式禁买，与金卡凭证同一条拦截。
  - 图标照 `mod_gear_evo_draw_credit`（金色底板 + 目标装备图标）；成交在
    `obj_gods_store_buy_confirm/Step_0`：扣神谕之石 + 凭证进背包，不解锁装备。
- 合成屋「神级进化」页接入**神器进化 / 宝石进化**两个子页（2026-11-16）：
  左边竖排按钮从 1 个变 3 个（金卡进化 / 神器进化 / 宝石进化），后两个是全新页面；
  进化链 **3 条神器（6 步）+ 11 条宝石（25 步）= 31 步 / 31 张凭证**，
  唯一事实源 `scripts/mod_craft_evo_table/mod_craft_evo_table.gml` 的 `mod_gear_evo_defs()`
  （`mod_gear_evo_*` 与金卡进化的 `mod_evo_*` 同域，不新增脚本资源、不动 `.yyp`）。
  - 落账口径（用户 2026-11-16 明确）：宝石进化后**星级归 0**、**不返还任何材料**
    （原版 `god_card.xml` 会按 `cost_gem_level` 退强化水晶，这里刻意不退）；
    武器**就地换装**（正装备着就换到原槽位），不兼容的专属宝石由 `weapon_gems_reconcile` 卸回背包。
  - **进化按钮下方不再显示任何说明文字**（原版那两行「等级保留 / 返还水晶」删掉）。
  - 右侧列表**只列已拥有的**武器 / 宝石（按进化链顺序，链外的专属宝石按存档顺序补后），未拥有的不出现在列表里。
  - 底部道具条改成**凭证架**：10 个自绘格按底图内壁实测几何（`x-797 / y+411 / 914×83 / pitch 91.4`），
    凭证（金色底板 + 目标物图标）**完美嵌进格子里**；点凭证 = 反查步骤 → 旧物槽 + 凭证槽整组落槽，
    点凭证槽 = 整组取回；滚轮在条上只翻凭证架，不漏到强化页。
  - 凭证**不注册 material**：沿用 `evo_credit_<目标id>` 前缀（与金卡凭证同一个识别分支），
    `get_material_amount` 直接读背包；`transfer_credit.gml` 的「进化凭证」段已适配成显示装备名 +
    进化路线（原先会把装备凭证当卡名显示）。
  - 自检：GML 侧 `mod_gear_evo_selfcheck()`（debug 首次打开打一次）；
    编辑机侧 `tools/gear_evo_check.py`（查未注册 id / 重复目标 / 凭证撞车，退出码 0 = 全绿）。
  - 未实装：「狡诈伪装」（`divine_forbidden`，生命系第 3 阶）mod 里没有 `register_gem` + 对象，
    链里注释留位，实装后取消 `mod_gear_evo_defs()` 那行注释即可，UI 不用改。
- 任务看板新增「一键领取」（2026-11-15，位置：标题栏右侧、关闭按钮左边）：
  一次领完**所有** `state == "completed"` 的任务奖励，**不限页签类别**（主线 / 支线 / 挑战 / 卡片情报）。
  按钮文字带待领条数「一键领取（N）」，N = 0 时置灰不可点。
  - 新增 `objects/obj_task_claim_all_btn`（Create / Step / Draw / Mouse_4 / Mouse_10 / Mouse_11）
    与精灵 `sprites/spr_task_claim_all_btn`（3 帧 144×48：常态 / 按下 / 禁用）。
    底板不带文字，文字用 `font_yuan` 叠画 —— 待领条数是动态的，烘进图里就改不了。
    生成脚本 `tools/make_task_claim_all_btn.py`（Pillow 超采样画圆角，可幂等重跑）。
  - 发奖逻辑抽成 `task_edit` 的 `task_grant_rewards(task_id)`：单个领取
    （`obj_task_claim_btn/Mouse_4`）与一键领取共用一份分支，将来加奖励类型不会漏改一边。
    一键领取**只 `save_file` 一次**（一批 50 条写 50 次会卡帧）。
  - 统计口径与领取口径逐条对齐：`completed` + `get_task_data` 非 `undefined`（孤儿任务既不计入也领不到，
    否则会出现「按钮显示 3、点下去只领到 2」）。
  - `obj_task_bg/Create_0` 创建它并登记进 `panel_anim_kids`（入场动画跟着淡入，文字用
    `ui_anim_text_alpha` 同步），`Destroy_0` 一并销毁。
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
  - 情报岛补注册 8 条（`mod_info_island_init`）：`kf_sh_rowboat` / `kf_sh_dragon_boat` /
    `kf_sh_flagship` / `kf_sh_kof_submarine` / `special_armour_mouse` /
    `soar_mouse` / `kf_sh_iron_man` / `kf_wd_hulk`；拼音检索走全量表无需登记。
    （`kf_wd_garbage` 原在此列，因与灼热版 `kf_zr_garbage` 同名重复已撤，见「优化与修复」首条。）
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
- 蛋蛋兔冷却改为「星级只吃攻击力，技能吃冷却时间」（2026-11-16，用户口径 + 左表）：
  - 冷却 90/87/84/81/76/71/66/61/50 秒（技能 0~8 级）搬进 `mod_skill_init` 的
    `register_card_skill("dandantu","cooldown", …)`；`mod_cards_init` 的三形态星级表
    统一改成 `array_create(17, 5400)`（恒 90 秒），不再随星级递减。
  - 情报岛文案同步：`mod_info_island_init` 的 dandantu 条目由「星级影响[攻击力]和[冷却时间]」
    改为「星级影响[攻击力]，技能影响[冷却时间]」——原来实战口径已按技能走，只有文案没改，
    玩家看到的就是「描述和实际不一致」。
- 退出确认框不再被连点绕过（2026-11-16）：
  - `obj_menu_manager/Step_0`：退出确认框已存在时，原来再按一次返回键直接 `game_end()`，
    连点（右键/ESC 两次）＝当场杀进程。现在这一支什么都不做，交回 `obj_quit_confirm`
    （确定 / 取消 / ESC）处理。
  - `obj_readyroom_manager/Step_0`：右键/ESC 原来是 toggle（框存在就销毁），连点两次＝
    弹出又被自己关掉。现在框存在时不再响应。
- 后羿（2026-11-16）：
  - 索敌恢复三行直扫：`d6ae7a5b7d` 把 `obj_houyi_god/Step_0` 的 `with (obj_enemy_parent)` 直扫
    换成按行桶 `combat_enemy_in_rows(… grid_row-1 … grid_row+1 …)`，用户报「不索敌、不出弹、
    老鼠也不啃它」。现恢复直扫（保留 `combat_target_alive` 存活判定），三行窗口不再受行桶影响。
  - 地火改为 **3×3**：`obj_houyi_god_bullet/Step_0` 原来在本行命中格往右铺 3/5 格（实际只看到一格），
    现在以命中格为中心铺 3 行 × 3 列共 9 格，每格仍是 0.5 秒、整段一次 700 伤害。
- 冲撞类卡片不再秒杀 / 撞飞 BOSS（2026-11-16，用户报变异钢铁侠 / 变异绿巨 / 变异火渣 / 变异冰渣）：
  - 根因：`obj_baiyang_effect` / `obj_doumaobang_cat` / `obj_tanchitu_rabbit` 的 BOSS 豁免写的是
    `is_boss && global.map_name == "跨服远征"`，而进关时 `room_transition` 会用 `register_map`
    的 name 覆盖 `map_name`（水火之间 / 巫毒研究所 / 灼热地域 / 美味岛…），于是只有古堡那章算数。
    三处统一去掉地图名依赖，BOSS 一律走「只扣血」分支。
  - `obj_cat`（第 0 列的猫）原来只在 `!can_loss`（爆炸/冲撞型）时才让 BOSS 免疫，普通猫会把 BOSS
    直接撞飞；补 `if (is_boss) continue;`。
- 星轨神可以靠命运女神升到 UM（2026-11-16）：`obj_clotho/Create_0` 的 `gold_cards` 名单漏了
  `xinggui_god` / `lingrong_god` / `panduola_god`，`Other_11` 里 `new_level >= 17` 的金卡判定
  不成立 → 被 `min(new_level,16)` 夹回 16 星。三张补进名单。
- 龙渊地精鼠钻地时免疫灰烬（2026-11-16）：`obj_ly_dijing/Other_10` 在钻地分支前追加
  `ly_mode == "dig" && damage_type == "ash"` → 直接按 0 伤害退出。原来能命中 underground 的
  灰烬卡（target_type = all / rotate / d_fruit）会把 `ly_dig_hittable` 置 true 从而漏进白名单。
- 索敌崩溃加固（2026-11-16，用户贴 `obj_stinky_tofu_pult` → `combat_enemy_nearest_in_row`
  报 `Unable to find instance for object index`）：`combat_target_alive` 追加对象池尸体判定
  （`instance_change(obj_pool_holder)` 回收后 id 仍在、变量仍在，旧判据会放行并选中尸体）。
- 关闭鼠标帧率锁定（2026-11-15）：
  - `objects/obj_game_init/Create_0.gml:176-194` 原先从 `config.ini` 的 `[settings] mouse_limit_hz`
    读入并写入 `global.mouse_limit_hz`（含 `cfg_rev` 老配置迁移分支），现整段注释，末尾恒置
    `global.mouse_limit_hz = 0;`。
  - `objects/obj_file_manager/Step_0.gml:63-99` 每 10 帧一次的重装钩子逻辑（`ml_tick` 计数 +
    `native_start_mouse_limit(global.mouse_limit_hz, window_handle())`，底层是 WH_MOUSE_LL
    低级鼠标钩子）整段注释；只保留初始化时与退出时各一次 `native_stop_mouse_limit()`，
    避免同进程残留钩子。
  - 原因：低级鼠标钩子会在高刷新率下被 Windows 超时回收（`LowLevelHooksTimeout`），
    导致指针偶发卡顿/丢帧；编辑器与战斗场景都不需要限帧，直接关掉更稳。
- 跨服·梦魇天空云层改为与棉花糖天空一致，同屏只剩一层（2026-11-15）：
  - 症状：进关后云层看起来有两层——底图（`spr_mengyantiankong_N`）左两列画死的云墙占一层，
    引擎铺的 `obj_cloud` 占另一层，且四处飘的云会直接压到画死的云墙上。
  - 根因有三处，逐条修：
    1. `objects/obj_battle/Draw_0.gml`：有 `bg_draw` 时先用 cover 比例把整张底图再画一遍兜底，
       再画精确份。两份缩放 1.8090 vs 1.7833、水平错开 56.3 px → 底图里的云与六芒星各出现两次。
       改为**只画精确那一份**，屏幕四边用「原图边缘 1 像素拉成条带」补（`draw_sprite_part_ext`，
       条带与精确份共用同一条格线，不会重影）。
    2. `datafiles/level_data/cross/nightmare_sky-0..7.json`：`spawn_interval` 5 秒 → **8 秒**、
       `interval`（云洞周期）5 秒 → **30 秒**。
       这是棉花糖天空的节奏（`obj_event_manager/Step_0.gml:328`/`:344` 的 `mod 1800` 与 `mod 480`）——
       云以 0.25 px/帧 左移，走完一格 107 px 需 428 帧 ≈ 7.1 秒，补排间隔必须 ≥ 这个值，
       否则补排快于消耗，同屏堆到 77 朵、前后三排叠在一起，看着就是第二层；
       云洞 5 秒一个也太密（用户说的「慢慢飘会出现漏洞」），改 30 秒。
    3. 同 8 个 JSON 增加 `"no_resident": true`（开局不铺 col2-8 的整屏云，避免「一开局全屏是云」）
       与 `"fade_col": 1`（流动云飘到第 2 列格心才淡出 —— 与棉花糖天空的 `get_world_position_from_grid(1,0)`
       完全一致，这样飘入的云正好接在底图左两列画死的云墙上，接成一整片，而不是中间留缝的两层）。
  - 配套引擎开关（默认值保持原版行为，不影响其它关卡）：
    - `objects/obj_event_manager/Step_0.gml:468` 的 `no_resident` 判断、`:473`/`:504` 的 `fade_col` 赋值；
    - `objects/obj_cloud/Create_0.gml` 新增 `fade_col = 1`，`Step_0.gml:11` 由写死 `get_world_position_from_grid(1,0)`
      改为读 `fade_col`。
  - 实测存活云数（新配置，7 行全开）：1 秒 7 朵 / 10 秒 14 朵 / 30 秒 28 朵 / 50 秒起稳态 49 朵；
    旧配置（常驻 + 5 秒补排 + 淡出于 col1）同期是 56 / 56 / 56 / 77 朵，前后三排叠在一起。
  - 预览与模拟脚本：`tools/sky_preview.py`（底图合成）、`tools/_sky_v6_preview.py`（顶层节奏）、
    `tools/_sky_v5_plans.py`（五套方案对照）、`tools/_sky_diff_double.py`（双画差分）、
    `tools/_sky_deliver.py`（8 关成品 + 时间线）、`tools/_sky_regress_bgdraw.py`（另 4 张 bg_draw 底图回归）。
    图在 `output/梦魇天空预览/`：`deliver_8levels.png`、`deliver_timeline.png`、`regress_bg_draw.png`、
    `final_cloud_plans.png`、`v4_double_diff.png`。
- 跨服 BOSS 变异护盾挪到身前、时长盖满减伤全过程（2026-11-15）：
  - 症状：变异皮特 / 变异朱莉的蜂巢护盾画在**身后偏下**（皮特在右下方压住腿、朱莉直接盖住整个身体），
    且技能动画一播完护盾就消失——皮特放钢爪时钢爪还在地上 2 秒，护盾已经没了。
  - 位置：两只 BOSS 立绘都朝左，「身前」= 屏幕左侧。按用户参考图折算
    （皮特 271×296 / origin(74,290)，朱莉 239×175 / origin(110,169)）：
    皮特 `shield_dx -101 / dy -134 / sx 0.95 / sy 1.05`，朱莉 `-130 / -100 / 1.05 / 1.12`
    （原来是 `+60/-145/2.0/1.45` 与 `+10/-82/1.8/1.0`，正 dx = 画到了身后，缩放也偏大）。
  - 时长：`shield_active` 不再只看 `state`。
    - 皮特：施法状态 **或** 自己放出的钢爪 / 尖刺 / 导弹还在场上（`owner_boss == id`）就保持展开，
      钢爪存活 180 tick、导弹约 120 tick，减伤随之盖满「地面物体停留」全过程；隐身（钻地/现身）期间收起。
    - 朱莉：技能状态 + 结束后 `shield_tail = 120` tick 尾期，覆盖召唤中尉落地与加血余波。
  - 涉及：`objects/obj_kuafu_boss_pete{,_claw,_spike,_missile}`、`objects/obj_kuafu_boss_julie`。
  - 新增 `tools/kuafu_shield_preview.py`：按 origin 对齐合成「立绘 + 护盾」，不进游戏就能调 shield_dx/dy/sx/sy。
- 变异嗡嗡中尉放熊猫的位置与本体落点对齐（2026-11-15）：
  - 症状：中尉技能2本体飞到 3~7 列的随机格，熊猫鼠却随机出现在 1~5 列，两者差好几列。
  - 修法：`objects/obj_kuafu_boss_buzz/Step_0.gml` 的 `skill_timer == 1` 先定下本轮目标格
    （`panda_col = jump_times` → 第 1~5 列），本体直接飞过去，`skill_timer == 91` 就在这一格生成变异熊猫；
    悬停偏移去掉 `-80`，本体中心与熊猫同落格心。
- 变异屎者的技能1召唤物改为变异幽灵（2026-11-15）：
  - `objects/obj_kf_zrb_shi_ignis/Step_0.gml` 鬼火消失时由 `obj_ghost_mouse` 改为 `obj_kf_zr_ghost`
    （`spr_kf_zr_ghost`，灼热地域的变异幽灵）。血量沿用原召唤物 280——
    这一招已从 5 只加到 10 只，按小怪 1000 血会把难度抬爆。
- 巫毒研究所的风洞整体上移 32 像素，与底图原铁笼重合（2026-11-15）：
  - 症状：8 张巫毒底图上的铁笼已擦除、改由 `obj_wind_tunnel` 绘制后，风洞比原位置偏下约一格的三分之一，
    每个格子都对不齐（用户截图标注红框 32px）。
  - 量化：按列做「金属 + 网面」投影，底图备份（`output/_tmp/bak_wuduyanjiusuo_*`）里原铁笼底边在格心 **+40.6**，
    游戏里风洞精灵内容底边在格心 **+72**，差 **31.4**，与截图红框一致。
  - 修法：`objects/obj_wind_tunnel/Create_0.gml` 的巫毒专用对齐分支由 `y += 35`（回到格心）
    改为 `y += 35 - 32`（回到格心再上移 32）。x 不动；`macchiato_port` / `tower_cake_15_*`
    走 `obj_event_manager` 生成、地图不是 `spr_wuduyanjiusuo*`，不进入该分支，位置保持原样。
  - 验证：`tools/wudu_windtunnel_align_sheet.py` 出三联图（底图原稿 / 当前 / 修复后），
    修复后精灵角钉与底图铁笼角钉重合。
- 修变异绿巨人技能1播成了站立攻击、不是原版的滚动（2026-11-15）：
  - 症状：巫毒研究所 BOSS「变异绿巨人」放技能1时播的是原地挥拳/抬腿，看不到滚动冲撞。
  - 根因在**精灵切段错了**：`spr_kf_wd_hulk_skill_1` 的 14 帧与 `spr_kf_wd_hulk_skill_1_ready`
    的 16 帧都不是连续段——用 `tools/swf_align.py` 对齐 SWF（`变异绿巨人.swf` → `DefineSprite_190`，
    480 帧）时单帧代价 1.19 / 6.06（正常应为 0.00），帧来源散落在跳跃段 `#114 #128 #142 #157 #323 #338` 等处。
  - 按 FrameLabel 重建：`变滚球`（0 基 94..104，11 帧）+ `受伤变滚球`（304..314，11 帧）= 22 帧 →
    `spr_kf_wd_hulk_skill_1_ready`；`滚球`（105..108，4 帧）+ `受伤滚球`（315..318，4 帧）= 8 帧 →
    `spr_kf_wd_hulk_skill_1`。画布 532×454、原点 (366,413) 与其它 hulk 精灵保持一致。
  - `obj_kf_wd_hulk/Step_0.gml` 的 SKILL1 常量同步：变滚球 11 帧按比例铺满原 40 tick
    （`floor(timer * 11 / _s1_in)`），滚球 `mod 7 → mod 4`（受伤 `+4`，原来受伤分支写死同值永远不播），
    倒放段改 11 帧倒序（`10 - ...` / `21 - ...`）。变身 40 / 滚动 55 / 疾跑 60 tick 的原版节奏不变，
    所有 timer 阈值与后续跳跃位移计算不受影响；模拟 0..329 全时段无越界，三段帧全部播到。
- 卡片情报任务奖励由 5000 金币调整为 2000（2026-11-15，`scripts/task_edit/task_edit.gml` 的
  `card_info_task_sync` 里 `rewards.amount`）。存档只存 `id / state / progress`，奖励从
  `global.task_pool` 现取，所以**老存档不用迁移**：重启后按 2000 发，已领取过的任务不受影响。
  设计文档 `docs/info_task_design/卡片情报任务_设计方案.md` 顶部已加变更注记（正文保留最初的 5000 作历史记录）。
- 修跨服 BOSS「阿诺 / 冰渣 / 火渣 / 法老」精灵动画播放错乱（2026-11-15）：
  - 症状：这几只 BOSS 的某几段动作（阿诺待机与冲刺、冰渣/火渣念咒与放球与攻击、法老召唤）会定帧、
    闪成空帧、或播成别的动作；冰渣/火渣尤其明显，两套形态（ice/fire）同时坏。
  - 根因**不在精灵**：把 108 个 `spr_infected_*` 逐帧与 SWF 单调对齐（新工具 `tools/swf_align.py`）
    后确认切片全部连续、逐像素等于 SWF 原图，帧数也与 FrameLabel 分段一致。
    真正的问题在 Step 里**照抄了原版的取模常量**：原版阿诺的待机/冲刺预备/冲刺精灵是 12 / 26 / 22 帧，
    变异版是 12 / 20 / 28 帧；原版冰渣念咒/念咒半段/放球/攻击是 8 / 8 / 16 / 17 帧，常量被误写成 9 / 9 / 18 / 19，
    于是 `mod N + N` 的受伤段索引落到 `2N-1`，超出精灵帧数——GM 画不出帧，表现为定帧或空帧。
  - 修正：`obj_infected_arno/Step_0.gml` 待机去掉越界的 `+12`（两分支同段），
    冲刺预备 `13→10`、冲刺 `11→14`，预备时长 `195→150`（`10*5*3`，仍是 3 个完整循环）；
    `obj_infected_bingzha` 与 `obj_infected_fire_residue` 的念咒 `9→8`、放球 `18→16`、攻击 `19→17`，
    待机 `12/12 → 8/+8`（原来两分支写死同值，受伤变体永远不播）；
    `obj_infected_pharaoh/Step_0.gml` 召唤补上受伤段 `+19`（精灵本来就是 19 正常 + 19 受伤）。
  - 顺手补 `spr_infected_arno_idle`：工作区已是正确的 12 帧（逐像素 = SWF `#1..#12`），
    库里那份 24 帧的第 8 帧起已串到射击段，是错的，提交时注意别把它带回去。
  - 新增回归工具 `tools/check_frame_range.py`：扫 `sprite_index` 与紧随其后的 `mod N` / `+ N`，
    按「两段 = 2N 帧、单段 = N 帧」对拍精灵实际帧数，一条命令列出全部越界（`--all` 可扫全量 `obj_infected_*`）。
- 修「至尊丰饶神被时光机升一星倍率就翻一倍」（2026-11-15）：
  - 症状：终转丰饶神连吃时光机，倍率按 2.5 → 5.12 → 7.32 → 7.5 一路叠，像是「每被升星类卡影响一次就叠一倍」。
  - 根因**不是**星级，是**同一实例被重复登记**：`mod_set_card_level`（`scripts/mod_set_card_level/mod_set_card_level.gml:84`）
    每次变星都把目标的 `buff_cells_refreshed` 置 false，而增幅源 Step 的 `if (!buff_cells_refreshed)`
    分支里既有「重建格子」也有「`ds_list_add(global.buff_sources, id)`」→ 变一次星就往增幅源表里多塞一条自己。
    `rebuild_buff_grid` 是按表逐条 `apply_buff` 的，至尊丰饶神走 `buff_stacking` 分支
    （`scripts/mod_build_buff_grid/mod_build_buff_grid.gml:181-188`，`stack_grid += v; stack_count++`），
    于是重复条数 = 叠层数，撞上 `buff_max_stacks = 3` 的上限就停在 7.5。3 倍上限的口径本身没问题，
    错在「一张卡算成三张卡」。
  - 修法：`scripts/mod_build_buff_grid` 新增 **幂等** 的 `mod_buff_source_add(_source)`
    （已在表里就不再 add），12 处增幅源登记全部改走它：`obj_aurora` / `obj_blueberry_tower` /
    `obj_berry_dessert` / `obj_fengrao_god` / `obj_fruit_tart` / `obj_hspeed_juicer` / `obj_mozhang` /
    `obj_nengliangmiao` / `obj_xiangliaohu` / `obj_wuxingshe` / `obj_xiangshui_god` / `obj_zhuzhujiaqiang`。
    重建格子仍然照旧（变星后 atk 变了必须重算），只是不再重复进表。
  - 复核：`output/_tmp/fengrao_stack_sim.py` 按同一逻辑复现，修复前 8→9→7→8 星得到
    2.50 / 5.12 / 7.32 / 7.50（与用户截图逐项一致），修复后四步均为应当倍率。
- 变异战神换用 + 素材修复，变异绿巨人移动改跳跃（2026-11-15）：
  - 水火之间 7 关、巫毒研究所 2/3 关的 BOSS 由 `war_god` 换成 `infected_zhanshen`
    （`shuihuo_7.json`、`wudu_2.json`×2、`wudu_3.json`×2，共 5 处；血量 250000 未变）。
  - `spr_infected_zhanshen_*` 素材修复：提交 `c9780a4f5f` 把这套精灵写坏了（除第 0 帧外，
    death/duck/gear/wood/summon/bullet* 的帧全部退化成 RGB 噪点），且图层目录写反
    （`layers/<layerGUID>/<frameGUID>.png` 才是美术，`layers/<frameGUID>/<layerGUID>.png`
    是 64×64 红叉占位）。按帧 GUID 从好提交 `4ec67fb2a6` 回填，并把每帧图层与顶层合成图
    统一成同一份（`tools/inf_zhanshen_audit.py` / `inf_zhanshen_restore.py` / `inf_zhanshen_repair.py`）。
    wood 末帧 `4ec67` 里也是噪点，用前一帧顶替。
  - 血条图标：原先直接登记 282×238 的 idle，`icon_height = sprite_height*1.8` 会把血条撑出屏幕；
    改为专用 48×40 图标 `spr_infected_zhanshen_icon`（`tools/make_inf_zhanshen_icon.py`，
    `boss_init` 同步）。原点取右中 (48,20)，与 `spr_mario_mouse_icon` 等同规格图标一致，
    绘制点 `x-3, y` 才不会压到血条上。
  - 原点错位：gear `xorigin 57→101`（内容中心）、summon `yorigin 260→177`（原值超画布 74px，
    与接替它的 soldier 对齐）、skill_1 `yorigin 229→238`（与 idle/death 同为底对齐）。
  - 变异绿巨人：`move_slow` / `move_fast` 原本是 SWF「变滚球 / 滚球」段（sprite 190 帧 94~108）
    重采样而来，一移动就成球滚。改取同 SWF 的「跳跃预备→跳跃→下落地面」段（健康 110~124、
    受伤 = +210）按原帧数原画布原原点替换（`tools/hulk_move_to_jump.py`），
    DISAPPEAR 走位与技能 1/3 冲撞全部变跳跃，对象代码零改动。
  - 字体补「蜷」（U+8737）：`font_yuan` / `font_hei` 图集各加 1 个字形
    （`tools/font_fill.py --chars 蜷 --only-chars`，新增该选项可只补指定字）。
    同时把情报岛绿巨人文案「技能3：蜷成球冲撞碾压本行」改成「技能3：连续跳跃冲撞碾压本行」，
    与新动画一致。
- 梦魇天空 8 张底图重做，云层由两层收敛为一层（2026-11-15，
  `spr_mengyantiankong_0..7` + `obj_event_manager/Step_0.gml` + `nightmare_sky-0..7.json`）：
  病灶有两处。① 旧底图本身画满整屏云（col2-8 全是静态云），引擎 `cloud` 事件开局又在
  col2-8 铺一层 `obj_cloud`，每 `spawn_interval` 秒再从 col9 飘入一排 —— 三层视觉叠加，
  表现为「一开局便是全屏都是云，随后慢慢飘会出现漏洞」。② 素材 `天空背景图.png`
  才是真正的纯天空底层（1167×620，无云无星）。
  配准结论：`天空背景图.png` 缩到 **0.964 倍**后从 **(15, 1)** 采样得到的 1109×597
  与旧美术的天空部分逐像素重合（左侧石柱带全分辨率 MSE=254.23 为全搜索空间最优），
  即旧美术 = 天空背景图 + 云 + 绿色六芒星障碍。**`bg_draw` 一个字未动**
  （`x=13.2 y=12.39 sx=1.7833 sy=1.78`），换底后格子相位不变。
  新底图合成口径（`tools/sky_preview.py`，产物 `output/梦魇天空预览/build/`）：
  底层 = 天空背景图按上述配准裁 1109×597；col 0-1 共 14 格逐格贴云，云瓦片取
  `spr_cloud_night` 两帧、按引擎 `obj_cloud` 的 `image_xscale/yscale = 1.8` 换算成
  84×71 美术像素（格宽 `107/1.7833 = 60.0`、格高 `116/1.78 = 65.2`），两帧交替；
  障碍六芒星从 `spr_mengyantiankong_1` 的 `(388,216)-(462,302)` 抠出（70×83，含内圈），
  按各关 JSON 的 `obstacle` 格中心贴回（0 关无；1/2 关 `(2,0)(4,0)`；3 关 `(1,0)(3,0)(5,0)`；
  4/5 关 `(1,0)(3,1)(5,0)`；6 关 `(1,1)(3,1)(5,1)`；7 关 `(1,0)(2,1)(3,0)(4,1)(5,0)`）。
  精灵写回 `tools/_sky_apply_sprites.py`：每个精灵写**两份**
  （`sprites/<名>/<帧id>.png` 与 `sprites/<名>/layers/<帧id>/<图层id>.png`，只写一份游戏里不变），
  尺寸 1109×597 与原图一致，`.yy` 无需改动；旧图备份在 `output/梦魇天空预览/backup/`。
  单层化：`obj_event_manager/Step_0.gml:468` 的常驻云分支加开关
  `if event_timer == 1 && !variable_struct_exists(event_list[i], "no_resident")`，
  8 个关卡 JSON 的 `cloud` 事件加 `"no_resident": true`（`tools/_sky_apply_json.py`，
  字符串替换不重排文件、保留原浮点写法，旧档备份 `output/梦魇天空预览/backup/json/`）。
  只保留 `:490` 起 col9 飘入的那一层，`is_hole` 棉花糖空缺逻辑挂在它身上，行为不变。
  其它地图（棉花糖天空等）没写 `no_resident`，常驻云照旧。
- 诸神之盾改回「商城直售」，不再从抽卡卡池出（2026-11-15，`gacha_random_card` + `obj_shop_buy_btn`）：
  抽卡池的 MOD 武器名单（`gacha_is_mod_weapon`）里删掉 `gods_shield` —— 这份名单同时充当
  「抽卡模式下商城禁售」的判据，所以只删一处就同时达成本体不进池 + 商城可买。
  新增 `gacha_shop_locked(_type,_id)` 统一判据：武器侧照旧读名单；宝石侧开一个例外白名单
  `gods_shield_gem_1..4`（光能/撕裂/永恒/生命之源）—— 4 颗之源宝石**商城也能买**
  （价格见 `mod_shop_init`，与死神镰刀系同为 200000），抽卡池里仍可抽（需先拥有诸神之盾）。
  `obj_shop_buy_btn/Draw_0` 的置灰与 `Mouse_4` 的点击拦截改为共用该函数，两处口径不会再分叉。
  镶嵌限制不变：4 颗宝石的 `allowed_weapons` 只有 `gods_shield`，`equip_gem` / `can_equip_gem`
  都按它拦，其它武器的宝石插不进来。
- 巫毒研究所 8 张底图换成作者修复版，右侧补丁全部消失（2026-11-15，`spr_wuduyanjiusuo_0..7`）：
  用户在 `res\...\09跨服\巫毒研究所\` 下重新修了一版（`巫毒8星.png` … `巫毒15星.png`，8..15 星
  依次对应 `spr_wuduyanjiusuo_0..7`），把上一版残留的亮块补丁、错位棋盘格全部补齐成纯净格。
  替换走 `tools/wudu_bg_replace.py`：从各 `<名>.yy` 读帧 id / 图层 id，逐张写**两份**
  （`sprites/<名>/<帧id>.png` 与 `sprites/<名>/layers/<帧id>/<图层id>.png`，只写一份游戏里不变），
  源图统一转 RGB 后落盘；旧图备份在 `output/_tmp/bak_wudu_replace_20261115_161840`。
  复检 `tools/wudu_bg_replace_selfcheck.py` 全绿（两份一致、1108×597、RGB、与旧图差异 6.32%~14.68%）。
  **`bg_draw` 未动**：相位相关对 8 对图求整体位移全是 `(0, 0)`（peak 0.935~0.996）、
  梳状拟合的格距与相位差都在 ±4px 内，新图与原图同尺寸同相位，`{10.14, 8.89, 1.7866, 1.7901}`
  继续有效；`python tools/cross_bg_align.py --verify` 叠图网格线与美术格缝仍吻合。
  关卡卡片图标按索引读同名精灵（`obj_cross_server_bg/Draw_0`），换图后自动同步。
- 修「跨服所有地图格子错位」（2026-11-15，`tools/cross_bg_align.py` + 40 个跨服关卡 JSON）：
  引擎网格是写死的 `grid_offset_x/y = 695/228`、格 `107×116`（`obj_battle/Create_0:36-41`），
  底图由关卡 JSON 的 `bg_draw` 缩放绘制（`obj_battle/Draw_0:3-9`）。原生底图（`spr_salad_island_land`
  2005×1080，1:1 直绘）实测格缝 `X=698+107.3k`、`Y=199+115.9k`，即**美术格缝比引擎列线右 3px、
  行线高 29px**（`obj_bbq/Other_11` 记过同类位移）——这是原版美术与逻辑网格的既定关系。
  跨服半尺寸美术（1108×597）实测格距是 **60×64**（不是 107/2 × 116/2），手调 `bg_draw` 时把
  缩放和相位一起凑，结果六张底图全部偏：`zhuore` 美术低 33px、`shuihuo_0` 低 29、`shuihuo_1` 低 33、
  `wudu` 低 29、`nightmare_sky` 低 15 且 `sy=1.884` 逐行累到 40px；古堡 8 关根本没 `bg_draw`
  （1:1 直绘，美术格距 108.8×117.7），每列还再漂 1.8px。
  现在按「`sx = 107/美术格距`、`sy = 116/美术格距`，再把第一条美术格缝钉到原生关系
  `(698, 199) mod (107, 116)`」反解：castle `{12.14, 11.05, 0.9835, 0.9858}`、
  nightmare_sky `{13.2, 12.39, 1.7833, 1.78}`、zhuore `{18.55, 6.07, 1.7833, 1.8172}`、
  shuihuo_0..3 `{20.33, 12.31, 1.7833, 1.8125}`、shuihuo_4..7 `{20.86, 10.5, 1.7866, 1.8125}`、
  wudu `{10.14, 8.89, 1.7866, 1.7901}`（古堡 8 关是新增 `bg_draw` 键）。
  复检：把美术按新参数还原成 1920×1080 后取样，`shuihuo_0/4` 的 12/9 个岩浆格与 `map` 里
  `object:["lava"]` 的格子**逐格 100% 吻合**、`zhuore` 61/63（两格是边缘取样误差）；
  水火底图的蓝色水域带也正好压在第 2~4 行（与 `map[row][1].type == "water"` 一致）。
  以后改跨服底图不要再手调 x/y：跑 `python tools/cross_bg_align.py --verify` 出叠图、
  `--apply` 写回，`FAMILIES` 里改美术格距/首缝即可。
- 底图精确对齐后 `bg_draw` 不再负责铺满屏幕（四边露 10~20px），而战斗房
  `clearViewBackground = false`、露出来就是脏像素；`obj_battle/Draw_0` 先按 cover 比例用同一张图
  铺一层兜底再画精确对齐那份（2026-11-15）。
- 巫毒研究所：底图上的铁笼改成直接擦掉，风洞恢复原尺寸绘制（2026-11-15）：
  上一版是把 `obj_wind_tunnel` 缩到 1.53 去贴底图里画好的铁笼，缩放/位置都对不齐、还会
  盖住相邻行。现在把 8 张底图（`spr_wuduyanjiusuo_0..7`）里那 39 个铁笼全部 P 掉
  （`tools/wudu_erase_windtunnel.py`，原图备份在 `output/_tmp/bak_wuduyanjiusuo_*`），
  `obj_wind_tunnel/Create_0` 恢复 1.8 倍、只把 obj_battle 传入的 (x+5, y-35) 偏移抵消回格心。
  擦除走的是「跨图同位置拷贝」：8 张底图是同一套网格美术（同为 night），同一格在别的
  关卡里往往是干净的，直接按像素搬过来，连光照渐变都一致；只有 (row0,col8) 和
  (row6,col8) 两格每关都有笼，用同列/同行 ±2~4 格兜底。39 个笼全部找到干净源，
  `tools/wudu_erase_selfcheck.py` 复检：8 张图网格内金属像素 0、黑网 ≤40。
  注意精灵目录两套图（顶层合成图 + `layers/<帧>/<图层>.png`）必须同时写，只写 layers
  游戏里纹丝不动。
- 修「疾风龙魂」灰烬类冷却 -50% 不生效（2026-11-15，`hex_card_cooldown`）：
  灰烬类一次性卡（可乐炸弹 / 老鼠夹 / 辣椒粉…）没有 cycle，它们的「冷却」就是卡槽冷却，
  走的是 `hex_card_cooldown(raw_cooldown, card_id)`；而那个函数原来只乘
  `hex_batch2_id_cycle`（按卡 id 的专属倍率），按**分类**给的 `cat_cycle` 一条都读不到
  —— 所以疾风龙魂、明火（灰烬卡冷却 +80%）在实机上全是空转。现对灰烬类另外乘一次
  `hex_category_mult(card_id, "cat_cycle")`，但跳过轰炸型 / 持续型（巧克力大炮、榴莲、
  火龙果这些仍走 cycle 攻击，已在 `hex_cycle_mult_for_card` 里乘过，再乘就重复）。
- 修「低声耳环」每局结束加的星级不进合成屋、强化从 0 星开始（2026-11-15，`hex_b3_levelup_card`）：
  该词条只抬 `unlocked_cards[].level`，而合成屋 / 背包 / 转职槽画的星星与「当前星级」
  一律读 `max_level`（`transfer_credit_card_level` 的注释写明了这个口径）。
  `level` 涨了、`max_level` 还是 0 → 星星不显示，强化入口按 0 星起算。
  现两个字段一起抬（`max_level = max(max_level, 新等级)`），并把上限口径从
  「`min(岛屿上限, max_level)`」改成「岛屿上限」—— 原来 `max_level` 就是当前星级，
  拿它当上限会让第二次结算立刻判满级、原地不动。
  注：老存档里已被这条 bug 写成 0 星的卡，需要新开一局重新结算才会补上。
- 修正巫毒研究所 8 关的「风洞」贴图错位（2026-11-15，`obj_wind_tunnel/Create_0`）：
  底图 `spr_wuduyanjiusuo_0..7` 的美术已经把铁笼（风洞外观）画进地图，实测每个铁笼
  约 **147×170** 世界像素、中心在格心 **(+6, +2)**；而风洞特效默认按 `image_xscale/yscale = 1.8`
  （123×131 → 221×236 ≈ 2×2 格）绘制、且由 `obj_battle` 按 `map_object_init` 的
  `y_offset: -35` 上偏落位 → 特效铁笼比底图铁笼大一圈又上移，画面里出现「大网格 + 小铁笼」
  双层错位，且盖住相邻行。现按底图前缀 `spr_wuduyanjiusuo` 分支：位置回正到格心 (+6, +2)、
  缩放改为 1.53（精灵内容 97×109 → 148×167，正好覆盖底图铁笼）。
  原版 `macchiato_port` / `tower_cake_15_1/2`（底图没有画铁笼，特效自己当铁笼）保持 1.8 倍 + 上偏不变。
  水滴/其它章节若日后也给底图预画铁笼，照这个分支加前缀即可。
- 去掉情报岛敌人页重复的「垃圾车僵尸鼠」（2026-11-15，`mod_info_island_init`）：
  敌人页列表直接遍历 `global.enemy_id_list`，每调一次 `register_enemy_info_island` 就多一张卡，
  而灼热版 `kf_zr_garbage`（`enemy_info_island_init.gml:144`）与巫毒版 `kf_wd_garbage`
  （`mod_info_island_init.gml:153`）同名同数值，于是页面上出现两个一模一样的小卡片。
  现删掉后注册的巫毒版条目、在原位留注释说明取舍，保留先生效的灼热版。
  巫毒版敌人本体、`datafiles/level_data/cross/wudu_*.json` 的波次与
  `tools/shuihuo_wudu_levels.py` 的 `WD_LAND_ORDER` 都不受影响（只是不上情报岛）。
  「新内容」里那条「情报岛补注册 9 条」据此变 8 条。
- 修复星轨神满 4 张进入全屏后 5×5 范围框与全屏四角装饰重叠（2026-11-15，`obj_xinggui_god/Step_0`）：
  原来 `xg_halo.visible` 写死为 `true`（注释里当时的理由是「四角是另加的一层，海洋女神同理」），
  4 张终转星轨神就是 4 个 5×5 框 + 1 套四角全屏，屏幕上糊成一片。
  现改为「全屏生效时只保留四角特效」：Step 每帧只遍历一次 `obj_xinggui_god` 统计
  `_n_all` / `_max_shape`（与每张卡自己的 `_should_full` 同口径），得到 `_any_full`；
  光环按 `_any_full` 用 `image_alpha` 每帧 ±0.1（≈0.17 秒）渐变，淡到 ≤0.02 才 `visible = false`，
  恢复时先抬 alpha 再显形 —— 硬切 `visible` 会重演 2026-11-13 那次「光环突然消失 → 四角突然出现」
  被当成闪烁的问题。顺带把判定块里重复的 `with (obj_xinggui_god)` 统计删掉，共用外层结果。
- 修复 `obj_xiao_long_bao` 等 18 个直射卡在 Step 里抛「Unable to find any instance for object index」（2026-11-14）：
  根因是 `scripts/combat_targets` 把实例 id 当「一定活着」用。① `combat_enemy_in_rows` 的跨帧缓存
  `_card.combat_row_target` 在目标被其它子弹打死后没有存活校验，下一帧直接 `with (过期 id)`，
  GM 会把该 id 当对象索引解析并报错（实测 101063）；② `combat_targets_row` 的行桶是「本 step
  首次调用时」的快照，同一 step 内后续被击杀的敌人仍留在数组里，因此 `combat_enemy_in_rows` /
  `combat_enemy_nearest_in_row` 的 `with (_candidates[i])` 有同样风险。
  修法：三处在 `with` 之前补 `instance_exists(x) && !object_exists(x)`（`instance_exists` 对对象索引
  恒为 true，必须两条一起判才排得干净，写法同 `precise_bbox_collision` 里的 `bullet_sap_type_list`）。
- 补上「行桶候选」的残留口子（2026-11-15）：`combat_enemy_nearest_in_row` 与 `combat_enemy_find_plant`
  的候选判定当时只写了 `instance_exists` 单判，与上一条定的双判口径不一致 —— 投手类卡片
  （`obj_egg_boiler_pult/Step_0:16`）在行桶快照之后、同 step 内目标被别的子弹打死时，`with` 依旧抛
  「Unable to find instance for object index」（堆栈落在 `combat_enemy_nearest_in_row`，行号报 -1）。
  现抽出 `scripts/combat_targets` 的 `combat_target_alive(_inst)`（= `instance_exists && !object_exists`），
  四处 `with` / 点访问前置统一改走它，后续新增索敌函数直接用这个 helper，不要再各写各的。
- 元素蛇三张卡的商城描述补上命中口径（2026-11-14）：`mod_shop_init` 里「…发射1发带不同效果的穿透子弹…」
  改为与卡槽 / 情报岛一致的「可穿过障碍物但不穿透老鼠」。至此四处玩家可见文案
  （卡面 `mod_cards_init`、卡槽 `mod_slots_init`、情报岛 `mod_info_island_init`、商城 `mod_shop_init`）
  口径统一 —— 穿透指的是**弹道穿障碍**，命中第一只老鼠即消散，不再让玩家误以为子弹会穿透老鼠。
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
