# AGENTS.md — FVM-Reborn-mod 工程契约

> 本文件是本仓库的**底层规则**：任何 agent（含 DSH / IDE 助手 / 未来的我）在动这个工程之前先读完本文。
> 它回答三件事：**改这个需求该动哪个文件**、**改的时候有哪些不能碰的红线**、**改完怎么验证**。
> 细节档案在 `docs/REFERENCE.md`（入库，按需读）与 `.workbuddy/memory/topics/`（本地，不入库）；本文只放"必须常驻上下文"的契约与会话入口。

---

## 0.0 开场确认（强制）

**任何 agent 在本仓库开始动作之前，必须先用 `read` 工具读本文件的四个核心区：§0.0 / §0 / §1 / §4**（约 6 KB；其余章节与 `docs/REFERENCE.md` 按需再读，不要整份重扫）—— 不许凭记忆、凭注入片段、凭文件名作答；读完后第一条回复以这一行开头：

> 已读取 AGENTS.md（<实测行数> 行 / <实测字节> B，UTF-8 无 BOM）— 本次遵守 §1 铁律与 §4 唯一事实源

- 行数用 `read` 工具返回或 LF 计数，字节用 `(Get-Item AGENTS.md).Length` 实测；数字随文件更新变化，**不要照抄任何示例**。
- 不要用 `pwsh Get-Content` 数行：多字节内容下会数错（283 行曾被数成 171 行）。
- 任务涉及数值 / 关卡 / 敌人时，紧跟一行：`触点：<按 §4 / §10 定位到的文件>。`
- 想省事就跑 `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_contract.ps1`：它打印「已读取 AGENTS.md（N 行 / N B，UTF-8 无 BOM）」+ sha256 指纹 + 记忆档案在位情况，把那行原样贴进回复即完成确认。
- 最后一步：扫一遍仓库根 `MISTAKES.md` 的速查表。命中症状就照「立刻改成这样」执行，别重新推理；本轮若又走了错路，收工前必须往那里追加一条（规则见 §1.5）。
- **跳读协议（省时间，别整份重扫）**：`check_contract.ps1 -Quiet` 输出的 sha256 与上一轮相同 → 契约没变，**不要 `read` 全文**，只按需读章节；sha 变了才整读。
- **三跳定位**：`INDEX.md`（主题 → 文件:行）→ `tools/lookup.ps1 <名字>`（内部走 `rg`，一次吐全部触点）→ `read` 带 `offset/limit` 只看那一段；清单外的名字直接 `rg -n -F "<名字>" objects scripts datafiles`。
- **找文件一律用 `rg`（已装），禁止 `pwsh Get-ChildItem -Recurse`**：全仓 `*.gml` 递归实测 **15.8~21.7 秒/次**；`rg` 限定目录只要 **0.06~0.31 秒**。`rg` = ripgrep 15.2.0：主副本 `%LOCALAPPDATA%\fvm-tools\rg.exe`（已写入用户 PATH），另在 `%LOCALAPPDATA%\Microsoft\WindowsApps\rg.exe` 放了一份（该目录本来就在 PATH 里，所以本机任意 shell 直接 `rg` 可用；仍找不到就用绝对路径）。
  - **列全部 `.gml`（全仓，最快写法）**：`rg --files -g "*.gml" -g "!{sprites,sounds,fonts}/**" .` → **162 ms / 3970 个**；再快一点就点名目录 `rg --files -g "*.gml" objects scripts rooms datafiles tools extensions .dsh` → **104 ms**。
  - **全仓搜中文 / 任意词（最快写法）**：`rg -n -F "<词>" -g "*.gml" -g "*.json" -g "*.md" -g "!{sprites,sounds,fonts,tilesets,shaders}/**" .` → **181 ms**；只要代码就 `rg -n -F "<词>" objects scripts datafiles` → **154 ms**。要后顾/断言再加 `--pcre2`。
  - **两条必须同时满足，少一条就慢十倍**（实测见 `MISTAKES.md` A13）：
    1. **排除大目录**（`sprites/` `sounds/` `fonts/` `tilesets/` `shaders/`，用 `-g "!{a,b,c}/**"`）—— 这是**剪枝**，匹配到目录就不再进去；本工程 18 万个文件里 `sprites/` 占绝大多数。
    2. **文本类型白名单**（`-g "*.gml" -g "*.json" -g "*.md"`）—— 否则会去读 `.png/.ogg/.yy/.yyp` 等，白白多花 2 秒。
  - **反例（别这么写）**：`rg --files -g "*.gml" .` 单用白名单 **1232 ms**（白名单不剪枝，仍要进 3903 个精灵目录）；`rg -n -F "丰饶" -g "!sprites/**" -g "!*.png" .` 不加文本白名单 **2232 ms**。慢的原因都不是匹配，是遍历和读二进制。
  - 名单外的单点查询优先用 `tools/lookup.ps1 <名字>`（一次吐卡片/槽位/情报岛/分类/对象/精灵全部触点，1.1~1.4 s，含 PowerShell 启动开销）。
  - 按命名规则直接拼路径仍是 0 秒：`objects/<名>/<名>.yy`、`scripts/<名>/<名>.gml`。
- **路径公式**：对象 = `objects/<名>/<名>.yy` + 事件文件（`Create_0` / `Step_0` / `Step_2` / `Draw_0` / `Other_N` / `Destroy_0` / `CleanUp_0`）；脚本 = `scripts/<名>/<名>.gml`；精灵帧 = `sprites/<名>/layers/<frameId>/<layerId>.png`。
- 等价入口：项目技能 `fvm-project-contract`（`.dsh/skills/fvm-project-contract/SKILL.md`）把「读文件 → 回报确认 → 按 §4 定位 → verify_gml」固化成流程，加载它即可。

