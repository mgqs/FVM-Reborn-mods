# 碰撞精度 B 方案：敌人固定判定框

> 一句话：给每个敌人离线烤一张「身体矩形」表，命中判定不再读运行时实例 bbox，而是读这张表。
> 全局开关 `ENEMY_BODY_ENABLED` 改 `false` 即完全退回原逻辑，不动任何调用点。

---

## 1. 为什么需要

现有命中判定读 `_inst_b.bbox_left/right/top/bottom`，这是 GameMaker 的**实例包围盒** —— 它由「当前帧的碰撞掩码」算出，会随敌人动作突变。

实测：

| 敌人 | 站立帧左缘 | 挥爪帧左缘 | 突变 |
|---|---|---|---|
| 巨人鼠 `spr_giant_mouse` | −57 px | −104 px | **凭空多 47 px** |

3813 个精灵里有 **773 个** 是 `collisionKind = 4`（Precise Per Frame，逐帧精确掩码），都会这样跳。

同时卡片索敌走的是整格判定（`abs(_g.col - grid_col) <= range_col`），一格 107 px，巨型鼠体宽 0.85 格可以横跨两格 → 最大误差 ≈ 半格 + 半体宽 ≈ **99 px**。

两类误差叠起来就是玩家感觉到的「碰撞很提前 / 忽早忽晚」。

---

## 2. 改了什么

| 文件 | 类型 | 说明 |
|---|---|---|
| `scripts/enemy_body/enemy_body.gml` | 新建 34,117 B | 564 条判定框表 + 12 个公共函数 |
| `scripts/enemy_body/enemy_body.yy` | 新建 255 B | 脚本资源描述，`parent` 指向 `folders/脚本/assistant.yy` |
| `FVM_Reborn_makk.yyp` | 改 | `resources` 5312 → 5313，新增 `enemy_body` 条目 |
| `scripts/precise_bbox_collision/precise_bbox_collision.gml` | 改 +20 行 | 第 60-80 行：B 侧是敌人且有表项时，用固定矩形替换实例 bbox |

**只改这一处判定入口**，就覆盖了所有走 `precise_bbox_collision` 的子弹命中 —— 全项目 135 处调用。

子弹侧（A 侧）不动：它本来就用 `sprite_get_bbox_*` + 旋转 AABB，是固定值。

---

## 3. 数据从哪来

生成器：`tools/gen_enemy_body.py`，一条命令跑完全流程。

```powershell
& "C:\Users\18203\.dsh\dsh-runtimes\dsh-plugin-desktop-primary-runtime\dependencies\python\python.exe" tools\gen_enemy_body.py
```

四步：

1. **收集 sprite** —— `enemy_init.gml` + `boss_init.gml` 的 `"spr":spr_xxx` 得 168 个；再扫 `obj_enemy_parent` 全部 304 个后代对象的 gml 里 `sprite_index / idle_spr / move_spr / attack_spr / death_spr / appear_spr = spr_xxx` 得 856 个；合计 896。
2. **扫首帧** —— 读 `sprites/<spr>/<spr>.yy` 的 `width/height/xorigin/yorigin` 与 `frames[0].name`，打开根目录 `<frameGuid>.png`，用 PIL 的 `alpha.getbbox()` 取不透明范围，减去 origin 得到相对原点的 `l/r/t/b`。
3. **过滤** —— 名字含 `appear|disappear|effect|skill|laser|lightning|_fx|shadow|warning|target|aim` **且不在注册表**的剔除；`w<24 或 h<24` 剔除；`|l|>300 或 |r|>300` 剔除。→ 保留 564。
4. **写 GML** —— 整段重写 `#macro` 与函数体，**数据段不要手改**。

### 覆盖情况

```
注册表 sprite 168 个 → 全部覆盖，零缺失
表内条目 564 条
```

剔除里最危险的两个（已挡掉，否则判定框会飞到地图外）：
- `spr_spider_man_mouse_skill_1`：w=569、l=−570
- `spr_travel_record_appear`：l=−1025、r=−861（偏移 −943）

### 关键数据

| 精灵 | l | r | t | b | 体宽 |
|---|---|---|---|---|---|
| `spr_giant_mouse` | −57 | 34 | −143 | −9 | 92 |
| `spr_football_fan_mouse_helmet` | −40 | 46 | −112 | −19 | 87 |
| `spr_football_fan_mouse` | −40 | 46 | −104 | −19 | 87 |
| `spr_normal_mouse` | −43 | 30 | −101 | −15 | 74 |

