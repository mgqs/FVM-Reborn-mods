# -*- coding: utf-8 -*-
"""
修复 spr_kuafu_* 精灵的帧文件路径。

问题：png 被平铺在 sprites/<name>/<frameId>.png，而 GameMaker 要求
      sprites/<name>/layers/<frameId>/<layerId>.png

用法：
    python tools/kuafu_sprite_fix.py            # 只诊断，不写盘
    python tools/kuafu_sprite_fix.py --apply    # 实际复制文件
"""
import json
import os
import re
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPRITES = os.path.join(ROOT, "sprites")


def load_yy(path):
    with open(path, "r", encoding="utf-8") as f:
        raw = f.read()
    raw = re.sub(r",(\s*[}\]])", r"\1", raw)  # GM 允许尾逗号
    return json.loads(raw)


def plan_sprite(spr_dir):
    """返回 (missing_list, fixable_list)；fixable 为 (src_png, dst_png)。"""
    name = os.path.basename(spr_dir)
    yy = os.path.join(spr_dir, name + ".yy")
    if not os.path.isfile(yy):
        return [], [], "no_yy"
    try:
        d = load_yy(yy)
    except Exception as e:
        return [], [], "bad_yy:%s" % e

    layer_ids = [L.get("name") for L in d.get("layers", [])]
    if not layer_ids:
        return [], [], "no_layer"

    frames = d.get("frames", [])
    missing, fixable = [], []
    for fr in frames:
        fid = fr.get("name")
        if not fid:
            continue
        for lid in layer_ids:
            dst = os.path.join(spr_dir, "layers", fid, lid + ".png")
            if os.path.isfile(dst):
                continue
            missing.append(dst)
            # 尝试几种可能的源位置
            for cand in (
                os.path.join(spr_dir, fid + ".png"),
                os.path.join(spr_dir, fid + ".png.kuafubak"),
                os.path.join(spr_dir, lid + ".png"),
            ):
                if os.path.isfile(cand):
                    fixable.append((cand, dst))
                    break
    return missing, fixable, "ok"


def main():
    apply = "--apply" in sys.argv
    dirs = sorted(
        os.path.join(SPRITES, n)
        for n in os.listdir(SPRITES)
        if n.startswith("spr_kuafu_") and os.path.isdir(os.path.join(SPRITES, n))
    )

    stat = {"ok": 0, "repairable": 0, "broken": 0}
    total_missing = 0
    total_fix = 0
    broken_detail = []
    fix_list = []

    for sd in dirs:
        missing, fixable, why = plan_sprite(sd)
        if why != "ok":
            stat["broken"] += 1
            broken_detail.append((os.path.basename(sd), why))
            continue
        if not missing:
            stat["ok"] += 1
            continue
        total_missing += len(missing)
        total_fix += len(fixable)
        if fixable:
            stat["repairable"] += 1
            fix_list.extend(fixable)
        else:
            stat["broken"] += 1
            broken_detail.append((os.path.basename(sd), "%d 帧无源文件" % len(missing)))

    print("spr_kuafu_* 目录数 : %d" % len(dirs))
    print("  已正常           : %d" % stat["ok"])
    print("  可修复           : %d" % stat["repairable"])
    print("  无法修复         : %d" % stat["broken"])
    print("缺失文件总数       : %d" % total_missing)
    print("可补齐文件数       : %d" % total_fix)
    if broken_detail:
        print("\n无法修复的资源:")
        for n, w in broken_detail[:40]:
            print("  %-42s %s" % (n, w))
        if len(broken_detail) > 40:
            print("  ... 共 %d 个" % len(broken_detail))

    if not apply:
        print("\n[诊断模式] 未写入任何文件。加 --apply 执行修复。")
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