---

## 0. 三十秒上手

- 工程根：`D:\gameProject\FVM-Reborn-mod`，主工程文件 `FVM_Reborn_makk.yyp`。
- GameMaker Studio 2 工程（GML），Godot/Unity 那套概念在这里不适用；**没有构建脚本产物**，全部逻辑即源码。
- 当前分支 `mods`，是《美食大战老鼠：重生》的 mod 分支；`global.game_version = "3.0.2.15"`（`objects/obj_game_init/Create_0.gml:48`）。
- 规模（2026-11-13 实测）：**1142** objects / **276** scripts / **3903** sprites / **7** rooms / **5990** 个 `.gml`（约 **28.9 万行**、10 MB）；关卡 JSON **314** 个（`datafiles/level_data` 递归：根 34 + `tower/` 142 + `volcanic/` 48 + `floating/` 30 + `cross/` 24 + `undersea/` 18 + `camp/` 12 + `longyuan/` 6）。
- 改动前的固定动作：`read` 目标文件（UTF-8）→ 判断它属于哪套注册表（见 §4）→ 改 → 跑 `tools/verify_gml.ps1` → 更新 `CHANGELOG.md`。
- **做新卡先找同类**：先查 §10.1 的分类对照表，照同类现有卡的 Create/Step 骨架抄，只改数值与精灵。
- **先索引后开文件**：`INDEX.md`（主题 → 文件:行）是入口；查一个名字用 `tools/lookup.ps1 <名字>`（内部走 `rg`）；清单外直接 `rg -n -F "<名字>" objects scripts`（0.14 s）。
- **踩过的坑不再重踩**：动手前扫 `MISTAKES.md` 速查表；它记的是"当时的错路"，命中就照正确路径走（详见 §1.5）。
- **与用户对话一律简体中文**（标识符、路径、命令、日志原文保持原样，见 §1.6）。
- **禁止**用 `pwsh Get-Content` 读含中文的 `.gml`（管道按 GBK 解码，会得到 `娉℃鏄ョ瑡` 这类乱码）。用 `read` / `grep` 工具，或 `[System.IO.File]::ReadAllText($p,[Text.Encoding]::UTF8)`。

---

## 1. 铁律（触碰即出错，已多次踩坑）

### 1.1 编码与格式

| 项 | 规则 |
|---|---|
| `.gml` / `.yy` / `.yyp` / `.json` / `.md` | **UTF-8 无 BOM**，LF 换行（`.gitattributes` 强制 `eol=lf`） |
| `.ps1` | **必须带 BOM**（否则 pwsh 5.1 按 ANSI 解码，中文注释变乱码） |
| `.yy` / `.yyp` | 允许尾逗号，标准 `json.loads` 会失败；读取前正则 `,(\s*[}\]])` 去掉尾逗号。偶发 `UNKNOWN: unknown error, open ...` 是 IDE 占用，重试一次 |
| 缩进 | 跟随目标文件的既有风格（老文件 4 空格、`mod_*` 表用 Tab）。**不要整文件重排**，diff 会污染 review |
| 编号/版本 | `CHANGELOG.md` 最新版置顶，格式 `# vX.Y.Z` + `## 新内容` / `## 优化与修复`，条目式中文 |

### 1.2 验证（改完必跑）

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\verify_gml.ps1 <文件或目录>
```

校验内容：BOM 规则、括号配平（先剔除 `//`、`/* */`、字符串字面量再数括号）、字节数、行数。只输出 FAIL 行时加 `-Quiet`。
`tools/verify_gml.ps1` 头部注释写的是「对应 AGENTS.md §1.2：编辑后必跑」——即本节。

### 1.3 GML 语言红线（高频翻车点）

1. **自定义速度不要叫 `speed`**。内置 `speed` 每帧按 `direction` 自动位移，叠加后会「右移 2N / 左移 0 / 下坠右漂」。用 `huagao_speed` 之类私有名，并在 Create 里 `speed = 0; hspeed = 0; vspeed = 0;`。
2. **三元运算符只能一层**。三档以上写 `if (x >= t2) return 3;` 顺序判断。
3. **数组引用不回写**：`var _l = global.save_data.xxx; array_push(_l, v)` 不会写回 `global.save_data`。直接操作 `global.save_data.xxx`。
4. **函数少传参 = GM1020**（报在调用行）。补参数时**不要改签名**，新增一个入口函数（例：`hex_enemy_scale` / `hex_enemy_scale_boss` 共用内部 `_apply`）。
5. **结构体字段别撞内置常量**。`_s.pi = x` → GM1031；读取时静默取 3.14159，只有赋值才炸。用 `pi_value`。
6. **孤儿事件文件**：`objects/x/Draw_0.gml` 存在但 `x.yy` 的 `eventList` 没有 `eventType: 8` → 该文件永不执行（`obj_12yinliao_effect` 踩过）。补事件后必须自己 `draw_self()` 兜底。
7. **值可能未定义时别直接乘**：`undefined` 参与乘法静默变 0，比报错难查。见 `obj_mod_manager/Create_0.gml` 里一排 `global.hex_mult = {atk: 1.0, ...}` 默认值。
8. **实例变量可能不存在时**先用 `variable_instance_exists(id, "xxx")` 判断，再读（`obj_card_parent/Step_0.gml` 的 `uses_fire_frame` 就是这个写法）。
9. **星级 shape 不能在实例层改**：`obj_card_parent/Other_10` 每帧按存档重建 shape。
10. **全屏列表/面板**用 `surface_create(view_w, view_h)` 裁剪，并在 `CleanUp` 里 `surface_free`。
11. **索敌/命中列**一律走 `scripts/combat_bounds`：`combat_cell_in` / `combat_right_x` / `combat_map_col_in` / `combat_last_col_x`。地图域 9 列（col 0..8），战斗域多一个第 10 列，硬编码列号必错。
12. 网格常量：`grid_offset_x = 695`、`grid_offset_y = 228`、`cell = 107×116`；生成点 = 格心 `+30, +38`。

