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
| 卡片待机像「一直在长大 / 帧序错乱」 | 量每帧不透明 bbox 宽度分段：生长段单调增、爆炸段橙色像素=0、待机段稳定且末帧=首帧；别拿「项目帧 vs 源帧像素一致」当帧序没问题的证据 | B14 |
| 特效一闪一闪 / 消失又出现 | 逐帧量 `(alpha>8).mean()`：末帧 0% 的是一次性脉冲，不能 loop → 加 `hold` 帧锁在常亮段 | B15 |
| 动态任务每局都退回「待办」/ 重复弹完成提示 | 查启动顺序：`prune` 必须排在 `sync`（动态注册）之后，且 prune 不能用 `get_task_data == undefined` 当判据 | B16 |
| 范围框 / 光环大小和技能范围对不上（还「形态越高框越小」） | 用**四角括号臂跨度**换算（每行/每列不透明像素数最多的那条）；画布尺寸和 bbox 都不行——星芒把 bbox 撑大且各形态比例不同；中心取格心 | B17 |
| 卡片击杀后掉率 / 击杀结算没触发 | 别 `instance_destroy(敌人)`；置 `ash_death = true` + `image_alpha = 0`，让 `obj_enemy_parent/Step_0:427` 走完结算 | B18 |
| 改了精灵帧/像素，游戏里没变 | 同时写 `sprites/<名>/<帧GUID>.png`（顶层合成图，运行时读它）和 `layers/<帧GUID>/<图层>.png` | B19 |
| 卡片的元素效果 / 附加状态「有时候不生效」 | 四连查：① 效果是否包在 `if (hp > 0)` 里（秒杀即跳过）② `image_xscale` 与 `visual_scale_*` 是否同值（bbox vs 绘制）③ 特效用 `image_speed=1` 时短帧是否 0.1 秒就没了 ④ 派生伤害的 `target_type` 是否跟原卡一致 | B20 |
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
| `git merge` / 大区间 `git diff` 在 Bash 里被 SIGTERM，或报 `index.lock: File exists` | 上千文件级别的 git 操作改用 **PowerShell 工具**跑（同一命令即可成功）；残留锁先 `Remove-Item .git\index.lock -Force` 再 `git checkout -- .` 复原 | A15 |
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

### A15 Bash 工具里跑上千文件的 `git merge` / `git diff` → SIGTERM 中断 + 残留 `.git/index.lock`
- **症状**：Bash 工具执行 `git merge --ff-only pr39`、`git diff --name-status <大区间> pr39` 被 `SIGTERM` 杀掉（exit 1、无输出），HEAD 不动但工作区已被删掉一批文件（`git status` 一片 `D`）；随后任何 git 写操作报 `fatal: Unable to create '.git/index.lock': File exists`。
- **错路**：以为命令本身出错反复重跑（撞锁）；`git diff` 加 `--no-renames` 后仍被杀；用 `core.renameLimit` 调参无效。
- **正确路径**：
  1. **上千文件的 git 操作（merge / reset / checkout / 大区间 diff）走 PowerShell 工具**，同一命令（`git merge --no-ff pr39 -F msg.txt`）一次成功。
  2. 中断后先判活：`Get-Process -Name git` 无进程 → `Remove-Item .git\index.lock -Force`；再查 `.git\MERGE_HEAD` / `.git\rebase-merge` 是否存在。
  3. 工作区被中途删文件：`git checkout -- .` 复原（`git status` 的 `D` 不是真实删除）。
  4. 合并提交的中文信息用 `Write` 写 UTF-8 文件 + `git merge -F`，别用 `-m` 直接传中文（PowerShell 控制台按 GBK 解码会显示乱码，虽未必写坏）。
- **证据**：2026-11-13 合并 PR39（1825 文件）时实测：Bash 两次 SIGTERM，PowerShell 一次成功。

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

### B14 卡片待机像「一直长大 / 帧序错乱」→ 先量每帧包围盒再定段落
- **症状**：`spr_shiliu_0/1/2` 待机时果实从 62px 一路涨到 74px 再跳回，用户报「精灵帧顺序不对」。
- **错路**：只比对「项目帧 vs 源帧」逐像素一致（结果全 0 差异）就下结论「帧序没问题，是代码问题」——像素一致只证明**导入没打乱**，证明不了**源文件名的顺序就是播放顺序**。
- **正确路径**：按帧打开、算不透明像素的 bbox 宽度序列，段落一眼分明：
  `[生长 宽 62→74 单调增] [爆炸 宽 165~331 且橙色像素=0] [成熟 宽 82~88 稳定，且末帧与段首帧逐字节相同 = 闭环]`。
  **段落切好之后还要问一句「卡片实际应该按什么顺序播」**——石榴的答案不是「待机在前」，
  而是 **生长 → 成熟 → 爆炸**（一次性卡先长出来再炸）。所以最终重排是
  `[生长 idx0..8][成熟 idx9..20][爆炸 idx21..][留档重复帧]`，`idle_anim = 20`。
  匹配不上「一次性序列」还会踩第二个坑：父类 IDLE 是 `0..idle_anim` 死循环，播完成熟段会回卷到幼苗，
  必须在 Step 里把回卷目标改到成熟段首帧（`image_index = 成熟起点 + (idx mod 成熟长度)`）。
  **闭环重复帧要留在成熟段末尾，不能丢到帧表最后**——帧表最后一段必须是「动作段」（爆炸/攻击），
  否则在 IDE 缩略图/预览里最后一眼看到的是一颗完好的果实，会被当成帧序还没修好。
  重排脚本：`tools/fix_shiliu_sprite_order.py`（原地重写每帧 PNG，GUID / `.yy` / 原点不动，帧总数不变）。
