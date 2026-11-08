# BOSS 随机音乐

> 设置 → 音频设置 → 第三行「BOSS 随机音乐」。
> 开关打开后，**每一场 BOSS 波会从本地曲库里随机挑一首**，不再固定播关卡自带的 `boss_music`。

---

## 1. 曲库放哪

```
%LOCALAPPDATA%\FVM_Reborn_makk\boss_music\
```

也就是 `C:\Users\<你>\AppData\Local\FVM_Reborn_makk\boss_music\`。

**只认 `.ogg`**。放 mp3/flac 进去不认，原因在下一节。

第一次打开设置页时会自动创建这个文件夹。

### 内置曲库（随游戏分发）

游戏自带 10 首，放在项目里的 `datafiles/boss_music_pack/`，打包后位于游戏目录的 `boss_music_pack/`：

| # | 曲目 | 大小 |
|---|---|---|
| 1 | 周杰伦 - 晴天 | 5.6 MB |
| 2 | 阿YueYue,刘兆宇 - 冬眠 | 3.9 MB |
| 3 | 蔡健雅 - 红色高跟鞋 | 4.5 MB |
| 4 | 未知歌手 - 七里香 | 6.7 MB |
| 5 | 杨丞琳 - 雨爱 | 6.1 MB |
| 6 | 张芸京 - 偏爱 | 4.7 MB |
| 7 | 周杰伦 - 花海 | 5.3 MB |
| 8 | 周杰伦 - 明明就 | 5.4 MB |
| 9 | 周杰伦 - 青花瓷 | 5.1 MB |
| 10 | (猴叫司凤版)-泡泡心 | 3.3 MB |

合计 **50.7 MB**。新设备装上就能用，不需要往曲库里放任何东西。

**两级扫描**：`boss_music_scan()` 先扫玩家目录（`boss_music\*.ogg`），再追加内置清单，两者进同一个随机池。

**要加一首内置歌**，得改三处：

1. 文件放进 `datafiles/boss_music_pack/`
2. `.yyp` 的 `IncludedFiles` 加一条（`filePath: "datafiles/boss_music_pack"`）
3. `scripts/boss_music/boss_music.gml` 的 `boss_music_builtin_list()` 里加文件名

**为什么不直接扫目录**：打包版里 `file_find_first` 枚举 included files 的行为在不同运行时上不一致（有的能扫到有的不能），所以内置曲库走**固定清单 + 逐个 `audio_create_stream`**，加载失败的自动换下一首（最多试 8 首）。

---

## 2. 为什么只能 .ogg

GM 加载外部音频只有一个入口：

```gml
audio_create_stream(path)   // 仅支持 .ogg
```

mp3 / flac / wav 没有对应的运行时 API（`audio_create_stream` 会返回 -1）。所以曲库必须转成 ogg。

---

## 3. 怎么把网易云的歌变成 ogg

### 步骤一：在客户端里下载

网易云音乐 → 找歌单「喜欢FVMBOSS曲库」→ 全选 → 下载。
你这台机器下载目录设的是 `D:\CloudMusic`（目前是空的）。

### 步骤二：一键转码

项目根目录跑：

```powershell
# 先看会转什么（不写文件）
& "C:\Users\18203\.dsh\dsh-runtimes\dsh-plugin-desktop-primary-runtime\dependencies\python\python.exe" tools\boss_music_import.py "D:\CloudMusic"

# 确认无误，真转
& "C:\Users\18203\.dsh\dsh-runtimes\dsh-plugin-desktop-primary-runtime\dependencies\python\python.exe" tools\boss_music_import.py "D:\CloudMusic" --apply
```

脚本会自动：

- 递归扫源目录里所有 `.mp3 / .flac / .m4a / .wav / .aac / .wma / .ape`
- 从 GameMaker runtime 里找自带的 `ffmpeg.exe`（不用你另装）
- 转成 `libvorbis` ogg（默认 `-q:a 6` ≈ 128 kbps），输出到曲库目录
- 重名自动加 `_2`、`_3`

音质想更好就加 `--quality 8`（文件大约翻倍）。

### VIP 歌下成 `.ncm` 怎么办（重要）

网易云默认把 VIP/付费曲目下载成 **`.ncm` 加密格式**，放在 `VipSongsDownload` 子目录。
这类文件**不能**直接转，也不能直接被播放器读。

本项目实测：`tools/ncm_decrypt.py` 能正确解出文件头（`CTENFDAM`）、RC4 key（AES 解出后前 17 字节为 `neteasecloudmusic`）与封面图边界，但解出的音频段没有 MP3 帧结构 —— 说明这批 VIP 文件的音频层与公开的 ncmdump 格式不同，**本地解不开**。

**但可以绕过去**：直接从公开音乐 API 取原始音频，不需要 ncm。

```powershell
# 只看会抓什么
& "C:\Users\18203\.dsh\dsh-runtimes\dsh-plugin-desktop-primary-runtime\dependencies\python\python.exe" tools\fetch_vip_songs.py