### 1.4 资源注册三处（新增对象/精灵）

1. `objects/<名>/<名>.yy`（或 `sprites/<名>/`）；
2. `FVM_Reborn_makk.yyp` 的 `resources` / `Folders`；
3. `folders/**/*.yy` 的 `listItems`（每个文件夹 `.yy` 的最后一项不带尾逗号）。

**GameMaker IDE 开着会抢写 `.yyp`**：外部脚本加进去的条目会被 IDE 的一次保存抹掉。自检报「yyp 未注册」时重跑注册脚本即可（脚本按 `path` 去重、只增不删）。整理文件夹结构用 `generate_folders.ps1`。

### 1.5 错题本（动手前先扫，出错后必记）

- **位置**：仓库根 `MISTAKES.md`（入库，参与 grep）。分区：A 工具与环境 / B 判断与定位 / C 机制与数值 / D 契约与流程；文件开头是速查表（动作或症状 → 立刻改成这样 → 条目号）。
- **动手前**：扫速查表。命中就照「立刻改成这样」执行，**不要重新推理**——重推理大概率再踩一次。
- **出错后**：当场在 `MISTAKES.md` 对应分区追加一条，用文件末尾的模板：`症状 / 错路 / 正确路径 / 证据`。同期在 `.workbuddy/memory/YYYY-MM-DD.md` 记现场。**错题本不进 CHANGELOG**（它记录的是错误路径，不是交付内容）。
- **什么算一条错**：① 用户纠正了你；② 改了文件却没生效（改错副本 / 漏事件表 / 漏解析分支）；③ 同一个动作做了两遍才成（工具用法错）；④ 验证漏做导致返工；⑤ 编译或断言错误源于自己的操作方式。
- **写法红线**：只写能被下一个人直接执行的路径；禁止感想、"下次注意"、无证据的推测；每条必须带 `文件:行` 或 `YYYY-MM-DD 日志` 证据。
- **交付前自检**：问一句"这轮有没有走错路"，有就记，没有就不写（不要为了凑数造条目）。

### 1.6 输出语言（与用户对话一律中文）

- **面向用户的一切文字用简体中文**：回复、解释、总结、表格表头、清单条目、报错说明、变更描述、提交说明，全部中文。
- **保持原样的只有标识符与技术值**：文件路径、函数名、变量名、命令、标志参数、日志原文、报错原文、代码块内容。不要翻译它们，也不要为了"全中文"把它们改写成中文说法。
- **不要中英混排成句**：写「用 `rg` 搜索」而不是「用 rg search 一下」；写「耗时 162 毫秒」而不是「162 ms 的性能」这类整句英文。单位符号（`ms`、`B`、`KB`）跟在数字后可以保留。
- **表格、标题、清单**同样中文；英文只出现在标识符列。
- 代码注释按目标文件既有语言，不要为了本条把已有英文注释改成中文。

---

## 2. 目录地图

| 路径 | 是什么 | 备注 |
|---|---|---|
| `FVM_Reborn_makk.yyp` | 工程清单：资源、房间顺序、纹理组、配置 | 816 KB；`*.yyp.bak*` 是一堆历史备份，别当源码用 |
| `FVM_Reborn_makk.resource_order` | IDE 里的资源排序 | 生成物 |
| `objects/` | 1142 个对象，每个目录 = `<名>.yy` + `<事件>.gml` | 见 §3 家族前缀 |
| `scripts/` | 276 个脚本，每个目录 = `<名>.gml`（函数集合） | 见 §4 事实源表 |
| `rooms/` | 7 个房间：`room_init` `room_menu` `room_map` `room_tower_cake` `room_laboratory` `room_ready` `room_battle` | 顺序即 `RoomOrderNodes` |
| `datafiles/` | 运行时打包数据：`level_data/`（关卡 JSON）、`boss_music_pack/`、`laboratory/`、`native/`（7z.dll、FvmNativeSupport.dll 副本） | 关卡数值改这里 |
| `sprites/` `sounds/` `fonts/` `shaders/` `tilesets/` `notes/` | 标准 GameMaker 资源目录 | 字体见 §7 |
| `extensions/` | `TextureEncode`（astcenc/bc7enc）、`WindowsNative`（`FvmNativeSupport.dll`、`7z.dll`） | 原生接口 |
| `FvmNativeSupport/` | C++ 源码工程（`FvmNativeSupport.slnx`、`.vcxproj`，x64/x86，Debug 配置映射到 Release） | 改 DLL 才动 |
| `tools/` | 约 130 个 Python/PowerShell 工具：资源生成、BOSS 流水线、字体、精灵核对、数值模拟、yyp 操作 | 见 §8 |
| `docs/` | **目前为空目录** | 多处代码注释引用 `docs/*.md`，那些文档已丢失；新文档请落这里并索引到本文件 |
| `.workbuddy/` | 本地记忆与反编译资料（**被 `.gitignore:64` 忽略，不入库**） | `memory/MEMORY.md`、`memory/topics/`、`memory/YYYY-MM-DD.md`、`utmt/`（UTMT 反编译 dump） |

