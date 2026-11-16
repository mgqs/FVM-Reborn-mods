# -*- coding: utf-8 -*-
"""把 SWF 里指定的 DefineShape/2/3/4 渲染成 PNG（纯 Python，无需 FFDec）。

为什么需要它：合成屋左侧「金卡进化 / 神器进化 / 宝石进化」三块标签在原版 SWF 里是
**矢量形状**（文字也被打成了字形轮廓），位图导出（swf_dump_bitmaps.py）里看不到它们。

支持范围（够用于 UI 元件）：实色填充、线性/放射渐变（取平均色）、实色描边、位图填充（跳过）。
不支持的边缘情况会静默降级成「画轮廓」，用于辨认足够了。

用法：
    python tools/swf_render_shape.py <swf> <草稿目录> --ids 672,678,683 --scale 2
    python tools/swf_render_shape.py <swf> <草稿目录> --size 46x85 --scale 2   # 按 bbox 筛
"""
import io
import os
import struct
import sys
import zlib

from PIL import Image, ImageDraw

SS = 4  # 超采样倍数


# ─────────────────────────── 基础读取 ───────────────────────────
class Bits:
    """按位读取 SWF 定长字段（SWF 里 UB/FB/SB 都是位对齐的）"""

    def __init__(self, buf, pos):
        self.buf = buf
        self.pos = pos          # 字节位置
        self.bit = 0            # 已读位数（0..7）
        self.acc = 0
        self.nbits = 0

    def _byte(self):
        b = self.buf[self.pos]
        self.pos += 1
        return b

    def ub(self, n):
        v = 0
        for _ in range(n):
            if self.nbits == 0:
                self.acc = self._byte()
                self.nbits = 8
            self.nbits -= 1
            v = (v << 1) | ((self.acc >> self.nbits) & 1)
        return v

    def sb(self, n):
        if n == 0:
            return 0
        v = self.ub(n)
        if v & (1 << (n - 1)):
            v -= 1 << n
        return v

    def align(self):
        self.nbits = 0

    def bytes_pos(self):
        return self.pos


def read_rect_bits(b):
    nb = b.ub(5)
    return (b.sb(nb), b.sb(nb), b.sb(nb), b.sb(nb))


def read_matrix(b):
    if b.ub(1):
        nb = b.ub(5)
        b.sb(nb)
        b.sb(nb)
    if b.ub(1):
        nb = b.ub(5)
        b.sb(nb)
        b.sb(nb)
    nb = b.ub(5)
    b.sb(nb)
    b.sb(nb)


