# MISTAKES.md — 犯错日志（动手前先扫这里）

> **用途**：把「已经踩过的坑」变成「下次一步到位的路径」。命中症状就照「正确路径」执行，不要重新推理一遍——重推理 90% 会再踩一次。
> **维护**：每次被用户纠正、或自己发现走了错路（含浪费了一次工具调用、改错文件、验证漏做），**当场追加一条**。只写事实与证据，不写感想。
> **分级**：A = 工具与环境（活儿怎么干的错）；B = 判断与定位（找到错地方）；C = 机制与数值（改了不生效）。D = 契约与流程（自身的规矩没守）。

---

## 速查表（30 秒扫完）

| 你正要做的动作 / 看到的症状 | 立刻改成这样 | 条目 |
|---|---|---|
| 想用 `Get-Content` 看 `.gml` 中文 | 用 `read` / `grep` 工具；pwsh 只用 `[IO.File]::ReadAllText($p,[Text.Encoding]::UTF8)` | A1 |
| 想用 `Get-Content` 数行数 | 用 `read` 工具或数 LF；`Get-Content` 会把 283 行数成 171 | A2 |
| 想把多行 python 塞进 `pwsh -Command` | 写 `.py` 文件再 `python x.py`，中文加 `PYTHONIOENCODING=utf-8` | A3 |
| 要用 python 改 `.ps1`（CRLF + BOM） | 先 `if '\r\n' in s` 规范化再比较，改完跑 `verify_gml.ps1` 确认 BOM 还在 | A4 |
| 改了 `Draw_0.gml` 画面毫无变化 | 先看该对象 `.yy` 的 `eventList` 有没有 `eventType:8` —— 没有就是孤儿文件，永不执行 | B1 |
| 动画看起来播了两遍 | 先查 sprite 表里有没有重复段，别先怀疑代码重播 | B2 |
| 贴图朝向反了 | 先开 `ViewImage` 看 sprite 首帧本身朝哪边，再决定翻转 | B3 |
| 报「贴图缺失」 | 先查 `sprites/<n>/layers/<frame>/<layer>/png` 层级与 `frames × layers` 数量，文件通常没丢 | B4 |
| 改关卡 `rewards[0]` 却没变化 | 发奖只读 `rewards[1]`；`rewards[0]` 仅用于 `obj_battle_pause_manager/Draw_0.gml:319` 显示 | B9 |
| 改了某张卡的数值，游戏里没变 | 数值唯一源是 `scripts/mod_cards_init/mod_cards_init.gml`；`mod_slots_init` 只是卡槽显示 | B10 |
| 新增 hp/atk 类新通道后词条恒 0 且不报错 | 按「字段 / 解析 / 读取 / 挂钩」四步逐项核对（漏「解析」最典型） | C3 |
| 新卡吃不到分类增幅 | 去 `mod_apply_category_buff_map`(`card_buff_category.gml:345`) 的 `_allowed`(:367-374) 或 `plant_buff_map_2` 副类型挂名字 | C18 |
| 攻击间隔压小后卡不发射 | `attack_timer == cycle - N*frame` 精确等号遇小数永不成立 → 取整 cycle，或置 `uses_fire_frame = true` | C2 |
| 想给对象加自定义速度 | 名字不要叫 `speed`（内置每帧按 `direction` 自动位移）；用 `xxx_speed` 并把 `speed/hspeed/vspeed = 0` | C1 |
| 想 `json.dump` 回写关卡 JSON | 手工改文本；回写会把 `1.666667` 变科学计数，且 203/314 个文件尾带 NUL | C6 |
| 想写嵌套三元 | 老 GML 运行时不认链式三元，要整体加括号 `(a) ? 1 : ((b) ? 2 : 3)` | C7 |
| 结构体字段想叫 `pi` / 撞内置常量 | 换名（`pi_value`），否则 GM1031 或静默取到常量值 | C8 |
| 想改某张卡的 `shape` 做测试 | 实例层改会被 `obj_card_parent/Other_10` 每帧按存档重建覆盖 | C9 |
| 想「扫一遍仓库找出所有引用」 | `rg -n -F "<名字>" objects scripts datafiles`（**0.14~0.31 s**）或 `tools/lookup.ps1 <名字>`；别用 `Get-ChildItem -Recurse`（15~22 秒/次） | A11 |
| 要下 GitHub release 资产（zip/exe） | 用 `https://ghproxy.net/https://github.com/...` 前缀；直链会 `curl (56) Connection was reset` | A12 |
| 全仓 `rg` 仍要 1~2 秒 | 少了「排大目录」或「文本白名单」：同时写 `-g "!{sprites,sounds,fonts,tilesets,shaders}/**"` 和 `-g "*.gml"`，立刻降到 0.1~0.2 s | A13 |
| 想一次校验多个目录 | `verify_gml.ps1` **只收一个位置参数**：写 `foreach ($p in @('a','b')){ ... -File tools\verify_gml.ps1 $p }`；直传两个目录报「A positional parameter cannot be found」 | A14 |
| 改了看板首行 y / 可见行数 | 三个文件必须同改：`obj_task_bg/Create_0`（首行 y）、`obj_task_bg/Mouse_60/61`（步长与边界）、`obj_task_line_bg/Step_2`（可见上界 + `else { y = -9999 }`）；只改一个会串位或叠到可见区 | C19 |
| 动态任务（`info_view_<卡>`）导致看板/领奖报错 | `get_task_data` 可能是 `undefined`：所有 `array_length(task_data.requirements)` 前加 `if task_data == undefined continue`；Draw 里还要判 `target_task_index < array_length(current_task_list)` | C20 |
| 要判断两套素材/精灵是不是同一份（男版女版、新旧版） | 逐帧逐像素比 `tobytes()`，看「一致帧数/总帧数」（18/18 vs 3/18）；别用缩略图平均差、别信文件夹名 | B13 |

