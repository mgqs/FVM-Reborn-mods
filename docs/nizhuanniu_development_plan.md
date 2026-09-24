# `nizhuanniu`（逆转牛）开发方案

> 依据图片：`niuzhuanniu-1.png`（防御卡查询·逆转牛）、`niuzhuanniu-2.png`（冷却时间性能表）。
> 内部 ID 采用仓库已有的 `spr_nizhuanniu*` 命名：`nizhuanniu`。
> 本文是开发方案，不代表已经实现、已编译或已通过运行测试。图片明确的规则优先；标注“建议/待确认”的内容不是图片事实。
> 无法承诺绝对零 BUG。交付标准是：数值逐项核对、静态检查、GameMaker 编译、战斗回归全部通过，且无已知阻断问题。

## 1. 图片事实（不可改）

### 1.1 卡面事实（图 1）

| 字段 | 内容 |
| --- | --- |
| 名称 | 逆转牛 |
| 类型 | 辅助型 |
| 耗能 | 150 |
| 范围 | 3*3 |
| 条件 | 全天 |
| 可以强化 | 卡片冷却速度 |
| 技能强化 | 该防御卡不支持技能 |
| 收录图鉴 | 生肖卡·牛年卡 |
| 图鉴加成 | 暂未开启 |
| 卡片能力 | 将范围内的普通老鼠逆转到出生时的位置 |
| 一转能力 | 击退附加伤害 |
| 二转能力 | 范围扩大到 5*5 |
| 转职路径 | 逆转牛 → 匀速逆转牛 → 光速逆转牛 |
| 作为副卡 | 好卡 |
| 续费价格 | 60000 点券永久 |

### 1.2 性能与附加说明（图 2）

| 冷却时间（星级） | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | Max | Ultra |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | :---: | :---: |
| 逆转牛（秒） | 50 | 48 | 46 | 44 | 42 | 40 | 38 | 35 | 32 | 29 | 26 | 23 | 20 | 17 | 14 | 11 | 7 | 空 | 空 |

附加说明：

* 耗能 150。
* 将范围内老鼠传送到自身所在行最右边。
* 一转后附加 1000 物理伤害（仅对被传送的老鼠有效，对 boss、鼹鼠无效）。

### 1.3 两条描述的统一口径

图 1 说“逆转到出生时的位置”，图 2 说“传送到自身所在行最右边”。二者统一为同一条规则：

> 普通老鼠的“出生位置”就是它所在行的右侧出生线；逆转 = 把它移回**它自己当前所在行**的出生线（不是卡牌所在行）。

这条必须写死为“老鼠自己的行”。3*3 / 5*5 会覆盖上中下三行或五行，如果把跨行老鼠统一拉到卡牌所在行，会破坏分路、卡住多节敌人，属于必须避免的 BUG。

## 2. 资源与现状核对

| 项目 | 现状 | 结论 |
| --- | --- | --- |
| `spr_nizhuanniu`（13 帧） | 已存在，已登记进 `FVM_Reborn_makk.yyp` | 直接使用 |
| `spr_nizhuanniu_1`（14 帧） | 已存在，已登记 | 直接使用 |
| `spr_nizhuanniu_2`（13 帧） | 已存在，已登记 | 直接使用 |
| `obj_nizhuanniu` | **不存在** | 需要新建 |
| `mod_cards_init` 数值注册 | **不存在** | 需要新增 |
| `mod_slots_init` 卡池注册 | **不存在** | 需要新增 |
| `mod_info_island_init` 图鉴 | **不存在** | 需要新增 |
| `mod_shop_init` 商店 | **不存在** | 需要新增 |
| `mod_skill_init` | 该卡不支持技能 | **不要注册** |

形态与素材对应关系按图片转职路径：

| shape | 名称 | 精灵 |
| --- | --- | --- |
| 0 | 逆转牛 | `spr_nizhuanniu` |
| 1 | 匀速逆转牛 | `spr_nizhuanniu_1` |
| 2 | 光速逆转牛 | `spr_nizhuanniu_2` |

## 3. 数值表

