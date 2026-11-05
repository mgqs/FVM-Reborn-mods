# -*- coding: utf-8 -*-
"""扫出 SWF 里每个 DefineSprite 的帧标签（FrameLabel），用于确定「动作区间」。

用法：python tools/swf_frame_labels.py <swf文件或目录>
输出：spriteId / 总帧数 / [(帧号, 标签), ...]
"""
import os
import struct
import sys
import zlib


def decompress(data):
    if data[:3] == b"CWS":
        return zlib.decompress(data[8:])
    if data[:3] == b"FWS":
        return data[8:]
    raise ValueError("不支持的 SWF 签名: %r" % data[:3])


def skip_rect(buf, pos):
    nbits = buf[pos] >> 3
    total_bits = 5 + nbits * 4
    return pos + (total_bits + 7) // 8


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


def parse(data):
    buf = decompress(data)
    pos = skip_rect(buf, 0)
    pos += 4  # frame rate(2) + frame count(2)
    sprites = {}

    def walk(start, end, sid=None):
        frame = 0
        for code, p, length in iter_tags(buf, start, end):
            if code == 1:          # ShowFrame
                frame += 1
            elif code == 39:       # DefineSprite
                child_id, frames = struct.unpack_from("<HH", buf, p)
                sprites[child_id] = {"len": frames, "labels": []}
                walk(p + 4, p + length, child_id)
            elif code == 43 and sid is not None:   # FrameLabel
                raw = buf[p:p + length]
                zero = raw.find(b"\x00")
                label = raw[:zero if zero >= 0 else len(raw)].decode("utf-8", "ignore")
                sprites[sid]["labels"].append((frame, label))

    walk(pos, len(buf))
    return sprites


def main():
    target = sys.argv[1] if len(sys.argv) > 1 else "."
    files = [target] if os.path.isfile(target) else [
        os.path.join(target, f) for f in sorted(os.listdir(target)) if f.lower().endswith(".swf")]
    for f in files:
        print("=" * 74)
        print(os.path.basename(f))
        try:
            sprites = parse(open(f, "rb").read())
        except Exception as e:
            print("  解析失败:", e)
            continue
        for sid, info in sorted(sprites.items()):
            if not info["labels"]:
                continue
            print("  sprite %-4d frames=%-4d labels=%s" % (sid, info["len"], info["labels"]))


if __name__ == "__main__":
    main()
