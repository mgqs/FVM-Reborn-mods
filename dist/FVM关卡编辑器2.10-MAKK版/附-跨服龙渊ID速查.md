# 跨服 / 龙渊 ID 速查（编辑器 & 实验室都能直接用）

编辑器里三个地方要填 ID：**基础信息页 → 地图精灵 / 先锋段音乐 / 精英段音乐 / BOSS段音乐**，**波次信息页 → 老鼠**。
下面是这三类 ID 的完整可用表，全部取自工程本身（`scripts\maps_init`、`scripts\mod_maps_init`、`scripts\*_enemy_init`、`sprites\`、`sounds\`），不是猜的。

> 说明：跨服/龙渊用的音乐和地图精灵**工程里本来就有**，不是这次新增的资源；这次加进 2.10 编辑器的是「跨服系列 / 龙渊系列」两个老鼠分组和 4 色龙柱物件。

---

## 1. 地图精灵（`map_sprite`，填 `spr_xxx`）

| chapter | 关卡 id（文件名称） | 中文名 | map_sprite |
| --- | --- | --- | --- |
| 跨服 | `ancient_castle_0` | 古堡初探 | `spr_mod_ancient_castle_0` |
| 跨服 | `ancient_castle_1` | 古堡一障 | `spr_mod_ancient_castle_1` |
| 跨服 | `ancient_castle_2` | 古堡二子 | `spr_mod_ancient_castle_2` |
| 跨服 | `ancient_castle_3` | 古堡三轮 | `spr_mod_ancient_castle_3` |
| 跨服 | `ancient_castle_4` | 古堡四影 | `spr_mod_ancient_castle_4` |
| 跨服 | `ancient_castle_5` | 古堡五崩 | `spr_mod_ancient_castle_5` |
| 跨服 | `ancient_castle_6` | 古堡六阶 | `spr_mod_ancient_castle_6` |
| 跨服 | `ancient_castle_7` | 古堡终破 | `spr_mod_ancient_castle_7` |
| 跨服 | `nightmare_sky_0` | 天空静夜 | `spr_mengyantiankong_0` |
| 跨服 | `nightmare_sky_1` | 天空蒙雾 | `spr_mengyantiankong_1` |
| 跨服 | `nightmare_sky_2` | 天空薄雾 | `spr_mengyantiankong_2` |
| 跨服 | `nightmare_sky_3` | 天空迷雾 | `spr_mengyantiankong_3` |
| 跨服 | `nightmare_sky_4` | 天空浓雾 | `spr_mengyantiankong_4` |
| 跨服 | `nightmare_sky_5` | 天空重雾 | `spr_mengyantiankong_5` |
| 跨服 | `nightmare_sky_6` | 天空毒雾 | `spr_mengyantiankong_6` |
| 跨服 | `nightmare_sky_7` | 天空破雾 | `spr_mengyantiankong_7` |
| 跨服 | `zhuore_0` | 炼狱之始 | `spr_zhuorediyu` |
| 跨服 | `zhuore_1` | 炼狱之觉 | `spr_zhuorediyu` |
| 跨服 | `zhuore_2` | 炼狱之风 | `spr_zhuorediyu` |
| 跨服 | `zhuore_3` | 炼狱之扇 | `spr_zhuorediyu` |
| 跨服 | `zhuore_4` | 炼狱之轮 | `spr_zhuorediyu` |
| 跨服 | `zhuore_5` | 炼狱之影 | `spr_zhuorediyu` |
| 跨服 | `zhuore_6` | 炼狱之锁 | `spr_zhuorediyu` |
| 跨服 | `zhuore_7` | 炼狱之末 | `spr_zhuorediyu` |
| 龙渊 | `longyuan_1_hard` | 松露大厅（日） | `spr_songludating_ri` |
| 龙渊 | `longyuan_2_hard` | 松露大厅（夜） | `spr_songludating_ye` |
| 龙渊 | `longyuan_3_hard` | 百味关 | `spr_baiweiguan` |
| 龙渊 | `longyuan_4_hard` | 赤霞渡（日） | `spr_chixiadu_ri` |
| 龙渊 | `longyuan_5_hard` | 赤霞渡（夜） | `spr_chixiadu_ye` |
| 龙渊 | `longyuan_6_hard` | 奶盖桥 | `spr_naigaiqiao` |

跨服只有 **3 张底图**（古堡 8 关共用一套 8 张、天空 8 张、炼狱 8 关共用 1 张）：

| spr id | 中文 | 用在哪 |
| --- | --- | --- |
| spr_mod_ancient_castle_0 ~ _7 | 古堡 0~7 | ancient_castle_0~7（跨服·古堡章节） |
| spr_mengyantiankong_0 ~ _7 | 天空静夜 / 蒙雾 / 薄雾 / 迷雾 / 浓雾 / 重雾 / 毒雾 / 破雾 | nightmare_sky_0~7（跨服·天空章节） |
| spr_zhuorediyu | 灼热地狱 | zhuore_0~7（跨服·炼狱章节） |
| spr_songludating_ri | 松露大厅·白天 | longyuan_1_hard |
| spr_songludating_ye | 松露大厅·黑夜 | longyuan_2_hard |
| spr_baiweiguan | 白薇馆（百味关） | longyuan_3_hard |
| spr_chixiadu_ri | 赤霞都·白天（赤霞渡日） | longyuan_4_hard |
| spr_chixiadu_ye | 赤霞都·黑夜（赤霞渡夜） | longyuan_5_hard |
| spr_naigaiqiao | 奶盖桥 | longyuan_6_hard |

---

## 2. BGM（`pre_music` / `elite_music` / `boss_music`）

| 音乐 id | 用途 | 音频文件 |
| --- | --- | --- |
| `mus_cross_server_night` | 跨服·夜（古堡 0-7、天空 0-7） | `mus_cross_server_night.wav` |
| `mus_cross_server_night_boss` | 跨服·夜 BOSS（古堡/天空的 BOSS 波） | `mus_cross_server_night_boss.wav` |
| `mus_cross_server_day` | 跨服·日（炼狱 0-7） | `mus_cross_server_day.wav` |
| `mus_cross_server_day_boss` | 跨服·日 BOSS（炼狱的 BOSS 波） | `mus_cross_server_day_boss.wav` |
| `day_xianfeng` | 龙渊·白天先锋（大厅日 / 赤霞渡日） | `day_xianfeng.mp3` |
| `day_jingying` | 龙渊·白天精英 | `day_jingying.mp3` |
| `night_xianfeng` | 龙渊·黑夜先锋（大厅夜 / 百味关） | `night_xianfeng.mp3` |
| `night_jingying` | 龙渊·黑夜精英 | `night_jingying.mp3` |
| `erqi_xianfeng` | 龙渊·二期先锋（赤霞渡夜 / 奶盖桥） | `erqi_xianfeng.mp3` |
| `erqi_jingying` | 龙渊·二期精英 | erqi_jingying.mp3`                |
| `Boss_zhandou` | 龙渊·BOSS（6 关通用） | `Boss_zhandou.mp3` |

