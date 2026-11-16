# -*- coding: utf-8 -*-
"""把用户修复好的巫毒研究所底图（巫毒8~15星.png）替换进 spr_wuduyanjiusuo_0..7。

规则（AGENTS.md §1.1 / §1.4）：
- 精灵帧图有两份必须同步：`sprites/<名>/<frameId>.png` 与
  `sprites/<名>/layers/<frameId>/<layerId>.png`，只换一份会导致 IDE/运行时取到旧图。
- 帧 id / 图层 id 一律从 `<名>.yy` 里读，不硬编码；`.yy` 不动（尺寸 1108x597 与原图一致）。
- 旧图先备份到 `output/_tmp/bak_wudu_replace_<时间戳>/`，可回滚。
- 输出统一 RGB（原精灵帧就是 RGB，无 alpha）。

用法：
    python tools/wudu_bg_replace.py            # 试跑，只打印计划
    python tools/wudu_bg_replace.py --apply    # 真正写入
"""
import argparse
import os
import re
import shutil
import time

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = (r"D:\FVM开发\game\FVM开发\res\美食大战老鼠bgm地图合集"
       r"\地图素材（更新至龙渊除厄第2期）\游戏地图背景\09跨服\巫毒研究所")
COUNT = 8


def sprite_ids(i):
    name = "spr_wuduyanjiusuo_%d" % i
    d = os.path.join(ROOT, "sprites", name)
    txt = open(os.path.join(d, name + ".yy"), encoding="utf-8").read()
    frame = re.search(r'"\$GMSpriteFrame":"v1","%Name":"([0-9a-f\-]+)"', txt).group(1)
    layer = re.search(r'"\$GMImageLayer":"","%Name":"([0-9a-f\-]+)"', txt).group(1)
    return name, d, frame, layer


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true")
    args = ap.parse_args()

    stamp = time.strftime("%Y%m%d_%H%M%S")
    bak = os.path.join(ROOT, "output", "_tmp", "bak_wudu_replace_" + stamp)
    rows = []
    for i in range(COUNT):
        name, d, frame, layer = sprite_ids(i)
        src = os.path.join(SRC, "巫毒%d星.png" % (8 + i))
        dsts = [os.path.join(d, frame + ".png"),
                os.path.join(d, "layers", frame, layer + ".png")]
        rows.append((i, src, dsts))
        print("%s  <- %s" % (name, os.path.basename(src)))
        for p in dsts:
            print("      -> %s" % os.path.relpath(p, ROOT))

    # 尺寸/模式校验：源图必须与 yy 记录的 1108x597 一致，否则会破坏 bg_draw 对齐
    for i, src, dsts in rows:
        name, d, frame, layer = sprite_ids(i)
        yy = open(os.path.join(d, name + ".yy"), encoding="utf-8").read()
        w = int(re.search(r'"width":\s*(\d+)', yy).group(1))
        h = int(re.search(r'"height":\s*(\d+)', yy).group(1))
        im = Image.open(src)
        if im.size != (w, h):
            raise SystemExit("%s 尺寸不符：源 %s vs 精灵 %dx%d" % (name, im.size, w, h))

    if not args.apply:
        print("\n（试跑；加 --apply 才写入）")
        return

    os.makedirs(bak, exist_ok=True)
    for i, src, dsts in rows:
        name, _, _, _ = sprite_ids(i)
        for p in dsts:
            if os.path.exists(p):
                rel = os.path.relpath(p, ROOT).replace("\\", "_").replace("/", "_")
                shutil.copy2(p, os.path.join(bak, rel))
            im = Image.open(src).convert("RGB")
            im.save(p, optimize=True)
        print("已替换 %s" % name)
    print("\n旧图备份：%s" % bak)


if __name__ == "__main__":
    main()