对象名家族前缀（数量前 20）：`obj_kuafu` 44（跨服）、`obj_infected` 35（变异）、`obj_kf` 33、`obj_ly` 29（龙渊）、`obj_mouse` 21、`obj_gods` 18（诸神）、`obj_ice` 13、`obj_machine` 13、`obj_ghost` 12、`obj_card` 12、`obj_zeus` 9、`obj_war` 9、`obj_tower` 8、`obj_undersea` 8、`obj_star` 8、`obj_aladdin` 8、`obj_death` 7、`obj_hex` 6、`obj_shop` 6。

---

## 3. 运行时骨架

### 3.1 启动链

`room_init`（`obj_game_init`）→ `room_menu`（`obj_menu_manager`）→ `room_map`（`obj_map_manager`）→ 可选 `room_tower_cake` / `room_laboratory` → `room_ready`（`obj_readyroom_manager`）→ `room_battle`（`obj_battle` + `obj_mod_battle_manager`）。

`objects/obj_game_init/Create_0.gml`（248 行）负责全局初始化，顺序不可乱：

1. `global.level / map_name / map_id / level_name / game_version` 等基础全局量（L37-54）；
2. `Music_Init()`；`global.laboratory_manager = new LaboratoryManager()` + `init()`；`global.gui_stack = new GuiStack()`；`global.native_util = new NativeUtil()`；
3. `init_native_log()` → `%LOCALAPPDATA%\FVM_Reborn_makk\native\latest.log`；`move_files()` 迁移旧存档 `FVM_Reborn\saves` → `FVM_Reborn_makk\saves`；
4. 建 `%LOCALAPPDATA%\FVM_Reborn_makk\mod`（外部 Mod 包目录）；
5. `global.keybind_config` 21 条快捷键（铲子 `vk_tab`，卡槽 1-10 数字键、11-16 `QWERTY`、17-21 `ASDFG`）→ 读进 `global.keybind_map`；
6. `config.ini`（在 `working_directory`）：缺失则写默认值；`difficulty` clamp 0~5、`play_mode` clamp 0~4（4 = 海克斯），旧合并编号 6 = 星际级+抽卡版、7 = 不朽级+欧皇版在此拆解；
7. `auth_init()` → `%LOCALAPPDATA%\FVM_Reborn_makk\auth.dat`；未授权时 `instance_create_depth(0, 0, -9500, obj_auth_gate)`，且必须在创建实例**之前**置 `global.auth_gate_force = true`（`Create` 同步执行，创建完再赋值已经晚了）。

### 3.2 Mod 注册入口 = `objects/obj_mod_manager/Create_0.gml`（persistent）

调用顺序**有依赖，不要重排**：

```
mod_slots_init()  mod_skill_init()  mod_weapons_init()  mod_info_island_init()
mod_shop_init()   mod_maps_init()   mod_enemy_init()    gods_goods_registry_init()
gods_shop_init()  mod_boss_init()   mod_cards_init()    mod_custom_key_check()
mod_material_init()  credit_shop_init()  cross_server_shop_init()   ← 必须在 mod_cards_init 之后（读卡片形态）
card_category_init()  mod_buff_init()  hex_registry_init()  hex_ensure_save_fields()
zhiyumiao_config_init()  external_mod_load_all()  cleanup_orphan_cards()
```

随后落默认值（防 `undefined` 乘法变 0）：`global.hex_mult = {atk:1.0, cycle:1.0, hp:1.0}`、`global.pi_enemy_mult = 1.0`、`global.pi_elite_extra = 0`、`global.pi_boss_escort = false`、`global.bond_mult = 1.0`、`global.bond_count = {}`、`global.bond_tier = {}`、`global.hex_level_cleared = false`、`global.hex_pick_open = false`、`global.hex_series_active = ""`、`global.hex_drop_used = false`。

收尾：融合卡 `_fusion_ids = ["lizi_god","youyu_god","ronghehaixing","ronghedan_god"]` 老存档 `max_shape/shape > 2` 夹回 2 并 `save_file`；`register_card_info_island("hufa_god", ...)` 双保险。

---

## 4. 唯一事实源表（★改数值先查这张表）

同一个概念往往有多份副本，**只有一处生效**。改错副本 = 白改。

