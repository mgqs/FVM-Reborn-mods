# 永恒·抽卡难度实现方案

## 1. 目标

新增一个独立的“永恒·抽卡”难度。该难度只在自身模式下启用以下功能：

- 使用永恒级别的战斗强度。
- 禁用普通商店。
- 禁用诸神商店。
- 禁用所有关卡 JSON 中的 `card_unlock` 奖励。
- 关卡胜利后生成 `spr_lihe` 礼盒。
- 点击礼盒后播放礼盒动画。
- 动画结束后在胜利结算页面显示随机卡片。
- 显示对应的卡槽贴图、卡片贴图和卡片形态。
- 点击“确定”后保存奖励并返回地图主页面。

其他难度的胜利、结算、关卡奖励、商店和诸神商店逻辑保持原样。

## 2. 难度编号

现有难度编号继续保留：

```text
0 美味级
1 火山级
2 浮空级
3 星际级
4 永恒级
5 不朽级
6 永恒·抽卡
```

不要复用 `4` 或 `5`。项目中已经使用 `difficulty == 5` 处理不朽难度的奖励、出怪数量和战斗逻辑。

新增统一判断函数：

```gml
function is_eternal_gacha_mode() {
    return global.difficulty == 6;
}
```

## 3. 难度选择界面

修改：

- `objects/obj_difficulty_select_btn/Mouse_4.gml`
- `objects/obj_difficulty_select_btn/Draw_0.gml`
- `objects/obj_game_init/Create_0.gml`

将难度循环范围从 `0~5` 扩展到 `0~6`。

新增难度描述：

```text
永恒·抽卡：
永恒级敌人强度。
禁用商店、诸神商店和关卡卡片奖励。
通关后通过礼盒随机获得卡片或卡片形态。
```

困难关卡文件仍然复用现有逻辑：

```gml
if (global.difficulty >= 2) {
    load hard_level_file;
}
```

战斗强度建议复用不朽级。若需要独立配置，可以在 `obj_battle` 和 `obj_enemy_parent` 中增加：

```gml
if (global.difficulty == 6) {
    hp_ratio = 0.5;
    spawn_multiplier = 2;
}
```

## 4. 禁用商店和诸神商店

相关文件：

- `objects/obj_player_menu_btn/Mouse_4.gml`
- `objects/obj_gods_hall_enter/Mouse_4.gml`
- `objects/obj_gods_store_enter/Mouse_4.gml`

入口创建时不创建商店和诸神商店按钮；点击处理处仍然增加保护，防止其他代码直接打开界面：

```gml
if (is_eternal_gacha_mode()) {
    show_notice("永恒·抽卡模式无法使用商店", 60);
    exit;
}
```

诸神商店使用相同保护提示。

## 5. 禁用关卡卡片本体奖励

现有关卡奖励结算位于：

`objects/obj_battle_pause_manager/Step_2.gml`

原有 `card_unlock` 处理只对普通难度执行：

```gml
if (global.difficulty != 6) {
    var card_unlock_id_list = global.level_file.rewards[1].card_unlock;

    for (var i = 0; i < array_length(card_unlock_id_list); i++) {
        unlock_card(
            card_unlock_id_list[i],
            0,
            0,
            global.save_data.unlocked_items.max_skill_level
        );
    }
}
```

金币、材料、武器和宝石奖励是否保留可以继续沿用当前结算逻辑。只有关卡卡片本体奖励需要在难度 `6` 下跳过。

## 6. 统一胜利入口

当前 Boss 胜利代码分散在多个 `Destroy_0.gml` 中。建议新增脚本：

`scripts/battle_finish_win/battle_finish_win.gml`

统一函数：

```gml
function battle_finish_win() {
    if (global.game_over) return;

    global.game_over = true;
    global.is_paused = true;

    if (is_eternal_gacha_mode()) {
        instance_create_depth(
            room_width / 2,
            room_height / 2,
            -3001,
            obj_gacha_drop
        );
        return;
    }

    var over = instance_create_depth(
        room_width / 2,
        room_height / 2,
        -3001,
        obj_game_over
    );

    over.sprite_index = spr_win;
    audio_play_sound(snd_win, 0, 0);
}
```

将各个 Boss 的直接胜利结算代码替换为：

```gml
battle_finish_win();
```

普通难度仍然创建原来的 `obj_game_over`；只有难度 `6` 创建礼盒。

## 7. 礼盒对象

新增对象：

```text
objects/obj_gacha_drop/
    obj_gacha_drop.yy
    Create_0.gml
    Step_0.gml
    Mouse_4.gml
    Draw_0.gml
```

