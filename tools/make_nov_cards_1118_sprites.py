# -*- coding: utf-8 -*-
"""11 月第四批新卡（结界马 / 阴阳蛇）精灵批生成 + 每卡一个 GMS 文件夹。

素材：D:\\FVM开发\\game\\FVM开发\\res\\res1118\\11月份做卡11.14
口径（沿用工程既有精灵）：
  · 地块精灵（卡片本体）—— 原点取「alpha 包围盒底边中心」（同 spr_galaxy_horse）
  · 朝右子弹 —— 原点贴包围盒右侧、垂直居中（同 spr_yuansushe_bullet）
  · 线段 / 多边形边 —— 原点取包围盒左侧中点（绘制时按长度拉伸 + 角度旋转）
  · 特效 / 范围框 —— 原点取画布中心
  · 每张卡的精灵统一挂 folders/精灵/mod/Cards/<卡名>.yy（2026-11-18 用户指定）

不依赖 PIL / numpy：本机 numpy 已损坏（import 后无 __version__）、Python312 无 PIL，
所以这里自带一个 8-bit RGBA PNG 的 alpha 包围盒读取。
"""
import os
import re
import sys
import zlib
import struct

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from make_multi_frame_sprite import build, ROOT  # noqa: E402

SRC_ROOT = r"D:\FVM开发\game\FVM开发\res\res1118\11月份做卡11.14"

# ── PNG alpha 包围盒（纯标准库）─────────────────────────
def _png_rgba(path):
    """返回 (w, h, alpha_bytes)。仅支持 bitdepth=8 的 colortype 6(RGBA)/2(RGB)。"""
    with open(path, "rb") as f:
        data = f.read()
    assert data[:8] == b"\x89PNG\r\n\x1a\n", path
    pos, idat, w, h, ct = 8, [], 0, 0, 6
    while pos < len(data):
        ln, typ = struct.unpack(">I4s", data[pos:pos + 8])
        chunk = data[pos + 8:pos + 8 + ln]
        if typ == b"IHDR":
            w, h, bd, ct = struct.unpack(">IIBB", chunk[:10])
            assert bd == 8 and ct in (6, 2), (path, bd, ct)
        elif typ == b"IDAT":
            idat.append(chunk)
        elif typ == b"IEND":
            break
        pos += 12 + ln
    raw = zlib.decompress(b"".join(idat))
    bpp = 4 if ct == 6 else 3
    stride = w * bpp
    out = bytearray(w * h * bpp)
    prev = bytearray(stride)
    p = 0
    for y in range(h):
        ft = raw[p]; p += 1
        line = bytearray(raw[p:p + stride]); p += stride
        if ft == 1:
            for i in range(bpp, stride):
                line[i] = (line[i] + line[i - bpp]) & 0xFF
        elif ft == 2:
            for i in range(stride):
                line[i] = (line[i] + prev[i]) & 0xFF
        elif ft == 3:
            for i in range(stride):
                a = line[i - bpp] if i >= bpp else 0
                line[i] = (line[i] + ((a + prev[i]) >> 1)) & 0xFF
        elif ft == 4:
            for i in range(stride):
                a = line[i - bpp] if i >= bpp else 0
                b = prev[i]
                c = prev[i - bpp] if i >= bpp else 0
                pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2 * c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[i] = (line[i] + pr) & 0xFF
        out[y * stride:(y + 1) * stride] = line
        prev = line
    if ct == 6:
        alpha = bytes(out[3::4])
    else:
        alpha = b"\xff" * (w * h)
    return w, h, alpha


def png_size(path):
    with open(path, "rb") as f:
        d = f.read(33)
    return struct.unpack(">II", d[16:24])


def alpha_bbox(path, thr=8):
    w, h, a = _png_rgba(path)
    minx, miny, maxx, maxy = w, h, -1, -1
    for y in range(h):
        row = a[y * w:(y + 1) * w]
        xs = [x for x, v in enumerate(row) if v > thr]
        if not xs:
            continue
        if y < miny:
            miny = y
        maxy = y
        if xs[0] < minx:
            minx = xs[0]
        if xs[-1] > maxx:
            maxx = xs[-1]
    if maxx < 0:
        return None
    return minx, miny, maxx, maxy


def union_bbox(paths):
    w, h = png_size(paths[0])
    r = [w, h, -1, -1]
    for p in paths:
        bb = alpha_bbox(p)
        if not bb:
            continue
        r[0] = min(r[0], bb[0]); r[1] = min(r[1], bb[1])
        r[2] = max(r[2], bb[2]); r[3] = max(r[3], bb[3])
    return tuple(r) if r[2] >= 0 else (0, 0, w - 1, h - 1)


def origin_for(mode, w, h, bb):
    minx, miny, maxx, maxy = bb
    if mode == "foot":
        return int(round((minx + maxx) / 2.0)), maxy
    if mode == "right_center":
        return max(0, maxx - 4), int(round((miny + maxy) / 2.0))
    if mode == "left_center":
        return minx + 2, int(round((miny + maxy) / 2.0))
    if mode == "center":
        return w // 2, h // 2
    raise ValueError(mode)


