# 原版 AS3 → GML 移植指南（BOSS 机制）

> 源码位置：`C:\Users\18203\Desktop\跨服\皮特\scripts`（原版《美食大战老鼠》Flash 客户端反编译稿，166 个 `.as`）
> 结论先说：**不能全自动反编译成 GML，但逻辑层可以"机械移植"——一套 BOSS ≈ 半天到一天。**

---

## 0. 一句话结论

| 层 | 能否直接转 | 说明 |
|---|---|---|
| **玩法逻辑**（状态机 / 计时 / 数值 / 技能调度） | ✅ 可以，接近 1:1 | 只用了 int/Number/Array/函数表，没有 Flash 特有语义 |
| **显示与动画**（`a_3909` 序列帧播放器、`MovieClip`、帧标签） | ⚠️ 需要替换 | 映射到项目已有的 `spr_*` + `longyuan_animation_table` 命名剪辑 |
| **资源与工厂**（`a_3924`/`a_3962` 对象池、`BitmapData` 缓存、`_assets/assets.swf`） | ❌ 不要转 | GMS 用实例 + sprite，池化交给引擎 |
| **网络/跨服协议**（`CVanish*`/`CGameResult`） | ❌ 无对应 | 重制版是单机，除非要做联机 |
| **反作弊**（`EncrypIntEx` 等） | ❌ 丢弃 | 混淆包装，读值即 `Value` 属性 |

**所以：BOSS 机制能实现，路径是"按类手工移植 + 资源重接"，不是跑个转换器。**

---

## 1. 为什么不能自动转（会踩死的 6 个硬依赖）

1. `extends Sprite / MovieClip`，靠显示列表 `addChild` + `FrameLabel` 定位帧 —— GML 没有帧标签，只有 `image_index`。
2. `new Timer(1000)`、`Event.ENTER_FRAME`、`addEventListener` —— GML 是 Step 事件驱动。
3. `BitmapData` / `Vector.<BitmapData>` 静态缓存（`a_1300` 1000 帧位图）—— GML 直接用 sprite。
4. 对象池单例（`a_3926()` pop/push 复用实例）—— 会与 GML 的 `instance_destroy` 语义冲突。
5. `getDefinitionByName` / `getClassByAlias` 反射建类（`AurUtility.a_1727`）—— GML 无反射。
6. 所有数值包在 `EncrypIntEx/EncrypNumber` 里，`a_1339`(血量)、`a_1350`(移速) 全是包装类 —— 移植时一律当普通变量读。

---

## 2. 必须掌握的字段对照表

### 2.1 单位基础字段（`a_4206` 老鼠基类）

| AS3 | 含义 | GML 对应 |
|---|---|---|
| `a_1339` | 当前血量 | `hp` |
| `m_iMaxLife` / `m_iArmorLifeValue` | 最大血 / 护甲血 | `max_hp` / `armor_hp` |
| `a_1350` | 移动速度（带方向符号） | `move_speed * dir` |
| `a_1272` / `a_1279` | 缩放 / 原点偏移 | `image_xscale` / `xoffset` |
| `a_1275` | 当前帧标签索引 | `ly_action`（配合 `longyuan_clip_set`） |
| `a_1276` / `a_1277` | 帧标签数组 / 帧号数组 | `longyuan_animation_table(kind)` |
| `a_1283` | 是否朝右（镜像） | `image_xscale` 符号 |
| `m_stCurrentFieldGrid` | 所在格子 | `grid_col` / `grid_row` |
| `m_iLifeValue` … `m_iEatLifeValue` | 血量 / 啃食伤害 | `hp` / `atk` |
| `m_iFreezeUpFrameNum` | 冰冻帧数 | `freeze_timer` |
| `m_bServerIssued` | 服务器下发标记 | 丢弃 |
| `numHardRate` | 难度倍率（血量） | 直接用，见 §4 |

### 2.2 战场与格子（`a_3491` / `BattleFieldView`）

