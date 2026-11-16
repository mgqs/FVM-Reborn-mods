# -*- coding: utf-8 -*-
"""跨服章节底图对齐（bg_draw 标定）

背景
----
引擎格子是写死的：`objects/obj_battle/Create_0.gml:36-41`
    grid_offset_x = 695 / grid_cell_size_x = 107
    grid_offset_y = 228 / grid_cell_size_y = 116
底图只由 `objects/obj_battle/Draw_0.gml:3-9` 按关卡 JSON 的 `bg_draw` 缩放绘制。

原生底图（`spr_salad_island_land`，2005x1080，1:1 直绘）实测：美术格缝
    X = 698 + 107.3k   Y = 199 + 115.9k
即**美术格缝比引擎行线高约 29px、比列线右 3px**（obj_bbq/Other_11.gml 记过同类现象），
这是原版美术与逻辑网格的既定关系，跨服章节必须照抄同一关系，否则植物/敌人
相对贴图地块就是"错位"。

跨服半尺寸美术（1108x597 等）实测格距是 60x64（不是 107/2 x 116/2），
所以正确做法是：sx = 107 / 美术格距、sy = 116 / 美术格距，再用第一条格缝
把相位钉到 (698, 199) mod (107, 116)。

用法
----
    python tools/cross_bg_align.py            # 打印拟定的 bg_draw
    python tools/cross_bg_align.py --apply    # 写回 datafiles/level_data/cross/*.json
    python tools/cross_bg_align.py --verify   # 生成 output/_tmp_grid/align_*.png 目检图

禁 json.dump 回写（见 AGENTS.md §10「改关卡」）：保持原文件格式，只做正则替换。
"""

import argparse
import glob
import json
import os
import re

# 引擎网格（唯一事实源：objects/obj_battle/Create_0.gml:36-41）
ENG_OX, ENG_OY = 695.0, 228.0
ENG_CW, ENG_CH = 107.0, 116.0

# 原生底图 spr_salad_island_land 实测格缝（2005x1080，1:1 直绘）
#   长边线检测：X = 698,806,913,...  梯度峰：Y = 199,313,428,...
NATIVE_SEAM_X = 698.0
NATIVE_SEAM_Y = 199.0

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CROSS_DIR = os.path.join(ROOT, "datafiles", "level_data", "cross")

# 每个美术家族实测的「美术空间格距」与「第一条格缝」（单位：美术像素）
# 数据来源见 CHANGELOG 与本工具 --verify 目检图。
FAMILIES = [
    dict(
        key="castle",
        sprites=["spr_mod_ancient_castle_%d" % i for i in range(8)],
        px=108.8, py=117.67, seam_x=915.0, seam_y=426.0,
    ),
    dict(
        key="nightmare_sky",
        sprites=["spr_mengyantiankong_%d" % i for i in range(8)],
        px=60.0, py=65.167, seam_x=384.0, seam_y=170.0,
    ),
    dict(
        key="zhuore",
        sprites=["spr_zhuorediyu"],
        px=60.0, py=63.833, seam_x=381.0, seam_y=170.0,
    ),
    dict(
        key="shuihuo_a",
        sprites=["spr_shuihuozhijian_0"],
        px=60.0, py=64.0, seam_x=380.0, seam_y=167.0,
    ),
    dict(
        key="shuihuo_b",
        sprites=["spr_shuihuozhijian_1"],
        px=59.889, py=64.0, seam_x=379.0, seam_y=232.0,
    ),
    dict(
        key="wudu",
        sprites=["spr_wuduyanjiusuo_%d" % i for i in range(8)],
        px=59.889, py=64.8, seam_x=385.0, seam_y=171.0,
    ),
]


def solve(fam):
    """由美术格距/格缝反解 bg_draw，使第一条格缝落在原生底图的同一关系上。"""
    sx = ENG_CW / fam["px"]
    sy = ENG_CH / fam["py"]
    # 相位：美术格缝 seam 映射到 NATIVE_SEAM（同余 107 / 116），
    # 取让底图尽量覆盖 0..1920 / 0..1080 的那个分支。
    x = NATIVE_SEAM_X - fam["seam_x"] * sx
    y = NATIVE_SEAM_Y - fam["seam_y"] * sy
    x = _pick_branch(x, ENG_CW, 0.0, 1920.0, fam, sx, is_x=True)
    y = _pick_branch(y, ENG_CH, 0.0, 1080.0, fam, sy, is_x=False)
    return dict(x=round(x, 2), y=round(y, 2), sx=round(sx, 4), sy=round(sy, 4))


def _pick_branch(v, pitch, lo, hi, fam, scale, is_x):
    """把 v 平移整数个格距，选让美术覆盖屏幕、空隙最小的分支。"""
    art_w = _art_size(fam["sprites"][0])[0 if is_x else 1] * scale
    best = None
    for k in range(-4, 5):
        cand = v + k * pitch
        gap = max(0.0, -cand) + max(0.0, cand + art_w - (hi - lo))
        key = (round(gap, 1), abs(cand))
        if best is None or key < best[0]:
            best = (key, cand)
    return best[1]


_SIZE_CACHE = {}