每关的推荐填法（和工程里 `maps_init` / `mod_maps_init` 完全一致）：

| 关卡 id | 先锋段 | 精英段 | BOSS段 |
| --- | --- | --- | --- |
| `ancient_castle_0` | `mus_cross_server_night` | `mus_cross_server_night` | `mus_cross_server_night_boss` |
| `ancient_castle_1` | `mus_cross_server_night` | `mus_cross_server_night` | `mus_cross_server_night_boss` |
| `ancient_castle_2` | `mus_cross_server_night` | `mus_cross_server_night` | `mus_cross_server_night_boss` |
| `ancient_castle_3` | `mus_cross_server_night` | `mus_cross_server_night` | `mus_cross_server_night_boss` |
| `ancient_castle_4` | `mus_cross_server_night` | `mus_cross_server_night` | `mus_cross_server_night_boss` |
| `ancient_castle_5` | `mus_cross_server_night` | `mus_cross_server_night` | `mus_cross_server_night_boss` |
| `ancient_castle_6` | `mus_cross_server_night` | `mus_cross_server_night` | `mus_cross_server_night_boss` |
| `ancient_castle_7` | `mus_cross_server_night` | `mus_cross_server_night` | `mus_cross_server_night_boss` |
| `nightmare_sky_0` | `mus_cross_server_night` | `mus_cross_server_night` | `mus_cross_server_night_boss` |
| `nightmare_sky_1` | `mus_cross_server_night` | `mus_cross_server_night` | `mus_cross_server_night_boss` |
| `nightmare_sky_2` | `mus_cross_server_night` | `mus_cross_server_night` | `mus_cross_server_night_boss` |
| `nightmare_sky_3` | `mus_cross_server_night` | `mus_cross_server_night` | `mus_cross_server_night_boss` |
| `nightmare_sky_4` | `mus_cross_server_night` | `mus_cross_server_night` | `mus_cross_server_night_boss` |
| `nightmare_sky_5` | `mus_cross_server_night` | `mus_cross_server_night` | `mus_cross_server_night_boss` |
| `nightmare_sky_6` | `mus_cross_server_night` | `mus_cross_server_night` | `mus_cross_server_night_boss` |
| `nightmare_sky_7` | `mus_cross_server_night` | `mus_cross_server_night` | `mus_cross_server_night_boss` |
| `zhuore_0` | `mus_cross_server_day` | `mus_cross_server_day` | `mus_cross_server_day_boss` |
| `zhuore_1` | `mus_cross_server_day` | `mus_cross_server_day` | `mus_cross_server_day_boss` |
| `zhuore_2` | `mus_cross_server_day` | `mus_cross_server_day` | `mus_cross_server_day_boss` |
| `zhuore_3` | `mus_cross_server_day` | `mus_cross_server_day` | `mus_cross_server_day_boss` |
| `zhuore_4` | `mus_cross_server_day` | `mus_cross_server_day` | `mus_cross_server_day_boss` |
| `zhuore_5` | `mus_cross_server_day` | `mus_cross_server_day` | `mus_cross_server_day_boss` |
| `zhuore_6` | `mus_cross_server_day` | `mus_cross_server_day` | `mus_cross_server_day_boss` |
| `zhuore_7` | `mus_cross_server_day` | `mus_cross_server_day` | `mus_cross_server_day_boss` |
| `longyuan_1_hard` | `day_xianfeng` | `day_jingying` | `Boss_zhandou` |
| `longyuan_2_hard` | `night_xianfeng` | `night_jingying` | `Boss_zhandou` |
| `longyuan_3_hard` | `night_xianfeng` | `night_jingying` | `Boss_zhandou` |
| `longyuan_4_hard` | `day_xianfeng` | `day_jingying` | `Boss_zhandou` |
| `longyuan_5_hard` | `erqi_xianfeng` | `erqi_jingying` | `Boss_zhandou` |
| `longyuan_6_hard` | `erqi_xianfeng` | `erqi_jingying` | `Boss_zhandou` |

