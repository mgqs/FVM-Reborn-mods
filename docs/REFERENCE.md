# REFERENCE.md — 细节参考（用到再读）

> 本文件是 `AGENTS.md` 的**离体细节**：这些内容重要但不必常驻上下文，所以从契约正文拆出，省掉每次会话的整读成本。
> **怎么用**：`AGENTS.md` §0.0 三跳协议 → `INDEX.md`（主题 → 文件:行）→ 本文件对应小节 → 需要行号时 `tools/lookup.ps1 <名字>`。
> **维护**：`AGENTS.md` 只留决策与指针；具体表、字段、行号、例外清单写这里。两边不要出现同一段落的两个版本。

---

## 经济 / 养成线（商店·材料·技能·强化·进化·融合·转职）

| 表 | key | 位置 | 备注 |
|---|---|---|---|
| 商品 `global.goods_map` / `goods_id_pool` | goods_id | `scripts/goods_registry`；注册在 `shop_init` + `mod_shop_init` | 字段 type(card/item/weapon/gem/*_attire/credit/camp)、`cost` 是**字符串金币**、unlock_item_id、display_name |
| 材料 `material_pool` | material_id | `scripts/material_registry` + `material_init`（16 种） | **数量不在池里**，存 `save_data.inventory[{id, amount}]`（`scripts/inventory`） |
| 技能 `global.skill_registry` | card_id → `[属性名, [0..8]]` | `scripts/card_skill` + `skill_init` + `mod_skill_init` | 下标即技能等级；上限走 `unlocked_items.max_skill_level` |
| 武器 `weapon_pool` / 宝石 `gems_pool` | weapon_id / gem_id | `weapons_init` + `mod_weapons_init` | `atk_impact` 等必须是 **16 项**（宝石 0..15） |
| 诸神 `gods_goods_map` | goods_id | `gods_shop_init` | type evo / tvoucher |
| 强化 / 融合 / 进化 / 转职 | 表 key = 卡 id 或档位 | `craft_rule_init`、`mod_craft_fusion_table`、`mod_craft_evo_table`、`mod_craft_transfer_table` | 转职是**函数**不是表（`mod_tg_*`），保底 `global.tg_pity` 不落盘 |

- 货币：金币 = `save_data.player.gold`（唯一硬通货）；威望 = 材料 `"prestige"`，走 `add_material_amount("prestige", ±n)`；其余（四叶草 / 香料 / 水晶 / 徽章 / 补给币 / 神谕之石）都是 material id，**没有独立的水晶货币**。
- 注册语义差异（常踩）：`register_material` 用 `ds_map_add` → **重复注册静默失败**；`register_goods` 用 `ds_map_set` → **可覆盖**，改价/改文案靠它；`register_card_skill` 只在 key 不存在时写入 → 对 `skill_init` 已注册的卡，`mod_skill_init` 的改写**完全无效**。
- UI 挂载：`obj_shop_bg/Create_0.gml:78` 起按 `goods_map` 建按钮，每页 16 格（营地 4×3 = 12）；跨服覆写过 `cost` 的商品必须进 `cross_server_exchange_ids` 剔除名单，否则普通商店会按金币重复卖；credit 类商品缺 `display_name` 会在建按钮时崩（表现为「某页打不开」）。
- 行号级细节 + 13 条坑：`.workbuddy/memory/topics/economy-craft.md`。

---

## 情报岛与海克斯（文案 · 拼音 · 乘区）

- **文案替换链**：`scripts/mod_info_island_text`。`info_island_text_render`(:185) 扫 `{…}` → `info_island_text_eval`(:132) 手写求值（**四则运算从左到右、无优先级**，空格/换行全跳过；除零或 undefined 原样吐回 `{…}`）→ 变量来自 `info_island_text_vars`(:26)（`get_plant_data_with_skill` + `custom` 按星级覆盖 + 跨形态兜底）。老卡（`scripts/info_island_init`）用 `[攻击力]`，**不替换**。
- **折行**：`scripts/card_info_island_registry` 的 `info_island_wrap(text, 35)` 是唯一入口（面板 `draw_text_ext` 宽 300px、行距 30）。**换行不能落进 `{}` 里**（eval 跳空白，会整段拼回一行）。
- **拼音搜索**：`scripts/mod_info_island_pinyin`（848 行，6763 字 GB2312 表 `py_char_table` :17，别手改；重生成 `tools/gen_info_island_pinyin.py`）。搜索词法在 `scripts/mod_info_island_search`（空格 = 且，`|`/`或`/逗号 = 或，`[ ]` 只是分类标记）。
- **海克斯三乘区**：`hex_apply_core`(hex_core.gml:346) 累乘 → `hex_sync_globals`(:298) 夹逼成 `global.hex_mult`（atk 0.25~8.0 / cycle 0.30~3.0 / hp 0.25~5.0；非海克斯模式恒 1.0）→ `hex_atk/cycle/hp_mult_for_card`(:795/:815/:828) → 落点 `obj_mod_battle_manager/Step_0.gml:282/:328/:342`。词条总数 243（`HEX_EXPECTED_TOTAL`，hex_core.gml:14 自检）。
- **增幅分组**：`scripts/card_buff_category` 的 `card_category_data`(:38) 定义分类 → `mod_apply_category_buff_map`(:345) 写 `global.plant_buff_map`（主类型）+ `plant_buff_map_2`（副类型，结算取高）→ `mod_get_buff_type` → `apply_buff` 写 `global.buff_grid`。**改分组后要检查后写循环是否覆盖你写的例外**（`cold_drew` 必须写在「散点追踪」循环之后）。
- 行号级细节与 12 条原话级坑：`.workbuddy/memory/topics/info-island-hex.md`。

---

## 新卡先找同类：19 类卡对照表 + 共用骨架

**规则**：动手做一张新卡之前，先回答「它属于哪一类」，然后**照同类现有卡的实现抄结构**，只改数值与精灵。不要凭空发明一套骨架——本工程 212 张卡的分化方式是"同一骨架 + 不同出弹时机"，不是 212 套架构。

**分类的唯一数据源**（`docs/卡片分类.md` 已丢失，这是仅存版本）：`scripts/card_buff_category/card_buff_category.gml` 的 `card_category_data()`（:41-:252，212 张卡，三级：大分类 / 小分类 / 子分类）。

查同类（先 `card_category_init()`，`obj_mod_manager` 里已调）：

```
card_get_category(id)            // :268 → {major, minor, sub}，未注册 undefined
get_cards_in_category("喷壶类")   // :315 → ds_list（分类名可填任一级）
card_in_category(id, "投掷类")    // :304 → bool
card_get_major/minor/sub(id)     // :280/:286/:294
```

**对照表：要做这类卡，就打开这个对象抄**

| 大分类 | 代表卡 → 对象 | 照抄哪几行 |
|---|---|---|
| 直射类·传统直线 | `double_long_bao` → `obj_double_long_bao` | Create:13 `attack_anim = 11`；Step:22-24 两段窗口；Step:32 `attack_timer == cycle - 4*flash_speed` 出弹 |
| 直射类·过火穿透 | `houyi_god` → `obj_houyi_god` | Step:33-36 `_spd = min(current_flash_speed, max(1, floor(cycle / attack_anim)))` —— **cycle 被压小后压缩动画窗口的标准写法** |
| 直射类·固定轨迹 | `huagao` → `obj_huagao` | Create:8 `feature_type = "lava"`；Step:8 自有 `huagao_timer`；Step:23 `huagao_bullet_sprite(shape)` |
| 投掷类·单线/多线 | `egg_boiler_pult` → `obj_egg_boiler_pult` | Step:36-44 三段窗口，多形态用 `shape == 2` 分支加发 |
| 投掷类·灼烧 | `lizi_god` → `obj_lizi_god` | Create:21-23 首发起手对齐（`cycle-75`）；Step:58 `_fi = min(attack_timer div current_flash_speed, attack_anim-1)`；Step:62 脱手帧 |
| 多向类·海星 | `coal_starfish` → `obj_coal_starfish` | Step:76-77 `_fire_frame = (shape >= 2) ? 15 : 21` + `state == CARD_STATE.ATTACK && !fired_this_attack` |
| 增幅类 | `xiangshui_god` → `obj_xiangshui_god` | Create:14 `attack_anim = 0`、:23 `buff_value = atk / 100`、:27 `buff_shape = "5x5"`；Step:6-12 `refresh_buff_cells()` + `global.buff_dirty = true` |
| 产能类 | `small_fire` → `obj_small_fire` | Step:16 `first_produce_delay`；Step:28-30 产火窗口 |
| 辅助类·承载 | `wooden_plate` → `obj_wooden_plate` | Create:13 `attack_anim = 0`、:16 `plant_type = "lilypad"` |
| 辅助类·种卡 | `magic_chicken` → `obj_magic_chicken` | Step:73-77 复制 `card_slot_data` 的 plant_type/feature_type + `can_copy_card_at_position` + `external_mod_spawn` |
| 辅助类·地形/反弹 | `oil_lamp` / `cherry_pudding` | Step 几乎只有 `event_inherited()`，真实逻辑在 `Other_11`/`Destroy_0` —— 别以为 Step 短就是没实现 |
| 防御类·面包 | `mianbao` → `obj_mianbao` | Create:7 只有 hp 归零才炸；Step:21 `bullet_damage`；Step:92-93 每帧实时读 `upgrade_data[? "cycle"]`；自带 `obj_mianbao_bullet` |
| 专业防空类 | `tang_hu_lu` → `obj_tang_hu_lu` | Step:32 / :35 双出弹点（`shape == 2` 追发一发） |
| 喷壶类·旋转/直线 | `coffee_pot` → `obj_coffee_pot` | Step:52-58 `attack_timer == cycle - (attack_anim-3) * flash_speed` 出弹 |
| 追踪类 | `takoyaki` / `cold_drew` | takoyaki Step:33 标准窗口；cold_drew Step:14-16 自有 `cooldown`、:69 `cooldown = cycle - attack_timer` 反向补冷却 |
| 非远程类·吞噬 | `hamburger` → `obj_hamburger` | Step:37/:43 自有 `relax_timer`；:58-73 咬合动画 |
| 灰烬类·瞬发/触发 | `coke_bomb` / `mouse_clip` | Step:12/:15 `cycle = upgrade_data[? "cycle"]`（二转 ×2）；:28 攻击帧推移；:57/:64 `calculate_plant_depth(...)`；mouse_clip:84 `attack_timer == cycle` 触发 |
| 灰烬类·持续 | `durian` → `obj_durian` | Create:31-33 `max_time = cycle; cycle = 60`（把攻击间隔当存活时间用） |
| 灰烬类·冲撞 | `baiyang` → `obj_baiyang` | Create:5 `spawned = false`；Step:6-8 一次性冲撞 |

**所有卡共用的骨架**（新卡必须遵守）：
- Create 第一行 `event_inherited()`，继承 `obj_card_parent`；只设 `attack_anim`（攻击动画帧数）、`plant_type`（`normal` 占地 / `lilypad` 承载 / `coffee` 种卡 / `gridless` 不占格）、`feature_type`（`lava` 可放岩浆 / `low` 低位）。
- 出弹一律在 Step 里按 `attack_timer` 窗口判断，不自己开计时器（除非该类本来就是自有计时器：`huagao_timer` / `relax_timer` / `cooldown`）。
- 深度一律 `calculate_plant_depth(grid_col, grid_row, plant_type)`，别手写。

**新卡自检四问（做完必答）**：
1. **出弹帧还在窗口里吗？** cycle 会被技能等级/攻速词条压小 → 抄 `houyi_god` 的 `_spd` 压缩，或给对象 `Create_0.gml` 置 `uses_fire_frame = true`（走 `obj_card_parent/Step_0.gml` 的 `_anim_flash` 兜底）。
2. **`attack_anim` 等于动画实际帧数吗？** 取值要"比实际少 1"才能完整播到最后一帧（见 `obj_huagao/Create_0.gml:14-15` 注释）。
3. **吃增幅的卡挂上名字了吗？** 必须在 `mod_apply_category_buff_map`（`card_buff_category.gml:345`）的 `_allowed` 名单（:367-374）或 `plant_buff_map_2` 副类型（:391/:407/:415/:418/:422）里出现，否则分类增幅一点也吃不到。
4. **分类表加了自己这一行吗？** 不加 → `card_in_category` 全 false → 所有按分类结算的增幅/词条/海克斯全部落空。改分类结构后必须同步刷新 `card_category_data()`，它是唯一数据源。