礼盒状态：

```text
0 等待点击
1 播放动画
2 动画结束
```

Create：

```gml
if (!is_eternal_gacha_mode()) {
    instance_destroy();
    exit;
}

sprite_index = spr_lihe;
image_index = 0;
image_speed = 0;
state = 0;
```

Mouse Left：

```gml
if (!is_eternal_gacha_mode()) exit;

if (state == 0) {
    state = 1;
    image_index = 0;
    image_speed = 1;
}
```

动画结束：

```gml
if (state == 1 && image_index >= image_number - 1) {
    image_speed = 0;
    image_index = image_number - 1;
    state = 2;

    global.gacha_reward = gacha_pick_random_reward();
    // 切换到特殊胜利结算显示
}
```

`spr_lihe` 已经包含多帧动画，可以直接使用 `image_speed` 播放。

## 8. 随机卡片和形态规则

新增脚本：

`scripts/gacha_random_card/gacha_random_card.gml`

抽取规则：

1. 未拥有卡片时，只能抽到该卡片的 `0` 形态。
2. 已拥有 `0` 形态后，可以抽到 `1` 形态。
3. 已拥有 `1` 形态后，可以抽到 `2` 形态。
4. 以此类推，不能跳过中间形态。
5. 已达到最大形态的卡片不进入“下一形态”候选池。

奖励候选项格式：

```gml
{
    id: card_id,
    shape: target_shape
}
```

推荐候选池逻辑：

```gml
function gacha_pick_random_reward() {
    var candidates = [];

    for (var i = 0; i < ds_list_size(global.player_deck); i += 2) {
        var card_id = global.player_deck[| i];
        var current_shape = -1;
        var target_shape = 0;

        if (is_card_unlocked(card_id)) {
            var info = get_card_info_simple(card_id);
            current_shape = info.shape;
            target_shape = current_shape + 1;
        }

        if (get_plant_shape_data(card_id, target_shape) != undefined) {
            array_push(candidates, {
                id: card_id,
                shape: target_shape
            });
        }
    }

    if (array_length(candidates) == 0) {
        return gacha_pick_fallback_reward();
    }

    return candidates[irandom(array_length(candidates) - 1)];
}
```

如果所有卡片都已经达到最大形态，需要定义兜底奖励。推荐方案是随机一张卡片并提升卡片等级，避免出现空奖励。

### 8.1 卡池数量和稀有度

当前注册表统计如下：

| 卡池 | 当前基础卡片数量 | 分类依据 |
|---|---:|---|
| 金卡 | 35 | `scripts/mod_slots_init/mod_slots_init.gml` 中已有 `is_gold: 1` |
| 生肖卡 | 12 | 现有生肖卡注册项：9 个模组生肖卡和 3 个基础生肖卡 |
| 普通卡 | 101 | 其余基础卡片 |
| 合计 | 148 | `cards_init.gml` 与 `mod_slots_init.gml` 的基础卡片 ID 合计 |

项目当前没有统一的卡片稀有度字段，因此不要根据卡片名称在抽卡代码中硬编码判断。建议在卡片注册数据中增加：

```gml
rarity: "gold"    // 金卡
rarity: "zodiac"  // 生肖卡
rarity: "normal"  // 普通卡
```

推荐使用类别概率：

| 类别 | 抽取概率 | 类别内单张卡片概率（按当前数量） |
|---|---:|---:|
| 金卡 | 10% | `10% / 35 = 0.2857%` |
| 生肖卡 | 20% | `20% / 12 = 1.6667%` |
| 普通卡 | 70% | `70% / 101 = 0.6931%` |

这样可以让生肖卡保持稀有主题，同时让金卡维持较低的整体出现率。类别内仍然是完全随机，不会因为某张卡片排在前面而增加概率。

如果希望严格做到“每张基础卡片等概率”，则可以把类别概率改为按数量分布：金卡 `23.65%`、生肖卡 `8.11%`、普通卡 `68.24%`。默认实现采用上面的 `10% / 20% / 70%` 方案。

### 8.2 形态候选池和类别概率

概率应当作用在“可获得的下一形态候选项”上：

1. 先按卡片当前形态筛选出可获得的下一形态。
2. 按候选项所属卡片的 `rarity` 分成金卡、生肖卡、普通卡三个列表。
3. 按 `10% / 20% / 70%` 选择一个类别。
4. 在选中的类别列表中均匀随机选择一张卡片。
5. 发放该卡片的下一形态。

