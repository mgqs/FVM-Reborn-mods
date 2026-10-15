# FVM-Reb-OnlineVersion-main -> FVM-Reborn-mod：内置 Mod VM 与开发工具整体迁移方案

> 目标：把 `D:\\gameProject\\FVM-Reb-OnlineVersion-main` 中的 **游戏内 Mod 脚本虚拟机（BIN VM）**、Mod 注册器、地图编译链、原生扩展、懒加载和联机中继能力，完整、可验证地合并到 `D:\\gameProject\\FVM-Reborn-mod`，并保留目标项目现有 Lua 外部 Mod 系统。

> 重要说明：本文的“虚拟机”指运行在 GameMaker 进程内的 GML 字节码解释器，不是 VMware、VirtualBox 或 Hyper-V。系统虚拟机只作为可选的构建环境隔离工具。

## 0. 源项目 VM 的准确规格

源项目 `scripts/scr_command_VM/scr_command_VM.gml` 实现的是内存型、无寄存器、全内存寻址 VM：

- `VM_Create(mem_size = 32768)` 默认创建 **32,768 个内存槽位**，不是 32,768 MB 磁盘或内存。
- 每个槽位由类型和值组成，类型为整数、浮点数、字符串池索引。
- VM 维护函数表、返回类型、字符串池、字符串映射、命名数组和随机种子。
- `scr_command_VM.gml` 约 6,055 行；`scr_command_VM_opt_execute.gml` 约 5,004 行；调用桥约 258 行；`src_mod.gml` 约 2,057 行。
- 每个 Mod 单元可以拥有自己的 VM 状态，但共享已注册的游戏 API 函数；不需要为每个 Mod 启动操作系统级虚拟机。
- 解释器执行 `.bin`，编译器是 `LabMapCompiler.exe`；`.txt -> .bin` 是开发时编译步骤。

目标项目目前还有一套独立的 Lua 外部 Mod 系统：`external_mod_system.gml` 通过 `FvmNativeSupport.dll` 调用 `ModLuaCreate/ModLuaCall/ModLuaDestroy`。迁移必须让 BIN VM 与 Lua 系统并存，不能用源 DLL 或源加载器覆盖目标 Lua 接口。

## 1. 盘点结论

本次已按两边的全量文件清单、GameMaker 资源目录、GML/YY/YYP、文档、工具和二进制资产进行盘点：

| 项目 | 文件数约 | 关键内容 |
|---|---:|---|
| 源项目 | 67,431 | `FVM-reborn.yyp`、`scripts/src_mod`、`objects/obj_*_mod` |
| 目标项目 | 144,334 | `FVM_Reborn_makk.yyp`、`external_mod_system`、模板/导入/输出流程 |
| 源 `datafiles/mod` | 314 | 卡、武器、宝石、时装、敌人、子弹、特效、地图包 |
| 源 `LabMapCompiler` | 152 | EXE、C++ 源码、测试语料、地图脚本 |
| 源 `datafiles/mod开发文档` | 21 | Mod/VM/地图参考资料 |
| 源 `FvmNativeSupport` | 12 | 原生库源码、Lua 5.4.8 及依赖 |
| 源 `relay_server` | 3 | Python、EXE、C++ 中继器 |

源 `docs/mod_plugin_guide.md` 明确了 8 类 Mod：`cards`、`weapons`、`gems`、`attires`、`enemies`、`bullets`、`effects`、`maps`。通常一个单元由 `xxx.json`、`xxx.bin` 和 PNG/OGG/BIN 资源组成；VM 源码是 `.txt`，由 `LabMapCompiler.exe` 编译为 `.bin`。

目标已经有 `scripts/external_mod_system`、`scripts/mod_maps_init`、`objects/obj_mod_menu`、`FvmNativeSupport`、`extensions/WindowsNative`、`mod_templates`、`imports` 和 `output`。目标运行时数据根是 `%LOCALAPPDATA%\\FVM_Reborn_makk`，Mod 在 `mod`，实验室在 `laboratory`。因此不能整目录覆盖。

## 2. 总体策略

采用“目标做宿主、源做能力基线、分层增量合并”：

1. 固定目标当前可构建状态，建立 Git 标签、压缩快照和虚拟机快照。
2. 按运行时 GML/YY、数据资源、编译工具、原生二进制、文档拆分迁移。
3. 先合并 VM 执行器和通用 `obj_*_mod`，再合并注册器/初始化，最后导入内容 Mod。
4. 同名文件逐文件比较；保留目标数据根、网络字段、资源 ID 和已有行为。
5. 工具和 DLL 版本化；构建产物进入 staging，不污染源目录。
6. 每阶段有门禁和回滚点，全部通过后才默认启用。

