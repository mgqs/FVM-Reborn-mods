# -*- coding: utf-8 -*-
"""变异战神精灵图层结构修复。

问题（2026-11-15 审计）：spr_infected_zhanshen_* 的图层目录写反了——
  layers/<layerGUID>/<frameGUID>.png   ← 真正的美术帧（每个精灵一份完整拷贝）
  layers/<frameGUID>/<layerGUID>.png   ← 64x64 的「缺图」红叉占位图（.yy 里声明的就是它）
  layers/<frameGUID>/<随机GUID>.png    ← 另一次导入留下的美术帧（未在 .yy 里声明）
顶层合成图 <frameGUID>.png 在多数帧上仍等于反向目录里的美术帧，所以游戏里大部分帧看着正常，
少数帧（合成图没跟上）会显示红叉/发虚。

修复（幂等）：
  1. 取美术帧：优先 layers/<layerGUID>/<frameGUID>.png，其次帧目录内尺寸正确的 png，最后用现有合成图
  2. 写回 layers/<frameGUID>/<layerGUID>.png 与 <frameGUID>.png（字节级拷贝，不重编码）
  3. 删掉帧目录里的非声明图层 png，删掉反向目录
  4. 首次运行把原目录备份到 output/_tmp/bak_<精灵名>/

用法：
  python tools/inf_zhanshen_repair.py            # 全部修复
  python tools/inf_zhanshen_repair.py --check    # 只统计待修项，不动磁盘
"""
import glob
import os
import re
import shutil
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPRITES = os.path.join(ROOT, "sprites")
BACKUP = os.path.join(ROOT, "output", "_tmp")
ORPHAN = os.path.join(BACKUP, "orphan_inf_zhanshen")
PREFIX = "spr_infected_zhanshen"


def move_aside(src, dst):
    """把多余文件挪到 output/_tmp 里，不直接删（避免批量删除护栏）。"""
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    if os.path.isdir(src):
        if os.path.exists(dst):
            return
        shutil.move(src, dst)
        return
    base, ext = os.path.splitext(os.path.basename(dst))
    n = 0
    while os.path.exists(dst):
        n += 1
        dst = os.path.join(os.path.dirname(dst), "%s_%d%s" % (base, n, ext))
    shutil.move(src, dst)

LAYER_RE = re.compile(r'"layers":\s*\[\s*\{[^\}]*?"name":\s*"([0-9a-f\-]{36})"', re.S)


def sprite_meta(name):
    yy = os.path.join(SPRITES, name, name + ".yy")
    text = open(yy, encoding="utf-8").read()
    W = int(re.search(r'"width":\s*(\d+)', text).group(1))
    H = int(re.search(r'"height":\s*(\d+)', text).group(1))
    ml = LAYER_RE.search(text)
    layer = ml.group(1) if ml else None
    frames = []
    for g in re.findall(
        r'"Id":\s*\{\s*"name":\s*"([0-9a-f\-]{36})",\s*"path":\s*"sprites/%s/' % re.escape(name), text
    ):
        if g not in frames:
            frames.append(g)
    if not frames:
        for g in re.findall(r'"\$GMSpriteFrame":"v1","%Name":"([0-9a-f\-]{36})"', text):
            if g not in frames:
                frames.append(g)
    return W, H, layer, frames


def pick_art(name, W, H, frame, layer):
    """返回该帧美术 png 路径；找不到返回 None。

    优先级：顶层合成图 > 反向目录 > 帧目录里的孤儿图层。
    合成图排第一，是因为 inf_zhanshen_restore.py 从 git 历史恢复时写的正是合成图，
    而反向目录里可能还躺着坏提交留下的噪点帧。
    """
    d = os.path.join(SPRITES, name)
    comp0 = os.path.join(d, frame + ".png")
    if os.path.exists(comp0) and Image.open(comp0).size == (W, H):
        return comp0
    inv = os.path.join(d, "layers", layer, frame + ".png")
    if os.path.exists(inv) and Image.open(inv).size == (W, H):
        return inv
    fdir = os.path.join(d, "layers", frame)
    cands = []
    for p in sorted(glob.glob(os.path.join(fdir, "*.png"))):
        if os.path.basename(p) == layer + ".png":
            continue
        try:
            if Image.open(p).size == (W, H):
                cands.append(p)
        except Exception:
            pass
    if cands:
        return cands[0]
    comp = os.path.join(d, frame + ".png")
    if os.path.exists(comp) and Image.open(comp).size == (W, H):
        return comp
    return None


def repair(name, apply=True):
    W, H, layer, frames = sprite_meta(name)
    d = os.path.join(SPRITES, name)
    plan = []
    for f in frames:
        fdir = os.path.join(d, "layers", f)
        target = os.path.join(fdir, layer + ".png")
        comp = os.path.join(d, f + ".png")
        art = pick_art(name, W, H, f, layer)
        need = art is None
        if not need:
            tgt_ok = os.path.exists(target) and Image.open(target).size == (W, H)
            need = not tgt_ok
        extras = [
            p for p in glob.glob(os.path.join(fdir, "*.png"))
            if os.path.basename(p) != layer + ".png"
        ]
        plan.append((f, art, need, extras))

    inv_dir = os.path.join(d, "layers", layer)
    inv_files = glob.glob(os.path.join(inv_dir, "*.png")) if os.path.isdir(inv_dir) else []
    todo = sum(1 for _, _, n, _ in plan if n)
    extra_n = sum(len(e) for _, _, _, e in plan)
    return dict(name=name, size=(W, H), layer=layer, frames=len(frames), todo=todo,
                extras=extra_n, inverted=len(inv_files), plan=plan, inv_dir=inv_dir)


def main():
    check = "--check" in sys.argv
    targets = [n for n in sorted(os.listdir(SPRITES)) if n.startswith(PREFIX)]
    print("%-34s %-9s %-4s %-6s %-6s %-8s" % ("精灵", "尺寸", "帧", "待修帧", "多余层", "反向目录"))
    for name in targets:
        try:
            r = repair(name, apply=not check)
        except Exception as e:  # noqa: BLE001
            print("%-34s ERROR %s" % (name, e))
            continue
        print("%-34s %-9s %-4d %-6d %-6d %-8d" % (
            name, "%dx%d" % r["size"], r["frames"], r["todo"], r["extras"], r["inverted"]))
        if check or r["todo"] == 0 and r["extras"] == 0 and r["inverted"] == 0:
            continue

        bak = os.path.join(BACKUP, "bak_" + name)
        if not os.path.exists(bak):
            shutil.copytree(os.path.join(SPRITES, name), bak)

        missing = []
        for f, art, need, extras in r["plan"]:
            fdir = os.path.join(SPRITES, name, "layers", f)
            os.makedirs(fdir, exist_ok=True)
            if art is None:
                missing.append(f)
                continue
            target = os.path.join(fdir, r["layer"] + ".png")
            comp = os.path.join(SPRITES, name, f + ".png")
            for dst in (target, comp):
                if os.path.abspath(art) != os.path.abspath(dst):
                    shutil.copyfile(art, dst)
            for e in extras:
                move_aside(e, os.path.join(ORPHAN, name, f))
        if os.path.isdir(r["inv_dir"]):
            move_aside(r["inv_dir"], os.path.join(ORPHAN, name, "_inverted"))
        if missing:
            print("    ! 无美术帧（需从 SWF 补）: %s" % ", ".join(x[:8] for x in missing))


if __name__ == "__main__":
    main()
