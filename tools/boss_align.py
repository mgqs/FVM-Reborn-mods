# -*- coding: utf-8 -*-
"""把「原版 BOSS 精灵」的每一帧对齐到「变异素材」的帧，用于确定分段边界。

素材与原版是同一套动作的重绘版，姿态一致，所以按视觉相似度取最近邻
可以得到单调递增的映射；映射的跳变点就是动作段边界。

用法：
    python tools/boss_align.py <原版精灵名> <素材目录名> <sprite_id>
"""
import os
import sys

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import zhuore_build as B            # noqa: E402

BOSS_SRC = r"C:\Users\18203\Desktop\跨服\灼热地域\BOSS\精灵"


def src_frames(cn, sid):
    base = os.path.join(BOSS_SRC, cn, "sprites")
    subs = [d for d in os.listdir(base) if "DefineSprite_%d_" % sid in d]
    if not subs:
        raise RuntimeError("%s 找不到 sprite %d" % (cn, sid))
    d = os.path.join(base, subs[0])
    files = [f for f in os.listdir(d) if f.lower().endswith(".png")]
    files.sort(key=lambda f: int(os.path.splitext(f)[0]))
    return [os.path.join(d, f) for f in files]


def sig(im, n=48):
    im = im.convert("RGBA")
    bb = im.split()[3].getbbox()
    if bb:
        im = im.crop(bb)
    a = np.asarray(im.resize((n, n), Image.LANCZOS), dtype=np.float32) / 255.0
    return np.concatenate([a[..., :3] * a[..., 3:4], a[..., 3:4]], axis=2).reshape(-1)


def align(sprite, cn, sid, total=None):
    m = B.sprite_meta(sprite)
    n = total or len(m["frames"])
    srcs = src_frames(cn, sid)
    O = np.stack([sig(B.frame_image(sprite, i)) for i in range(n)])
    Sp = np.stack([sig(Image.open(p)) for p in srcs])
    D = np.abs(O[:, None, :] - Sp[None, :, :]).mean(2)     # (n, len(srcs))
    best = D.argmin(1)
    print("%s  原版 %d 帧 · 素材 %d 帧" % (sprite, n, len(srcs)))
    segs = []
    prev = -1
    for i, b in enumerate(best):
        if b != prev:
            segs.append((i, int(b)))
            prev = b
    for j, (oi, si) in enumerate(segs):
        end = segs[j + 1][0] if j + 1 < len(segs) else n
        sn = (segs[j + 1][1] if j + 1 < len(segs) else int(best[-1]) + 1) - si
        print("   原版 %3d..%-3d (%2d 帧)  ->  素材 %3d..%-3d (%2d 帧)%s"
              % (oi, end - 1, end - oi, si, si + sn - 1, sn,
                 "" if sn == end - oi else "   << 数量不同，需重采样"))
    return best


if __name__ == "__main__":
    sprite, cn, sid = sys.argv[1], sys.argv[2], int(sys.argv[3])
    total = int(sys.argv[4]) if len(sys.argv) > 4 else None
    align(sprite, cn, sid, total)