### A11 用 `Get-ChildItem -Recurse` 找文件 → 每次 15~22 秒
- **症状**：一件「找一下哪些文件引用了 X」的活儿拖到几十秒；换个关键词再扫一遍，时间线性叠加。
- **实测**：`Get-ChildItem -Recurse -Filter *.gml` **15.8 s**；`-Recurse -File | Where-Object Extension -eq '.gml'` **21.7 s**；`objects` 目录树 0.5 s（规模：5990 个 `.gml` / 10 MB / 1142 对象目录）。
- **错路**：先全仓列举再筛。
- **正确路径**：**`rg`（ripgrep）限定目录** → `read` 带 `offset/limit` 只读相关段。
  - 列文件 `rg --files -g "*.gml" objects scripts` → **55~64 ms**（3966 个）
  - 全仓列 gml `rg --files -g "*.gml" -g "!{sprites,sounds,fonts}/**" .` → **162 ms**（3970 个）
  - 搜名字 `rg -n -F "<名字>" objects scripts datafiles` → **135~309 ms**
  - 全仓搜词 `rg -n -F "<词>" -g "*.gml" -g "*.json" -g "*.md" -g "!{sprites,sounds,fonts,tilesets,shaders}/**" .` → **181 ms**
  - 一次吐全部触点（卡片/敌人/关卡）用 `tools/lookup.ps1 <名字>`，内部已改走 `rg`
  - 按命名规则直接拼路径仍是 0 秒：`objects/<名>/<名>.yy`、`scripts/<名>/<名>.gml`
- **证据**：2026-11-13 实测（v13 与 15.2.0 各 3 轮）；`rg` 装在 `%LOCALAPPDATA%\fvm-tools\rg.exe` 并已进用户 PATH；`tools/lookup.ps1` 即为此而建，并于同日改为调用 `rg`。

---