| 概念 | 生效位置 | 只是显示 / 冗余的位置 |
|---|---|---|
| 卡片数值（hp/cost/atk/range/cooldown/cycle/description） | `scripts/mod_cards_init/mod_cards_init.gml`（4885 行） | `scripts/mod_slots_init/mod_slots_init.gml` 的 `register_card`（卡槽初始显示）、`scripts/mod_info_island_init`（情报岛文案） |
| 卡片技能覆盖 | `scripts/mod_skill_init/mod_skill_init.gml` | — |
| 卡片槽位/精灵/费用 | `scripts/mod_slots_init` + 各 `objects/obj_<卡>/Create_0.gml` | — |
| 敌人属性（速度/血量/免疫） | 敌人对象里的 `move_speed`、`immune_to_ash` | `register_enemy` 的 `speed` / `ash_proof` 只喂情报岛与抽卡显示 |
| 关卡数值 | `datafiles/level_data/*.json`（改数值优先改这里） | `scripts/mod_maps_init` / `maps_init` 里的地图注册 |
| 跨服关卡判定 | `scripts/cross_server_level_index`：`cross_server_level_index(id)`（非跨服返回 -1）+ `is_cross_server_level(id)` | **禁止硬写 `ancient_castle_` 前缀** |
| 跨服奖励 | `cross_server_reward(id, is_first)` → `{silver, gold_medal, coins}`（8 处调用） | — |
| 战斗倍率终值 | `objects/obj_mod_battle_manager/Step_0.gml` 的 `buff_multiplier` | 其它地方只往上叠层并 `global.buff_apply_id += 1` 触发重算 |
| 存档字段 | `scripts/load_file/load_file.gml`（`reset_file()` 定义完整结构，`ensure_save_data()` 做非破坏迁移） | — |
| 难度数值 | `scripts/difficulty_rules` | `config.ini` 只存玩家选择 |
| 网格/列域 | `scripts/combat_bounds` + 常量 695/228/107/116 | — |

**卡片结构**：`mod_register_plant_lite(id, [ { name, shape, description, hp[], cost[], atk[], range[], cooldown[], cycle[], custom: info_custom([...]) }, ... ])`。数组长度 17~19，索引 = 星级；`shape` 三档（0/1/2）＝三个形态。`scripts/mod_register_plant_lite/mod_register_plant_lite.gml`（253 行）建 `global.plant_registry[id] = {shapes:{...}}`，每形态含 `base_*` + `upgrades["0"]` + `custom`；重复注册会打印 `mod植物已注册: `。

**注册表家族**：`card_registry` `enemy_registry` `level_registry` `map_registry` `material_registry` `weapon_registry` `boss_registry` `goods_registry` `card_info_island_registry`。

---

### 4.5 经济 / 养成线（速查）

金币 = `save_data.player.gold`（唯一硬通货）；威望 = 材料 `"prestige"`；**没有独立水晶货币**，其余（四叶草 / 香料 / 水晶 / 徽章 / 补给币 / 神谕之石）都是 material id。
三条注册语义差异（改不动多半栽在这）：`register_material` 用 `ds_map_add` → 重复注册静默失败；`register_goods` 用 `ds_map_set` → 可覆盖，改价/改文案走它；`register_card_skill` 只在 key 不存在时写入 → 对 `skill_init` 已注册的卡，`mod_skill_init` 的改写无效。

表清单（goods / material / skill / weapon / gem / gods / craft 四表）、货币口径、商店 UI 挂载点与 13 条坑：`docs/REFERENCE.md` 的「经济 / 养成线」。

---

## 5. 战斗内数据流（排查"数值不对"用）

0. **敌人/BOSS 三张表**：`global.enemy_map`（`scripts/enemy_registry/enemy_registry.gml`，12 字段 `name/_obj/hp/shield/description/speed/atk/cycle/range/ash_proof/spr/feature`，**生成口只读 `_obj`**）、`global.boss_list`（`scripts/boss_registry`，只存 `name/hp/icon/icon_scale` → 只喂血条名字与图标）、`global.enemy_info_island`（`scripts/enemy_info_island_registry`，图鉴文案，`info_island_wrap(info,35)` 折行）。**BOSS 不是独立表**，只是 hp 上万 + 对象 `is_boss = true` 的普通条目；新增 BOSS 必须 `register_enemy` + `register_boss` **成对写**（漏前者 → 生成口 `ds_map_exists` 判空，永远不生成；漏后者 → 血条名字/图标退回默认）。`register_enemy` 用 `ds_map_add`（重复 key 静默失败），mod 只能新增 id 不能覆盖本体。`mouse_id` = 对象 Create / `enemy_map` key / `boss_list` key **三处必须一致**（兜底回填在 `objects/obj_battle/Create_0.gml:416-418`，兜底前病毒增伤/情报收集判定失效）。**没有掉落表**：金币/材料写在对象自己的死亡分支里（副本 BOSS 必须判 `!ly_boss_is_peer`，否则双倍）。BOSS 深度 `-10 - row*45 - col*5 - 4.5`，龙渊系再深 3 档（`-12`）。细节：`.workbuddy/memory/topics/enemies-bosses.md`。

1. **普通鼠唯一生成口**：`objects/obj_battle/Create_0.gml` 的组波循环（列 `9 + x_offset`）→ `hex_enemy_scale()`。
2. **BOSS 独立生成口**：`objects/obj_battle/Step_2.gml`。
3. **关卡波次**：地图共 **11 张**（本体 8 张在 `scripts/maps_init/maps_init.gml`，跨服 3 张在 `scripts/mod_maps_init/mod_maps_init.gml`），关卡 JSON **314 个**。波次结构 `waves[i]{wave_index,boss,boss_wave,subwaves[]}` → `subwaves[j]{subwave_index,enemy_list[]}`；`rewards[0]` = 普通 `{gold,items[]}`、`rewards[1]` = 首通 `{gold,items[],gem_unlock[],card_unlock[],weapon_unlock[],player_level,skill_level}`。常见 2 波（`2×140` / `5×4` / `9×2`），但并非全是 2 波（`cookie_island` 是 5 波）。关键字段：`total_waves`、`starting_flame`、`elite_wave`、`boss_wave`、`time_limit`、`map_cols/rows`、`waves[].subwaves[].enemy_list`、`rewards[0/1]`。**没有敌人总数汇总字段**，要总数得自己遍历。
   其他硬事实：**行属性（陆/水）只由每行第 2 格（索引 1）的 `type` 决定**（`objects/obj_battle/Create_0.gml:146`）；`version >= 1.3` 才用 `subwaves[].local_min/max_wave_time` 覆盖外层（`:239-264`）；`boss_wave` 只是 UI 提示、可 > `total_waves`，`boss3` 字段引擎从不读；**发奖只用 `rewards[1]`**，`rewards[0]` 仅在 `objects/obj_battle_pause_manager/Draw_0.gml:319` 显示；抬级只在首通 `objects/obj_battle_pause_manager/Step_2.gml:158-160`（`player_level`）/`:161-167`（`skill_level`），**没有经验值曲线**，`player.level` 完全由关卡 JSON 推进；`complete_level` 在 `scripts/edit_file/edit_file.gml:148`（`:151` 对 `test_level` 永不记账）。**203 / 314 个关卡 JSON 在收尾 `}` 后带 NUL `0x00`**：GML `json_parse` 容忍，python `json` 报 `Extra data` → 不要批量"修"。
