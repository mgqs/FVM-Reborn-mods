# -*- coding: utf-8 -*-
"""删掉单只 BOSS 已生成的全部资源（精灵 / 对象 / yyp 登记 / 分组清单），
用于「原版对象选错了、要换一个基座重建」这种返工。

    python tools/zhuore_boss_clean.py mary

只动 `spr_kf_zrb_<key>*` / `obj_kf_zrb_<key>*`，不会碰别的资源。
分组 .yy 直接删掉，之后 register 会按规格重建。
"""
import io
import os
import re
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
YYP = os.path.join(ROOT, "FVM_Reborn_makk.yyp")
SPR_DIR = os.path.join(ROOT, "sprites")
OBJ_DIR = os.path.join(ROOT, "objects")
SPR_FOLDER = "folders/精灵/Enemy/kuafu/zhuorediyu/boss"
OBJ_FOLDER = "folders/物体/Enemy/kuafu/zhuorediyu/boss"


def main(key):
    hit = []
    for d in sorted(os.listdir(SPR_DIR)):
        if d.startswith("spr_kf_zrb_" + key):
            shutil.rmtree(os.path.join(SPR_DIR, d))
            hit.append("sprites/" + d)
    for d in sorted(os.listdir(OBJ_DIR)):
        if d.startswith("obj_kf_zrb_" + key):
            shutil.rmtree(os.path.join(OBJ_DIR, d))
            hit.append("objects/" + d)

    txt = io.open(YYP, encoding="utf-8-sig").read()
    out = []
    for line in txt.splitlines(True):
        m = re.search(r'"path":"(sprites|objects)/([^/"]+)/', line)
        if m and m.group(2).startswith(("spr_kf_zrb_" + key, "obj_kf_zrb_" + key)):
            continue
        out.append(line)
    io.open(YYP, "w", encoding="utf-8", newline="\n").write("".join(out))

    for p in ("%s/%s.yy" % (SPR_FOLDER, key), "%s/%s.yy" % (OBJ_FOLDER, key)):
        f = os.path.join(ROOT, p.replace("/", os.sep))
        if os.path.isfile(f):
            os.remove(f)
            hit.append(p)

    print("已清理 %d 项：%s" % (len(hit), key))
    for h in hit:
        print("  -", h)


if __name__ == "__main__":
    main(sys.argv[1])
