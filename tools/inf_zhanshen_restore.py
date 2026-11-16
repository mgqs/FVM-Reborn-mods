# -*- coding: utf-8 -*-
"""从 git 历史版本恢复变异战神精灵帧。

背景：spr_infected_zhanshen_* 在提交 c9780a4f5f（"修复部分BUG，更新跨服"）里被写坏——
除第 0 帧外，death/duck/gear/wood/summon/bullet* 的帧全部退化成 RGB 噪点 + 抖动 alpha；
上一条好提交 4ec67fb2a6 里同一批帧（同一批帧 GUID）是干净的美术图。

本脚本按帧 GUID 从 4ec67fb2a6 取图，只替换「当前判定为噪点」的帧，
写到 layers/<frameGUID>/<layerGUID>.png 与 <frameGUID>.png 两处（两处必须一致）。

用法：
  python tools/inf_zhanshen_restore.py --check     # 只报告
  python tools/inf_zhanshen_restore.py            # 执行恢复
"""
import io
import os
import subprocess
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
from inf_zhanshen_repair import PREFIX, SPRITES, sprite_meta  # noqa: E402

GOOD = "4ec67fb2a6"
ISO_MAX = 0.65   # 孤立像素占比超过这个值判为噪点（干净帧实测 ≤0.47，噪帧 ≥0.85）


def show(ref, path):
    p = subprocess.run(["git", "show", "%s:%s" % (ref, path)], cwd=ROOT,
                       capture_output=True)
    if p.returncode != 0:
        return None
    return p.stdout


def isolated_ratio(im):
    im = im.convert("RGBA")
    W, H = im.size
    px = im.load()
    iso = 0
    n = 0
    asum = 0
    for y in range(H):
        for x in range(1, W - 1):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            n += 1
            asum += a
            l = px[x - 1, y]
            rr = px[x + 1, y]
            if (max(abs(r - l[0]), abs(g - l[1]), abs(b - l[2])) > 25
                    and max(abs(r - rr[0]), abs(g - rr[1]), abs(b - rr[2])) > 25):
                iso += 1
    if n == 0:
        return 1.0, 0.0
    return iso / n, asum / n


def is_noise(im):
    iso, mean = isolated_ratio(im)
    return iso > ISO_MAX, iso, mean


def main():
    check = "--check" in sys.argv
    names = [n for n in sorted(os.listdir(SPRITES)) if n.startswith(PREFIX)]
    print("%-34s %-4s %-6s %-6s" % ("精灵", "帧", "当前噪帧", "可恢复"))
    for name in names:
        W, H, layer, frames = sprite_meta(name)
        d = os.path.join(SPRITES, name)
        noisy = []
        for i, f in enumerate(frames):
            p = os.path.join(d, f + ".png")
            if not os.path.exists(p):
                noisy.append((i, f))
                continue
            bad, iso, mean = is_noise(Image.open(p))
            if bad:
                noisy.append((i, f))
        if not noisy:
            print("%-34s %-4d %-6s %s" % (name, len(frames), "-", ""))
            continue
        ok = 0
        if not check:
            bak = os.path.join(ROOT, "output", "_tmp", "bak2_" + name)
            if not os.path.exists(bak):
                import shutil
                shutil.copytree(d, bak)
        for i, f in noisy:
            raw = show(GOOD, "sprites/%s/%s.png" % (name, f))
            if raw is None:
                continue
            im = Image.open(io.BytesIO(raw))
            if im.size != (W, H):
                continue
            bad, iso, mean = is_noise(im)
            if bad:
                continue
            ok += 1
            if check:
                continue
            fdir = os.path.join(d, "layers", f)
            os.makedirs(fdir, exist_ok=True)
            with open(os.path.join(fdir, layer + ".png"), "wb") as fh:
                fh.write(raw)
            with open(os.path.join(d, f + ".png"), "wb") as fh:
                fh.write(raw)
        print("%-34s %-4d %-6d %-6d" % (name, len(frames), len(noisy), ok))


if __name__ == "__main__":
    main()