| AS3 | 含义 | GML |
|---|---|---|
| `a_3491.a_1080` / `a_1081` | 格宽 / 格高 | `global.grid_cell_size_x/y` |
| `BattleFieldView.a_1011` / `a_1012` | 列数 / 行数 | `global.grid_cols/rows` |
| `BattleFieldView.a_1013` | 战场像素宽 | `global.grid_cols * global.grid_cell_size_x` |
| `m_iXGridNo` / `m_iYGridNo` | 格子坐标 | `grid_col` / `grid_row` |
| `m_iFieldGridType` | 格型（0 普通 / 2 水或洞） | 地形表 `grid_terrains` |
| `ChangeFieldGrid(grid)` | 移动到格子 | 重算 `grid_col/row` |
| `a_3438(col,row)` | 取格子 | 项目现有格子查询 |
| `AddToBattleView(obj, layer, grid)` | 挂到某图层 | `instance_create_depth` 的 depth |

`BattleLayerDefine` 的 depth 顺序（`INTRUDER_LAND_TYPE=10`、`SKY=11`、`SKY_BOSS=12`、`SHOT=13`、`EFFECTS_TOP=15`）可以直接对到 `instance_create_depth` 的层号。

### 2.3 帧标签：AS3 → 项目命名剪辑

AS3 里到处是 `gotoAndStop((a_1276[i] as FrameLabel).frame)`，等价于 GMS 的：

```gml
longyuan_clip_set("正常前进");   // 内部查 longyuan_animation_table → [spr, start, end]
```

所以移植 BOSS 的**前置条件**是：把原 SWF 的帧标签列成"名字 → 精灵帧区间"表，塞进 `longyuan_animation_table(kind)`。这一步是纯人工，也是工作量的大头。

---

## 3. tick 与时序换算

- `a_4216(param1)` 每帧被 `BattleFieldView.a_3432()` 调一次，`param1` 是**帧计数**。→ GML 里 `Step` 里 `global.battle_tick += 1`，把 `global.battle_tick` 传进去。
- 基类 `IsCalTick(tick)` = `tick & 1 == 0 && tick != last` → **BOSS 逻辑隔帧跑**（30fps 下等效 15fps）。
- 龙机 BOSS 里 `m_iPeriodTime = 80`，每帧 `--`，在 63/41/23/4/0 处触发动作 → 80 帧 ≈ 2.7 秒一轮。**这些数字全部可以原样搬，不需要换算**（前提是游戏帧率仍是 30）。

---

## 4. 数值从哪来（关键认知）

这些 `.as` **不是纯骨架，数值就内联在代码里**：

```as3
this.m_iMaxLife = new EncrypIntEx(15000);   // 基类默认血
this.m_iInjuredLife = 5000;                 // 重伤阈值
this.m_fOrginSpeed = a_3491.a_1080 / 6;     // 默认速度 = 格宽/6
```

唯一的关卡级缩放（龙机 BOSS）：

```as3
_loc3_ = root.m_stGameData["iMapID"];       // 关卡 ID
_loc4_ = root.m_stGameData["byGameMode"];   // 难度模式
if (2819 == _loc3_) {
    m_numHardRate = 1.6;
    if (_loc4_ > 1) m_numHardRate = 1.3;    // 高难度反而降？
}
a_1339 *= m_numHardRate;                     // 只乘血量
```

→ 移植时把 `numHardRate` 做成 `hex_enemy_scale_boss()` 之外的第二个倍率源，**只乘血与阈值，不乘移速**（与现有 BOSS 缩放规矩一致）。

---

## 5. 通用 BOSS 基类骨架（可直接落地）

对应 `BaseBossMoveIntruder`。放进 `objects/obj_as3_boss_parent`，`Create` 里：