项目按 60 FPS 运行，图片单位“秒”需要乘 60 转为帧。

### 3.1 星级冷却时间（帧）

```
[3000, 2880, 2760, 2640, 2520, 2400, 2280, 2100, 1920, 1740, 1560, 1380, 1200, 1020, 840, 660, 420]
```

对应 50、48、46、44、42、40、38、35、32、29、26、23、20、17、14、11、7 秒，长度 17（0 到 16 星）。

### 3.2 其余字段

| 字段 | shape 0 | shape 1 | shape 2 | 说明 |
| --- | --- | --- | --- | --- |
| cost | 150 | 150 | 150 | 全星级固定；新增显示用 `register_card` 的 cost 也填 150 |
| cycle | 0 | 0 | 0 | 图片没有攻击间隔；该卡不是攻击循环卡 |
| atk | 0 | 0 | 0 | 1000 是固定效果伤害，不放进星级攻击数组，不参与攻击力加成 |
| range | 3 | 3 | 5 | 仅作展示/登记；逻辑用下面的 `effect_radius` |
| effect_radius | 1 | 1 | 2 | 半径 1 = 3*3，半径 2 = 5*5 |
| reverse_damage | 0 | 1000 | 1000 | 固定值，仅一转及以后 |
| cooldown | 3.1 数组 | 3.1 数组 | 3.1 数组 | 星级只影响冷却 |
| hp | 待确认 | 待确认 | 待确认 | 图片没有给生命值 |
| skill | 无 | 无 | 无 | 不写 `mod_skill_init` |

**待确认（不能猜）**：图片没有给生命值。一次性辅助卡在项目里的先例是 `obj_ventilation_fan`，它直接 `invincible = true`。建议先按 `invincible = true` 处理（保证起手动画期间不会被啃掉导致“卡放了但效果没出”），等拿到官方生命值再切回可被攻击。

### 3.3 注册时必须显式限定 17 档

`mod_register_plant_lite(arg0, arg1, arg2 = true)` 第三参数为 `false` 时最大等级是 16。图片只给到 16 星，Max / Ultra 为空，所以：

```
mod_register_plant_lite("nizhuanniu", [...], false);
```

且所有数组长度必须是 17（索引 0 到 16），不能用 18 档的越界 clamp 偷偷补 17、18 星。

## 4. 行为与状态机

### 4.1 触发时机（关键口径）

图片只给了“冷却时间”，没有给“攻击间隔”，说明这不是一张持续攻击卡。**推荐口径：放置后经过起手动画，触发一次逆转脉冲，随后卡片退场**，与既有一次性辅助卡 `obj_ventilation_fan` 的结构一致。

如果要改成“在场持续触发”，必须先补一个触发间隔数值（秒/帧），否则每次 Step 都触发会造成老鼠被锁死在出生线，属于设计级 BUG。本文按一次性触发落地。

### 4.2 状态机

| 状态 | 含义 | 退出条件 |
| --- | --- | --- |
| IDLE | 放置后播放待机/起手动画 | `state_timer >= activate_delay` |
| ACTIVATING | 已执行一次逆转脉冲，播放激活动画 | 动画播放完 |
| DONE | 淡出后 `instance_destroy()` | 销毁 |

`has_activated` 用来防止重复触发；`Destroy_0` 不再触发第二次。

### 4.3 目标筛选规则

一次脉冲只处理同时满足以下条件的老鼠：

1. `instance_exists(id)`，且 `hp > 0`。
2. `state != ENEMY_STATE.DEAD`。
3. `target_type == "normal"`（“普通老鼠”）。
4. `is_boss == false`（对 boss 无效）。
5. `mouse_id != "mole"`（对鼹鼠无效；鼹鼠本身是 `target_type = "underground"`，属双保险）。
6. `abs(grid_row - 卡牌.grid_row) <= effect_radius`。
7. `abs(grid_col - 卡牌.grid_col) <= effect_radius`。

使用 `grid_row` / `grid_col` 判断范围，不用 `x/y` 距离，避免跨行误判和多节敌人判定错位。

### 4.4 传送规则

