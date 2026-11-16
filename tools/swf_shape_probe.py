# -*- coding: utf-8 -*-
"""SWF 矢量形状探针：列出每个 DefineShape/2/3/4 的 bbox（像素）。

用途：合成屋左侧「金卡进化 / 神器进化 / 宝石进化」三块标签在原版 SWF 里是**矢量**
（不是位图，位图导出看不到它们）。先用本脚本按尺寸/长宽比挑出候选 characterId，
再用 swf_render_shape.py 渲染成 PNG。

用法：python tools/swf_shape_probe.py <swf> [--min-h 60] [--max-h 400] [--aspect 0.3 0.9]
"""
import struct
import sys
import zlib


def decompress(data):
    if data[:3] == b"CWS":
        return zlib.decompress(data[8:])
    if data[:3] == b"FWS":
        return data[8:]
    raise ValueError("不支持的 SWF 签名: %r" % data[:3])


def iter_tags(buf, pos, end):
    while pos + 2 <= end:
        code_len = struct.unpack_from("<H", buf, pos)[0]
        pos += 2
        code = code_len >> 6
        length = code_len & 0x3F
        if length == 0x3F:
            length = struct.unpack_from("<I", buf, pos)[0]
            pos += 4
        yield code, pos, length
        pos += length
        if code == 0:
            return


def read_rect(buf, pos):
    """返回 (xmin, xmax, ymin, ymax) 单位 twips，和新的 pos"""
    nbits = buf[pos] >> 3
    total = 5 + nbits * 4
    nbytes = (total + 7) // 8
    bits = int.from_bytes(buf[pos:pos + nbytes], "big")
    bits >>= (nbytes * 8 - total)
    mask = (1 << nbits) - 1
    vals = []
    for i in range(4):
        v = (bits >> (nbits * (3 - i))) & mask
        if v & (1 << (nbits - 1)):
            v -= 1 << nbits
        vals.append(v)
    return (vals[0], vals[1], vals[2], vals[3]), pos + nbytes


def main():
    swf = sys.argv[1]
    min_h, max_h = 60, 400
    asp_lo, asp_hi = 0.25, 0.95
    a = sys.argv[2:]
    for i in range(0, len(a) - 1, 2):
        if a[i] == "--min-h":
            min_h = int(a[i + 1])
        elif a[i] == "--max-h":
            max_h = int(a[i + 1])
        elif a[i] == "--aspect":
            asp_lo, asp_hi = float(a[i + 1].split(",")[0]), float(a[i + 1].split(",")[1])
    raw = decompress(open(swf, "rb").read())
    pos = 0                                  # 帧 RECT 从第 0 字节起（decompress 已剥掉 8 字节头）
    _, pos = read_rect(raw, pos)
    pos += 4
    rows = []
    for code, p, ln in iter_tags(raw, pos, len(raw)):
        if code not in (2, 22, 32, 83):
            continue
        cid = struct.unpack_from("<H", raw, p)[0]
        box, _ = read_rect(raw, p + 2)
        w = (box[1] - box[0]) / 20.0
        h = (box[3] - box[2]) / 20.0
        if h <= 0 or w <= 0:
            continue
        if not (min_h <= h <= max_h):
            continue
        if not (asp_lo <= w / h <= asp_hi):
            continue
        rows.append((round(w, 1), round(h, 1), cid, code, box))
    rows.sort(key=lambda r: (r[1], r[0]))
    print("候选 %d 个（宽 × 高 × id × tag）" % len(rows))
    for r in rows:
        print("  %6.1f x %6.1f   id=%-5d tag=%-2d  bbox=%s" % (r[0], r[1], r[2], r[3], r[4]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