def _art_size(sprite):
    if sprite in _SIZE_CACHE:
        return _SIZE_CACHE[sprite]
    yy = os.path.join(ROOT, "sprites", sprite, sprite + ".yy")
    txt = open(yy, encoding="utf-8-sig").read()
    w = int(re.search(r'"width":\s*(\d+)', txt).group(1))
    h = int(re.search(r'"height":\s*(\d+)', txt).group(1))
    _SIZE_CACHE[sprite] = (w, h)
    return w, h


def family_of(sprite):
    for fam in FAMILIES:
        if sprite in fam["sprites"]:
            return fam
    return None


def load_json(path):
    s = open(path, encoding="utf-8-sig").read().replace("\x00", "")
    s = re.sub(r",(\s*[}\]])", r"\1", s)
    return json.loads(s)


BG_RE = re.compile(r'("bg_draw"\s*:\s*)\{[^{}]*\}')


def bg_text(bg):
    return '{"x": %s, "y": %s, "sx": %s, "sy": %s}' % (
        _num(bg["x"]), _num(bg["y"]), _num(bg["sx"]), _num(bg["sy"]))


def _num(v):
    s = ("%.4f" % v).rstrip("0").rstrip(".")
    return s if s not in ("", "-") else "0"


def rewrite(path, bg):
    raw = open(path, encoding="utf-8-sig").read()
    has_bom = raw.startswith("\ufeff")
    body = raw.lstrip("\ufeff")
    if BG_RE.search(body):
        body2 = BG_RE.sub(lambda m: m.group(1) + bg_text(bg), body, count=1)
    else:
        # 在 "map_sprite": "..." 之后插入 bg_draw
        m = re.search(r'(?m)^([ \t]*)"map_sprite"\s*:\s*"[^"]*"\s*,', body)
        if not m:
            raise SystemExit("找不到 map_sprite 字段: " + path)
        indent = m.group(1)
        body2 = (body[:m.end()] + "\n" + indent + '"bg_draw": ' + bg_text(bg) + ","
                 + body[m.end():])
    if body2 != body:
        with open(path, "w", encoding="utf-8-sig" if has_bom else "utf-8", newline="\n") as f:
            f.write(body2)
        return True
    return False


def verify():
    """渲染 1920x1080 叠图：底图按拟定 bg_draw 还原 + 引擎 9x7 网格线。"""
    from PIL import Image, ImageDraw

    out_dir = os.path.join(ROOT, "output", "_tmp_grid")
    os.makedirs(out_dir, exist_ok=True)
    for fam in FAMILIES:
        bg = solve(fam)
        spr = fam["sprites"][0]
        png = sorted(glob.glob(os.path.join(ROOT, "sprites", spr, "*.png")))[0]
        art = Image.open(png).convert("RGBA")
        # 与 objects/obj_battle/Draw_0.gml 一致：先按 cover 铺一层兜底，再画精确对齐那份
        canvas = Image.new("RGBA", (1920, 1080), (20, 20, 20, 255))
        cover = max(1920.0 / art.width, 1080.0 / art.height)
        cv = art.resize((int(art.width * cover), int(art.height * cover)), Image.BILINEAR)
        canvas.alpha_composite(cv, (int((1920 - cv.width) / 2), int((1080 - cv.height) / 2)))
        big = art.resize((int(art.width * bg["sx"]), int(art.height * bg["sy"])), Image.BILINEAR)
        canvas.alpha_composite(big, (int(round(bg["x"])), int(round(bg["y"]))))
        d = ImageDraw.Draw(canvas, "RGBA")
        for c in range(10):
            x = ENG_OX + c * ENG_CW
            d.line([(x, ENG_OY), (x, ENG_OY + 7 * ENG_CH)], fill=(0, 255, 0, 200))
        for r in range(8):
            y = ENG_OY + r * ENG_CH
            d.line([(ENG_OX, y), (ENG_OX + 9 * ENG_CW, y)], fill=(255, 0, 255, 200))
        d.text((12, 12), "%s  x=%.1f y=%.1f sx=%.4f sy=%.4f"
               % (fam["key"], bg["x"], bg["y"], bg["sx"], bg["sy"]), fill=(255, 255, 0, 255))
        name = os.path.join(out_dir, "align_%s.png" % fam["key"])
        canvas.convert("RGB").save(name)
        print("verify ->", name)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true", help="写回关卡 JSON")
    ap.add_argument("--verify", action="store_true", help="生成叠图目检")
    args = ap.parse_args()

    if args.verify:
        verify()
        return

    changed = 0
    for path in sorted(glob.glob(os.path.join(CROSS_DIR, "*.json"))):
        data = load_json(path)
        spr = data.get("map_sprite", "")
        fam = family_of(spr)
        if fam is None:
            print("跳过（未知底图）", os.path.basename(path), spr)
            continue
        bg = solve(fam)
        old = data.get("bg_draw")
        if old and all(abs(old.get(k, 0) - bg[k]) < 1e-4 for k in ("x", "y", "sx", "sy")):
            continue
        print("%-22s %-24s %s -> %s" % (os.path.basename(path), spr,
                                        old and bg_text(old) or "(无)", bg_text(bg)))
        if args.apply:
            if rewrite(path, bg):
                changed += 1
    if args.apply:
        print("已写入 %d 个文件" % changed)
    else:
        print("（未写入；加 --apply 生效）")


if __name__ == "__main__":
    main()