禁止：覆盖 `FVM_Reborn_makk.yyp`、覆盖 `level_data`、把源 `datafiles/mod` 直接塞入目标 `datafiles`、只复制 BIN 不复制 JSON/资源、未核对位数就替换 DLL。

## 3. 目录映射

| 源路径 | 目标建议落点 | 规则 |
|---|---|---|
| `datafiles/mod/**` | `mod_source/**`，运行时导出到用户 Mod 目录 | 保持 cards/weapons 等层级 |
| `datafiles/mod开发文档/**`、`docs/mod_plugin_guide.md` | `docs/source-mod-reference/**` | 原文归档，另写目标差异 |
| `LabMapCompiler/**` | `tools/LabMapCompiler/**` | EXE、源码、README、tests、corpus 一起迁移 |
| `MapEditCreator/**` | `tools/MapEditCreator/**` | 保留编辑器配置和示例 |
| `FvmNativeSupport/**` | `FvmNativeSupport/**` | 与目标版本逐文件合并 |
| `extensions/WindowsNative/**` | `extensions/WindowsNative/**` | 同时核对 YY 扩展定义和 DLL |
| `datafiles/native/**` | `datafiles/native/**` | 只放运行时 DLL |
| `relay_server/**` | `tools/relay_server/**` | 与 GameMaker 资源分离 |
| `lazyloading_*.py` | `tools/lazyloading/**` | 迁移脚本、恢复脚本和依赖说明 |
| `scripts/src_mod/**` | 与 `external_mod_system` 建兼容层 | 禁止直接覆盖目标实现 |
| `objects/obj_*_mod/**` | 对应目标对象目录 | 同名对象语义合并并登记 YYP |

建议新增：`tools/migration/manifests`、`tools/migration/staging`、`mod_source/{cards,weapons,gems,attires,enemies,bullets,effects,maps}`。

## 4. 备份、清单和隔离虚拟机

迁移前执行：

```powershell
git status --short
git tag migration/before-online-mod-$(Get-Date -Format yyyyMMdd-HHmm)
Compress-Archive -Path 'D:\\gameProject\\FVM-Reborn-mod\\*' -DestinationPath 'D:\\gameProject\\FVM-Reborn-mod-before-migration.zip'
Get-ChildItem -Recurse -File 'D:\\gameProject\\FVM-Reb-OnlineVersion-main' |
  Get-FileHash -Algorithm SHA256 |
  Export-Csv 'tools/migration/manifests/source-sha256.csv' -NoTypeInformation
```

虚拟机是固定工具链和回滚边界，不是游戏运行时依赖。建议 Hyper-V/VMware/VirtualBox，Windows 10/11 x64，4 vCPU、16 GB 内存、120 GB 磁盘、NAT 网络。建立快照：`clean-os`、`tools-installed`、`baseline-build`、`migration-complete`。

安装顺序：

1. Windows 更新、Git、VC++ 运行库。
2. GameMaker Studio 2 和与项目匹配的 Runtime。
3. Visual Studio Build Tools：MSVC v142、Windows SDK、C++ 桌面工具；YYC 必须验证 VS 路径。
4. Python 3.x；深度懒加载脚本安装 Pillow，并准备 ffmpeg。
5. 7-Zip 和 Git submodule 工具。原生库需要执行：
   `git submodule update --init --recursive`
6. 可选 Node.js，用于已有文档工具。

记录到 `tools/migration/environment-lock.json`：GameMaker/Runtime、VS/MSVC/SDK、Python/Pillow、ffmpeg、7z、DLL SHA256、目标平台和 Git commit。项目放在虚拟机本地短路径，避免共享文件夹权限和性能问题。

## 5. 冲突分析和资源清单

新增 `scan_projects.ps1` 输出：

```text
source-files.csv / target-files.csv：相对路径、大小、SHA256
path-collisions.csv：同路径冲突
resource-ids.csv：YY/YYP 资源名、路径、类型
mod-assets.csv：json/bin/txt/png/ogg 配对
native-assets.csv：dll/exe/7z/ffmpeg 位数和依赖
```

冲突规则：

- 源新增：放入新目录；GameMaker 资源再登记进目标 YYP。
- 同名同 hash：保留目标，记录一致。
- 同名不同 hash：比较调用方、全局变量、资源 ID、数据根和网络字段后手工合并。

重点冲突：`obj_game_init`、`src_mod`/`external_mod_system`、`mod_maps_init`、VM 脚本、`obj_*_mod`、`room_init/room_map/room_laboratory`、WindowsNative 扩展和项目 YYP。