```gml
event_inherited();               // 继承 obj_enemy_parent 默认值
is_boss = true;
immune_to_ash = true;

// ===== 移植自 BaseBossMoveIntruder =====
as3_state      = 0;              // 0 NONE / 1 DEAD / 2 HIDE / 3 APPEAR / 4 WAITING / 5 MOVE
as3_last_tick  = -1;
as3_rest_tick  = 0;              // m_iRestTick 休息帧
as3_injured    = false;          // IsInjured
boss_hp_max    = 15000;
boss_hp_injured= 5000;           // m_iInjuredLife
hard_rate      = 1;              // numHardRate
as3_speed      = global.grid_cell_size_x / 6;
launch_num     = 0;              // m_iLaunchNum 剩余连发
launch_delay   = 0;              // m_iLaunchDelayTick
launch_interval= 0;              // m_iLaunchIntervalTick
launch_tick    = -1;             // m_iLastLaunchShotTick
```

`Step` 里（照抄 `a_4216` 的骨架）：

```gml
if global.is_paused exit;
global.battle_tick += 1;

// IsCalTick：隔帧
if ((global.battle_tick & 1) == 0 && as3_last_tick != global.battle_tick) {
    as3_last_tick = global.battle_tick;

    // 死亡
    if (as3_state != 1 && hp <= 0) { as3_state = 1; boss_as3_life_zero(); exit; }
    if (as3_state == 1) { boss_as3_dead_frame(); exit; }

    // 休息帧：只推进动画 + 继续移动 + 允许放技能
    if (as3_rest_tick > 0) {
        as3_rest_tick -= 1;
        if (as3_state == 5) boss_as3_move_self();
        boss_as3_check_launch_skill();
        exit;
    }

    // 子类状态机
    boss_as3_switch_state();
}
```

关键辅助（三行就够）：

```gml
function boss_as3_is_injured() { return hp < boss_hp_injured * hard_rate; }

function boss_as3_state_key() {
    return string(as3_state) + "_" + string(boss_as3_is_injured());   // 例 "5_0"
}

// 连发判定（对应 IsCanLaunchShot）
function boss_as3_can_launch(_tick) {
    if (!boss_as3_is_skill_state() || !boss_as3_is_in_battle()) return false;
    var _fire = false;
    if (launch_num > 0) {
        if (launch_tick == -1) _fire = (_tick == launch_delay);
        else _fire = (_tick == launch_tick + launch_interval);
        if (_fire) { launch_num -= 1; launch_tick = _tick; }
    }
    return _fire;
}
```

`boss_as3_switch_state / boss_as3_is_skill_state / boss_as3_check_launch_skill / 状态→剪辑字典`
**每个 BOSS 各写一份**——原版就是这样：基类里这三个函数全是 `throw Error("需要重载")`。

---

## 6. 真实片段对照：龙机 BOSS 一轮 80 帧

原版（`DragonMachineBossLowerBodyMoveIntruder.a_4216`）：

```as3
if (100000 == m_iPeriodTime) { m_iPeriodTime = 80; visible = true; ... }
if (m_iPeriodTime > 0) {
    --m_iPeriodTime;
    if (63 == m_iPeriodTime) { /* 起手动画，按血量选 A/B 组帧 */ }
    if (41 == m_iPeriodTime) { visible = false; }              // 钻地
    if (23 == m_iPeriodTime) {                                 // 从另一侧冒头
        visible = true; gotoAndStop(1);
        if (2 == m_iAttackTimes % 4)
            _loc2_ = grids[2 + rand(rows-2)][cols-1];          // 贴右边界
        else
            _loc2_ = grids[rand(rows)][cols-4];                // 靠左 4 列
        ChangeFieldGrid(_loc2_);
    }
    if (4 == m_iPeriodTime) { /* 对当前格 + 右一格造成伤害 */ }
}
if (0 == m_iPeriodTime) {
    switch (m_iAttackTimes % 4) { case 0: state=1; case 1: state=2; ... }
}
```

GML（等价）：

