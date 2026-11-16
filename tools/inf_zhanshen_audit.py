# -*- coding: utf-8 -*-
"""变异战神精灵结构审计（只读）。

背景：spr_infected_zhanshen_* 系列精灵存在图层目录写反的问题——
  layers/<layerGUID>/<frameGUID>.png  ← 真正的美术帧（目录写反了）
  layers/<frameGUID>/<layerGUID>.png  ← 64x64 的「缺图」红叉占位图
  layers/<frameGUID>/<otherGUID>.png  ← 另一次修复留下的美术帧（未在 .yy 里声明）

用法：
  python tools/inf_zhanshen_audit.py            # 打印审计表
  python tools/inf_zhanshen_audit.py --json      # 机器可读
"""
import glob
import hashlib
import json
import os
import re
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPRITES = os.path.join(ROOT, "sprites")
PREFIX = "spr_infected_zhanshen"

FRAME_RE = re.compile(r'"\$GMSpriteFrame":\s*"v1",\s*"%Name":\s*"([0-9a-f\-]{36})"')
LAYER_RE = re.compile(r'"layers":\s*\[\s*\{[^\}]*?"name":\s*"([0-9a-f\-]{36})"', re.S)


def md5(p):
    with open(p, "rb") as f:
        return hashlib.md5(f.read()).hexdigest()


def sprite_frames(yy_text):
    """从 .yy 的 tracks.keyframes 里按出现顺序取帧 GUID（去重保序）。"""
    seen = []
    for g in FRAME_RE.findall(yy_text):
        if g not in seen:
            seen.append(g)
    return seen


def audit(name):
    d = os.path.join(SPRITES, name)
    yy = os.path.join(d, name + ".yy")
    if not os.path.exists(yy):
        return None
    text = open(yy, encoding="utf-8").read()
    mw = re.search(r'\n  "width":\s*(\d+)', text)
    mh = re.search(r'\n  "height":\s*(\d+)', text)
    if not mw or not mh:
        return {"name": name, "error": "no width/height"}
    W, H = int(mw.group(1)), int(mh.group(1))
    ml = LAYER_RE.search(text)
    layer = ml.group(1) if ml else None
    frames = sprite_frames(text)

    inverted_dir = os.path.join(d, "layers", layer) if layer else None
    inverted = {}
    if inverted_dir and os.path.isdir(inverted_dir):
        for p in glob.glob(os.path.join(inverted_dir, "*.png")):
            inverted[os.path.basename(p)[:-4]] = p

    rows = []
    for f in frames:
        fdir = os.path.join(d, "layers", f)
        comp = os.path.join(d, f + ".png")
        declared_png = os.path.join(fdir, layer + ".png") if layer else None
        rec = {"frame": f, "layers": {}, "comp": None}
        for p in sorted(glob.glob(os.path.join(fdir, "*.png"))):
            im = Image.open(p)
            rec["layers"][os.path.basename(p)[:-4]] = {
                "size": list(im.size),
                "md5": md5(p),
                "ok_size": im.size == (W, H),
            }
        if os.path.exists(comp):
            im = Image.open(comp)
            rec["comp"] = {"size": list(im.size), "md5": md5(comp)}
        if f in inverted:
            im = Image.open(inverted[f])
            rec["inverted"] = {"size": list(im.size), "md5": md5(inverted[f])}
        rec["declared_ok"] = bool(
            declared_png
            and os.path.exists(declared_png)
            and Image.open(declared_png).size == (W, H)
        )
        rows.append(rec)

    bad_declared = sum(1 for r in rows if not r["declared_ok"])
    orphan_layer = sum(
        1 for r in rows if any(k != layer for k in r["layers"])
    )
    comp_mismatch = 0
    for r in rows:
        art = r.get("inverted")
        if art and r["comp"] and art["md5"] != r["comp"]["md5"]:
            comp_mismatch += 1
    return {
        "name": name,
        "size": [W, H],
        "layer": layer,
        "frames": len(frames),
        "inverted_files": len(inverted),
        "bad_declared": bad_declared,
        "frames_with_orphan_layer": orphan_layer,
        "comp_differs_from_art": comp_mismatch,
        "rows": rows,
    }


def main():
    as_json = "--json" in sys.argv
    out = []
    for name in sorted(os.listdir(SPRITES)):
        if not name.startswith(PREFIX):
            continue
        r = audit(name)
        if r:
            out.append(r)
    if as_json:
        print(json.dumps(out, ensure_ascii=False, indent=1))
        return
    print("%-34s %-9s %-3s %-4s %-6s %-6s %-6s" % (
        "精灵", "尺寸", "帧", "反向层", "坏声明", "孤儿层", "合成图异"))
    for r in out:
        if "error" in r:
            print("%-34s ERROR %s" % (r["name"], r["error"]))
            continue
        print("%-34s %-9s %-3d %-4d %-6d %-6d %-6d" % (
            r["name"],
            "%dx%d" % tuple(r["size"]),
            r["frames"],
            r["inverted_files"],
            r["bad_declared"],
            r["frames_with_orphan_layer"],
            r["comp_differs_from_art"],
        ))


if __name__ == "__main__":
    main()