# 真抓 + 转码
& "C:\Users\18203\.dsh\dsh-runtimes\dsh-plugin-desktop-primary-runtime\dependencies\python\python.exe" tools\fetch_vip_songs.py --apply
```

脚本读 `D:\CloudMusic\VipSongsDownload` 里 `.ncm` 的**文件名**当歌名（`歌手 - 歌名`），
去 GD Studio 音乐 API 搜同款、拿 320kbps 直链、下载、再用 ffmpeg 转成 ogg 放进曲库。
文件名不需要和曲库里一致，脚本会自动跳过已存在的。

> `--br 192` 可以省流量；偶尔遇到 503，重跑一次即可（脚本对每首会重试 3 次）。

网易云那边如果还想自己下，就在 **设置 → 下载设置 → 下载格式** 选 **MP3**（不要选「高品质/无损」），重新下载出来就是明文。

### 如果歌还在网易云的 `.uc` 缓存里

`%LOCALAPPDATA%\Netease\CloudMusic\Cache\Cache\*.uc` 是另一套加密缓存，同样不能直接转。

---

## 4. 实际行为

| 情况 | 结果 |
|---|---|
| 开关关 | 播关卡自带 `boss_music`，与改动前完全一致 |
| 开关开 + 曲库有歌 | 每次进 BOSS 波随机一首，**同一场战斗只抽一次**；内置 BOSS 音乐被 `audio_stop_sound` 停掉 |
| 开关开 + 玩家曲库为空 | 只用内置 10 首，仍能随机 |
| 开关开 + 玩家曲库也为空且内置缺失 | 静默回退自带 `boss_music`，不报错、不弹窗 |
| 开关开 + 某首歌损坏 | `audio_create_stream` 返回 -1 → 回退自带音乐 |
| 精英波（elite wave） | 不受影响，仍用关卡 `elite_music` |
| 没有 BOSS 的关卡 | 不触发，全程播关卡 `pre_music` |

随机范围包含刚播过的那首（不记忆历史），连续两场撞歌是正常的。

### 开关长什么样

用的是 `obj_setting_toggle` —— 和「游戏设置」页里抽卡版 / 欧皇版 / 随机礼盒 / 海克斯那四个勾选**完全同一个控件**
（`spr_option_setting_toggle`，64×64，5 帧开合动画，点击有回弹）。

位置在音频设置页第三行：`[✓] BOSS 随机音乐 ............ 40 首`。
悬停会提示曲库路径。

### 为什么第一版没生效（已修）

两个独立问题：

1. **开关被建到了「画面设置」页**：`draw_audio_page()` 才是音频页，第一版误写进 `draw_settings_page()`，
   所以音频页只看得到标签、看不见勾选框。
2. **文件访问用了绝对路径**：`file_find_first` / `audio_create_stream` 在 GM 沙盒模式下只认
   相对游戏存档目录的路径，喂 `C:\Users\...\boss_music\*.ogg` 会扫到 0 个文件 →
   `boss_music_resolve()` 一直返回 fallback → 听起来"开了没反应"。

现在 `boss_music_scan()` 先用 `boss_music\*.ogg` 相对路径扫，扫不到再用绝对路径兜底；
`audio_create_stream` 加载失败也会换绝对路径重试一次。

---

## 5. 实现位置

| 文件 | 作用 |
|---|---|
| `scripts/boss_music/boss_music.gml` | 扫描曲库、随机选取、流的生命周期管理 |
| `scripts/boss_music/boss_music.yy` | 资源描述 |
| `objects/obj_battle/Step_2.gml:207` | `new_battle_music = boss_music_resolve(global.level_data.boss_music)` |
| `objects/obj_battle_music_controller/Other_5.gml` | 房间结束时销毁本次创建的流 |
| `objects/obj_game_init/Create_0.gml:187` | 从 `config.ini` 读 `boss_music_random` |
| `objects/obj_setting_toggle/Create_0.gml` | 开关初始状态 |
| `objects/obj_setting_toggle/Mouse_4.gml` | 点击后写 `global.boss_music_random` + 落 ini |
| `objects/obj_config_menu/Step_0.gml:78-81` | 音频页创建开关（y+61 第三行） |
| `objects/obj_config_menu/Draw_0.gml` | 「BOSS 随机音乐」标签 + 曲库曲目数 |
| `tools/boss_music_import.py` | 本地音乐 → ogg 转码工具 |
| `tools/fetch_vip_songs.py` | 从公开音乐 API 抓 VIP 曲目 → ogg（绕过 ncm） |
| `tools/ncm_decrypt.py` | ncm 结构解析（备用；本地解不开 VIP 曲目，注释里有卡点分析） |

### 为什么流不在切歌那一刻销毁

`obj_battle_music_controller` 的 `Other_10` 逻辑是：

```gml
audio_stop_sound(battle_music)   // 旧 id
battle_music = new_battle_music
audio_play_sound(battle_music, 0, true)
```

如果 `boss_music_resolve()` 在返回新流之前就把旧流 `audio_destroy_stream` 了，
上面第一行会拿一个已销毁的索引去 `audio_stop_sound` → 报「索引不映射到音频资产」。

所以流只在 `Other_5`（Room End）统一回收，一场战斗最多累积 1~2 个，内存可忽略。

---

## 6. 退回

**只关功能**：设置里把开关关掉即可，代码照常跑。

**完全移除**：

```powershell
Copy-Item '.workbuddy\backup\boss_music_20261108\*' -Destination . -Force   # 不推荐，路径是打平的
```

更干净的方式：

```powershell
git checkout -- objects/obj_game_init/Create_0.gml objects/obj_setting_toggle objects/obj_config_menu objects/obj_battle/Step_2.gml objects/obj_battle_music_controller FVM_Reborn_makk.yyp
Remove-Item 'scripts\boss_music' -Recurse -Force
```

备份在 `.workbuddy\backup\boss_music_20261108\`（文件名带路径前缀，形如 `objects_obj_battle_Step_2.gml`）。