### A13 全仓 `rg` 仍要 1~2 秒 → 白名单不剪枝，缺的是「排除大目录」
- **症状**：照抄 `rg --files -g "*.gml" .` 或 `rg -n -F "词" -g "!sprites/**" -g "!*.png" .`，实测 1.2~2.2 s，怀疑 rg 没装上或没生效。
- **错路**：以为 `-g "*.gml"` 会先筛目录；实际上**白名单不剪枝**——rg 必须进入 `sprites/` 的 3903 个目录逐层枚举，才能判断里面有没有 `.gml`。反过来只排大目录不加文本白名单，则会去读 `.png/.ogg/.yy/.yyp`，耗时同样在 2 s 级。
- **正确路径**：两条同时写。
  - 剪枝（省 10 倍）：`-g "!{sprites,sounds,fonts,tilesets,shaders}/**"` — 黑名单匹配到目录就不再深入。
  - 白名单（省读二进制）：`-g "*.gml" -g "*.json" -g "*.md"`。
  - 最终两条：
    - 列全部 gml → `rg --files -g "*.gml" -g "!{sprites,sounds,fonts}/**" .` **162 ms / 3970 个**
    - 全仓搜词 → `rg -n -F "<词>" -g "*.gml" -g "*.json" -g "*.md" -g "!{sprites,sounds,fonts,tilesets,shaders}/**" .` **181 ms**
  - 再者：点名目录比剔目录更快 —— `rg --files -g "*.gml" objects scripts rooms datafiles tools extensions .dsh` **104 ms**。
- **实测对照（2026-11-13，各 3 轮取最低）**：
  | 写法 | 耗时 |
  |---|---|
  | `rg --files -g "*.gml" .`（仅白名单） | 1232 ms |
  | `+ -g "!{sprites,sounds,fonts}/**"` | 162 ms |
  | 点名代码目录 | 104 ms |
  | `rg -n -F "丰饶" -g "*.gml" .`（仅白名单） | 2055 ms |
  | `rg -n -F "丰饶" -g "!sprites/**" -g "!*.png" .`（仅排除） | 2232 ms |
  | 白名单 + 排大目录 | 181~219 ms |
  | `rg -n -F "丰饶" objects scripts datafiles`（点名目录） | 154 ms |
  | 对照 `git grep -n -F "丰饶"`（跟踪文件全仓） | **16 404 ms**（Windows 上逐 blob 解压，别用） |
  | 对照 `git ls-files "*.gml"` | 108 ms（但漏未跟踪文件 5 个） |
- **证据**：同日基准脚本输出；全仓 180 165 个文件 vs `.gml` 仅 3990 个 —— 瓶颈始终是目录遍历，不是匹配。

---

## A. 工具与环境

### A1 `pwsh Get-Content` 读中文 `.gml` → GBK 乱码
- **症状**：输出 `娉℃鏄ョ瑡`；或 grep 明明存在的字搜不到。
- **错路**：为了省事用 `Get-Content` 直接看文件。
- **正确路径**：用 `read` / `grep` 工具；必须走 pwsh 时用 `[System.IO.File]::ReadAllText($p,[Text.Encoding]::UTF8)`。无例外。
- **证据**：`AGENTS.md` §0；本次契约勘察首日即撞。

### A2 `pwsh Get-Content` 数行数 → 数错
- **症状**：`(Get-Content x).Count` 得 171，而文件真是 283 行。
- **根因**：多字节内容下按管道解码后行边界被吞。
- **正确路径**：用 `read` 工具的行号，或 `[IO.File]::ReadAllText(...) -split "`n"` 数 LF。
- **证据**：2026-11-13 盲测 A 的实测对比（283 vs 171）。

### A3 多行 python 塞进 `pwsh -Command` → ParserError
- **症状**：`ParserError: 字符串缺少终止符`，脚本根本没跑。
- **正确路径**：`write` 一个 `.py` 文件 → `python .workbuddy\tmp\x.py`；中文输出设 `$env:PYTHONIOENCODING='utf-8'`，或写文件后用 `read` 看。
- **证据**：2026-11-13 批量改 AGENTS.md 时反复撞。

### A4 用 python 改 `.ps1`（CRLF + BOM）断言失败
- **症状**：`AssertionError: quiet block not found`，明明字符串就在文件里。
- **根因**：文件是 CRLF，待查串是 LF 写的，`old in s` 恒 false。
- **正确路径**：`if '\r\n' in s:` 先规范化（`s.replace('\r\n','\n')` 比对，写回时还原 CRLF），改完跑 `verify_gml.ps1` 确认 BOM 还在。
- **证据**：`tools/check_contract.ps1` 的 `-Quiet` 格式修正（patch6）。