- **证据**：2026-11-13 日志；`objects/obj_shiliu_baobao_bing/Create_0.gml:17-36`、`Step_0.gml:32-42`。

### B15 特效「一闪一闪 / 消失又出现」→ 先量 alpha 曲线，别急着查代码
- **症状**：星轨神本体光环每播一遍就整片消失再淡入；用户描述为「特效应该一直存在，而不是消失又出现」。
- **错路**：先怀疑是不是特效对象被销毁 / 被 `visible` 开关切了（`xg_halo.visible = !xg_fullscreen` 确实是次要原因）。
- **正确路径**：对特效精灵逐帧算 `(alpha>8).mean()`：末帧 0.00% 的就是**一次性脉冲**（淡入→常亮→淡出→空），
  这类精灵**不能循环**，必须「播到常亮帧后 hold」：给特效对象加 `xg_hold_frame`，`image_index >= hold` 就 `image_speed = 0` 并锁帧。
  对照：`spr_haiyang_god_effect` 全程 alpha 28~35、无空帧 → 可以放心循环，所以海洋不闪。
- **证据**：2026-11-13 日志；`objects/obj_xinggui_god_effect/Step_0.gml`、`objects/obj_xinggui_god/Create_0.gml:60`。

### B16 动态任务每次进游戏都退回「待办」→ 查启动时的 prune / sync 顺序
- **症状**：卡片情报任务（`info_view_*`）完成后再开一次游戏又变待办，情报岛重复弹「任务完成」。
- **错路**：先怀疑 `card_info_task_complete` 的幂等判断 / state 没写进去（那两处确实也该加固，但不是主因）。
- **正确路径**：看启动流程 `objects/obj_game_init/Other_2.gml` —— 原来是 `prune → sync`，而
  `task_init()` **只注册 90 条静态任务**，动态 `info_view_*` 的池条目由 `card_info_task_sync()` 现场注册；
  prune 那一刻池里没有这些 key → `get_task_data(tid) == undefined` 成立 → 全部当孤儿删除，
  紧接着 sync 按 `new` 重建。修法：① prune 只用「卡还在不在解锁列表」判定；② 启动顺序改成 `sync → prune`。
- **证据**：2026-11-13 日志；`scripts/task_edit/task_edit.gml:219`、`objects/obj_game_init/Other_2.gml:180`。

### B17 范围框/光环画出来比技能范围大或小 → 按「括号臂跨度」换算，画布和 bbox 都不行
- **症状**：星轨神情报写 5*5。第一版用画布算：四转/终转的光环只有 4.4 格（0 转几乎准，越往后越缩）。
  第二版改用 bbox 算：shape0 5.2 格、shape1 5.0 格、**shape2 只剩 4.2 格**（用户三联截图直接指出）。
- **两层错路**（都要避开）：
  1. 用 `sprite_get_width/height`（**画布**）—— 特效素材为了容纳扩散/发光，四周留了大量透明边。
  2. 用**常亮帧的不透明 bbox** —— 四角括号的角上还挂着星芒/光晕，bbox 比「括号本体」大一圈，
     而且**各形态撑大的比例不一样**（shape0 +5%、shape1 +6%、shape2 +28%/+16%）。
     拿 bbox 当分母 = 按「星芒尖端」对齐，括号本体自然偏小，且形态越高越小。
- **正确路径**：摊成 alpha 掩码后统计**每一行 / 每一列的不透明像素数**，
  像素最多的那一行 / 那一列就是四角括号的四条臂，**臂的跨度才是玩家眼里的「框」**。
  `scale = 目标格数 * grid_cell_size / 臂跨度`，各轴独立；中心取**格心**
  （`grid_offset + (col+0.5)*cell`），别拿卡片 `x/y`（脚底原点 / 悬浮偏移会整体错半格）。
  脚本：`tools/measure_xinggui_halo.py`（换素材重跑，把常量表填回 Create）。三个形态的臂跨度量出来
  几乎相同（295~307 × 313~324）→ 说明美术本来就画成同一尺寸，按它缩放后三者视觉必然一致。
- **验证**：把缩放后的帧贴到 `9x7` 网格模拟图上、画目标 5*5 红框，四角必须贴在框角（三形态各一张并排比）。
- **证据**：2026-11-13 日志；`objects/obj_xinggui_god/Create_0.gml`（`_vis_w/_vis_h` 表）、`tools/measure_xinggui_halo.py`。

