# -*- coding: utf-8 -*-
"""纹理组页数审计 / 大图分流

用途：定位 GameMaker 编译期 "Texture compression failed" +
      "Unable to create a bitmap of size (2048x2048) - out of memory"。

默认 dry-run，只打印报告，不改任何文件。
--apply 才会把 >= 阈值的 sprite 迁到 bg_full 组，并同步 .yyp / folders。

用法：
    python tools/texgroup_audit.py                    # 只报告
    python tools/texgroup_audit.py --apply            # 迁移 >=1024px 的 sprite
    python tools/texgroup_audit.py --apply --min 512  # 自定义阈值
"""
import argparse
import json
import os
import re
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
YYP = os.path.join(ROOT, "FVM_Reborn_makk.yyp")
TRAILING = re.compile(r",(\s*[}\]])")


def load_yy(path):
    with open(path, "r", encoding="utf-8-sig") as f:
        raw = f.read()
    return json.loads(TRAILING.sub(r"\1", raw))


def dump_yy(path, obj):
    """保持 GameMaker 风格：4 空格缩进 + 尾逗号。"""
    text = json.dumps(obj, ensure_ascii=False, indent=2)
    open(path, "w", encoding="utf-8").write(text + "\n")


def iter_sprites():
    spr_dir = os.path.join(ROOT, "sprites")
    for name in sorted(os.listdir(spr_dir)):
        yy = os.path.join(spr_dir, name, name + ".yy")
        if os.path.isfile(yy):
            yield name, yy


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--min", type=int, default=1024)
    ap.add_argument("--page", type=int, default=2048)
    ap.add_argument("--target-group", default="bg_full")
    args = ap.parse_args()

    yyp = load_yy(YYP)
    groups = {}
    for g in yyp.get("TextureGroups", []):
        groups[g["name"]] = g
    print("=== .yyp textureGroups (%d) ===" % len(groups))
    for g in yyp.get("TextureGroups", []):
        print("  %-22s border=%-2s autocrop=%-5s scaled=%-5s %s %s"
              % (g.get("name"), g.get("border"), g.get("autocrop"),
                 g.get("isScaled"), g.get("compressFormat"),
                 g.get("customOptions")))

    # 统计
    stats = {}
    big = []
    total = 0
    for name, yy in iter_sprites():
        total += 1
        t = open(yy, "r", encoding="utf-8-sig").read()
        wm = re.search(r'"width":\s*(\d+)', t)
        hm = re.search(r'"height":\s*(\d+)', t)
        gm = re.search(r'"path":\s*"texturegroups/([^"]+)"', t)
        if not (wm and hm):
            continue
        w, h = int(wm.group(1)), int(hm.group(1))
        grp = gm.group(1) if gm else "Default"
        g = groups.get(grp, {})
        b = int(g.get("border", 2) or 0) * 2
        area = (w + b) * (h + b)
        s = stats.setdefault(grp, {"n": 0, "area": 0, "big": 0})
        s["n"] += 1
        s["area"] += area
        if w >= args.min or h >= args.min:
            s["big"] += 1
            big.append((name, w, h, grp, area))

    page = args.page * args.page
    print("\n=== 各组理论页数（%dx%d 页，含 border 折算）===" % (args.page, args.page))
    print("%-22s %7s %8s %9s %10s" % ("group", "sprites", "大图", "理论页数", "页内存MB"))
    rows = sorted(stats.items(), key=lambda kv: -kv[1]["area"])
    tot_pages = 0
    for grp, s in rows:
        pages = -(-s["area"] // page)
        tot_pages += pages
        print("%-22s %7d %8d %9d %10d" % (grp, s["n"], s["big"], pages, pages * page * 4 // 1048576))
    print("%-22s %7d %8s %9d %10d" % ("合计", total, "", tot_pages,
                                      tot_pages * page * 4 // 1048576))

    print("\n=== >= %dpx 的 sprite (%d 个) ===" % (args.min, len(big)))
    for name, w, h, grp, area in sorted(big, key=lambda x: -x[4]):
        print("  %-36s %5dx%-5d %11s px  [%s]" % (name, w, h, format(area, ","), grp))

    if not args.apply:
        print("\n[dry-run] 未修改任何文件。加 --apply 把上面这些 sprite 迁到 %s 组。"
              % args.target_group)
        return 0

    # ---- apply ----
    tgt = args.target_group
    if tgt not in groups:
        groups[tgt] = {
            "$GMExtensionResource": "",
            "%Name": tgt,
            "autocrop": False,
            "border": 0,
            "compressFormat": "custom",
            "customOptions": "BCN -u4",
            "directory": "",
            "groupParent": None,
            "isScaled": False,
            "mipsToGenerate": 0,
            "name": tgt,
            "resourceType": "GMFolder",
            "resourceVersion": "2.0",
            "targets": -1,
        }
        yyp["TextureGroups"].append(groups[tgt])
        print("[apply] .yyp 新增组 %s" % tgt)

    changed = 0
    for name, w, h, grp, area in big:
        if grp == tgt:
            continue
        yy = os.path.join(ROOT, "sprites", name, name + ".yy")
        t = open(yy, "r", encoding="utf-8-sig").read()
        new = re.sub(r'("textureGroupId":\s*\{[^}]*?"path":\s*")texturegroups/[^"]+"',
                     r'\1texturegroups/%s"' % tgt, t, count=1)
        if new != t:
            shutil.copy2(yy, yy + ".texbak")
            open(yy, "w", encoding="utf-8-sig").write(new)
            changed += 1
    dump_yy(YYP, yyp)
    shutil.copy2(YYP, YYP + ".texbak")
    print("[apply] 迁移 %d 个 sprite → %s（原文件存为 *.texbak）" % (changed, tgt))
    return 0


if __name__ == "__main__":
    sys.exit(main())
