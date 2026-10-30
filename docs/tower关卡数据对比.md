# tower 关卡数据对比：原版 v3.0.0 vs FVM-Reborn-mod

> 对比日期：2026-10-30
> 对比对象：
> - 原版 `D:\ruanjian\QQ\QQ下载\FVM_Reborn v3.0.0-PC单机版\level_data\tower`
> - 本 mod `datafiles\level_data\tower`
>
> 复现工具：`tools/tower_cmp.py`

## 0. 一句话结论

142 个文件一一对应、没有增删；剥掉浮点写法/尾逗号/尾部 `\x00` 等格式噪声后，**真正的差异只有两处系统性改动 + 一处 BUG**：

1. 全部 140 个关卡的 `elite_wave`（精英波起点）被改写；
2. 70 个 BOSS 关（`tower-N-2`）的波次结构由 **3 波合并为 2 波**，敌人阵容一个字没动；
3. `tower-19-2.json`（普通难度）被**困难难度数据覆盖**，`level_name` 也是错的。

## 1. 文件清单与格式层差异

| 项目 | 结果 |
|---|---|
| 文件数量 | 双方各 142 个 |
| 仅一方存在 | 无 |
| 字节完全相同 | 0 个 |
| 语义（JSON 解析后）完全相同 | 2 个：`tower-35-3.json`、`tower-35-3_hard.json` |
| 语义不同 | 140 个 |

字节全不同但大多不是真差异，原因是原版导出格式：

- 所有数字写成浮点：`"total_waves":3.0` vs mod 的 `3`；
- 数组/对象尾部带**多余逗号**（标准 JSON 解析会报 `Illegal trailing comma`）；
- 文件末尾多一个 `\x00` 空字节。

因此 mod 侧每个文件都比原版小（`-51` ~ `-5316` 字节），这不是内容缺失。

## 2. 差异一：`elite_wave`（影响全部 140 关）

`elite_wave` 表示从第几波开始进入精英阶段，被 `obj_level_progress_bar`、`obj_battle/Step_2`、`obj_battle_pause_manager`、`obj_event_manager` 等读取，决定进度条分段与精英波判定。

| 关卡类型 | 原版 v3.0.0 | mod |
|---|---|---|
| 普通关 `tower-N-1`（70 个文件） | `0`（不进入精英阶段） | `2` |
| BOSS 关 `tower-N-2`（70 个文件） | `0` | `1` |
| `tower-35-3`（2 个文件） | `2` | `2`（唯一完全一致，连格式都没变） |

分布统计：

- 原版 `elite_wave`：`0` × 140，`2` × 2
- mod `elite_wave`：`2` × 72，`1` × 70

**除 `elite_wave` 外，70 个普通关 `tower-N-1` 与原版逐字段完全一致**（地图、波次、敌人、奖励全同）。

来源：commit `4ec67fb2a6`（新增海洋女神、护法神、工匠神、炎帝、重生神）。在 `v2.4.1`（`b054dad3db`）时仍是 `0`。

## 3. 差异二：BOSS 关波次结构 3 波 → 2 波（影响 70 关）

|  | 原版 v3.0.0 | mod |
|---|---|---|
| `waves` 数量 | 3 | 2 |
| `waves[0]` | 普通波，6 个 subwave | 普通波，**12 个 subwave** |
| `waves[1]` | 普通波，6 个 subwave | BOSS 波，30 个 subwave |
| `waves[2]` | BOSS 波，30 个 subwave | — |
| `total_waves` | `3` | `2` |
| `boss_wave`（顶层） | `3` 或 `4` | `2` |
| `subwave_index` | **全为 0** | 0/1/2… 顺序编号 |

即 mod 把原版的前两波**拍平成一波**，BOSS 波上移一位。

### 3.1 敌人阵容零变化的验证

把原版 `waves[0].subwaves + waves[1].subwaves` 拼接后与 mod 的 `waves[0].subwaves` 逐条比对（忽略 `subwave_index`）：

- **69 / 70 个文件完全相等**，包含每个 `enemy_list` 的 `type`、`row`、`prosperity`，以及每个 subwave 的 `local_min_wave_time` / `local_max_wave_time`。
- 唯一不等的就是 `tower-19-2.json`，见第 4 节。

各 BOSS 关 subwave 总数两边一致（如 tower-1-2 为 12+30=42，tower-19-2 为 156），地图 `map`、`map_sprite`、`starting_flame`、`time_limit`、`rewards` 全部相同。