### A5 新建 `.ps1` 忘 BOM
- **症状**：pwsh 5.1 下中文注释变乱码；`verify_gml.ps1` 报 FAIL。
- **正确路径**：`.ps1` 一律 `New-Object System.Text.UTF8Encoding($true)`；其它文件一律 `$false`。
- **证据**：`AGENTS.md` §1.1；`tools/check_contract.ps1` 建档时已按带 BOM 写。

### A6 逐条 `edit` 改 `AGENTS.md` → 上下文被全文注入冲爆
- **症状**：每改一次，下一轮就收到一份 37 KB 的 system-reminder 全文。
- **正确路径**：把多处改动攒成**一个** python patch 脚本，跑一次；跑完立刻 `verify_gml.ps1`。
- **证据**：2026-11-13 前三次 patch 的教训。

### A7 临时脚本散落仓库根 / `tools/` → git status 噪声
- **症状**：`git status` 里一堆 `_tmp_*.py`、`_tmp_xlsx_dump.txt`、`tools/_tmp_probe*.py`。
- **正确路径**：临时件一律放 `.workbuddy/tmp/`（已被 `.gitignore:64` 忽略），用完删；**不要**落 `tools/`。
- **证据**：2026-11-13 交付时 `git status` 实际输出。

### A8 `.yy` 用 `encoding='utf-8'` 读 → 误判「yy 损坏」
- **症状**：`json.load` 抛 `Unexpected UTF-8 BOM`，看着像文件坏了。
- **根因**：新建的 5 个 sprite `.yy` 带 BOM。
- **正确路径**：读 `.yy` 一律 `encoding='utf-8-sig'`；写回按 §1.1 用无 BOM。
- **证据**：2026-11-04 日志（`honglonglong_icon/idle/laser`、`infected_bingzha_ball/fire_ball`）。

### A9 yyp 一致性脚本按 `.gml` 拼 scripts 路径 → 假报大量缺失
- **症状**：脚本报 268 条 scripts 未注册，实际全在。
- **根因**：`.yyp` 里 scripts 也登记 `.yy` 后缀。
- **正确路径**：一致性核对统一按 `.yy` 拼路径。
- **证据**：2026-11-02 日志。

### A10 正则批量改表格误伤同形列
- **症状**：重排词条编号时 14 条银级「叠」列数字被改。
- **正确路径**：锚定行首 `(?m)^\| \d+ \|`，改完抽样核对非目标列。
- **证据**：2026-10-26 日志。

### A12 直接用 GitHub release 直链下载 → `curl: (56) Recv failure: Connection was reset`，得到 0 字节文件
- **症状**：`curl -L -o x.zip https://github.com/.../releases/download/...` 返回 exit 56，文件不存在或 0 B；但 `api.github.com` 能正常取 JSON。
- **错路**：先试官方直链（`objects.githubusercontent.com` 被重置），失败后才想起镜像；`Invoke-WebRequest` 结果一样。
- **正确路径**：下载 GitHub release 资产时**直接用镜像前缀**，一次成功：
  `curl -L --fail --silent -o out.zip "https://ghproxy.net/https://github.com/<owner>/<repo>/releases/download/<tag>/<asset>"`
  （`gh-proxy.com` / `mirror.ghproxy.com` 为备选；资产名先用 `https://api.github.com/repos/<owner>/<repo>/releases/latest` 查 `assets[].browser_download_url`，API 本身是通的）
  下载后必查字节数 > 预期值再解压，避免拿 0 B 文件去 `Expand-Archive`。
- **证据**：2026-11-13 装 ripgrep 15.2.0 时实测：直链 RST / `ghproxy.net` 前缀 1 789 611 B 成功。