```gml
// boss_as3_switch_state() 里
if (boss_status == 0) {
    if (boss_period == 100000) {
        boss_period = 80;
        visible = true;
        longyuan_clip_set(hp > hard_rate * 5000 ? "现身" : "现身_破损");
    }
    if (boss_period > 0) {
        boss_period -= 1;
        if (boss_period == 63) longyuan_clip_set(hp > hard_rate * 5000 ? "起手" : "起手_破损");
        if (boss_period == 41) visible = false;
        if (boss_period == 23) {
            visible = true;
            // 双端一致的伪随机：用 java LCG，与 RandomSeedBoss 同算法
            var _row = (attack_times % 4 == 2)
                     ? 2 + boss_rand(global.grid_rows - 2)
                     : boss_rand(global.grid_rows);
            var _col = (attack_times % 4 == 2) ? global.grid_cols - 1 : global.grid_cols - 4;
            boss_move_to_grid(_col, _row);
        }
        if (boss_period == 4) boss_damage_grid(grid_col, grid_row);
        // 位移
        x += boss_vx;
        y += boss_vy;
    }
    if (boss_period == 0) {
        switch (attack_times % 4) {
            case 0: boss_status = 1; break;
            case 1: boss_status = 2; break;
            case 2: boss_status = 3; break;
            case 3: boss_status = 4; break;
        }
        boss_period = 100000;
        attack_times += 1;
    }
}
```

**注意**：原版用 `RandomSeedBoss`（48 位 LCG，与 `java.util.Random` 同算法）保证双端一致。单机可以直接 `random()`，但要复刻原版行为就得照抄 LCG —— 算法在 `com/adobe/utils/RandomSeed.as`，40 行，能逐行搬。

---

## 7. 接线清单（照项目现有 BOSS 体系）

1. **精灵与帧表**：把 SWF 里该 BOSS 的 MovieClip 导出成 `spr_xxx`，在 `longyuan_animation_table` 加 `case "xxx": {"动作名": [spr, 起始帧, 结束帧], ...}`。帧名必须和 AS3 的 `FrameLabel` 对得上。
2. **注册血量/图标**：`scripts/boss_init/boss_init.gml` 里 `register_boss("id",{"name":"","hp":N,"icon":spr_xxx_icon})`。
   - ⚠️ `icon` 必须用小图（血条按 `icon_scale` 放大到 1.8 倍绘制）；用 282×238 的本体图会炸屏 —— 这是 `obj_infected_zhanshen` 现存 bug 的成因。
3. **出战**：关卡 JSON 的 `boss_wave` / `enemy_list` 写 `mouse_id`，走 `obj_battle/Step_2` 的 `boss_waiting_clear` 分支。
4. **血条**：走 `obj_boss_hpbar`，不要自己画。
5. **缩放**：`hex_enemy_scale_boss()` 只乘血与攻；BOSS 的 `numHardRate` 是第二层，别重复乘。

---

## 8. 工作量估算

| 工作 | 量 |
|---|---|
| 通用基类（状态机 + 连发 + 帧态字典 + 死亡） | 0.5 天，一次做完复用 |
| 单个 BOSS 的 `SwitchState`（原版 200~450 行 AS3） | 0.5~1 天 |
| 帧标签 → `longyuan_animation_table`（每 BOSS 10~30 个动作） | 0.5 天（大头，纯人力） |
| 技能特效/弹幕对象（`DragonLowerBodyBossShot` 等） | 0.5 天/个 |
| 联调（血条、波次、缩放、图鉴） | 0.5 天 |

**可用资产**：`BaseBossMoveIntruder` 的骨架、`DragonMachineBossLowerBodyMoveIntruder` 的完整 450 行四段循环、`GhostBoss/GhostScepter`（两个"装饰型无敌单位"，30 行就能搬完）、`DragonLowerBodyBossShot`（弹幕）。

---

## 9. 建议的落地顺序

1. 先搬 `GhostBossMindMoveIntruder`（最简单：直线移动 + 不能吃 + 血 900）验证"tick + 帧表 + 图层"三件套。
2. 再搬 `BaseBossMoveIntruder` 骨架 + 一个技能型 BOSS 验证技能调度。
3. 最后搬龙机 BOSS（多部件 + 弹幕 + 钻地），它是原版最复杂的 BOSS。
