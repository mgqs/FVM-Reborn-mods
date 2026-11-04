# -*- coding: utf-8 -*-
"""
font_repack.py —— 把 GameMaker 字体图集按更紧的间距重排，腾出补字空间

背景
    fonts/<name>/<name>.png 是字体内嵌图集，glyphs 里每个字记录在图集上的
    x/y/w/h。font_fill.py 只能往「最后一行之后」追加，一旦图集写满就没救了。
    本工具把已有字形按 gap=2 / 行距 = h+2 重新紧密排布，只改 x/y 与 png 内容，
    w/h/offset/shift/ascender 一律不动，因此运行时排版不会变化。

用法
    python tools/font_repack.py --dry-run        # 只报告能腾出多少行
    python tools/font_repack.py                  # 真正写入（自动备份 .bak_<时间>）
    python tools/font_repack.py --font font_hei
"""

import argparse
import io
import json
import os
import re
import shutil
import sys
import time

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LEFT = 6          # 左边界（GM 纹理组 border）
TOP = 2
RIGHT_PAD = 3     # 右边留白
BOTTOM_PAD = 3
GAP = 2           # 字间距（font_fill 用 3，这里压到 2）
ROW_EXTRA = 2     # 行距 = h + ROW_EXTRA


def paths(name):
    d = os.path.join(ROOT, "fonts", name)
    return os.path.join(d, name + ".yy"), os.path.join(d, name + ".png")


def load(name):
    yy, _ = paths(name)
    raw = io.open(yy, encoding="utf-8").read()
    data = json.loads(re.sub(r",(\s*[}\]])", r"\1", raw))
    return raw, data


GLYPH_LINE = re.compile(
    r'^(\s*)"(\d+)":\{"character":(\d+),"h":(\d+),"offset":(-?\d+),"shift":(\d+),"w":(\d+),"x":(\d+),"y":(\d+),\},$')


def parse_glyph_lines(raw):
    """返回 (起点, 终点, [每行解析结果])；行序即 glyphs 的添加顺序"""
    gs = raw.index('\n  "glyphs":{\n') + len('\n  "glyphs":{\n')
    ge = raw.index('\n  },', gs)
    lines = raw[gs:ge].split("\n")
    out = []
    for i, ln in enumerate(lines):
        m = GLYPH_LINE.match(ln)
        if not m:
            raise RuntimeError("glyphs 第 %d 行格式不认识: %r" % (i, ln[:120]))
        out.append(dict(idx=i, ch=int(m.group(3)), h=int(m.group(4)),
                        w=int(m.group(7)), x=int(m.group(8)), y=int(m.group(9))))
    return gs, ge, out


def repack(name, dry=False):
    yy, png = paths(name)
    raw, data = load(name)
    gs, ge, gl = parse_glyph_lines(raw)
    if len(gl) != len(data["glyphs"]):
        raise RuntimeError("%s: glyphs 行数 %d 与 json 键数 %d 不一致"
                           % (name, len(gl), len(data["glyphs"])))

    im = Image.open(png)
    W, H = im.size
    h_set = set(g["h"] for g in gl)
    if len(h_set) != 1:
        raise RuntimeError("%s: 字形高度不统一 %r，本工具不支持" % (name, sorted(h_set)))
    row_h = h_set.pop()

    # 按当前视觉顺序（先 y 后 x）重排，保证与「字符添加顺序」一致，便于以后排查
    order = sorted(gl, key=lambda g: (g["y"], g["x"]))
    x, y = LEFT, TOP
    placed = []
    for g in order:
        w = g["w"]
        if x + w > W - RIGHT_PAD:
            x = LEFT
            y += row_h + ROW_EXTRA
        if y + row_h > H - BOTTOM_PAD:
            raise RuntimeError("%s: 重排后仍然越界（%d 个字放不进，需要高度 ≥ %d）"
                               % (name, len(placed), y + row_h + BOTTOM_PAD))
        placed.append((g, x, y))
        x += w + GAP

    used_h = max(p[2] for p in placed) + row_h
    old_used_h = max(g["y"] for g in gl) + row_h
    print("\n=== %s ===" % name)
    print("  字形 %d 个，图集 %dx%d，行高 %d" % (len(gl), W, H, row_h))
    print("  重排前占用高度 %d，重排后 %d，腾出 %d px ≈ %d 行"
          % (old_used_h, used_h, old_used_h - used_h,
             (old_used_h - used_h) // (row_h + ROW_EXTRA)))

    # 校验：逐块像素必须一一对应（paste 不带 mask，直接覆盖像素，不做 alpha 混合）
    src = im.convert("RGBA")
    out = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    for g, nx, ny in placed:
        blk = src.crop((g["x"], g["y"], g["x"] + g["w"], g["y"] + g["h"]))
        out.paste(blk, (nx, ny))
    for g, nx, ny in placed:
        a = src.crop((g["x"], g["y"], g["x"] + g["w"], g["y"] + g["h"])).tobytes()
        b = out.crop((nx, ny, nx + g["w"], ny + g["h"])).tobytes()
        if a != b:
            raise RuntimeError("%s: 字符 %r 像素搬运不一致" % (name, chr(g["ch"])))

    # 新坐标写回 yy
    newpos = {g["ch"]: (nx, ny) for g, nx, ny in placed}
    lines = raw[gs:ge].split("\n")
    for i, ln in enumerate(lines):
        m = GLYPH_LINE.match(ln)
        nx, ny = newpos[int(m.group(3))]
        lines[i] = '%s"%s":{"character":%s,"h":%s,"offset":%s,"shift":%s,"w":%s,"x":%d,"y":%d,},' % (
            m.group(1), m.group(2), m.group(3), m.group(4), m.group(5),
            m.group(6), m.group(7), nx, ny)
    new_raw = raw[:gs] + "\n".join(lines) + raw[ge:]

    if dry:
        print("  DRY：未写盘")
        return dict(name=name, freed_rows=(old_used_h - used_h) // (row_h + ROW_EXTRA))

    stamp = time.strftime("%Y%m%d_%H%M%S")
    shutil.copy2(yy, yy + ".bak_" + stamp)
    shutil.copy2(png, png + ".bak_" + stamp)
    out.save(png)
    io.open(yy, "w", encoding="utf-8", newline="\n").write(new_raw)
    print("  已写盘（备份 .bak_%s），占用高度 %d → %d" % (stamp, old_used_h, used_h))
    return dict(name=name, freed_rows=(old_used_h - used_h) // (row_h + ROW_EXTRA))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--font", default=None)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    names = [args.font] if args.font else ["font_yuan", "font_hei", "font_pixel"]
    for n in names:
        repack(n, dry=args.dry_run)


if __name__ == "__main__":
    main()