* 目标行 = 老鼠自己的 `grid_row`。
* 目标 `x`：优先用敌人出生时记录的 `birth_x`；没有该变量时回退到 `get_world_position_from_grid(global.grid_cols, 老鼠.grid_row).x`（`global.grid_cols` 是地图列数，标准地图为 9，正好是右侧出生列）。
* 目标 `y` 保持不变，避免不同行的 y 偏移被清掉。
* 若老鼠已经站在出生线附近（`x >= 目标x - global.grid_cell_size_x * 0.5`），跳过，不传、不伤。这一条是防止“已经回到出生线又被无限逆转”的关键保险。

### 4.5 伤害规则

* 仅 shape >= 1 且 `reverse_damage = 1000`。
* 只对**本次真正被传送**的老鼠生效；被跳过（已在出生线、被过滤）的不受伤。
* 通过敌人统一的受伤接口结算：

```
with (_enemy)
{
    damage_amount = 1000;
    damage_type = "physical";
    event_user(0);
}
```

项目 `obj_enemy_parent.Other_10` 的规则是：`normal` 先扣护盾，`pierce` 同时扣护盾和血，**其他类型直接扣血**。因此 `physical` 会落到“直接扣血”分支，等于无视护盾的物理伤害。如果设计上物理伤害应当先扣护盾，把 `damage_type` 改成 `"normal"`；这一条列为待确认，但两种都必须只结算一次。

## 5. 逐事件伪代码

### 5.1 `obj_nizhuanniu / Create_0`

```
event_inherited();
plant_id = "nizhuanniu";
obj_type = object_index;
event_user(0);

sprite_index = spr_nizhuanniu;
if (shape == 1) sprite_index = spr_nizhuanniu_1;
else if (shape == 2) sprite_index = spr_nizhuanniu_2;

attack_anim   = 0;
idle_anim     = sprite_get_number(sprite_index);
flash_speed   = 5;
plant_type    = "normal";
is_slowdown   = false;
invincible    = true;                      // 待确认；图片未给生命值

effect_radius = (shape >= 2) ? 2 : 1;      // 1 => 3*3, 2 => 5*5
reverse_damage = (shape >= 1) ? 1000 : 0;  // 固定值，不参与星级/buff

activate_delay = 4 * flash_speed;          // 起手动画时长，按素材帧数校准
state_timer    = 0;
anim_timer     = 0;
anim_frame     = 0;
has_activated  = false;
is_activating  = false;
```

### 5.2 `obj_nizhuanniu / Step_0`

```
if (global.is_paused) exit;
event_inherited();

if (is_frozen) exit;   // 与项目现有冻结规则保持一致

state_timer++;
// 待机动画：image_index = anim_frame（0 ~ idle_anim-1 循环）

if (!has_activated && state_timer >= activate_delay)
{
    has_activated = true;
    is_activating = true;
    nizhuanniu_reverse_pulse(id, effect_radius, reverse_damage);
}

if (is_activating)
{
    // 播放激活动画 / 淡出，播完 instance_destroy()
}
```

### 5.3 逆转脉冲 `nizhuanniu_reverse_pulse`

```
function nizhuanniu_reverse_pulse(_self, _radius, _damage)
{
    // 1) 先快照目标 id，避免一边移动一边遍历
    var _ids = [];
    with (obj_enemy_parent)
    {
        if (hp <= 0) continue;
        if (state == ENEMY_STATE.DEAD) continue;
        if (is_boss) continue;
        if (mouse_id == "mole") continue;
        if (target_type != "normal") continue;
        if (abs(grid_row - _self.grid_row) > _radius) continue;
        if (abs(grid_col - _self.grid_col) > _radius) continue;
        array_push(_ids, id);
    }

    // 2) 逐个传送，必要时补伤害
    for (var i = 0; i < array_length(_ids); i++)
    {
        var _e = _ids[i];
        if (!instance_exists(_e)) continue;
        if (_e.hp <= 0 || _e.state == ENEMY_STATE.DEAD) continue;

        var _dest_x = get_world_position_from_grid(global.grid_cols, _e.grid_row).x;
        if (variable_instance_exists(_e, "birth_x")) _dest_x = _e.birth_x;

        // 已在出生线的跳过，防止无限逆转
        if (_e.x >= _dest_x - global.grid_cell_size_x * 0.5) continue;

        _e.x = _dest_x;
        _e.grid_col = global.grid_cols;

        instance_create_depth(_e.x, _e.y, _e.depth - 10, obj_nizhuanniu_effect);

        if (_damage > 0)
        {
            with (_e)
            {
                damage_amount = _damage;
                damage_type = "physical";
                event_user(0);
            }
        }
    }
}
```