### A14 `verify_gml.ps1` 直传多个目录 → 位置参数报错
- **症状**：`verify_gml.ps1 a b c` 输出 `A positional parameter cannot be found that accepts argument 'b'`，exit 1，一个文件都没校验。
- **错路**：以为能像 `rg` 一样吃多个路径，结果整批改动没校验就往下走了。
- **正确路径**：一次一个路径，要批量就循环：
  `foreach ($p in @('objects\obj_task_bg','scripts\task_edit')) { powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\verify_gml.ps1 $p }`
  然后 `if ($o -match '失败 [1-9]')` 判失败，别只看最后一行。
- **证据**：2026-11-13 实施卡片情报任务时实测。

---

## B. 判断与定位（先查这里，别从代码猜）

### B1 改了 `Draw_0.gml` 完全没反应 → 孤儿事件文件
- **根因**：`objects/x/Draw_0.gml` 存在，但 `x.yy` 的 `eventList` 没 `eventType:8, eventNum:0` → 永不执行（`obj_12yinliao_effect` 踩过，改了两版都没反应）。
- **正确路径**：先读 `.yy` 的 `eventList`；补事件后必须自己 `draw_self()` 兜底。
- **证据**：2026-10-28 日志；`gml-pitfalls.md`。

### B2 动画「播两遍」→ 先查 sprite，不要先怀疑代码
- **正确路径**：看 sprite 帧表里有没有重复段，再回代码。
- **证据**：2026-10-27 日志。

### B3 贴图朝向反了 → 先看 sprite 本身
- **错路**：直接改对象里的 `image_xscale`。
- **正确路径**：`ViewImage` 看首帧朝哪边再定翻转；这是同类错误第二次犯（地精鼠 / 无常鸡毛掸子）。
- **证据**：2026-10-27 日志「同类错误第二次犯」。

### B4 「贴图缺失」→ 先查路径层级与数量，不是文件丢了
- **根因 1**：导入脚本把帧图平铺在 `sprites/<n>/<frameId>.png`，而 GM 只认 `sprites/<n>/layers/<frameId>/<layerId>.png`。
- **根因 2**：`.yy` 的 `layers` 有 6 条同名 `default`，`frames` 只有 2 个 → 2×5 = 10 条 missing。
- **正确路径**：先数 `frames × layers`，再查目录层级；正常 sprite 的 `layers` 只应有 1 条。
- **证据**：2026-11-04、2026-11-05 日志。

### B5 视觉大小不对 → 先核对原版精灵再缩放
- **证据**：2026-11-05 日志（`spr_blonde_mary_idle` 放大看就是同一只螃蟹人鱼）。

### B6 版面数字对不齐 → 不要在 Draw 里各写一份常数
- **正确路径**：一个基准变量算一次，两处引用同一值。
- **证据**：2026-10-29 日志。

### B7 底图上的绿星不是 bug
- **事实**：那是预置小火焰；出现位置错乱多半是行列写反。
- **证据**：2026-11-04 日志。

### B8 「卡能选中但放不下」→ 查 `hex_place_locked()`，不是 gridless
- **根因**：`hex_place_locked()` 只看 `hex_state.first_done`；任何一条路径关掉首抽面板却漏设标记，整局锁死且照常运行。
- **证据**：2026-10-26 日志。

### B9 改 `rewards[0]` 白改
- **事实**：发奖全用 `rewards[1]`（首通档）；`rewards[0]` 只在 `obj_battle_pause_manager/Draw_0.gml:319` 显示。
- **证据**：2026-11-13 关卡调研。

### B10 数值改了不生效 → 先过一遍「唯一事实源表」
- **典型**：改 `mod_slots_init` 的 atk（那里没有 atk 字段）；改 `register_enemy` 的 `speed`（那只喂情报岛显示，真正生效的是对象里的 `move_speed`）。
- **正确路径**：`AGENTS.md` §4 那张表，先定位再动手。

### B11 `spec` / 注释里的中文标签不可信
- **案例**：`zhuore_boss_spec.py` 里 skill_3/4 段定义循环错位一位 → 滚石与陨石动画互换；spec 自己写的中文标签是错的。
- **正确路径**：以实测「逐帧非透明面积曲线」或截图为准。
- **证据**：2026-11-09 日志。