4. **倍率**：各加成源向 `obj_mod_battle_manager` 的 `buff_multiplier` 叠乘，新加成在其后再乘一层并复用 `global.buff_apply_id` 令牌重算。
5. **敌人精灵两套布局**（由 `shield_max_hp > 0 && shield_hp > 0` 决定）：
   - 有盾：`move*4 + attack*4 + death`；
   - 无盾：`move*2 + attack*2 + death`。
   换皮新鼠的精灵**总帧数必须等于原版**，否则动画与逻辑错位。
6. **官方速度表口径 = 表格值 × 0.03**（9.32 → 0.2796、30 → 0.9、12 → 0.36）。
7. **出弹绑动画帧的卡**（`obj_coal_starfish` `obj_fashishe` `obj_fengrao_god` `obj_houyi_god` `obj_hufa_god` `obj_ronghehaixing` …）在 `Create_0.gml` 里置 `uses_fire_frame = true;`；`obj_card_parent/Step_0.gml` 据此在 `cycle` 被压小时压缩动画步长（`_anim_flash`），保证出弹帧一定播到。

---

### 5.5 情报岛 / 海克斯（速查）

文案 `{…}` 由 `info_island_text_render`(:185) → `info_island_text_eval`(:132) 求值（**四则从左到右、无优先级**；除零或 undefined 原样吐回）；折行唯一入口 `info_island_wrap(text, 35)`，换行不要落进 `{}` 里；海克斯三乘区 `hex_apply_core`(:346) → `hex_sync_globals`(:298) 夹逼（atk 0.25~8.0 / cycle 0.30~3.0 / hp 0.25~5.0），非海克斯模式恒 1.0。

拼音表与搜索词法、增幅分组（`plant_buff_map` / `plant_buff_map_2`）与 12 条原话级坑：`docs/REFERENCE.md` 的「情报岛与海克斯」。

## 6. 存档