# ── GMS 文件夹（每张卡一个）───────────────────────────
FOLDER_TMPL = '''{
  "$GMFolder":"",
  "%%Name":"%(name)s",
  "folderPath":"folders/精灵/mod/Cards/%(name)s.yy",
  "isDefaultView":false,
  "listViewItems":[],
  "name":"%(name)s",
  "resourceType":"GMFolder",
  "resourceVersion":"2.0",
  "viewLocked":false,
  "visible":true,
  "folders":[],
  "listItems":[
  ],
}
'''


def ensure_folder(name):
    """新建 folders/精灵/mod/Cards/<name>.yy 并登记到 Cards.yy 与 yyp Folders。"""
    rel = "精灵/mod/Cards/%s" % name
    path = os.path.join(ROOT, "folders", *rel.split("/")) + ".yy"
    if not os.path.exists(path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            f.write(FOLDER_TMPL % dict(name=name))
        print("文件夹已建:", rel)

    # 父文件夹 Cards.yy 的 folders 数组
    parent = os.path.join(ROOT, "folders", "精灵", "mod", "Cards.yy")
    s = open(parent, encoding="utf-8").read()
    entry = '    {"name":"%s","path":"folders/%s.yy",},\n' % (name, rel)
    if entry not in s:
        anchor = re.search(r'"folders":\[\n', s)
        s = s[:anchor.end()] + entry + s[anchor.end():]
        open(parent, "w", encoding="utf-8", newline="\n").write(s)
        print("  Cards.yy folders 已登记")

    # yyp Folders 数组
    yyp = os.path.join(ROOT, "FVM_Reborn_makk.yyp")
    s = open(yyp, encoding="utf-8").read()
    yent = ('    {"$GMFolder":"","%%Name":"%s","folderPath":"folders/%s.yy",'
            '"name":"%s","resourceType":"GMFolder","resourceVersion":"2.0",},\n') % (name, rel, name)
    if yent not in s:
        anchor = re.search(r'"Folders":\[\n', s)
        s = s[:anchor.end()] + yent + s[anchor.end():]
        open(yyp, "w", encoding="utf-8", newline="\n").write(s)
        print("  yyp Folders 已登记")


# ── 精灵作业表（源目录, 精灵名, 纹理组, 原点模式, 目标文件夹）──
JJ = "mod/Cards/jiejiema"
YY = "mod/Cards/yinyangshe"

JOBS = [
    # 结界马：3 形态 + 4 特效
    ("spr-jiejiema/0shape", "spr_jiejiema", "cards", "foot", JJ),
    ("spr-jiejiema/1shape", "spr_jiejiema_1", "cards", "foot", JJ),
    ("spr-jiejiema/2shape", "spr_jiejiema_2", "cards", "foot", JJ),
    ("spr-jiejiema/effect-1grid", "spr_jiejiema_fx_grid", "effects", "center", JJ),
    ("spr-jiejiema/effect-1line", "spr_jiejiema_fx_line", "effects", "left_center", JJ),
    ("spr-jiejiema/effect-side-of-polygon", "spr_jiejiema_fx_side", "effects", "left_center", JJ),
    ("spr-jiejiema/effect-inside-polygon", "spr_jiejiema_fx_inside", "effects", "center", JJ),
    # 阴阳蛇：3 形态 + 阴/阳子弹 + 中毒特效
    ("spr-yinyangshe/0shape", "spr_yinyangshe", "cards", "foot", YY),
    ("spr-yinyangshe/1shape", "spr_yinyangshe_1", "cards", "foot", YY),
    ("spr-yinyangshe/2shape", "spr_yinyangshe_2", "cards", "foot", YY),
    ("spr-yinyangshe/yin-bullet", "spr_yinyangshe_bullet_yin", "bullet", "right_center", YY),
    ("spr-yinyangshe/yang-bullet", "spr_yinyangshe_bullet_yang", "bullet", "right_center", YY),
    ("spr-yinyangshe/posioneffect-onmouse", "spr_yinyangshe_fx_poison", "effects", "center", YY),
]


def frame_paths(d):
    names = [f for f in os.listdir(d) if f.lower().endswith(".png")]
    names.sort(key=lambda x: int(os.path.splitext(x)[0]))
    return [os.path.join(d, f) for f in names]


def main():
    only = sys.argv[1:] or None
    ensure_folder("jiejiema")
    ensure_folder("yinyangshe")
    for rel, name, tg, mode, pdir in JOBS:
        if only and name not in only:
            continue
        d = os.path.join(SRC_ROOT, rel.replace("/", os.sep))
        paths = frame_paths(d)
        w, h = png_size(paths[0])
        bb = union_bbox(paths)
        ox, oy = origin_for(mode, w, h, bb)
        build(name, paths, w, h, ox, oy, tg, pdir=pdir)
        print("    %dx%d  origin(%d,%d)  bbox=%s  frames=%d" % (w, h, ox, oy, bb, len(paths)))


if __name__ == "__main__":
    main()
