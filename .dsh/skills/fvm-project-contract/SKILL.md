---
name: fvm-project-contract
description: FVM-Reborn-mod（GameMaker Studio 2 塔防 mod，D:\gameProject\FVM-Reborn-mod）工程契约入口。凡是本仓库的改动、排查、加卡/加关卡/加敌人/BOSS、商店与经济、海克斯、字体、外部 Mod、编码与 verify_gml 校验任务，动手前先加载本技能：读取 AGENTS.md 的四个核心区（§0.0 / §0 / §1 / §4） 并回报「已读取」确认，再按 §4 唯一事实源表定位文件。
---

# FVM-Reborn-mod 工程契约（加载后第一步就是读规则）

## 输出语言

对用户的一切文字用简体中文：回复、说明、表格、清单、结论。只有文件路径、函数名、变量名、命令、日志与报错原文保持原样，不要翻译，也不要为凑中文改写标识符。

## 第 0 步：读取并回报（不可跳过，不许凭记忆或注入片段作答）

1. 用 `read` 工具完整读取 `D:\gameProject\FVM-Reborn-mod\AGENTS.md`。文件约 300 行 / 32 KB；若返回被截断，用 `offset` 续读直到文件末尾。
2. 实测行数与字节数，**不要照抄本文里的任何数字**：
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_contract.ps1 -Quiet
   ```
   它会直接打印第 3 步要的那一行（含实测行数、字节、sha256 指纹）。
3. 读完立刻用**这一行**作为回复的开头（后面才写任务内容）：

   ```
   已读取 AGENTS.md（<实测行数> 行 / <实测字节> B，UTF-8 无 BOM）— 本次遵守 §1 铁律与 §4 唯一事实源
   ```

4. 若本次任务涉及改数值/关卡/敌人，再补一行「触点：<文件路径>」，说明按 §4 / §10 定位到了哪个文件。

行数以 `read` 工具返回或 LF 计数为准 —— **不要用 `pwsh Get-Content` 数行**（多字节内容下会数错：曾把 283 行数成 171 行）。

## 第 1 步：定位（别改错副本）

- 数值类改动先查 AGENTS.md **§4 唯一事实源表**：同一概念常有多份副本，只有一处生效。
- 查位置三件套：`INDEX.md`（主题 → 文件:行）→ `tools/lookup.ps1 <名字>`（内部走 `rg`）→ `read offset/limit`。要扫清单外的名字用 `rg -n -F "<名字>" objects scripts datafiles`（0.14~0.31 s）；**不要** `Get-ChildItem -Recurse`（15~22 s）。
- 常见任务直接看 **§10 常见任务 → 触点清单**（改卡数值 / 加新卡 / 改关卡 / 加敌人 BOSS / 改 UI）。
- 行号级细节在 `.workbuddy/memory/topics/`（本地，不入库）：

| 文件 | 覆盖 |
|---|---|
| `cards.md` | 卡片 12 步链路、`plant_registry` 结构、shape/至尊/融合语义 |
| `enemies-bosses.md` | 敌人/BOSS 三张表、两套状态机、各章节来源与数值 |
| `levels-maps.md` | 11 张地图、关卡 JSON 全字段、314 个 JSON 分布、加载链 4 处 |
| `economy-craft.md` | 商店/材料/技能/强化/融合/进化/转职、货币口径 |
| `info-island-hex.md` | 情报岛文案求值、拼音检索、海克斯三乘区、增幅分组 |
| `gml-pitfalls.md` `hex.md` `fonts.md` `infected-zhanshen.md` | GML 坑全集 / 海克斯详版 / 字体 / 变异战线 |
| `../MEMORY.md` `../YYYY-MM-DD.md` | 长期总表 / 逐日工作日志（踩坑现场） |

## 第 2 步：改

- `.gml` / `.yy` / `.yyp` / `.json` / `.md`：**UTF-8 无 BOM + LF**；`.ps1`：**必须带 BOM**。
- 读含中文的 `.gml` 用 `read` / `grep` 工具，**不要用 `pwsh Get-Content`**（GBK 解码 → `娉℃鏄ョ瑡` 乱码）。
- 星级 shape 不能在实例层改；自定义速度不要命名为 `speed`；索敌/命中列走 `scripts/combat_bounds`。
- 关卡 JSON **不要用 `json.dump` 回写**（浮点被写成科学计数、文件尾 NUL 丢失）。

## 第 3 步：验证（必跑）

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\verify_gml.ps1 <改动路径>
```

全绿后再 `CHANGELOG.md` 追加条目（最新版本段在文件顶部）。用户没明确要求时**不自动 commit / push**。

## 回报模板（任务结束时）

```
已读取 AGENTS.md（<实测行数> 行 / <实测字节> B，UTF-8 无 BOM）— 本次遵守 §1 铁律与 §4 唯一事实源
触点：<按 §4/§10 定位到的文件>
改动：<文件:行> …
验证：verify_gml.ps1 → 通过 N / 失败 0
```

## 第五步（前置与收尾都算）：错题本

- **动手前**：`read` 仓库根 `MISTAKES.md` 的速查表；细节需要时按 `INDEX.md` 跳到 `docs/REFERENCE.md`（`## 速查表（30 秒扫完）` 那张表）。命中症状直接走「立刻改成这样」，不要重新推一遍。
- **收尾前**：问自己"这轮有没有走错路"。有 → 按 `MISTAKES.md` 末尾模板追加一条（症状 / 错路 / 正确路径 / 证据），并同步 `.workbuddy/memory/YYYY-MM-DD.md`。没有 → 不写，别凑数。
- 判据：用户纠正过你 / 改了没生效 / 同一动作做两遍才成 / 验证漏做返工 / 操作方式引发的编译或断言错误。
