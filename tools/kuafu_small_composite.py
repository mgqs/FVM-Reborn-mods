# -*- coding: utf-8 -*-
"""【已停用 / 已回滚 2026-11-05】把「变异小件」合成进变异鼠背筐。

用户要求退回此改动：三只鼠的 100 帧已从 output/_tmp/bak_spr_kuafu_* 还原，
背筐重新是空的。脚本保留仅作历史参考，入口已在文件末尾关闭；
若要复活该方案，需先把 __main__ 里的 guard 去掉。
"""
import io
import json
import os
import re
import shutil
import sys

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPR = os.path.join(ROOT, "sprites")
BAK = os.path.join(ROOT, "output", "_tmp")

# 大图, 小件图, 桶口中心, 桶口宽, 死亡帧数
CFG = [
    ("spr_kuafu_panda", "spr_kuafu_little_panda", (112, 46), 44, 22),
    ("spr_kuafu_wrestler", "spr_kuafu_little_wrestler", (118, 46), 40, 22),
    ("spr_kuafu_armour", "spr_kuafu_little_armour", (122, 55), 42, 22),
]


def frame_names(sprite):
    p = os.path.join(SPR, sprite, sprite + ".yy")
    s = io.open(p, encoding="utf-8-sig").read()
    s = re.sub(r",(\s*[}\]])", r"\1", s)
    d = json.loads(s)
    return [f["name"] + ".png" for f in d["frames"]]


def alpha_bbox(im):
    return im.split()[3].getbbox()


def build_head(little, mouth, rim_w):
    lp = Image.open(os.path.join(SPR, little, frame_names(little)[0])).convert("RGBA")
    x0, y0, x1, y1 = alpha_bbox(lp)
    w, h = x1 - x0, y1 - y0
    head_w = 0.58 * w
    cx = x0 + 0.30 * w
    crop = lp.crop((int(cx - head_w * 0.62), y0 - 2,
                    int(cx + head_w * 0.62), int(y0 + h * 0.52)))
    scale = (rim_w * 0.72) / head_w
    nh = crop.resize((max(1, int(crop.width * scale)),
                      max(1, int(crop.height * scale))), Image.LANCZOS)
    mask = Image.new("L", nh.size, 0)
    d = ImageDraw.Draw(mask)
    d.ellipse((-1, -2, nh.width, nh.height * 0.98), fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(0.8))
    return nh, mask


def main():
    for big, little, (mx, my), rim_w, death in CFG:
        names = frame_names(big)
        bak = os.path.join(BAK, "bak_" + big)
        if not os.path.isdir(bak):
            os.makedirs(bak)
            for n in names:
                shutil.copy2(os.path.join(SPR, big, n), os.path.join(bak, n))
            print("[bak]", big, len(names))
        else:
            print("[bak] 已存在，直接用备份作源", big)

        head, mask = build_head(little, (mx, my), rim_w)
        px = int(mx - head.width / 2)
        py = int(my + 7 - head.height)

        limit = len(names) - death
        done = 0
        for i, n in enumerate(names):
            src = os.path.join(bak, n)
            im = Image.open(src).convert("RGBA")
            if i < limit:
                im.paste(head, (px, py), mask)
                done += 1
            im.save(os.path.join(SPR, big, n))
        print("[ok]", big, "合成帧", done, "/", len(names), "头部", head.size, "落点", px, py)


if __name__ == "__main__":
    raise SystemExit(
        "kuafu_small_composite 已按用户要求回滚并停用："
        "运行会把小件重新贴回背筐。若确实要复活，先删掉本 guard。"
    )
    main()
