# 美食大战老鼠：重生

《美食大战老鼠：重生》是一款基于 GameMaker 引擎重新编写的《美食大战老鼠》同人游戏，旨在回归塔防初衷，优化不合理的游戏体验。

---

## 📋 目录

- [美食大战老鼠：重生](#美食大战老鼠重生)
  - [📋 目录](#-目录)
  - [软件简介](#软件简介)
  - [分支说明](#分支说明)
  - [权限声明](#权限声明)
  - [免责声明](#免责声明)
  - [安装与运行](#安装与运行)
  - [构建方式](#构建方式)
    - [Windows 动态库构建](#windows-动态库构建)
    - [macOS 本地构建](#macos-本地构建)
  - [贡献指南](#贡献指南)
  - [问题反馈](#问题反馈)

---

## 软件简介

《美食大战老鼠：重生》是使用 GameMaker 引擎重新编写的美食大战老鼠同人游戏，旨在回归塔防初衷，优化不合理的游戏体验。

## 分支说明

本仓库包含以下主要分支：

- **master(gitee)/main(github)**：稳定版分支，用于发布经过测试的稳定版本。建议通过此分支开发修改版。
- **develop**：开发版分支，用于进行日常开发和功能迭代。

## 权限声明

本软件基于 **GNU General Public License v3.0 (GPL 3.0)** 许可证开源。

您可以自由地：
- **复制** — 复制和分发本软件
- **修改** — 对本软件进行修改
- **再分发** — 分发修改后的版本

但必须遵守以下条款：
- **提供源代码** — 分发时必须同时提供完整的源代码
- **保留版权声明** — 必须保留原始版权声明
- **标注修改内容** — 必须明确标注对原作的修改
- **相同许可证** — 修改后的作品必须同样以 GPL 3.0 许可证发布

详细条款请参阅 [GPL 3.0 许可证全文](https://www.gnu.org/licenses/gpl-3.0.html)。

## 免责声明

本软件为同人作品，所有美术资源版权归属于欢乐互娱公司。本作品仅用于学习和交流目的，严禁任何形式的商业使用。如果您用于商业用途，由此产生的一切后果请自行承担。

## 安装与运行

Windows 版本可在 release 中下载，解压后运行可执行文件。macOS 版本可按下文在本地构建，运行生成的 `.app`。游玩过程中请不要修改资源文件夹中的任何文件，否则造成的游戏崩溃等问题后果自负。

## 构建方式

如果使用YYC构建方式，请按照以下方式构建：
- 在 **GameMaker Studio2** 中打开此项目
- 下载 **Visual Studio** ，并安装MSVC v142生成工具
- 在GMS2中设置VS路径
- 点击构建-创建可执行文件即可

如果使用VM构建方式，则无需额外操作，直接构建即可

### Windows 动态库构建

由于使用到了 [7zip](https://github.com/ip7z/7zip) 来解压文件，引入了 git submodule，如果需要构建 windows 的原生动态库，则需要先执行

``` bash
git submodule update --init --recursive
```

### macOS 本地构建

运行目标为搭载 Apple Silicon（ARM64）的 Mac，系统需要 macOS 11 或更新版本。构建需要可运行 GameMaker LTS 2026 的 Apple Silicon Mac、完整的 Xcode（已完成首次启动配置）、Python 3，以及 GameMaker 的 macOS Runtime。先在 GameMaker 中登录一次，让命令行构建能够使用本地许可证。

在项目根目录运行：

```bash
python3 tools/build_macos.py
```

脚本编译并测试 ARM64 原生扩展，生成 ARM64 启动器，调用 GameMaker 编译 VM 资源，并将 Runtime 自带的 Runner 及框架裁剪为 ARM64 后组装 `.app`，再使用本地 ad-hoc 签名（`codesign --sign -`）签署并打包。这个流程无需开发者证书、Team ID 或 Apple 描述文件。输出为：

- `dist/macos/FVM_Reborn_makk.app`
- `dist/macos/FVM_Reborn_makk-macOS.zip`

构建日志位于 `.macos-build/build.log`；缓存和生成的原生库均不提交到 Git。构建默认使用一个编译线程，规避当前 macOS Runtime 并行压缩纹理时的卡死；纹理压缩器在缓存中使用本地签名副本。脚本也包含 [GameMaker 官方提供的 macOS 命令行构建崩溃规避设置](https://github.com/YoYoGames/GameMaker-Bugs/issues/15357)，只对构建进程设置 `COMPlus_ZapDisable=1`。若安装了多个 Runtime 或账号，可显式指定：

```bash
python3 tools/build_macos.py \
  --runtime-path /Users/Shared/GameMakerStudio2-LTS2026/Cache/runtimes/runtime-2026.0.0.23 \
  --user-dir "$HOME/Library/Application Support/GameMakerStudio2-LTS2026/你的用户目录"
```

仅构建和测试原生库（无需 GameMaker 登录）：

```bash
python3 tools/build_macos.py --native-only
```

完成原生库构建后，也可以在 GameMaker IDE 中选择 macOS / VM，并切换到 `macOS` 配置编译。该配置为 Mac Runner 启用 BC3 纹理（`BCN -3 -u4`），`Default` 配置的 BC7 设置保留给 Windows。原有的 `WindowsNative` 扩展会在 macOS 自动使用 `libFvmNativeSupport.dylib`，Windows 继续使用 DLL。Mac 的地图及 Mod 解压使用系统 libarchive，Lua 使用项目内附的源码，不需要安装 Homebrew 或下载 Windows 的 7zip 子模块。

macOS 的原生文件操作与 GML 相对存档路径统一使用 `game_save_id`，因此存档、备份、授权记录、Mod 和自定义音乐位于同一游戏数据目录。设置中显示的音乐目录会反映实际位置。Windows 的 IME 屏蔽和全局鼠标限频钩子在 macOS 不启用，保留正常的中文输入。

macOS 的搜索、授权码、昵称和数量输入框使用 Cocoa 原生文本编辑，支持系统中文输入法，以及 `⌘A` 全选、`⌘C` 复制、`⌘X` 剪切、`⌘V` 粘贴和 `⌘Z` 撤销。组合输入在选词后才同步给游戏；用回车确认候选词不会同时提交表单。输入框关闭或销毁时会移除原生控件并把键盘焦点交回游戏。

macOS 启用 Retina 高分屏支持，避免系统将整个应用窗口按低分辨率放大。原生输入框按窗口比例定位，适配高分屏与窗口缩放。

macOS 将大型纹理组按场景动态加载，在备战界面根据关卡敌人清单预热资源，返回菜单时卸载战斗分组。内置背景音乐按曲目流式读取，并跟随设置中的音乐音量和静音控制。构建脚本在临时项目中展开 macOS 配置，规避 Runtime 忽略配置覆盖的问题；源码及原始素材不会在构建时被改写。打包前会检查音乐流文件和动态纹理是否实际包含在应用中。

macOS 使用固定间隔计时（`tm_sleep`、2 毫秒睡眠裕量）并关闭 VSync，以减少战斗时的帧间隔抖动。正常速度仍为 60 FPS，倍速仍为 120 FPS。

macOS 包含一个原生启动入口，会规范化游戏资源路径后再启动 Runner，兼容从压缩包解压后由访达触发的 App Translocation。请完整解压 `.app` 后再打开；程序会在启动前检查必要资源。

原有的星星法杖、玫瑰盾两个零长度占位音效已补为 10 毫秒静音 WAV，避免 macOS OpenAL 拒绝创建空音频缓冲区。

本地签名用于本机构建运行；如需公开分发并通过 Gatekeeper 自动校验，需要另行使用 Developer ID 签名及 Apple 公证。

## 贡献指南

欢迎通过 fork 提交您的贡献！如果您希望参与开发，请遵循以下步骤：
1. Fork 本仓库；
2. 在 main 分支基础上创建您的功能分支；
3. 提交更改并发起 Pull Request。

## 问题反馈

如果您在使用过程中遇到问题，或有改进建议，欢迎通过 Issues 页面提交反馈。

---
**注意**：本项目为爱好者作品，与官方无关。请支持官方正版游戏。
