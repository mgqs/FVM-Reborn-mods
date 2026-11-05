# -*- coding: utf-8 -*-
"""
精灵资源体检 / 修复。

能识别两类病灶：
  A. 帧文件路径错位：png 平铺在 sprites/<name>/<frameId>.png，
     而 GM 要求 sprites/<name>/layers/<frameId>/<layerId>.png
  B. layers[] 冗余：数组里有多条 GMImageLayer（多为按帧生成 GUID 的旧脚本遗留），
     GM 会为每帧的每个图层去找图 -> 报 File missing。

用法：
    python tools/kuafu_sprite_fix.py              # 只扫 spr_kuafu_*
    python tools/kuafu_sprite_fix.py --all        # 扫全项目
    python tools/kuafu_sprite_fix.py --apply      # 执行 A 类修复（复制文件）

B 类不自动改 .yy —— 自动裁层有风险，脚本只报告，人工确认后再改。
"""
import json
import os
import re
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPRITES = os.path.join(ROOT, "sprites")


def load_yy(path):
    with open(path, "r", encoding="utf-8-sig") as f:  # 新建 sprite 常带 BOM
        raw = f.read()
    raw = re.sub(r",(\s*[}\]])", r"\1", raw)  # GM 允许尾逗号
    return json.loads(raw)


def check_sprite(spr_dir):
    """返回 dict(missing, fixable, extra_layers, why)。"""
    name = os.path.basename(spr_dir)
    yy = os.path.join(spr_dir, name + ".yy")
    out = {"missing": [], "fixable": [], "extra_layers": [], "why": "ok"}
    if not os.path.isfile(yy):
        out["why"] = "no_yy"
        return out
    try:
        d = load_yy(yy)
    except Exception as e:
        out["why"] = "bad_yy: %s" % e
        return out

    layer_ids = [L.get("name") for L in d.get("layers", []) if L.get("name")]
    if not layer_ids:
        out["why"] = "no_layer"
        return out
    if len(layer_ids) > 1:
        out["extra_layers"] = layer_ids[1:]

    for fr in d.get("frames", []):
        fid = fr.get("name")
        if not fid:
            continue
        for lid in layer_ids:
            dst = os.path.join(spr_dir, "layers", fid, lid + ".png")
            if os.path.isfile(dst):
                continue
            out["missing"].append(dst)
            for cand in (
                os.path.join(spr_dir, fid + ".png"),
                os.path.join(spr_dir, fid + ".png.kuafubak"),
                os.path.join(spr_dir, lid + ".png"),
            ):
                if os.path.isfile(cand):
                    out["fixable"].append((cand, dst))
                    break
    return out


def main():
    apply = "--apply" in sys.argv
    scan_all = "--all" in sys.argv

    dirs = []
    for n in sorted(os.listdir(SPRITES)):
        d = os.path.join(SPRITES, n)
        if not os.path.isdir(d):
            continue
        if scan_all or n.startswith("spr_kuafu_"):
            dirs.append(d)

    ok = repairable = 0
    total_missing = total_fix = 0
    fix_list = []
    layer_bad = []
    hard_broken = []

    for sd in dirs:
        r = check_sprite(sd)
        name = os.path.basename(sd)
        if r["why"] != "ok":
            hard_broken.append((name, r["why"]))
            continue
        if r["extra_layers"]:
            layer_bad.append((name, len(r["extra_layers"]) + 1, len(r["missing"])))
        if not r["missing"]:
            ok += 1
            continue
        total_missing += len(r["missing"])
        total_fix += len(r["fixable"])
        if r["fixable"]:
            repairable += 1
            fix_list.extend(r["fixable"])
        else:
            hard_broken.append((name, "%d 帧无源文件" % len(r["missing"])))

    print("扫描范围    : %s (%d 个精灵)" % ("全项目" if scan_all else "spr_kuafu_*", len(dirs)))
    print("  完全正常  : %d" % ok)
    print("  可补文件  : %d" % repairable)
    print("  缺失文件  : %d（可补齐 %d）" % (total_missing, total_fix))
    print("  layers 冗余: %d" % len(layer_bad))
    print("  无法修复  : %d" % len(hard_broken))

    if layer_bad:
        print("\n[B 类] layers[] 条目过多（需手工裁到 1 条）:")
        for n, nl, miss in layer_bad:
            print("  %-42s layers=%d  关联缺失 %d 条" % (n, nl, miss))

    if hard_broken:
        print("\n[A 类] 无源文件 / yy 异常:")
        for n, w in hard_broken[:40]:
            print("  %-42s %s" % (n, w))
        if len(hard_broken) > 40:
            print("  ... 共 %d 个" % len(hard_broken))

    if not apply:
        print("\n[诊断模式] 未写入任何文件。加 --apply 执行 A 类修复。")
        return

    done = 0
    for src, dst in fix_list:
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        if not os.path.isfile(dst):
            shutil.copy2(src, dst)
            done += 1
    print("\n已复制 %d 个帧文件。" % done)


if __name__ == "__main__":
    main()
