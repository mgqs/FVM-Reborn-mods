# 外部卡片 Mod 接口 v1

## 当前实现与验证边界

代码已接入 Mod 管理界面、JSON 注册、动态 PNG 动画、Lua 回调和通用子弹。
注册复用游戏现有卡池、植物数值、情报岛和技能接口，卡片按 ID 保存进度。
关闭或删除 Mod 后保留卡片进度，重新启用同 ID 包后恢复。
导入、开关和删除在重启游戏后生效。

本次没有编译或运行游戏；四阶段功能仍需实际游戏验收。Lua 原生桥接源码已加入
FvmNativeSupport 工程，旧 DLL 不包含新接口时，外部 Mod 会加载失败并记录原因。

## 存放和打包

管理界面解压至 `%LOCALAPPDATA%\FVM_Reborn_makk\mod`。
把下面的文件打成 ZIP，可以把扩展名改成 `.fvmmod`：

```text
manifest.json
card.json
logic.lua
images/icon.png
images/idle_01.png
images/idle_02.png
images/bullet_01.png
images/bullet_02.png
```

`manifest.json`：

```json
{"api_version":1,"name":"冰冻小笼包","cards":["card.json"]}
```

为兼容早期方案，卡片也接受 `is_god` 作为 `is_gold` 的别名，
`max_star` 可明确写 16 或 18，`initial_unlock.star` 可作为 `level` 的别名；
18 星仍必须同时标记为金卡，并且只能由 Clotho 临时提升。

## 卡片 JSON

```json
{
  "api_version": 1,
  "id": "xiaoming.ice_card",
  "name": "冰冻小笼包",
  "description": "发射让老鼠减速的冰弹",
  "is_gold": false,
  "icon": "images/icon.png",
  "script": "logic.lua",
  "hp": 50,
  "cost": 100,
  "atk": 20,
  "range": 10,
  "cooldown": 420,
  "cycle": 120,
  "initial_unlock": {"level":0,"shape":0,"skill":0},
  "animations": {
    "idle": {
      "frames": ["images/idle_01.png", "images/idle_02.png"],
      "fps": 12,
      "loop": true,
      "origin": "bottom_center"
    }
  },
  "projectiles": {
    "ice": {
      "frames": ["images/bullet_01.png", "images/bullet_02.png"],
      "fps": 15,
      "origin": "center"
    }
  }
}
```

数值可以写单个值，表示每个星级相同；也可以写数组，按 0 星至最高星顺序排列。
卡片动画默认以所有帧可见图案的并集底部中心为原点，透明留白不参与定位；背包、选卡图标也以可见图案底部中心为原点；子弹使用图片中心。
使用 `origin: "bottom_center"` 或 `origin: "center"` 自动定位；`origin: "custom"` 配合 `origin_x`、`origin_y` 可手动定位。旧坐标配置仍然兼容。
普通卡数组为 17 项，金卡数组为 19 项。`cooldown`、`cycle` 采用游戏帧，60 帧为一秒。
`range` 使用游戏原有数值；Lua 作者自行决定索敌范围如何使用它。

**合成屋最多强化至 16 星。17、18 星只能由 Clotho 对金卡临时提升。**
金卡必须在卡片根配置中写 `is_gold: true`。17、18 星数据用于战场临时加成，
不会通过初始解锁或合成屋获得。原版卡的 Clotho 判断保持现有规则。

多个形态放入 `shapes` 数组，`shape` 从 0 连续编号，各形态填写名称、描述和上述数值、动画。
金卡标记统一使用根配置。可选技能格式为
`"skill":{"property":"cycle","values":[120,115,110,105,100,95,90,85,80]}`。

## Lua 行为

脚本返回回调表；每张放置实例拥有独立 `state`。

```lua
return {
  on_create = function(ctx, state)
    state.ticks = 0
  end,
  on_step = function(ctx, state)
    state.ticks = (state.ticks or 0) + 1
    if state.ticks < ctx.cycle then return end
    for _, enemy in ipairs(ctx.enemies) do
      if enemy.row == ctx.row and enemy.x >= ctx.x then
        api.shoot({sprite="ice", damage=ctx.atk, speed=8, slow_ticks=180})
        state.ticks = 0
        break
      end
    end
  end
}
```

回调包括 `on_create`、`on_step`、`on_timer`、`on_animation_event`、
`on_animation_end`、`on_hit`、`on_destroy`。额外事件数据在 `ctx.event`。
销毁回调只作通知，其命令不会执行。切换房间时释放 Lua 实例。

可调用命令：

| 命令 | 参数例子 |
| --- | --- |
| `api.shoot` | `{sprite="ice",damage=20,speed=8,slow_ticks=180}` |
| `api.damage` | `{target=enemy.id,amount=20,damage_type="normal"}` |
| `api.heal` | `{amount=10}` |
| `api.produce` | `{amount=25}` |
| `api.animate` | `{name="attack"}` |
| `api.timer` | `{seconds=2,name="attack"}` |
| `api.remove` | `{}` |
| `api.log` | `{message="行为调试"}` |

