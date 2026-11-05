# 纹理编译 OOM 修复方案

> 症状：编译时报 11 条 `Texture compression failed for group "X"`，伴随
> `Unable to create a bitmap of size (2048x2048) - out of memory (System.OutOfMemoryException)`。
> 结论先说：**不是纹理压缩器坏了，不是你的新精灵有问题，是编译期提交内存被打穿。**
> 资源一张都不用删，像素一个都不用降。

---

## 1. 证据链（全部实测）

### 1.1 自定义压缩器本身完全正常

`extensions/TextureEncode/convTextures.bat` 的 BCN 分支：

```bat
if %ToolType%==BCN (
  "%~dp0bc7enc.exe" -g %CustomOptions% "%InputFile%" "%OutputFile%.dds"
  copy "%OutputFile%.dds" "%OutputFile%" /y
)
```

手工喂一张 `spr_clotho_star_up` 的帧（130×165 PNG，2,002 B）：

```
$env:ToolType='BCN'; $env:CustomOptions='-u4'    →  convTextures.bat
结果：6 ms 产出 22,324 B DDS，BC7 mode 5:82 / 6:1262 / 7:42，退出码 0
```

→ 编码器、bat、参数、BC7 profile 全部健康。

### 1.2 真实失败点在纹理打包阶段，错误码是「进程起不来」

命令行复现（`Igor.exe -options=<build.bff> -v -- Windows Compile`）日志尾部：

```
Source image: ...\_2048_131_BCN_-u4\enemy_tower_10.png 2048x2048
... Wrote DDS file ...\enemy_tower_10.custom.dds

Failed loading PNG file ...\_2048_131_BCN_-u4\enemy_floating_13.png
Failed loading PNG file ...\_2048_131_BCN_-u4\enemy_volcanic_12.png
系统找不到指定的文件。
cmd.exe exited with non-zero status (-1073741502)
```

`-1073741502` = `0xC0000142` = **STATUS_DLL_INIT_FAILED**：
子进程（`cmd.exe` → `bc7enc.exe`）在初始化阶段就死了。这不是压缩失败，
是系统已经分配不出进程需要的地址空间/桌面堆。

紧接着 `enemy_floating_13.png`、`enemy_volcanic_12.png` 直接「文件不存在」——
GMAssetCompiler 连页位图落盘都写不出来。

### 1.3 进程内 GC 数据：峰值 7.2 GB，回收量 5.46 GB

日志中段：

```
2 :: GC.Collect - diff=5459521424, current=7221901176, startSize = 1762379752
```

- `startSize` ≈ 1.76 GB（刚进纹理阶段）
- `current` ≈ **7.22 GB**（GC 后仍占）
- `diff` ≈ 5.46 GB（这一轮回收掉的垃圾）

即：每压完一批页，托管堆会涨到 7.2 GB 再做一次 GC。这是 GMAssetCompiler
在 131 页纹理 + 自定义压缩器下的正常峰值行为，**不是 bug**。

### 1.4 机器侧凑不齐这 7.2 GB

崩溃时刻实测：

| 指标 | 数值 |
|---|---|
| 物理内存 | 15.68 GB |
| 提交上限 | **16.68 GB** |
| 编译前已提交 | **11.6 GB**（IDE 1.6 GB + 4 个 DSH + 4 个 WorkBuddy + 系统） |
| 剩余可提交 | ≈ 5.0 GB |
| Igor 需要的峰值 | **7.2 GB** |

`11.6 + 7.2 = 18.8 GB > 16.68 GB` → 缺口约 **2.1 GB**，且在纹理阶段刚过半时就撞墙，
这正好解释了为什么失败的是 `effects` / `enemy_floating` / `enemy_volcanic` 这些
**排在中后段的组**，而更早、页数更多的 `maps`(33 页) / `Default`(19 页) 反而编完了。

### 1.5 页文件是短板

```
C:\pagefile.sys   1024 - 2048 MB
D:\pagefile.sys   8192 - 16384 MB
AutomaticManagedPagefile = False
```

提交上限 16.68 GB ≈ 物理 15.68 + 页文件初始 1 GB。**上限完全由页文件决定**，
而 D 盘还有 193 GB 空闲没用上。

---

## 2. 根因

> GMAssetCompiler 在 131 张 2048×2048 纹理页上做 BC7 编码，托管堆峰值 7.2 GB；
> 机器提交上限只有 16.68 GB，编译前已被其它进程占掉 11.6 GB，缺口 2 GB 左右。
> 于是先从「页 PNG 落盘失败」，再到「子进程 0xC0000142」，最后连锁成 11 条
> `Texture compression failed`。

与以下因素**无关**（均已排除）：

| 怀疑对象 | 实测结论 |
|---|---|
| `bc7enc.exe` / `convTextures.bat` | 手工跑 6 ms 出 DDS，正常 |
| 今天新增的 300 个 PNG（`spr_kuafu_armour/panda/wrestler` 各 200 帧） | 实际尺寸与 .yy 完全一致，无 ≥1024px，合计只值约 4 页 |
| 今天新增的 2 个精灵（`spr_hex_mark`、`spr_kuafu_pete_claw_effect`） | 128×123、84×69，可忽略 |
| 纹理组配置 | `.yyp` 的 `TextureGroups` 一字节未动 |
| 资源缓存脏 | 缓存已清空重来，症状不变 |

---

## 3. 修复方案