## 6. VM 运行时迁移

源 VM 块：

```text
_OBJECT_CFG       .bin 加载时执行一次
_OBJECT_CREATE    实例创建
_OBJECT_STEP      每帧
_OBJECT_DRAW      绘制
_OBJECT_DESTROY   销毁
```

`_OBJECT_CFG` 发生在没有实例时，适合 `VM_LoadSpritePerm_Ex`，不能读当前实例。对象实际执行块为：

```text
obj_card_mod   CREATE/STEP/DRAW/DESTROY
obj_weapon_mod CREATE/STEP/DRAW
obj_bullet_mod CREATE/STEP/DRAW/DESTROY
obj_effect_mod CREATE/STEP/DRAW/DESTROY
obj_enemy_mod  CREATE/STEP/DRAW/DESTROY
```

逐项合并并验证：

```text
目录扫描、mod_dir、JSON 注册、ID 冲突
BIN 解码、常量初始化、块表和版本
VM_GetCurCard、VM_GetProp/SetProp
VM_CreateInstance、VM_DestroyInstance
VM_LoadSpritePerm_Ex、VM_PlaySound
VM_EnemyInRange、VM_GetInstancesInRange、VM_GetHomingTarget
VM_Array*、VM_InstArray*
VM_CallFunc、VM_FuncExists、VM_FuncDesc
日志、坏包隔离、联机禁用/同步
```

不能假设通用 `_OBJECT_HIT`/`_OBJECT_KILL` 存在；碰撞要在 STEP 自己处理。副武器盾牌由角色直接创建，不经过 `obj_weapon_mod` VM，只能迁移 JSON 数据和 CFG 预加载能力。

每个通用对象合并后都要：保留目标父对象和网络字段、登记 YYP、以最小 Mod 测试实例创建/属性/绘制/销毁。

## 7. 注册和加载顺序

把源入口适配到目标体系：

```text
src_mod_init
src_mod_weapons_init
src_mod_gems_init
src_mod_attires_init
src_mod_enemies_init
src_mod_bullets_init
src_mod_effects_init
src_mod_maps_init
src_mod_maps_load_dir
```

目标 `obj_game_init` 已创建 `%LOCALAPPDATA%\\FVM_Reborn_makk`，所以源代码必须改为调用目标 NativeUtil/ExternalModSystem。固定顺序：

```text
配置 -> 原生库 -> VM 注册 -> JSON 注册 -> BIN/CFG
-> 资源预加载 -> 地图注册 -> Mod 菜单
```

单包失败只隔离该包并写入 `native/latest.log`。配置建议支持 `enabled`、`root`、`strict_manifest`、`allow_unsigned`。

## 8. 内容 Mod 迁移

导入到 `mod_source`，编译后导出到 staging，再复制到用户运行时目录。每个包校验：

```text
JSON 存在；有逻辑时 BIN 存在
TXT 仅为源码，不能当运行时逻辑
JSON 中 sprite/icon/sound 全部存在
ID 不与内置或其他 Mod 重复
地图元数据、脚本、背景、图标齐全
```

兼容检查必须包含：

1. 卡片数值数组按目标加载器要求处理为 17 档。
2. `sprite` 同时作为卡面/预览时，检查帧数和锚点。
3. 动画显式设置 `idle_anim`、`attack_anim`、`flash_speed`、`state`。
4. 卡片销毁使用 `hp=0`；子弹/特效按对象约定使用销毁属性。
5. `VM_CallFunc` 只允许 `global._VM_call_dict` 中登记的函数，最多 15 参数；导入前静态检查。
6. 复制类卡检查 `last_placed_card_id/shape` 黑名单，防止复制自身。
7. 宝石槽位、联机禁用列表、盾牌无 VM 限制写入清单。

地图流程：MapEditCreator/示例 -> TXT -> LabMapCompiler BIN -> 地图 JSON/资源 -> `mod_maps_init` -> 实验室 -> 实战。源 compiler 的 `_tests` 和 `corpus` 必须作为回归语料。

## 9. 编译器、原生库、懒加载、中继

`LabMapCompiler` 迁移到 `tools/LabMapCompiler`，保留 EXE、C++、`build.bat`、`parse_bin.py`、README、tests、corpus 和示例。封装为：

```powershell
tools\\LabMapCompiler\\LabMapCompiler.exe input.txt output.bin
```

编译后用 `parse_bin.py` 检查块、版本、长度；错误返回非零并阻止打包。