### B18 卡片击杀后直接 `instance_destroy(敌人)` → 漏掉掉落 / 击杀结算
- **症状**：石榴爆爆冰旧实现把老鼠打死就 `instance_destroy()` + 自己贴灰烬特效；海克斯模式下的
  `hex_on_kill` / `hex_try_drop` / 塔之诅咒全都不触发（掉卡、火苗、诅咒爆炸都没了）。
- **根因**：敌人死亡分两步 —— `obj_enemy_parent/Other_10.gml` 只负责扣血，**不销毁**；
  真正的死亡结算在 `Step_0.gml:427` 的 `if (hp <= 0 && state != ENEMY_STATE.DEAD)`：
  `hex_batch2_on_enemy_death` → `hex_on_kill` → `hex_try_drop` → `state = DEAD`；
  然后 `image_alpha <= 0 && state == DEAD` 才 `instance_destroy`。直接销毁 = 把整段跳过。
- **正确做法**：想「击杀但不播死亡动画」时置 `with (_t) { ash_death = true; image_alpha = 0; }`，
  父类会立刻隐形、照常走完结算再自己销毁；特效由卡片侧另建（如 `obj_shiliu_ash_fx`）。
- **另一个坑**：`obj_mouse_ash_death` 有自己的生命周期（`life 90` → `image_index 14` 定格 → 淡出），
  拿它贴自定义碎冰图并 `image_speed = 0` 结果是**永远不动**。要「完整播一遍」就写独立特效对象。
- **证据**：2026-11-13 日志；`objects/obj_shiliu_bullet/Step_0.gml`、`objects/obj_enemy_parent/Step_0.gml:427`。

### B19 改了精灵帧内容，游戏里却还是老画面 → 顶层合成图没同步
- **症状**：石榴帧序重排后 `--check` 逐帧全 OK，但游戏里播的还是旧顺序（用户报「没有按照你给的帧顺序实现」）。
- **根因**：GMS 精灵目录里有**两套图**：
  - `sprites/<名>/layers/<帧GUID>/<图层GUID>.png` —— 图层源图，IDE 编辑器读它；
  - `sprites/<名>/<帧GUID>.png` —— **顶层合成图，运行时和 IDE 预览读的是这一张**。
  只覆盖前者等于什么都没改。单图层无偏移时两者内容必须完全相同（可用 md5 校验）。
- **正确做法**：任何「原地重写精灵像素」的脚本都要两边一起写。
  `tools/make_multi_frame_sprite.py` 一直是对的（两个路径都 copy）；
  `tools/fix_shiliu_sprite_order.py` 已补齐，`--check` 也两边都比。
- **验证**：对每个精灵的每帧比 `md5(顶层) == md5(图层)`，不一致的报出来。
- **证据**：2026-11-13 日志；`tools/fix_shiliu_sprite_order.py:layer_png()`。

---

### B20 「子弹特效 / 附加效果有时候不生效」→ 四处静默吞掉，逐一排查
- **症状**：元素蛇四色子弹（定身 / 毒气 / 冰冻 / 暴击）大部分命中都没反应，偶尔才有。
- **四个原因**（全都不会报错）：
  1. **附加效果包在 `if (hp > 0)` 里**：卡攻击力高 → 命中基本秒杀 → 老鼠一死 `hp <= 0` 就整段跳过。
     元素效果应当「命中即判定」：已死目标写状态无害，毒气尤其要照放（它会在原地毒到周围）。
  2. **判定盒比画出来的小**：本项目子弹的 `bbox` 只看 `image_xscale`，而父类 `Draw_0` 优先用
     `visual_scale_*` 绘制。只设 `visual_scale = 1.3` 而 `image_scale = 1` → 判定盒比视觉小 30%，
     边缘命中被静默漏掉。**两个都要设成同一值**（父 Draw 优先 visual_scale，不会双倍放大）。
  3. **特效用 `image_speed = 1` 播**：素材帧数差很多（暴击 5 帧 / 冰晶 6 帧 / 眩晕 20 帧），
     短特效只有 0.08~0.1 秒，肉眼看不到 → 用 `image_speed = 0` + 每帧停留 N tick，寿命按帧数算。
  4. **派生伤害的 `target_type` 抄错**：毒气沿用 `"normal"` 时 `can_target_on("normal","dance"/"invisible")`
     为 false，非主流鼠 / 未显形幽灵吃不到毒 → 应跟原卡一致（`"pierce"`）。
- **通用检查顺序**：先看「效果代码有没有被执行」（击杀分支 / hp 判定），再看「判定有没有命中」（bbox vs 视觉），
  最后看「特效有没有播出来」（帧数 × tick）。
- **证据**：2026-11-13 日志；`objects/obj_yuansushe_bullet/Step_0.gml`、`objects/obj_yuansushe_fx/*.gml`。

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