### B12 跨服判断散在前缀里 → 用索引函数
- **错路**：`string_pos("ancient_castle_", id) == 1` 写死前缀（历史上散在 9 处，castle 走硬编码徽章档位、json 里根本没有 `gold`，新章节一上线就掉进普通关分支炸）。
- **正确路径**：`cross_server_level_index(id)`（非跨服 -1）+ `is_cross_server_level(id)`。
- **证据**：2026-11-04 日志；`AGENTS.md` §4。

### B13 按素材文件夹名判断「男版 / 女版」→ 男女反了
- **症状**：9 组变装里「星之焕男」「星之焕女」播反；用户指出 `DefineSprite_799_...StarRadianceGirlSkillEffectMovie` 才是女版。
- **错路**：① 拿桌面文件夹中文名（`星之焕男变身`）与 SWF 名里的 `Girl` 互相印证就当结论；② 用 48×48 缩略图算平均像素差判断精灵归属——男女两版构图高度相似，平均差都接近 0，等于没判。
- **正确路径**：**逐帧逐像素**比：`Image.open(a).convert('RGBA').tobytes() == Image.open(b).convert('RGBA').tobytes()`，计数后看 `18/18` 还是 `3/18`，量级差得很明显。同尺寸同构图的两套素材一定比到「N/总帧数」级别一致才认。
  实测归属：`星之焕男变身` ≠ SWF（3/18），`spr_huan_bianshen2` = SWF（18/18）。
- **证据**：2026-11-13 日志；`scripts/attire_transformation/attire_transformation.gml:29-36`。

---

## C. 机制与数值（改了不生效 / 静默错）

### C1 自定义速度叫了 `speed`
- **现象**：向右飞的 16px/帧（双倍）、向左飞原地不动、竖向子弹向右漂。
- **根因**：内置 `speed` 每帧按 `direction`（默认 0=向右）自动位移，Step 里再 `x += dir*speed` 叠加。
- **正确路径**：私有名（`huagao_speed`），Create 里 `speed = 0; hspeed = 0; vspeed = 0;`。
- **证据**：2026-10-24 日志；`obj_huagao_bullet/Create_0.gml`。

### C2 `attack_timer == cycle - N*flash_speed` 精确等号 + cycle 变小 → 永不发射
- **现象**：技能等级高 / 攻速词条一压，卡就不出弹。
- **正确路径**：① `cycle` 取整（`max(1, round(base_cycle * clamp(...)))`，见 `obj_mod_battle_manager/Step_0`）；② 或抄 `obj_houyi_god/Step_0.gml:33-36` 的 `_spd` 压缩窗口；③ 或给对象置 `uses_fire_frame = true` 走 `obj_card_parent/Step_0.gml` 的 `_anim_flash`。
- **证据**：2026-11-05 日志；2026-11-13 未提交改动。

### C3 新增通道只写「字段 + 读取」漏「解析」→ 恒 0 且不报错
- **案例**：`cat_hp` 通道定义了字段、写了 `hex_hp_mult_for_card` 消费，漏 `hex_apply_core` 的解析分支。
- **正确路径**：新通道固定四步核对：字段定义 / 解析写入 / 读取消费 / 挂钩点。
- **证据**：2026-10-26 日志。

### C4 `register_card_skill` 只 add 不覆盖
- **事实**：`skill_init` 已注册的卡，`mod_skill_init` 的改写完全无效。
- **正确路径**：改技能走 `get_plant_data_with_skill` 的数组，或先确认 key 不存在。

### C5 `register_material` 静默失败，`register_goods` 可覆盖
- **事实**：前者 `ds_map_add`（重复 key 静默不写），后者 `ds_map_set`（覆盖）。
- **正确路径**：改价/改文案走 goods；材料只能新增 id。

### C6 `json.dump` 回写关卡 JSON → 数值被毁
- **事实**：会把 `1.666667` 写成科学计数/截断；**203/314** 个文件收尾 `}` 后带 NUL `0x00`（GML 容忍，python `json` 报 `Extra data`）。
- **正确路径**：手工改文本；批量任务用逐行替换，收尾保留原字节尾巴。