动画 `events` 示例：`[{"frame":2,"name":"fire"}]`。帧序号从 1 开始，
Lua 在 `on_animation_event` 中按 `ctx.event.name` 判断事件。
同一动画的 PNG 必须尺寸一致，fps 为 1–60。暂停时行为、定时器和动画停止。
动画也可以使用 `pattern`、`start`、`end` 字段生成连续文件名，兼容例如
`images/idle_%03d.png` 这种写法；子弹动画放在形态动画中的 `bullet` 名称也会自动注册。

### 子弹目标与交互规则

SWF 适配器可通过 `api.shoot` 传入 `speed_y`、`vertical_distance` 和 `burn`。`vertical_distance` 为斜向移动的总垂直距离，达到后水平飞行；反弹后仍保留剩余距离。`burn` 包含 `probability`、`roll`（0–100）、`power` 和 `duration`（100ms tick）。灼烧拒绝 Boss、死亡或不可见目标，多次命中独立叠加并独立到期，来源卡片死亡后仍结算；暂停时停止。当前处理沿用原版效果 tick 0/10/20... 的先伤害后扣持续时间顺序。敌方通过现有伤害事件结算，宿主免疫/护甲规则与 Flash 可能不同。

卡片 `target_type` 是敌方目标范围的上限，子弹默认继承；子弹 `target_filter` 仅进一步筛选，不扩大卡片攻击范围。不要填写 `types` 和地面/空中/地鼠开关即可直接继承。显式 `types: []` 表示不选择任何敌人。

| target_type | 可攻击范围 |
| --- | --- |
| normal | 普通地面、障碍（潜水、舞者、地鼠、隐形另有分类） |
| air | 普通地面 + 空中 |
| air_only | 仅空中 |
| throw | 普通地面 + 潜水鼠 |
| track | 普通地面 + 潜水鼠 + 空中 |
| pierce | 普通地面 + 舞者 + 障碍 + 隐形 |
| rotate | 除潜水外全覆盖，含空中、地鼠、隐形 |
| d_fruit | 与 rotate 相同 |
| all | 全部 |

该规则同步用于卡片目标查询、普通子弹类型索引和 Mod 子弹命中判定。

子弹动画可在 `projectiles` 对应条目内配置 `damage_type`、`target_filter`、`hit`、`reflection` 和 `enhancement`。`target_filter.team` 支持 `enemy`、`friendly`、`all`；也可以直接写 `ground`、`air`、`mole`、`enemy`、`friendly`、`invincible` 布尔字段。`types` 可限制敌人类别（`normal`、`diver`、`air`、`dance`、`obstacle`、`underground`、`invisible`），留空时沿用卡片的 `target_type`。

`hit.max_hits` 控制子弹累计命中数，写 `0` 表示不限次数；`repeat_hit` 开启后可再次命中相同目标，间隔由 `repeat_interval_ticks` 指定（每秒按 60 tick 计算）。子弹移动按本帧整段路径检测，并按接触先后处理，避免高速穿过目标。达到命中上限后，`destroy_on_hit: true` 直接销毁子弹；设为 `false` 则保留外观继续移动，但不再造成伤害。穿透三只目标设置 `max_hits: 3`，无限穿透设置 `max_hits: 0`。伤害通过游戏现有的敌人受伤事件结算，包含护甲、护盾和死亡规则。

`reflection.sources` 可填写 `cherry_pudding`、`water_god`，`max_count` 限制反弹次数；反弹会翻转水平速度，可选增加反弹卡片的攻击力，并可改变目标阵营。`enhancement.sources` 可填写 `brazier`、`jinniu`、`fire_god`，每个接触来源仅增强一次，按其 `atk` 乘算伤害；`clear_slow` 可配置增强后是否清除减速。

友方目标会使用卡片受击/死亡事件。当前游戏的普通卡片伤害没有与敌人相同的护甲结算接口，因此友方受击直接扣除生命值，并受无敌状态保护。

未设置交互来源时，子弹照常穿过火盆、金牛、火神、布丁、水神，但不触发增强或反弹。`sources: []` 即关闭该交互。`reflection.team: "keep"` 保留目标阵营，布丁/水神成为战斗归属来源，Lua 的 `on_hit` 仍发送给发射卡片。反弹仅反转水平分量，符合这两张原版卡片的直线子弹规则。

目标类型检测使用移动矩形碰撞盒，保证高速路径不会漏检矩形碰撞盒；不是 PNG 每像素形状的精确碰撞。目标仍须与子弹同一逻辑行。当前增强仅接入倍率伤害，不包含原版冰弹的分阶段转火、自动更换火焰图像或火神特殊溅射。

## 游戏验收清单

- 管理：导入有效/无效包、重复 ID、滚动、开关保存、删除、打开目录、返回设置。
- 注册：情报岛名称和描述、背包图标、合成屋、选卡、卡组、重新启动恢复。
- 行为：放置、索敌、发射、减速、动画事件、定时器、暂停、异常脚本隔离。
- 一致性：16 星强化上限、金卡 Clotho 17/18 星、普通卡不超过 16 星、转职、技能、复制、复活、铲除和死亡。
- 关闭恢复：进度保留，重新启用同 ID Mod 恢复；缺失卡片不能放置。