FvmNativeSupport 合并顺序：比较 DLL SHA256/导出函数/位数 -> 比较 YY 扩展调用约定 -> 合并源码和测试 -> 生成 DLL -> 放入 `extensions/WindowsNative` 与 `datafiles/native`。DLL 与 `7z.dll` 必须同位数，发布包带 SHA256。

懒加载脚本放入 `tools/lazyloading`。浅层脚本无需额外库，深度脚本需要 Pillow 和 ffmpeg；两个迁移脚本互斥，切换前必须运行恢复脚本并检查备份。

relay server 放入 `tools/relay_server`，保留 Python/EXE/C++。测试服务端、客户端、错误端口、断线重连、Mod 不一致和被禁用 Mod；不要把中继器当 GameMaker 资源。

## 10. 自动化脚本

建议新增：

```text
tools/migration/scan_projects.ps1
tools/migration/merge_resources.ps1
tools/migration/validate_mods.ps1
tools/migration/compile_vm.ps1
tools/migration/validate_bin.ps1
tools/migration/stage_runtime.ps1
tools/migration/build_release.ps1
tools/migration/rollback.ps1
```

全部脚本要求严格模式、明确输入输出、失败即退出、时间戳日志、绝对/显式根路径、禁止删除源目录。

## 11. 验证门禁

**A：基线。** 迁移前 VM/YYC 各构建一次，启动主菜单、实验室、一张战斗地图并退出，保存日志和包 hash。

**B：最小 VM 包。** 一个卡、武器、子弹、特效、敌人，验证 JSON -> BIN -> CFG -> 生命周期、属性、索敌、子实例、动画、声音、销毁，以及坏包隔离。

**C：全内容包。** 导入全部 314 个源 Mod 文件，检查注册数量、缺失资源、ID、内存、加载时间；重点测复杂卡、盾牌、副武器、复制类卡、地图和联机禁用。

**D：工具链。** 跑 LabMapCompiler 全部 tests/corpus，编译一张地图，跑懒加载迁移/还原，加载原生 DLL，启动中继完成一局联机。

**E：发布包。** 在干净虚拟机生成 VM 和 YYC 包，验证无开发机绝对路径、用户目录自动创建、存档迁移、Mod 开关、坏包恢复和卸载残留。

## 12. 回滚和提交

回滚顺序：删除 staging -> 恢复用户 Mod/实验室备份 -> revert 迁移提交 -> 恢复 DLL 与扩展成对版本 -> 必要时恢复 YYP 和虚拟机快照。每次发布保留源/目标清单、冲突报告、环境锁定、构建日志、包 hash、测试报告和快照名。

建议提交拆分：

```text
migration: inventories and environment lock
mod-runtime: VM and common objects
mod-runtime: registries and target data-root adapter
tools: LabMapCompiler and MapEditCreator
native: FvmNativeSupport and Windows extension
content: Mod packages and docs
tools: lazyloading and relay server
test: VM/map/native/online fixtures
release: VM/YYC packages and manifests
```

## 13. 最终验收

- `FVM_Reborn_makk.yyp` 可打开，无丢失/重复/红色资源错误。
- 目标原有功能与基线一致。
- 八类 Mod 都能识别，真实内容通过完整生命周期测试。
- TXT -> BIN、BIN 解析、错误隔离和日志可重复。
- 编译器、地图工具、懒加载、原生库、7z、中继器在隔离虚拟机可用。
- VM 与 YYC 均能在干净虚拟机启动，YYC 使用正确 MSVC v142/SDK。
- Mod/实验室/存档使用 `%LOCALAPPDATA%\\FVM_Reborn_makk`，无开发机绝对路径。
- 发布包有 SHA256、工具版本、许可证和源代码交付说明。
- 任一迁移层可通过 Git 标签、备份包或虚拟机快照恢复。

## 14. 实际执行清单

```text
[ ] Git 标签、压缩备份、clean-os 快照
[ ] 锁定 GameMaker/Runtime、VS v142、Python、Pillow、ffmpeg、7z
[ ] 生成 hash、资源 ID、冲突、Mod 配对清单
[ ] 导入文档和工具到隔离目录
[ ] 合并 VM 和 obj_*_mod，完成最小包门禁
[ ] 合并注册器、初始化顺序、LOCALAPPDATA 适配
[ ] 导入并校验全部 JSON/BIN/资源
[ ] 导入 LabMapCompiler/地图工具并跑 corpus
[ ] 合并 FvmNativeSupport/WindowsNative/7z
[ ] 接入懒加载和 relay server
[ ] VM 构建、YYC 构建、干净虚拟机验收
[ ] 生成发布包、hash、日志、许可证和回滚材料
```

