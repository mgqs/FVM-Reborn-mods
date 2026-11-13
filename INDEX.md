# INDEX.md — 一页索引（主题 → 位置）

> 用途：**省掉全仓扫描**。先在这里找主题，再 `tools/lookup.ps1 <名字>`，最后 `read` 带 `offset/limit` 只看那一段。
> 规则：一行一个主题；只写「去哪个文件的哪一行」；细节不写在这里（细节在 `.workbuddy/memory/topics/`）。
> 维护：新增事实源时同步加一行；地址失效时改地址，不要删行。

| 主题 | 位置 | 说明 |
|---|---|---|
| 全局初始化（版本号、config.ini、快捷键、授权门） | `objects/obj_game_init/Create_0.gml` | 248 行，启动第一站 |
| 基础注册表（商店/材料/技能底座） | `objects/obj_game_init/Other_2.gml` | 在 mod_* 之前跑 |
| Mod 注册总入口（23 个 init 的顺序） | `objects/obj_mod_manager/Create_0.gml` | 顺序有依赖，别重排 |
| **卡片数值**（hp/cost/atk/range/cooldown/cycle） | `scripts/mod_cards_init/mod_cards_init.gml` | 4885 行，唯一生效源 |
| 卡片槽位显示（背包里看到的描述） | `scripts/mod_slots_init/mod_slots_init.gml` | 只显示，无 atk 字段 |
| 卡片情报岛文案 | `scripts/mod_info_island_init/mod_info_island_init.gml` | 215 个 register 调用点 |
| 卡片技能覆盖（0~8 级） | `scripts/mod_skill_init/mod_skill_init.gml` | 只对未注册的 key 生效 |
| 卡片分类（212 张，三级） | `scripts/card_buff_category/card_buff_category.gml:41-252` | `card_get_category` :268 |
| 分类增幅落点（主/副类型） | `scripts/card_buff_category/card_buff_category.gml:345` | `_allowed` 名单 :367-374 |
| 卡面骨架/出弹时机 | `objects/obj_card_parent/Step_0.gml` | `_anim_flash` 出弹兜底 :274-290 |
| 敌人表（12 字段） | `scripts/enemy_registry/enemy_registry.gml` | `register_enemy` 用 ds_map_add |
| BOSS 血条表 | `scripts/boss_registry/boss_registry.gml` | 只有 name/hp/icon |
| 敌人图鉴文案 | `scripts/enemy_info_island_registry` | 35 字折行 |
| 普通鼠生成 | `objects/obj_battle/Create_0.gml` | 组波循环 → `hex_enemy_scale()` |
| BOSS 生成 | `objects/obj_battle/Step_2.gml` | 手写 create，漏 hex 缩放 |
| 关卡 JSON（314 个） | `datafiles/level_data/**` | 见下「关卡目录」 |
| 地图注册（本体 8 张） | `scripts/maps_init/maps_init.gml` | :3 龙渊 … :1817 探险营地 |
| 地图注册（跨服 3 张） | `scripts/mod_maps_init/mod_maps_init.gml` | :3 / :106 / :213 |
| 跨服判定 + 奖励 | `scripts/cross_server_level_index/cross_server_level_index.gml` | :5 索引 / :35 奖励 |
| 战斗倍率终值 | `objects/obj_mod_battle_manager/Step_0.gml` | `buff_multiplier` |
| 海克斯累乘与夹逼 | `scripts/hex_core/hex_core.gml:346` / `:298` | 三乘区 0.25~8.0 / 0.30~3.0 / 0.25~5.0 |
| 存档结构（含迁移） | `scripts/load_file/load_file.gml` | `reset_file` :212 |
| 存档写入 | `scripts/save_file/save_file.gml` | `json_stringify` |
| 网格与列域 | `scripts/combat_bounds/combat_bounds.gml` | :24~:76 九个函数 |
| 商店 UI 构建 | `objects/obj_shop_bg/Create_0.gml:78` | 每页 16 格 |
| 结算发奖 / 抬级 | `objects/obj_battle_pause_manager/Step_2.gml:158` | 只用 `rewards[1]` |
| 外部 Mod API v1 | `scripts/external_mod_system/external_mod_system.gml` | 720 行 |
| 字体字形表 | `fonts/<n>/<n>.yy` 的 `"character"` | 补字走 `tools/font_fill.py` |
| 工具链 | `tools/` | 约 130 个脚本 |
| 契约体检 | `tools/check_contract.ps1` | 打印 sha256 + 记忆档案在位 |
| 一次定位一个名字 | `tools/lookup.ps1 <名字>` | 内部走 `rg`，0.15~0.3 s 出全部触点 |
| 全文搜索 / 列文件 | `rg`（`%LOCALAPPDATA%\fvm-tools\rg.exe`，已在用户 PATH） | 全仓列 gml：`rg --files -g "*.gml" -g "!{sprites,sounds,fonts}/**" .`（162 ms）；全仓搜词：`rg -n -F "<词>" -g "*.gml" -g "*.json" -g "*.md" -g "!{sprites,sounds,fonts,tilesets,shaders}/**" .`（181 ms）；单点：`rg -n -F "<名字>" objects scripts datafiles`（154 ms） |
| 犯错日志 | `MISTAKES.md` | 动手前扫速查表 |
| 经济/养成线全表 · 情报岛与海克斯 · 19 类卡对照表 | `docs/REFERENCE.md` | 从 AGENTS.md 拆出的离体细节 |
| 细节档案 | `.workbuddy/memory/topics/*.md` | 9 份，按主题 |

## 关卡目录（`datafiles/level_data/`）

根 34 个、`tower/` 142、`volcanic/` 48、`floating/` 30、`cross/` 24、`undersea/` 18、`camp/` 12、`longyuan/` 6 = **314**。

## 事件文件命名（对象内，省掉 ls）

`Create_0.gml` / `Step_0.gml` / `Step_1.gml` / `Step_2.gml` / `Draw_0.gml` / `Draw_64.gml` / `Other_4.gml` / `Other_10.gml` / `Other_11.gml` / `CleanUp_0.gml` / `Destroy_0.gml` / `Alarm_0.gml` / `Mouse_4.gml`。