### 5.4 出生坐标记录（`obj_enemy_parent / Create_0`）

为了让“出生时的位置”是真实出生点，需要在敌人父对象创建事件追加两行：

```
birth_x = x;
birth_y = y;
```

说明：

* `instance_create_depth` 先设置坐标再执行 Create，所以这里拿到的就是真实出生点。
* 不改变任何现有行为，只是多两个变量。
* 脉冲里用 `variable_instance_exists(_e, "birth_x")` 做兼容：万一某些敌人是别的方式创建、没走到父 Create，则回退到右侧出生列，不会报错。

## 6. 边界与防 BUG 清单

| 编号 | 风险 | 处理 |
| --- | --- | --- |
| B1 | 把跨行老鼠拉到卡牌所在行，破坏分路 | 目标行永远用老鼠自己的 `grid_row` |
| B2 | 老鼠已在出生线，每帧被重复传送 | 目标已在出生线附近直接跳过 |
| B3 | 一次脉冲里老鼠被移动后又被判定一次 | 先快照 id 数组，再处理；`processed` 天然由快照保证唯一 |
| B4 | 敌人受伤后被销毁，继续读 `_e.x` 报错 | 每次访问前 `instance_exists` + `hp > 0` 判断；先传送后伤害 |
| B5 | boss / 鼹鼠 被误伤 | `is_boss`、`mouse_id == "mole"`、`target_type != "normal"` 三重过滤 |
| B6 | 多节敌人（车、鼠夹列车）只动头或只动身 | 先生成“禁止逆转名单”并回归测试；不确定的多节敌人默认排除 |
| B7 | 卡被啃死导致效果没触发 | 先 `invincible = true`（待确认），或保证起手动画足够短 |
| B8 | 冻结状态与父对象冲突 | 与 `obj_card_parent` 一致：`is_frozen` 时不推进触发计时 |
| B9 | 暂停时仍在计时/移动 | 统一在 Step 顶部 `if (global.is_paused) exit;` |
| B10 | 伤害重复结算 | 一次脉冲对每个 id 只调用一次 `event_user(0)` |
| B11 | 1000 伤害被星级或魔杖放大 | 固定常量；不写入星级 `atk` 数组，不接攻击力 buff 链 |
| B12 | 17/18 星越界 | 注册用 `false`，数组长度 17，Max/Ultra 保持关闭 |
| B13 | 旧存档缺少新解锁项 | 新 `unlock_item_id` 按项目现有“缺失即未解锁”规则处理，不写脏数据 |
| B14 | 资源未登记导致编译失败 | 新增 `obj_nizhuanniu`、`obj_nizhuanniu_effect` 到 `.yyp` 及对应 folder `.yy` |
| B15 | 商店价格与图片不一致 | `register_goods` 的 cost 用图片的 `60000`，若项目定价体系不同再单独确认 |

## 7. 注册与接入清单

1. `mod_slots_init.gml`：`register_card("nizhuanniu", obj_nizhuanniu, [...])`，三个 shape，`cost: 150`，`cooldown: 3000`（0 星基准，随后由星级数据覆盖），`plant_type: "normal"`，`feature_type: "normal"`，`target_card: "none"`，`is_gold: 0`。
2. `mod_cards_init.gml`：`mod_register_plant_lite("nizhuanniu", [...], false)`，三个 shape，数组长度 17，冷却用第 3.1 节，`cycle` 全 0。
3. `mod_info_island_init.gml`：图鉴文案必须覆盖 3*3 / 5*5、1000 物理伤害、对 boss 与鼹鼠无效、不支持技能。
4. `mod_shop_init.gml`：`register_goods("nizhuanniu", {type:"card", cost:"60000", unlock_item_id:"nizhuanniu", ...})`。
5. `FVM_Reborn_makk.yyp` 与 `folders`：登记新对象与资源，检查名称唯一、GUID 不冲突。
6. `mod_skill_init.gml`：**不新增**该卡技能注册。

