# -*- coding: utf-8 -*-
"""从 SWF 里把所有 DefineBitsLossless / DefineBitsLossless2 位图导出为 PNG。

用途：原版美术常以位图形式塞在 SWF 里（不是矢量），比如合成屋左侧的
`金卡进化 / 神器进化 / 宝石进化` 三块标签就是 46×85 位图。本脚本不做
形状渲染，只解位图 —— 因此不需要 FFDec / swf2png。

用法：
    python tools/swf_dump_bitmaps.py <swf> <输出目录> [--min-w 30 --max-w 200 --min-h 30 --max-h 200]

输出：<输出目录>/bm_<characterId>_<w>x<h>.png
"""
import os
import struct
import sys
import zlib

try:
    from PIL import Image
except ImportError:  # pragma: no cover
    print("需要 Pillow：pip install pillow")
    raise


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


def decode_lossless(body, fmt2):
    """返回 (w, h, rgba_bytes)

    布局：ShapeId(UI16) / BitmapFormat(UI8) / Width(UI16) / Height(UI16) / Data
    —— 注意格式是单字节，别按 4 个 UI16 解（会把 w/h 解成乱码）。
    """
    cid, fmt, w, h = struct.unpack_from("<HBHH", body, 0)
    p = 7
    if fmt == 3:            # 8bit 调色板
        ncol = body[p] + 1
        p += 1
        pal = body[p:p + ncol * (4 if fmt2 else 3)]
        p += ncol * (4 if fmt2 else 3)
        data = zlib.decompress(body[p:])
        px = bytearray()
        bpp = 4 if fmt2 else 3
        for idx in data:
            px += pal[idx * bpp: idx * bpp + bpp]
            if not fmt2:
                px += b"\xff"
        return cid, w, h, bytes(px)
    if fmt == 4:            # 15bit
        data = zlib.decompress(body[p:])
        px = bytearray()
        for i in range(0, len(data) - 1, 2):
            v = data[i] | (data[i + 1] << 8)
            r = (v >> 10) & 0x1F
            g = (v >> 5) & 0x1F
            b = v & 0x1F
            px += bytes((r << 3 | r >> 2, g << 3 | g >> 2, b << 3 | b >> 2, 255))
        return cid, w, h, bytes(px)
    if fmt == 5:            # 32bit ARGB
        data = zlib.decompress(body[p:])
        px = bytearray(len(data))
        # ARGB -> RGBA
        for i in range(0, len(data), 4):
            a, r, g, b = data[i], data[i + 1], data[i + 2], data[i + 3]
            px[i] = r
            px[i + 1] = g
            px[i + 2] = b
            px[i + 3] = a
        return cid, w, h, bytes(px)
    return None


def save_jpeg_tag(body, code, outdir, min_w, max_w, min_h, max_h, tables=b""):
    """DefineBitsJPEG2(21) / DefineBitsJPEG3(35) / DefineBits(6)：直接吐 PNG/JPEG 负载。

    ⚠️ 老格式（尤其 tag 6）的 JPEG 数据**没有量化表 / 霍夫曼表**，表在单独的
    JPEGTables(tag 8) 里；不拼上会 Image.open 失败。拼法：SOI + tables[2:] + data[2:]。

    返回导出的文件名（未导出返回 None）。"""
    import io
    cid = struct.unpack_from("<H", body, 0)[0]
    if code == 6:
        data = body[2:]
        alpha = None
    elif code == 21:
        data = body[2:]
        alpha = None
    else:                                   # 35：UI32 AlphaDataOffset + JPEG + zlib(alpha)
        alpha_off = struct.unpack_from("<I", body, 2)[0]
        data = body[6:2 + alpha_off]
        try:
            alpha = zlib.decompress(body[2 + alpha_off:])
        except Exception:
            alpha = None
    if tables and data[:2] == b"\xff\xd8":
        data = data[:2] + tables[2:] + data[2:]
    try:
        im = Image.open(io.BytesIO(data))
        im.load()
        im = im.convert("RGBA")
    except Exception:
        return None
    w, h = im.size
    if min_w is not None and w < min_w:
        return None
    if max_w is not None and w > max_w:
        return None
    if min_h is not None and h < min_h:
        return None
    if max_h is not None and h > max_h:
        return None
    if alpha and len(alpha) == w * h:
        im.putalpha(Image.frombytes("L", (w, h), alpha))
    fn = os.path.join(outdir, "jpeg_%d_%dx%d.png" % (cid, w, h))
    im.save(fn)
    return fn


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 1
    swf, outdir = sys.argv[1], sys.argv[2]
    min_w = max_w = min_h = max_h = None
    args = sys.argv[3:]
    for i in range(0, len(args) - 1, 2):
        k, v = args[i], int(args[i + 1])
        if k == "--min-w":
            min_w = v
        elif k == "--max-w":
            max_w = v
        elif k == "--min-h":
            min_h = v
        elif k == "--max-h":
            max_h = v
    os.makedirs(outdir, exist_ok=True)
    raw = decompress(open(swf, "rb").read())
    # 跳过 header：8 字节之外还有 rect + framerate + framecount
    pos = 8
    nbits = raw[pos] >> 3
    pos += (5 + nbits * 4 + 7) // 8 + 4
    n = 0
    tables = b""
    for code, p, ln in iter_tags(raw, pos, len(raw)):
        if code == 8:                        # JPEGTables
            tables = raw[p:p + ln]
            continue
        if code in (6, 21, 35):
            if save_jpeg_tag(raw[p:p + ln], code, outdir, min_w, max_w, min_h, max_h, tables):
                n += 1
            continue
        if code not in (20, 36):
            continue
        body = raw[p:p + ln]
        try:
            cid, w, h, px = decode_lossless(body, code == 36)
        except Exception as e:
            print("跳过 tag%d: %s" % (code, e))
            continue
        if min_w is not None and w < min_w:
            continue
        if max_w is not None and w > max_w:
            continue
        if min_h is not None and h < min_h:
            continue
        if max_h is not None and h > max_h:
            continue
        im = Image.frombytes("RGBA", (w, h), px)
        fn = os.path.join(outdir, "bm_%d_%dx%d.png" % (cid, w, h))
        im.save(fn)
        n += 1
    print("导出 %d 张位图 → %s" % (n, outdir))
    return 0


if __name__ == "__main__":
    sys.exit(main())
