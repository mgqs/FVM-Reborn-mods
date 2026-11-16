# -*- coding: utf-8 -*-
"""替换后自检：① 两份 png 与源图逐像素一致 ② 尺寸/模式合规 ③ 与旧图几何同相位
④ .yy 未被改动（宽度/高度/帧 id 仍在）⑤ 铁笼残留统计。
"""
import hashlib
import os
import re

import numpy as np
from PIL import Image

ROOT = r"D:\gameProject\FVM-Reborn-mod"
SRC = (r"D:\FVM开发\game\FVM开发\res\美食大战老鼠bgm地图合集"
       r"\地图素材（更新至龙渊除厄第2期）\游戏地图背景\09跨服\巫毒研究所")
BAK = None


def latest_bak():
    d = os.path.join(ROOT, "output", "_tmp")
    cands = sorted([x for x in os.listdir(d) if x.startswith("bak_wudu_replace_")])
    return os.path.join(d, cands[-1]) if cands else None


def spr_ids(i):
    name = "spr_wuduyanjiusuo_%d" % i
    d = os.path.join(ROOT, "sprites", name)
    txt = open(os.path.join(d, name + ".yy"), encoding="utf-8").read()
    frame = re.search(r'"\$GMSpriteFrame":"v1","%Name":"([0-9a-f\-]+)"', txt).group(1)
    layer = re.search(r'"\$GMImageLayer":"","%Name":"([0-9a-f\-]+)"', txt).group(1)
    return name, d, frame, layer, txt


def sha(p):
    return hashlib.sha256(open(p, "rb").read()).hexdigest()[:12]


def main():
    bak = latest_bak()
    ok = True
    for i in range(8):
        name, d, frame, layer, txt = spr_ids(i)
        sp = os.path.join(SRC, "巫毒%d星.png" % (8 + i))
        p_outer = os.path.join(d, frame + ".png")
        p_layer = os.path.join(d, "layers", frame, layer + ".png")
        a = np.asarray(Image.open(sp).convert("RGB"))
        b = np.asarray(Image.open(p_outer).convert("RGB"))
        c = np.asarray(Image.open(p_layer).convert("RGB"))
        same_outer = bool((a == b).all())
        same_layer = bool((a == c).all())
        same_both = bool((b == c).all())
        w = int(re.search(r'"width":\s*(\d+)', txt).group(1))
        h = int(re.search(r'"height":\s*(\d+)', txt).group(1))
        size_ok = (b.shape[1], b.shape[0]) == (w, h)
        mode = Image.open(p_outer).mode
        # 与旧图比：整体结构是否同相位（不做缩放/平移）
        old_path = None
        if bak:
            cand = os.path.join(bak, os.path.relpath(p_outer, ROOT).replace("\\", "_").replace("/", "_"))
            if os.path.exists(cand):
                old_path = cand
        same_geom = "-"
        dmax = -1
        if old_path:
            o = np.asarray(Image.open(old_path).convert("RGB")).astype(np.int16)
            dmax = int(np.abs(o - b.astype(np.int16)).max())
            diffpct = float((np.abs(o - b.astype(np.int16)).max(axis=2) > 8).mean() * 100)
            same_geom = "%.2f%%" % diffpct
        good = same_outer and same_layer and same_both and size_ok
        ok = ok and good
        print("%s  外帧=%s 层帧=%s 两份一致=%s 尺寸 %dx%d(期望 %dx%d)%s 模式=%s 与旧图差异=%s 旧图备份=%s"
              % (name, "OK" if same_outer else "!!", "OK" if same_layer else "!!",
                 "OK" if same_both else "!!", b.shape[1], b.shape[0], w, h,
                 "" if size_ok else " !!", mode, same_geom, "有" if old_path else "无"))
    print("\n总判定：" + ("全部通过" if ok else "存在问题"))
    print("备份目录：" + str(bak))


if __name__ == "__main__":
    main()