推荐图鉴文案：

```
基础能力：将自身周围3*3范围内的普通老鼠逆转到其所在行的出生位置（最右边）。
 *星级影响[卡片冷却速度]，该防御卡不支持技能。
 *对boss、鼹鼠无效。

一转能力：被逆转的老鼠额外受到1000点物理伤害。

二转能力：逆转范围扩大到5*5。
```

## 8. 验收用例

| 编号 | 场景 | 预期 |
| --- | --- | --- |
| T1 | 0 星放置，范围内 1 只普通老鼠 | 起手动画后老鼠回到自己那行的出生线，卡片退场 |
| T2 | 16 星 | 冷却为 420 帧；其余行为不变 |
| T3 | shape 1（匀速逆转牛） | 被传送老鼠额外扣 1000；未被传送的不扣 |
| T4 | shape 2（光速逆转牛） | 3*3 外的上/下两行老鼠也被逆转并受伤，最远 5*5 |
| T5 | 范围内的 boss | 不传送、不受伤 |
| T6 | 范围内的鼹鼠 | 不传送、不受伤 |
| T7 | 空中 / 水中 / 地下老鼠 | `target_type != "normal"` 的全部不受影响 |
| T8 | 老鼠已在出生线 | 不重复传送、不受伤、不刷特效 |
| T9 | 多张逆转牛同时触发 | 每张各自结算一次，无重复伤害、无列表串用 |
| T10 | 触发时鼠标被其它子弹击杀 | 无对已销毁实例的读取，无报错 |
| T11 | 暂停 / 冻结 | 暂停不计时；冻结时不触发，解冻后行为一致 |
| T12 | 铲除卡片 | 按最终确认口径执行：一次性口径下不在 Destroy 里补触发 |
| T13 | 边界行（第 1 行、最后 1 行） | 不越界，不出现负行或超出 `global.grid_rows` |
| T14 | 旧存档 / 新存档 | 均可读取，新卡默认未解锁，不破坏已有数据 |
| T15 | 编译 | GameMaker VM 编译通过；如需发布 YYC 同样通过 |

数值验收：0 到 16 星冷却逐项与图片一致；Max / Ultra 不可用；重复触发、重复伤害为 0。

## 9. 待确认项（实现前锁定）

1. 触发口径：一次性触发（本文推荐）还是在场持续触发？持续触发必须补触发间隔。
2. 生命值：图片未给；是否按 `invincible = true` 处理。
3. 物理伤害是否无视护盾：本文按项目 `Other_10` 语义用直接扣血；如果应走护盾，改 `damage_type = "normal"`。
4. 传送目标：`birth_x`（真实出生点）还是右侧出生列中心；本文优先 `birth_x`。
5. 多节敌人名单（车辆、列车、召唤物）哪些禁止逆转。
6. 铲除 / 被摧毁时是否补触发一次。
7. 商店价格与解锁方式是否沿用图片的 60000 点券永久。

## 10. 实现顺序

1. 新建 `obj_nizhuanniu`，完成 Create 与精灵形态切换。
2. 在 `obj_enemy_parent` 追加 `birth_x / birth_y`。
3. 实现逆转脉冲（先只做传送，不做伤害），跑通 3*3 单行场景。
4. 加入 1000 物理伤害与 boss / 鼹鼠过滤。
5. 接入 5*5 二转范围。
6. 写入三处注册（卡池 / 星级数值 / 图鉴）与商店。
7. 补特效、音效、描述，最后执行第 8 节全部验收。

---

本方案基于两张图片与当前仓库代码编写；未执行 GameMaker 编译与运行时测试。落地前请先确认第 9 节待确认项。