### C7 链式三元 → 编译错误
- **正确路径**：`(a) ? 1 : ((b) ? 2 : 3)`，或三档以上直接 `if` 顺序返回。
- **证据**：2026-10-26 日志 `obj_baibianshe/Step_0.gml:74`。

### C8 结构体字段撞内置常量
- **现象**：`_s.pi = x` → GM1031；读取时静默拿到 3.14159，只有赋值才炸。
- **正确路径**：换名 `pi_value`。

### C9 实例层改 `shape` 被覆盖
- **事实**：`obj_card_parent/Other_10` 每帧按存档重建 shape。
- **正确路径**：改存档字段，或改注册表形态数据。

### C10 后写循环覆盖前面的例外
- **案例**：`cold_drew` 必须在「散点追踪」循环之后写（否则被覆盖成 `tracker_advanced`，莓果点心那格没人读）。
- **正确路径**：改 `mod_apply_category_buff_map` 后，检查例外是否排在覆盖它的循环之后。
- **证据**：`card_buff_category.gml:409-415` 注释。

### C11 `var _l = save_data.xxx; array_push(_l, v)` 不回写
- **正确路径**：直接操作 `global.save_data.xxx`。

### C12 BOSS 不吃 PI / 词条倍率
- **根因**：BOSS 生成口是 `obj_battle/Step_2.gml` 手写 `instance_create_depth`，不走 `Create_0` 的组波循环，因此从不调 `hex_enemy_scale()`。
- **正确路径**：新增生成口必须显式补 `hex_enemy_scale_boss()`。

### C13 跨房间覆盖层的恢复逻辑只写在主菜单
- **案例**：跨服「回跨服页」恢复只写在 `obj_menu_manager/Create_0`，从 `room_map` 弹的就丢了。
- **正确路径**：任何「从 A 房间弹出的覆盖层」都在 A 房间的 Create 里做一份同构恢复。
- **证据**：2026-11-10 日志。

### C14 GameMaker IDE 开着时外部改 `.yyp`
- **现象**：脚本加进去的资源条目被 IDE 一次保存抹掉；自检报「yyp 未注册」。
- **正确路径**：先关 IDE；被抹后重跑注册脚本（按 path 去重、只增不删）。

### C15 在 IDE 里打开字体资源点「确定」
- **现象**：重新栅格化，把 `font_fill.py` 补进去的字形冲掉。
- **正确路径**：补字只用脚本，别在 IDE 打开字体资源。

### C16 `undefined` 参与乘法 → 静默变 0
- **正确路径**：可能未定义的量在 `obj_mod_manager/Create_0` 里先落默认值（`global.hex_mult = {atk:1.0,...}`）；实例变量先 `variable_instance_exists`。

### C17 脚本生成 sprite 时每帧新建 layer → 幽灵图层
- **现象**：`.yy` 声明 6 个 `GMImageLayer`（同名 `default`），每帧只有 1 张图 → 36 条引用缺 30。
- **正确路径**：同一 sprite 的所有帧共用 `layers[0]`；`layers` 恒为 1 条（多图层例外）。
- **证据**：2026-11-05 日志。

### C18 分类表没加自己那一行 → 按分类的增幅/词条全落空
- **正确路径**：新卡在 `card_category_data()`（`card_buff_category.gml:41-252`）补一行；吃增幅还要在 `mod_apply_category_buff_map` 的 `_allowed`(:367-374) 或 `plant_buff_map_2` 副类型挂名字。

### C19 改任务看板首行 y / 可见行数只改了一个文件 → 行串位或叠到可见区
- **症状**：新加的页签压住第一行；或者任务一多，未定位的行按 Create 时的 y 全叠在可见区上。
- **错路**：只把 `obj_task_bg/Create_0` 的 `y-130` 改成 `y-65`，忘了 `obj_task_line_bg/Step_2.gml` 里 `y_offset + 10` 的上界和 `Mouse_60/61` 的步长。
- **正确路径**：三处必须同改 ——
  1. `objects/obj_task_bg/Create_0.gml` 建行 y（`y-65+52*i`）；
  2. `objects/obj_task_bg/Mouse_60.gml` / `Mouse_61.gml` 的步长与边界（现为 9）；
  3. `objects/obj_task_line_bg/Step_2.gml` 的可见上界（`y_offset + 8`）+ **`else { y = -9999 }`**（原版靠「行数 ≤ 可见数」隐式成立，不加兜底就会叠）。