如果某个类别当前没有可获得候选项，不应让抽卡失败。建议把该类别的概率转移到其他仍有候选项的类别，再进行一次归一化抽取。例如金卡全部满形态时，将剩余的 `10%` 按生肖卡和普通卡的原比例重新分配。

## 9. 胜利结算页面

修改：

`objects/obj_battle_pause_manager/Draw_0.gml`

结算页面增加难度分支：

```gml
if (global.difficulty == 6) {
    // 显示抽卡奖励
} else {
    // 原有结算页面
}
```

难度 `6` 的结算页面显示：

```text
通关成功

随机获得卡片

[卡槽外框]
[卡片贴图]
卡片名称
形态：0 / 1 / 2

[确定]
```

卡片数据优先通过完整卡片注册表或 `get_plant_shape_data(card_id, shape)` 获取，避免因为卡片尚未解锁而无法读取贴图。

卡片贴图使用对应形态的数据：

```gml
var card_data = get_plant_shape_data(
    global.gacha_reward.id,
    global.gacha_reward.shape
);

draw_sprite_ext(
    card_data[? "sprite"],
    0,
    reward_x,
    reward_y,
    1,
    1,
    0,
    c_white,
    1
);
```

卡槽背景可以复用现有卡槽贴图，但不要直接创建 `obj_card_slot`，因为 `obj_card_slot` 包含战斗中的选卡、放置和冷却逻辑。

## 10. 确定按钮和保存

点击“确定”时才正式保存奖励：

```gml
if (!is_eternal_gacha_mode()) exit;
if (global.gacha_reward.received) exit;

unlock_card(
    global.gacha_reward.id,
    0,
    global.gacha_reward.shape,
    global.save_data.unlocked_items.max_skill_level
);

save_file(global.save_slot);
global.gacha_reward.received = true;

global.game_over = false;
global.is_paused = false;
global.menu_screen = true;
global.gui_stack.to(room_map);
```

抽卡数据只在难度 `6` 下初始化：

```gml
if (is_eternal_gacha_mode()) {
    global.gacha_reward = {
        id: "",
        shape: 0,
        received: false
    };
}
```

## 11. 模式隔离要求

以下逻辑必须全部检查 `global.difficulty == 6`：

- 礼盒创建。
- 礼盒显示。
- 礼盒鼠标点击。
- 礼盒动画结束处理。
- 随机卡片生成。
- 特殊胜利结算页面。
- 抽卡卡片绘制。
- 抽卡确定按钮。
- 抽卡奖励保存。
- 关卡 `card_unlock` 奖励屏蔽。
- 商店和诸神商店入口屏蔽。

其他难度必须继续使用：

- 原有 `obj_game_over` 胜利流程。
- 原有胜利结算页面。
- 原有关卡卡片奖励。
- 原有商店和诸神商店。

## 12. 文件清单

新增：

```text
scripts/battle_finish_win/battle_finish_win.gml
scripts/gacha_random_card/gacha_random_card.gml
objects/obj_gacha_drop/*
```

修改：

```text
objects/obj_difficulty_select_btn/Mouse_4.gml
objects/obj_difficulty_select_btn/Draw_0.gml
objects/obj_game_init/Create_0.gml
objects/obj_battle/Create_0.gml
objects/obj_battle/Step_0.gml
objects/obj_enemy_parent/Step_0.gml
objects/obj_battle_pause_manager/Step_2.gml
objects/obj_battle_pause_manager/Draw_0.gml
objects/obj_player_menu_btn/Mouse_4.gml
objects/obj_gods_hall_enter/Mouse_4.gml
objects/obj_gods_store_enter/Mouse_4.gml
多个 Boss 的 Destroy_0.gml
```

## 13. 推荐验收流程

1. 难度 `0~5` 通关，确认没有礼盒和抽卡结算内容。
2. 难度 `6` 通关，确认最后一只老鼠死亡后只生成一个礼盒。
3. 点击礼盒，确认 `spr_lihe` 完整播放一次。
4. 确认结算页面显示随机卡片和正确形态贴图。
5. 点击“确定”，确认卡片写入存档并返回地图。
6. 用只有 `0` 形态的卡片再次抽取，确认可以获得 `1` 形态。
7. 确认未拥有卡片只能先获得 `0` 形态。
8. 确认难度 `6` 不会获得 JSON 中的 `card_unlock` 卡片。
9. 确认难度 `6` 无法打开普通商店和诸神商店。
10. 确认普通难度的原结算、卡片奖励和商店行为没有变化。