### P1（推荐，根治，不动项目任何文件）加大 D 盘页文件

把 D 盘页文件上限从 16,384 MB 提到 49,152 MB。D 盘现有 193 GB 空闲，代价 48 GB 磁盘。

提交上限会从 16.68 GB 升到 ≈ 65 GB，编译期再也不会撞墙。

**做法（二选一）**

- 图形界面：`Win+R` → `sysdm.cpl` → 高级 → 性能「设置」→ 高级 → 虚拟内存「更改」
  → 选中 D 盘 → 自定义大小 → 初始 `16384` / 最大 `49152` → 设置 → 确定 → **重启**
- 或者：以管理员身份运行本仓库的 `tools\set_pagefile.ps1`，然后重启

> **状态：已执行（2026-11-05 13:17）**
> ```
> C:\pagefile.sys   1024-2048   MB   （未改）
> D:\pagefile.sys  16384-49152  MB   （已改，原 8192-16384）
> ```
> 注册表目标值已写入，**但当前生效的提交上限仍是 16.68 GB —— 必须重启才生效**。
> 重启后用 `tools\check_build_env.ps1` 确认第 2 节显示上限 ≥ 40 GB。

### P2（配合 P1 使用）编译前腾出提交内存

编译前关掉这些后台进程（实测合计约 3.6 GB 提交）：

- WorkBuddy × 4（338 + 203 + 169 + 159 MB）
- 多余的 DSH Desktop 实例（678 + 335 + 267 + 132 MB，只留当前这个）
- 浏览器多余标签、其它 IDE

编译前可以跑 `tools\check_build_env.ps1` 自检，输出提交余量够不够 8 GB。

### P3（可选，进一步降峰值，不降像素）

纹理页从 2048 提到 4096：总页数 **131 → 约 36**，`convTextures.bat` 调用次数
131 次降到 36 次，位图分配次数降 73%。

| 页尺寸 | 页数 | 目标位图总量 | 子进程调用次数 |
|---|---|---|---|
| 2048×2048 | 131 | ≈ 2.1 GB | 131 |
| 4096×4096 | ≈ 36 | ≈ 2.3 GB | 36 |

总字节几乎不变（略增），像素一张不减，只是装箱方式变了。
**注意**：4096 单页 64 MB，必须配合 P1 的页文件扩容，否则 2048 过不去、4096 更过不去
（之前 4096 也报错，是因为当时还有 5.5 GB 的残留 Igor 进程占着内存）。

改法：`options\windows\options_windows.yy` → `option_windows_texture_page: "4096x4096"`。
本仓库当前是 `"2048x2048"`。

### P4（不推荐，会改视觉）把整图背景单独成组

63 张 2005×1080 全屏地图背景在 `maps` 组里一张占一页（33 页的大头）。
给它们单独建组、`autocrop:false`、`border:0` 能减少装箱扫描开销，但**页数不会减少**，
因为 2005 > 2048-padding。要真降页只能缩放，那就降像素了 —— 按你的约束，这条跳过。

---

## 4. 附带发现（顺手记录，不致命）

1. **残留 Igor 进程**：编译失败后 `Igor.exe` 不退出，实测残留占 5.5 GB，会把后续
   每一次编译都拖死。**编译失败后务必在任务管理器里结束所有 `Igor.exe`**，
   或直接运行 `tools\kill_igor.ps1`。
2. **音频文件损坏**（3 处，GM 会自动强制转换，不中断编译）：
   - `sounds/snd_cold_brew_machine/snd_cold_brew_machine.wav` → malformed
   - `sounds/snd_spoon_rabbit/snd_spoon_rabbit.wav` → malformed
   - 另有 3 条 `Failed to parse return from ffmpeg, unable to determine samples duration.`
   建议之后重新导出这几条音效。
3. **构建缓存已被清空**：本次排查中途终止了 Igor，`GMS2CACHE\FVM_Reborn_FB75BF12\`
   下的 `macros.json` / `preferences.json` / `PlatformOptions.json` 等配置被清掉，
   只剩 `Default` 纹理目录。**下次在 IDE 里点一次构建就会自动重建，无需处理**；
   但在那之前命令行直接调 Igor 会报
   `The given key (asset_compiler_cache_directory) was not present in the dictionary`。

---

## 5. 验收

| # | 检查项 | 通过标准 |
|---|---|---|
| 1 | 页文件 | `Get-CimInstance Win32_PageFileSetting` 显示 D 盘 `16384-49152` |
| 2 | 提交上限 | ≥ 40 GB |
| 3 | 编译前提交余量 | ≥ 8 GB |
| 4 | 编译结果 | 不再出现 `Texture compression failed` |
| 5 | 不再出现 0xC0000142 | 日志无 `exited with non-zero status (-1073741502)` |
| 6 | 纹理页产物 | `GMS2CACHE\<项目>\Default\TextureGroups\_*_BCN_-u4\` 下 `.dds` 数量等于页数 |
| 7 | 出包 | `build\FVM_Reborn_makk.exe` 产出且能启动 |

---

## 6. 一句话总结

`bc7enc` 没坏、资源没坏、配置没坏 —— 是 131 页纹理把 GMAssetCompiler 顶到 7.2 GB，
而你的提交上限只有 16.68 GB 且已被占 11.6 GB。**把 D 盘页文件上限加到 49 GB，
编译前关掉多余后台进程，就能过。**