def read_gradient(b, rgba):
    b.ub(2)
    b.ub(2)
    n = b.ub(4)
    stops = []
    for _ in range(n):
        b.ub(8)
        if rgba:
            r, g, bl, a = b.ub(8), b.ub(8), b.ub(8), b.ub(8)
        else:
            r, g, bl, a = b.ub(8), b.ub(8), b.ub(8), 255
        stops.append((r, g, bl, a))
    avg = (sum(s[0] for s in stops) // n, sum(s[1] for s in stops) // n,
           sum(s[2] for s in stops) // n, sum(s[3] for s in stops) // n)
    return avg


def read_fill_styles(b, rgba):
    cnt = b.ub(8)
    if cnt == 0xFF:
        cnt = b.ub(16)
    out = []
    for _ in range(cnt):
        t = b.ub(8)
        if t == 0x00:
            if rgba:
                out.append(("solid", (b.ub(8), b.ub(8), b.ub(8), b.ub(8))))
            else:
                out.append(("solid", (b.ub(8), b.ub(8), b.ub(8), 255)))
        elif t in (0x10, 0x12, 0x13):
            read_matrix(b)
            out.append(("solid", read_gradient(b, rgba)))
        elif 0x40 <= t <= 0x43:
            b.ub(16)
            read_matrix(b)
            out.append(("none", None))
        else:
            out.append(("none", None))
    return out


def read_line_styles(b, rgba):
    cnt = b.ub(8)
    if cnt == 0xFF:
        cnt = b.ub(16)
    out = []
    for _ in range(cnt):
        w = b.ub(16) / 20.0
        if rgba:
            c = (b.ub(8), b.ub(8), b.ub(8), b.ub(8))
        else:
            c = (b.ub(8), b.ub(8), b.ub(8), 255)
        out.append((w, c))
    return out


def parse_shape(body, rgba):
    """返回 (bbox_twips, fills, paths)，paths = [(fill_idx, line_idx, [pts])]"""
    b = Bits(body, 0)
    b.ub(16)                       # ShapeId
    box = read_rect_bits(b)
    fills = read_fill_styles(b, rgba)
    lines = read_line_styles(b, rgba)
    nfill = b.ub(4)
    nline = b.ub(4)

    paths = []
    cur = None                     # [fill0, fill1, line, [pts]]
    pen = (0, 0)
    fill0 = fill1 = 0
    line = 0

    def flush():
        if cur and len(cur[3]) > 1:
            paths.append((cur[0], cur[1], cur[2], list(cur[3])))

    while True:
        t = b.ub(1)
        if t == 0:
            new_styles = b.ub(1)
            has_line = b.ub(1)
            has_f1 = b.ub(1)
            has_f0 = b.ub(1)
            move = b.ub(1)
            if move:
                nb = b.ub(5)
                pen = (b.sb(nb), b.sb(nb))
            if has_f0:
                fill0 = b.ub(nfill)
            if has_f1:
                fill1 = b.ub(nfill)
            if has_line:
                line = b.ub(nline)
            if new_styles:
                fills = read_fill_styles(b, rgba) or fills
                lines = read_line_styles(b, rgba) or lines
                nfill = b.ub(4)
                nline = b.ub(4)
            if move:
                flush()
                cur = [fill0, fill1, line, [(pen[0], pen[1])]]
                continue
            # 只改样式：结束当前子路径
            flush()
            cur = None
            continue
        straight = b.ub(1)
        if straight:
            nb = b.ub(4) + 2
            general = b.ub(1)
            if general:
                dx = b.sb(nb)
                dy = b.sb(nb)
            elif b.ub(1):      # 竖线
                dx = 0
                dy = b.sb(nb)
            else:              # 横线
                dx = b.sb(nb)
                dy = 0
            npt = (pen[0] + dx, pen[1] + dy)
            if cur is None:
                cur = [fill0, fill1, line, [(pen[0], pen[1])]]
            cur[3].append(npt)
            pen = npt
        else:
            nb = b.ub(4) + 2
            cx = pen[0] + b.sb(nb)
            cy = pen[1] + b.sb(nb)
            ax = cx + b.sb(nb)
            ay = cy + b.sb(nb)
            if cur is None:
                cur = [fill0, fill1, line, [(pen[0], pen[1])]]
            # 二次贝塞尔离散
            x0, y0 = pen
            for i in range(1, 9):
                s = i / 8.0
                mt = 1 - s
                cur[3].append((mt * mt * x0 + 2 * mt * s * cx + s * s * ax,
                               mt * mt * y0 + 2 * mt * s * cy + s * s * ay))
            pen = (ax, ay)
        if b.pos > len(body) + 4:
            break
    flush()
    return box, fills, lines, paths


# ─────────────────────────── 渲染 ───────────────────────────
def render(body, rgba, scale=1.0, bg=(0, 0, 0, 0)):
    box, fills, lines, paths = parse_shape(body, rgba)
    xmin, xmax, ymin, ymax = [v / 20.0 for v in box]
    w = max(1, int(round((xmax - xmin) * scale)))
    h = max(1, int(round((ymax - ymin) * scale)))
    W, H = w * SS, h * SS
    img = Image.new("RGBA", (W, H), bg)

    def tx(x):
        return (x / 20.0 - xmin) * scale * SS

    def ty(y):
        return (y / 20.0 - ymin) * scale * SS

    # 按 fill 分组：每个填充色画一张 mask，用 XOR 处理字形镂空
    for idx in range(1, len(fills) + 1):
        kind, col = fills[idx - 1]
        if kind != "solid" or col is None or col[3] == 0:
            continue
        mask = Image.new("L", (W, H), 0)
        dm = ImageDraw.Draw(mask)
        touched = False
        for f0, f1, ln, pts in paths:
            if f0 != idx:
                continue
            touched = True
            poly = [(tx(x), ty(y)) for x, y in pts]
            dm.polygon(poly, fill=255)
        if not touched:
            continue
        layer = Image.new("RGBA", (W, H), col[:3] + (0,))
        a = layer.split()[3].point(lambda v: col[3])
        mask = Image.composite(a, Image.new("L", (W, H), 0), mask)
        layer.putalpha(mask)
        img = Image.alpha_composite(img, layer)

    # 描边（字形通常靠 fill 就够了，这里只补轮廓）
    for f0, f1, li, pts in paths:
        if li <= 0 or li > len(lines):
            continue
        wpx, col = lines[li - 1]
        if col[3] == 0:
            continue
        dm = ImageDraw.Draw(img)
        poly = [(tx(x), ty(y)) for x, y in pts]
        dm.line(poly, fill=col, width=max(1, int(round(wpx * scale * SS))), joint="curve")

    return img.resize((w, h), Image.LANCZOS)


def main():
    swf, outdir = sys.argv[1], sys.argv[2]
    ids, want_size, scale = set(), None, 1.0
    a = sys.argv[3:]
    for i in range(0, len(a) - 1, 2):
        if a[i] == "--ids":
            ids = {int(v) for v in a[i + 1].split(",")}
        elif a[i] == "--size":
            want_size = tuple(float(v) for v in a[i + 1].lower().split("x"))
        elif a[i] == "--scale":
            scale = float(a[i + 1])
    os.makedirs(outdir, exist_ok=True)
    data = open(swf, "rb").read()
    raw = zlib.decompress(data[8:]) if data[:3] == b"CWS" else data[8:]
    b = Bits(raw, 0)
    read_rect_bits(b)
    b.align()
    pos = b.bytes_pos() + 4
    n = 0
    while pos + 2 <= len(raw):
        code_len = struct.unpack_from("<H", raw, pos)[0]
        pos += 2
        code = code_len >> 6
        ln = code_len & 0x3F
        if ln == 0x3F:
            ln = struct.unpack_from("<I", raw, pos)[0]
            pos += 4
        body = raw[pos:pos + ln]
        pos += ln
        if code == 0:
            break
        if code not in (2, 22, 32, 83):
            continue
        cid = struct.unpack_from("<H", body, 0)[0]
        bb = Bits(body, 2)
        box = read_rect_bits(bb)
        w = (box[1] - box[0]) / 20.0
        h = (box[3] - box[2]) / 20.0
        if ids and cid not in ids:
            continue
        if want_size and (abs(w - want_size[0]) > 3 or abs(h - want_size[1]) > 3):
            continue
        try:
            im = render(body, code in (22, 32, 83), scale)
        except Exception as e:
            print("id=%d 渲染失败：%s" % (cid, e))
            continue
        fn = os.path.join(outdir, "shape_%d_%dx%d.png" % (cid, im.width, im.height))
        im.save(fn)
        n += 1
    print("渲染 %d 个形状 → %s" % (n, outdir))
    return 0


if __name__ == "__main__":
    sys.exit(main())
