"""生成变异战神精灵的「仓库 HEAD（修复前） vs 当前工作区（修复后）」对比图。

为什么要单独写这个脚本：
  之前的对比图直接拿本地备份当「修复前」，而且噪点帧的 alpha 只有 70~120，
  叠在灰底上看着像「空白残影」，容易被误认为是图做坏了。
  这里改成：① 修复前统一从 git HEAD 取（与仓库提交状态一致，可复核）；
            ② 噪点帧 alpha ×3 后再画，并标注「已提亮」，让噪点肉眼可辨；
            ③ 每格标帧号，上下一一对应。

用法：
    python tools/inf_zhanshen_diff_sheet.py            # 生成两张图
    python tools/inf_zhanshen_diff_sheet.py --check    # 只统计，不写图
"""

import io
import os
import subprocess
import sys

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from inf_zhanshen_repair import SPRITES, sprite_meta  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "output")
FONT_PATH = r"C:\Windows\Fonts\msyh.ttc"

SPRITES_LIST = [
    "spr_infected_zhanshen_duck",
    "spr_infected_zhanshen_death",
    "spr_infected_zhanshen_gear",
    "spr_infected_zhanshen_wood",
    "spr_infected_zhanshen_summon",
]

BG = (58, 58, 58, 255)
BAND_BAD = (86, 52, 52, 255)
BAND_OK = (52, 74, 58, 255)


def font(size):
    return ImageFont.truetype(FONT_PATH, size)


def head_png(sprite, frame):
    """取 HEAD 里的顶层合成图；不存在返回 None。"""
    p = subprocess.run(
        ["git", "show", "HEAD:sprites/%s/%s.png" % (sprite, frame)],
        cwd=ROOT, capture_output=True,
    )
    if p.returncode != 0:
        return None
    return Image.open(io.BytesIO(p.stdout)).convert("RGBA")


def boost_alpha(im, times=3):
    """把 alpha 乘回去，噪点才看得见（只用于展示，不改磁盘文件）。"""
    r, g, b, a = im.split()
    a = a.point(lambda v: min(255, v * times))
    return Image.merge("RGBA", (r, g, b, a))


def draw_cell(sheet, im, box, label, label_color=(230, 230, 230), pad=4):
    x0, y0, x1, y1 = box
    w, h = x1 - x0 - pad * 2, y1 - y0 - pad * 2 - 16
    if im is not None:
        thumb = im.copy()
        thumb.thumbnail((w, h), Image.LANCZOS)
        sheet.alpha_composite(thumb, (x0 + pad + (w - thumb.width) // 2,
                                      y0 + pad + (h - thumb.height) // 2))
    d = ImageDraw.Draw(sheet)
    d.text((x0 + pad, y0 + pad + h + 2), label, font=font(13), fill=label_color)


def build_one(sprite, indices, cell=(150, 116)):
    """一个精灵：标题条 + 上排 HEAD + 下排当前。"""
    W, H, layer, frames = sprite_meta(sprite)
    cols = len(indices)
    cw, ch = cell
    sheet = Image.new("RGBA", (cols * cw, 26 + ch * 2), BG)

    d = ImageDraw.Draw(sheet)
    d.rectangle([0, 0, cols * cw, 26], fill=(38, 38, 38, 255))
    d.text((6, 4), "%s（%d 帧，尺寸 %dx%d）  上=HEAD 修复前(alpha×3)  下=当前工作区"
           % (sprite.replace("spr_infected_zhanshen_", ""), len(frames), W, H),
           font=font(14), fill=(255, 220, 120))

    for c, idx in enumerate(indices):
        idx = min(idx, len(frames) - 1)
        f = frames[idx]
        before = head_png(sprite, f)
        if before is not None:
            before = boost_alpha(before)
        cur_path = os.path.join(SPRITES, sprite, f + ".png")
        after = Image.open(cur_path).convert("RGBA")

        box_b = (c * cw, 26, (c + 1) * cw, 26 + ch)
        box_a = (c * cw, 26 + ch, (c + 1) * cw, 26 + ch * 2)
        ImageDraw.Draw(sheet).rectangle(box_b, fill=BAND_BAD)
        ImageDraw.Draw(sheet).rectangle(box_a, fill=BAND_OK)
        draw_cell(sheet, before, box_b, "f%d 修复前" % idx, (255, 190, 190))
        draw_cell(sheet, after, box_a, "f%d 修复后" % idx, (190, 255, 200))
    return sheet


def compose(rows, gap=10):
    width = max(r.width for r in rows) + 12
    height = sum(r.height for r in rows) + gap * (len(rows) - 1) + 12
    sheet = Image.new("RGBA", (width, height), (30, 30, 30, 255))
    y = 6
    for r in rows:
        sheet.alpha_composite(r, (6, y))
        y += r.height + gap
    return sheet


def spread(n, k=5):
    if n <= k:
        return list(range(n))
    picks = [0, 1]
    for j in range(1, k - 2):
        picks.append(round(j * (n - 1) / (k - 2)))
    picks.append(n - 1)
    out = []
    for p in picks:
        if p not in out:
            out.append(p)
    return out[:k]


def main(check):
    rows = []
    for s in SPRITES_LIST:
        idxs = spread(len(sprite_meta(s)[3]), 5)
        rows.append((s, idxs))
        print("%-34s 抽样帧 %s" % (s, idxs))
    if check:
        return

    os.makedirs(OUT, exist_ok=True)
    sheet = compose([build_one(s, idxs) for s, idxs in rows])
    p1 = os.path.join(OUT, "inf_zhanshen_before_after.png")
    sheet.convert("RGB").save(p1)
    print("写出", p1, sheet.size)

    # duck 全帧对照（34 帧，分块 9 列）
    sprite = "spr_infected_zhanshen_duck"
    n = len(sprite_meta(sprite)[3])
    blocks = []
    for start in range(0, n, 9):
        idxs = list(range(start, min(start + 9, n)))
        blocks.append(build_one(sprite, idxs, cell=(140, 108)))
    full = compose(blocks)
    p2 = os.path.join(OUT, "inf_zhanshen_duck_full_compare.png")
    full.convert("RGB").save(p2)
    print("写出", p2, full.size)


if __name__ == "__main__":
    main("--check" in sys.argv)