球鼠掉盔前后两套表几乎一致（只有 t/b 差 8px），不会引发判定跳变。

---

## 4. 怎么退回（三级）

### 一级：全局关掉（推荐，改 1 个词）

`scripts/enemy_body/enemy_body.gml` 第 12 行：

```gml
#macro ENEMY_BODY_ENABLED false
```

`enemy_body_get()` 直接返回 `undefined`，所有调用点走原 bbox 路径。**不需要改任何调用点**。

### 二级：只回退判定入口

`scripts/precise_bbox_collision/precise_bbox_collision.gml` 恢复备份：

```
.workbuddy\backup\enemy_body_20261108\precise_bbox_collision.gml
```

### 三级：整体回滚

```powershell
Copy-Item '.workbuddy\backup\enemy_body_20261108\precise_bbox_collision.gml' 'scripts\precise_bbox_collision\precise_bbox_collision.gml' -Force
Copy-Item '.workbuddy\backup\enemy_body_20261108\FVM_Reborn_makk.yyp' 'FVM_Reborn_makk.yyp' -Force
Remove-Item 'scripts\enemy_body' -Recurse -Force
```

### 单个敌人退回

删掉表里对应那一行（`["spr_xxx", l, r, t, b],`），该敌人立刻退回实例 bbox，其余不受影响。

---

## 5. 公共函数

```gml
enemy_body_get(_e)                          // { l, r, t, b } 或 undefined
enemy_body_has(_e)                          // 是否有表数据
enemy_body_left / right / top / bottom(_e)  // 世界坐标，无数据时自动退回 bbox_*
enemy_body_rect(_e)                         // 一次取四点（推荐，少查三次表）
enemy_in_blast(_e, _bx, _by, _r)            // 爆炸：到身体矩形最近距 <= r
enemy_in_card_range(_cx, _cy, _e, _range_px) // 索敌：卡片中心到身体矩形最近距 <= range
```

两个判定函数都用「到矩形最近点距离」，**只会放宽不会收紧** —— 原来打得到的，改完照样打得到。

---

## 6. 收益与边界

### 已生效

- 子弹命中敌人：从「按当前帧掩码」变成「按站立身体轮廓」，巨人鼠挥爪不再凭空多 47 px。

### 未接入（函数已备好，一行替换即可）

| 位置 | 现状 | 可用函数 | 为什么没动 |
|---|---|---|---|
| 啃卡 `obj_enemy_parent/Step_0.gml:301-309` | `dx = x - other.x` 比 `attack_range` | `enemy_body_left()` | 30-48px 误差属合理咬合缓冲，改了可能影响手感 |
| 爆炸 `obj_donut_bullet/Destroy_0.gml` | 中心距 `< 165` | `enemy_in_blast()` | 影响多拿滋等溅射卡 |
| 300+ 卡索敌 | 整格 `abs(col差) <= range_col` | `enemy_in_card_range()` | 改动面太大，建议按卡逐个换 |

**注意：三线酒架的「提前命中」不是这个问题。** 它的根因是子弹 `row` 跟着 lerp 走、视觉跟着 `y` 走，行号与画面不同步 —— B 方案治不了，要单独修行号逻辑。

---

## 7. 已知坑

1. **`object_exists(_e)` 必须先挡** —— 传 `obj_enemy_parent` 这种对象索引时，`instance_exists()` 会返回 true，然后读实例变量直接崩。`enemy_body_is_enemy()` 已处理。
2. **`image_xscale` 可能为负**（左右翻转），`enemy_body_rect()` 里已经交换 l/r。
3. **表 key 是 sprite 索引数字**，不是名字 —— 运行时要 `asset_get_index`。改名 sprite 后表会失效（退回 bbox，不崩）。
4. **新增敌人不会自动进表** —— 必须重跑生成器。漏掉的只是精度不变，不会报错。

---

## 8. 相关文件

```
scripts/enemy_body/enemy_body.gml          判定框表 + 公共函数
scripts/enemy_body/enemy_body.yy           资源描述
scripts/precise_bbox_collision/...         接入点（B 侧替换）
tools/gen_enemy_body.py                    生成器（一体化）
tools/_enemy_body_raw.json                 中间数据快照
.workbuddy/backup/enemy_body_20261108/     备份
docs/碰撞体系全景.png                       碰撞体系总图
```