**注意**：龙渊用的不是 `mus_` 开头的新名字，而是老资源名 `day_xianfeng` / `night_xianfeng` / `erqi_xianfeng` / `Boss_zhandou`（文件是 `.mp3`，不是 `.wav`，但资源名照填即可）。

---

## 3. 老鼠 ID（波次 json 里的 `enemy_list[].type`）

### 跨服系列（26 只，group = `kuafu`）

| id | 中文名 | HP | 地形 | BOSS |
| --- | --- | --- | --- | --- |
| `kuafu_boss_buzz` | 变异嗡嗡中尉 | 50000 | 陆地 | ✅ |
| `kuafu_boss_julie` | 变异迷雾朱莉 | 50000 | 陆地 | ✅ |
| `kuafu_boss_pete` | 变异钢爪皮特 | 40000 | 陆地 | ✅ |
| `kuafu_boss_baron` | 变异针头男爵 | 30000 | 陆地 | ✅ |
| `kuafu_boss_xiaoming` | 变异酷帅小明 | 60000 | 陆地 | ✅ |
| `kuafu_rambo` | 兰博僵尸鼠 | 1100 | 陆地 |  |
| `kuafu_pirate` | 加勒比僵尸鼠 | 3000 | 陆地 |  |
| `kuafu_gift` | 多宝太郎僵尸鼠 | 900 | 陆地 |  |
| `kuafu_cucumber` | 黄瓜平民僵尸鼠 | 480 | 陆地 |  |
| `kuafu_flute` | 魔笛僵尸鼠 | 1800 | 陆地 |  |
| `kuafu_football_fan` | 苹果球迷僵尸鼠 | 960 | 陆地 |  |
| `kuafu_iron_pan` | 煎蛋铁锅僵尸鼠 | 2000 | 陆地 |  |
| `kuafu_skateboard` | 橘子滑板僵尸鼠 | 800 | 陆地 |  |
| `kuafu_landlady` | 变异房东僵尸鼠 | 1800 | 陆地 |  |
| `kuafu_wrestler` | 摔跤手僵尸鼠 | 8100 | 陆地 |  |
| `kuafu_panda` | 变异熊猫僵尸鼠 | 3600 | 陆地 |  |
| `kuafu_armour` | 特种装甲僵尸鼠 | 43200 | 陆地 |  |
| `kuafu_glider` | 滑翔僵尸鼠 | 600 | 陆地 |  |
| `kuafu_barrier` | 路障僵尸鼠 | 1100 | 陆地 |  |
| `kuafu_airbrone` | 空降爆破僵尸鼠 | 1800 | 陆地 |  |
| `kuafu_waste_flying` | 废品飞兵僵尸鼠 | 960 | 陆地 |  |
| `kuafu_paratrooper` | 伞兵僵尸鼠 | 900 | 陆地 |  |
| `kuafu_bat` | 蝙蝠僵尸鼠 | 880 | 陆地 |  |
| `kuafu_hopper` | 变异跳跳僵尸鼠 | 370 | 陆地 |  |
| `kuafu_soar` | 腾空僵尸鼠 | 3500 | 陆地 |  |
| `kuafu_jet` | 喷气僵尸鼠 | 10500 | 陆地 |  |