所以这是**纯波次切分方式的变化**，不改难度数值，但会改变实际战斗节奏：

- 少一次波次间隔 / 少一次波间刷怪停顿；
- `elite_wave` 从 0 改成 1，进入第 2 波即视为精英阶段；
- 进度条按 `total_waves=2` 重新分段，原 3 段变 2 段。

### 3.2 字段模板（改造时对齐用）

`waves[]` 的键固定为 7 个：

```json
{
  "boss_wave": false,
  "wave_index": 1,
  "boss": "",
  "boss_1_hp_modify": 1,
  "subwaves": [ ... ],
  "boss2": "",
  "boss_2_hp_modify": 1
}
```

`subwaves[]` 只有 2 个键：`enemy_list`、`subwave_index`。

`enemy_list[]` 只有 3 个键：`row`、`prosperity`、`type`，例如：

```json
{"row": 1, "prosperity": 0, "type": "normal_mouse"}
```

## 4. BUG：`tower-19-2.json` 被困难版覆盖

`datafiles/level_data/tower/tower-19-2.json` 现在是困难难度的数据：

| 判据 | 结果 |
|---|---|
| `level_name` | 写成 `"tower-19-2_hard"`（应为 `"tower-19-2"`） |
| 与同目录 `tower-19-2_hard.json` | 156 个 subwave **逐位置完全相同** |
| 737 条敌人 `(type, row)` 序列 | 与 `tower-19-2_hard.json` **逐条相同** |
| 与原版普通 19-2 | 敌人 `row` 行号分布不同（原版普通版与困难版在 19-2 这关只差行号分布） |

影响范围：**仅塔 19-2 一关的普通难度**，其余 69 个 BOSS 关正常。玩家在普通难度 19-2 会撞上困难难度的刷怪路线。

引入版本：同样来自 commit `4ec67fb2a6`。`v2.4.1`（`b054dad3db`）与中间版本（`cbd935f3bd`）的 `tower-19-2.json` 都还是 `level_name = "tower-19-2"` 且行号正确。

### 4.1 修复方法

以**原版 v3.0.0 的 `tower-19-2.json`** 为内容源（普通版行号正确），套用本 mod 的 2 波结构：

1. `level_name` 改回 `"tower-19-2"`；
2. `waves` 合并为 2 个：
   - `waves[0]`：原版 `waves[0].subwaves` + `waves[1].subwaves` 拼接，`subwave_index` 从 0 重新编号；`boss_wave=false`、`boss=""`、`boss2=""`、`boss_1_hp_modify=1`、`boss_2_hp_modify=1`、`wave_index=1`；
   - `waves[1]`：原版 `waves[2]` 整体照搬，仅把 `wave_index` 改为 `2`（`subwave_index` 从 0 重编号）；
3. `total_waves=2`、`boss_wave=2`、`elite_wave=1`；
4. 其余顶层字段（`map`、`map_sprite`、`starting_flame` 等）保持 mod 现状，`map` 两边本就相同。

**注意**：不要用 mod 当前的 `tower-19-2.json` 做底本，它与 `tower-19-2_hard.json` 完全相同，无法区分。

## 5. 汇总对照表

| 维度 | 原版 v3.0.0 | mod | 是否有意改动 |
|---|---|---|---|
| 文件数 | 142 | 142 | — |
| `elite_wave`（普通关） | 0 | 2 | 是（commit 4ec67fb2a6） |
| `elite_wave`（BOSS 关） | 0 | 1 | 是 |
| BOSS 关波数 | 3 | 2 | 是 |
| BOSS 关 subwave 总数 | 相同 | 相同 | 否 |
| BOSS 关敌人阵容 | 相同 | 相同 | 否 |
| 地图 / 奖励 / 火苗 / 限时 | 相同 | 相同 | 否 |
| `subwave_index` | 全 0 | 顺序编号 | 是（规范化） |
| `tower-19-2` 普通难度 | 普通版 | **困难版（BUG）** | 否，需修 |

## 6. 复现方式

```bash
cd D:\gameProject\FVM-Reborn-mod

# 差异汇总（按影响文件数排序）
python tools/tower_cmp.py

# 单文件逐字段明细
python tools/tower_cmp.py tower-1-2.json
```

脚本已处理原版的三类格式噪声（尾部 `\x00`、尾逗号、浮点整数），数字按值比较，因此输出的是真实语义差异。