- **证据**：2026-11-13 加第 4 页签「卡片情报」时，首行 410→475、可见 11→9。

### C20 动态任务 id 让 `get_task_data` 返回 `undefined` → 看板/领奖崩
- **症状**：进战斗或在看板点开卡片情报任务时报 `array_length` 相关错误，或详情面板显示上一条任务的内容。
- **根因**：卡片情报任务 id 是 `info_view_<card_id>`，卡被清掉（`cleanup_orphan_cards`）后注册表里没了，但 `global.save_data.tasks` 里还留着条目。
- **正确路径**：所有拿 `get_task_data(x)` 结果用之前先判 `undefined`：
  `obj_task_manager/Create_0.gml` 的 `refresh_task_progress`、`obj_task_bg/Create_0.gml` 的 `check_card_upgrade` 与 `refresh_task_list`、`obj_task_claim_btn/Mouse_4.gml`、`obj_task_line_bg/Draw_0.gml` 与 `Mouse_4.gml` 的 `btn_index` 越界判断、`obj_task_bg/Draw_0.gml` 的 `target_task_index` 越界判断。
- **证据**：2026-11-13 `scripts/task_edit/task_edit.gml:145-182` 用动态 id；防护分别落在 `objects/obj_task_manager/Create_0.gml:43`、`objects/obj_task_bg/Create_0.gml:34`、`objects/obj_task_bg/Draw_0.gml:10-14`。

---

## D. 契约与流程（自己的规矩没守）

### D1 改了文件没跑 `verify_gml.ps1`
- **后果**：BOM/括号问题留到 IDE 编译才炸，定位成本翻十倍。
- **正确路径**：改完立刻 `powershell -NoProfile -ExecutionPolicy Bypass -File tools\verify_gml.ps1 <路径>`。
- **已知误报**：`verify_gml.ps1` 校验它自己会报 `[] 28/29`（正则/类型加速器的方括号），忽略。

### D2 引用不存在的章节号
- **案例**：`AGENTS.md` 与 `verify_gml.ps1` 头部都写「第 2.2 条」，而现行文件只有 §1.2 → 编号漂移。
- **正确路径**：引用章节一律写 `§x.y`，改章节结构时全仓 grep 一次旧编号。

### D3 契约文档里写「示例数字」
- **案例**：`SKILL.md` 写过「283 行 / 30431 B」当示例，subagent 可能直接照抄。
- **正确路径**：一律写 `<实测行数>` / `<实测字节>` 占位。

### D4 只在对话里下结论，没落盘
- **后果**：下一轮/下一个 agent 重新踩。
- **正确路径**：结论进 `AGENTS.md`（契约）或 `.workbuddy/memory/topics/`（细节）或本文件（错误路径）。

### D5 明知文件是 CRLF，还用 LF 字符串去 python 里做替换
- **症状**：`AssertionError: show-dirs body`，而 `grep` 明明能搜到那段文本。
- **错路**：`io.open(..., newline="")` 读进来是带 `\r\n` 的串，`old` 却按 `\n` 拼。
- **正确路径**：读后立刻 `s = raw.replace("\r\n", "\n")` 再比；写回前 `s.replace("\n", "\r\n")`（`.ps1` 还要 `utf-8-sig`）。这是 A4 的复发——**改 `.ps1` 前先看 A4**。
- **证据**：2026-11-13 `tools/lookup.ps1` 打补丁时第二次踩。

---

## 追加模板

```
### X{n} <一句话症状>
- **症状**：看到什么、在哪一步暴露。
- **错路**：当时怎么做的。
- **正确路径**：下次一步到位的动作（可复制）。
- **证据**：`文件:行` 或 `YYYY-MM-DD 日志`。
```