- 文件：`saves/save<slot>.json`（`working_directory` 下），`scripts/save_file/save_file.gml` 用 `json_stringify(global.save_data)` 写；失败 `show_notice("存档保存失败，请重试", 60)`。
- 读取：`scripts/load_file/load_file.gml`；不存在则 `reset_file(file_slot)`；解析后 `ensure_save_data()` 补字段（**非破坏迁移**，保留通关记录与游玩时间），旧 `version` 逐级升（1.4 → 1.8 → 1.9）。
- 顶层字段：`version`（当前 1.8/1.9）、`player{gold, level, experience, name, total_time, crown_version}`、`unlocked_cards[{id, level, shape, skill, max_level, max_shape}]`、`completed_levels`、`completed_elite_levels`、`gacha_box_buy_count`、`inventory`、`unlocked_items{max_card_level, max_skill_level, max_gem_level, max_slot, max_shape[], shovel, elite_unlocked, ...}`、`unlocked_weapons`、`unlocked_gems`、`weapon_gem_memory`、`equipped_items{main_weapon, secondary_weapon, super_weapon}`、`saved_decks[6]`、`tasks`、`completed_tasks`、`attires`、`equipped_cookbook[3]`、`hex_unlocked`、`hex_stats{runs_cleared, runs_abandoned, best_pi}`。
- 转职保底/暗概率不单独建字段，挂在每张卡的 `unlocked_cards` 条目上（`tg_pity` / `tg_hidden`，写法同 `craft_fail_streak`）。
- 玩家数据根目录：`%LOCALAPPDATA%\FVM_Reborn_makk\`（`config.ini`、`saves/`、`mod/`、`native/latest.log`、`auth.dat`、`boss_music/`）。

---

## 7. 字体与字形

- 字体按**字形表**打包：`fonts/<n>/<n>.yy` 里的 `"character": NNNN` 列表。`font_yuan` 6250 字、`font_hei` 5971 字、`font_pixel` 6515 字。
- 补字：`tools/font_fill.py`；空间不够先 `tools/font_repack.py`（字距 3 → 2）。
- **不要在 IDE 里打开字体资源点"确定"**：会重新栅格化，把补进去的字形冲掉。
- 开场卡顿主因在 `after_texture_load()`：`scribble_font_bake_outline_4dir("font_hei")` + `scribble_super_glyph_copy_all`。已收窄 `_target_fonts = ["font_yuan","font_hei"]`、`_source_fonts = ["font_yuan","font_pixel"]`（17966 → 1134）。`font_song` 只画 ASCII，`font_song2` 零引用，别再加。

---

## 8. 工具链（改什么，用哪个脚本）

| 任务 | 工具 |
|---|---|
| 校验编码/括号 | `tools/verify_gml.ps1` |
| **全文搜索 / 列文件** | `rg`（ripgrep 15.2.0，`%LOCALAPPDATA%\fvm-tools\rg.exe`，已在用户 PATH）—— 限定目录 **0.06~0.31 s**，全仓排大目录后 **0.1~0.2 s**，替代 `Get-ChildItem -Recurse`（15~22 s）与 `Select-String`；`tools/lookup.ps1` 内部已改用它。全仓两条最优命令见 §0.0 |
| 契约体检（会话开场自证） | `tools/check_contract.ps1` —— 打印行数/字节/sha256/记忆档案在位状态 |
| 生成多帧精灵 | `tools/make_multi_frame_sprite.py`、`tools/make_hex_mark_sprite.py`、`tools/import_weapon_sprites.ps1` |
| 灼热跨服 BOSS 全流水线 | `tools/zhuore_spec.py` → `zhuore_boss_build.py sprites|objects|register|all` → `zhuore_boss_selfcheck.py`；关卡侧 `zhuore_levels_build.py` / `zhuore_level_selfcheck.py` / `zhuore_map_guide.py` |
| 精灵/帧核对 | `boss_seg_sheet.py`、`boss_cmp_sheet.py`、`boss_frame_bbox.py`、`boss_visual_centre.py`、`dump_sprite_grid.py`、`texgroup_audit.py` |
| 字体 | `font_fill.py`、`font_repack.py` |
| 海克斯校验 | `hex_b3_check.py`、`hex_b3_chain.py`、`hex_b3_segment_check.py`、`hex_b3_wire_gems.py` |
| 数值/平衡模拟 | `gods_stats.py`、`gods_sim.py`、`pool_audit.py`、`tower_cmp.py`、`gm_arity_check.py`（函数传参个数检查） |
| yyp 与构建环境 | `add_objects_to_yyp.ps1`、`build_weapon_objects.ps1`、`check_build_env.ps1`、`set_pagefile.ps1`、`kill_igor.ps1`、根目录 `generate_folders.ps1` |
| 音频 | `ncm_decrypt.py`、`fetch_vip_songs.py`、`音频转OGG.ps1/.bat/.exe` |
| 关卡编辑 | `tools/level_editor/` |

日志：`tools/igor_build.log`、`igor_compile.log`、`igor_j2.log`。

---

## 9. 外部 Mod 系统（External Mod API v1）

`scripts/external_mod_system/external_mod_system.gml`（720 行）。

- 数值单位：`cooldown` / `cycle` 是 **tick（60 = 1 秒）**。
- 加载目录 `%LOCALAPPDATA%\FVM_Reborn_makk\mod`，每子目录一个包，`mod_state.json` 控制 `enabled`。
- 包结构：`manifest.json`（`api_version` 必须 = 1，`cards` 为 1~64 个 `card.json` 相对路径）或裸 `card.json`；允许一层外目录。路径必须包内相对（禁 `..` 与绝对路径）；id 长度 3~100、含 `.`、字符集 `[A-Za-z0-9._-]`。
- 卡注册链：`mod_register_plant_lite` → `register_card(id, obj_external_mod_card, slots)` → `register_card_info_island` → `register_card_skill` → `ds_map_set(global.plus_card_map, ...)` → `global.external_card_registry[$ id] = d`。**整包全部校验通过才发解锁**，任一失败整包回滚（`external_mod_unregister` + `external_mod_assets_delete`），错误进 `global.external_mod_errors`。
- Lua 绑定通过 `FvmNativeSupport.dll`：`ModLuaCreate` / `ModLuaCall` / `ModLuaDestroy`（`dll_cdecl`，`ty_string`/`ty_real`），优先 `working_directory + "native/FvmNativeSupport.dll"`。回调 `external_mod_callback(inst, event, extra)` → `native_mod_lua_call(handle, event, json_stringify(context))` → `json_parse`。
- 常用函数：`external_mod_validate/load_all/spawn/context/animate/callback`、`sprite(root, anim, assets, default_origin="bottom_center")`、`animation_frames`（上限 256）、`projectile_rules`、`apply_burn`、`card_max_level`（默认 16）。

---

## 10. 常见任务 → 触点清单

**改某张卡的数值/文案**
1. `scripts/mod_cards_init/mod_cards_init.gml`（唯一生效数值）；
2. `scripts/mod_slots_init/mod_slots_init.gml`（卡槽描述，用户在背包里看到的那份）；
3. `scripts/mod_info_island_init/mod_info_island_init.gml`（情报岛说明，含星级/技能口径）；
4. `CHANGELOG.md` 记一条。

**加一张新卡**：`mod_cards_init` 注册 → `mod_slots_init` 的 `register_card` → 情报岛 `register_card_info_island` → 技能 `mod_skill_init` → 新建 `objects/obj_<卡>/`（Create/Step/Draw + `.yy` 事件表）→ yyp 三处注册 → 精灵资源 → `verify_gml.ps1`。

**改关卡**：优先改 `datafiles/level_data/*.json`（**不要用 `json.dump` 回写**：会把 `1.666667` 写成科学计数/被截断，且文件尾常带 `\x00`）。跨服关卡额外注意 `global.cross_server_return_map_id/_name` 的还原（`objects/obj_cross_server_level_create/Mouse_4.gml:53-54` 存、`:56` 强写 `map_id="tower_cake"`），以及三条跨服章节的 `levels_data` 里写的是 `pre_level`、而 `obj_cross_server_bg/Create_0.gml:35` 读 `pre_level_require` → 链式解锁实际恒 true（新增章节别照抄这个字段名）。

**加敌人/BOSS**：`mod_enemy_init` / `mod_boss_init` 注册 + 对象 + 精灵（帧数与布局见 §5 第 5 点）。灼热系走 `zhuore_*` 流水线，别手搓。

**改 UI/菜单**：`obj_*_manager` 的 Create 里建控件，`gui_stack.push/pop` 管层级（战斗退出栈是 `[room_map, room_ready, room_battle]`，胜利 `pop` 两次回 `room_map`）。

### 10.1 新卡先找同类（强制）

**规则**：动手前先回答「它属于哪一类」，照同类现有卡抄结构，只改数值与精灵。本工程 212 张卡的分化方式是"同一骨架 + 不同出弹时机"，不是 212 套架构。

**分类唯一数据源**（`docs/卡片分类.md` 已丢失）：`scripts/card_buff_category/card_buff_category.gml` 的 `card_category_data()`（:41-:252）。查同类：`card_get_category(id)`(:268) / `get_cards_in_category("喷壶类")`(:315) / `card_in_category(id,"投掷类")`(:304)。

**19 类卡 → 代表卡 → 照抄哪几行**的完整对照表、共用骨架三条、以及新卡自检四问的逐条依据：`docs/REFERENCE.md` 的「新卡先找同类」。

**新卡自检四问（做完必答）**：
1. 出弹帧还在窗口里吗？（cycle 会被压小 → 抄 `houyi_god` 的 `_spd`，或置 `uses_fire_frame = true`）
2. `attack_anim` 比动画实际帧数少 1 吗？
3. 吃增幅的卡在 `mod_apply_category_buff_map` 的 `_allowed`（:367-374）或 `plant_buff_map_2` 里挂名了吗？
4. 分类表加了自己这一行吗？（不加 → `card_in_category` 全 false，按分类结算的增幅/词条/海克斯全落空）

---

## 11. 验证与交付

1. `tools/verify_gml.ps1 <改动路径>` 全绿；
2. 逻辑改动在游戏内跑一遍对应场景（战斗需看：卡是否能放出子弹、倍率是否正确、退房间是否还原底图）；
3. `git status` 确认没有误改 `*.yyp.bak*`、没有 IDE 生成的 `.resource_order` 噪声；
4. `CHANGELOG.md` 追加条目（当前版本段在文件顶部）；
5. 用户要求时才 `git commit` / `push`（默认不自动提交）。

---

## 12. 已知坑与历史决策在哪

- `INDEX.md` — **一页索引**（入库）：34 行「主题 → 文件:行」+ 关卡目录分布 + 事件文件命名；先查它再开文件。
- `MISTAKES.md` — **犯错日志**（入库）：速查表 + A/B/C/D 四区「症状 → 错路 → 正确路径 → 证据」（条数随维护增长，看 `check_contract.ps1` 输出）。动手前扫它，出错后补它。
- `.workbuddy/memory/MEMORY.md` — 长期备忘总表（105 行，本文件多数结论的出处）。
- `.workbuddy/memory/topics/gml-pitfalls.md` — GML 坑全集（比 §1.3 更细）。
- `.workbuddy/memory/topics/info-island-hex.md` — 情报岛文案/拼音检索/海克斯乘区/增幅分组，行号级细节 + 12 条原话级坑（2026-11-13 调研）。
- `.workbuddy/memory/topics/economy-craft.md` — 商店/材料/技能/强化/进化/融合/转职的表与字段、货币口径、13 条坑（2026-11-13 调研）。
- `.workbuddy/memory/topics/cards.md` — 卡片 12 步链路、`plant_registry` 结构、shape/至尊/融合语义、新增卡清单、7 条坑（2026-11-13 调研）。
- `.workbuddy/memory/topics/enemies-bosses.md` — 敌人/BOSS 三张表、两套状态机、灼热/龙渊/跨服/变异来源、新增清单、13 条坑（2026-11-13 调研）。
- `.workbuddy/memory/topics/levels-maps.md` — 11 张地图注册表、关卡 JSON 实测字段（含 rewards/map 二维格）、314 个 JSON 分布、加载链 4 处、跨服索引、改关卡步骤（2026-11-13 调研）。
- `.workbuddy/memory/topics/hex.md` — 海克斯玩法详版；`topics/fonts.md` — 字体字形；`topics/infected-zhanshen.md` — 变异战线。
- `.workbuddy/memory/YYYY-MM-DD.md` — 逐日工作日志（含每次踩坑的现场：2026-11-09 灼热 BOSS 动画段错位、2026-11-10 跨服退出栈等）。
- `.workbuddy/utmt/` — UTMT 反编译 dump（`dumpZ/`、`verify/` 两套 CodeEntries），用于「原版行为」对照；`spec` 里的中文注释不可信，以实测面积曲线/截图为准。

**跨服关卡的退出语义**（易回归）：`gui_stack.pop()` 两次回 `room_map`；「回跨服页」的恢复逻辑原本只写在 `obj_menu_manager/Create_0.gml`，`obj_map_manager/Create_0.gml` 末尾需要同构的一份；改写 `map_id` 之前必须先记 `global.cross_server_return_map_id/_name`；失败（`spr_lose`）不还原（`obj_baiyang_effect` / `obj_doumaobang_cat` / `obj_tanchitu_rabbit` 靠 `map_name == "跨服远征"` 豁免 BOSS 冲撞）。