### 龙渊系列（18 只，group = `longyuan`）

| id | 中文名 | HP | 地形 | BOSS |
| --- | --- | --- | --- | --- |
| `longyuan_pingmin` | 龙渊平民鼠 | 200 | 陆地 |  |
| `longyuan_dijing` | 地精鼠 | 500 | 陆地 |  |
| `longyuan_dongfeng` | 东风鼠 | 2340 | 陆地 |  |
| `longyuan_gaoqiao` | 高跷鼠 | 660 | 陆地 |  |
| `longyuan_kailu` | 开路鼠 | 1000 | 陆地 |  |
| `longyuan_langyabang` | 狼牙棒鼠 | 6000 | 陆地 |  |
| `longyuan_longmu` | 龙母鼠 | 200 | 陆地 |  |
| `longyuan_yaoguan` | 药罐鼠 | 2500 | 陆地 |  |
| `longyuan_zhibuji` | 织布机鼠 | 3500 | 陆地 |  |
| `longyuan_zhinian` | 执念鼠 | 3000 | 陆地 |  |
| `longyuan_fuzhou` | 符咒鼠 | 3000 | 陆地 |  |
| `longyuan_zhizhujing` | 蜘蛛精鼠 | 800 | 陆地 |  |
| `longyuan_fuzhou_minion` | 符咒随从鼠 | 200 | 陆地 |  |
| `ly_diting` | 谛听鼠 | 200000 | 陆地 |  |
| `ly_hengha` | 哼哈将军 | 150000 | 陆地 |  |
| `ly_mengpo` | 孟婆鼠 | 300000 | 陆地 |  |
| `ly_wuchang` | 无常鼠 | 250000 | 陆地 |  |
| `ly_youshen` | 游神鼠 | 100000 | 陆地 |  |

---

## 4. 在实验室（Laboratory）里怎么写

实验室读的是同一份关卡 json，字段名一模一样，敌人 id 直接写上面表里的字符串：

```json
{
  "level_name": "longyuan_1_hard",
  "map_sprite": "spr_songludating_ri",
  "pre_music": "day_xianfeng",
  "elite_music": "day_jingying",
  "boss_music": "Boss_zhandou",
  "waves": [
    {
      "wave_index": 1,
      "boss_wave": false,
      "boss": "", "boss_1_hp_modify": 1,
      "boss2": "", "boss_2_hp_modify": 1,
      "subwaves": [
        {
          "subwave_index": 0,
          "local_min_wave_time": -1,
          "local_max_wave_time": -1,
          "enemy_list": [
            { "type": "longyuan_pingmin", "row": -1, "prosperity": 0 },
            { "type": "longyuan_kailu",   "row": 3,  "prosperity": 0 },
            { "type": "ly_youshen",       "row": -1, "prosperity": 0 }
          ]
        }
      ]
    }
  ]
}
```

- `row`：1~7 = 指定行（1 基），`-1` = 随机行
- BOSS 波就把 `boss_wave` 设 true，`boss` 填 `ly_mengpo` 这类 id，`boss2` 可再叠一只
- 地形（`map[].type`）只认 `normal` / `water` / `obstacle`；地图物件写 `map[r][c].object = ["ly_longzhu_1"]`

## 5. 地图物件 id（`object` 数组）

| id | 中文名 | 说明 |
| --- | --- | --- |
| `obstacle` | 障碍物 | 原版，暗红底，可直接放卡在别的格 |
| `wind_tunnel` | 风洞 | 原版 |
| `lava` | 岩浆 | 原版 |
| `seawater` | 海水 | 原版 |
| `ly_longzhu_1` | 龙柱·懒惰(橙) | 周期效果：懒惰 |
| `ly_longzhu_2` | 龙柱·暴食(绿) | 周期效果：暴食 |
| `ly_longzhu_3` | 龙柱·贪婪(黄) | 周期效果：贪婪 |
| `ly_longzhu_4` | 龙柱·傲慢(青) | 周期效果：傲慢 |
| `ly_ludi_track_1` | 岩浆轨道·陆地1 | 奶盖桥专用 |
| `ly_ludi_track_2` | 岩浆轨道·陆地2 | 奶盖桥专用 |

龙柱格子的地形要写 `obstacle`（和原版 longyuan_1_hard.json 一致），引擎只会在该格生成龙柱对象、不再生成地形贴图。
