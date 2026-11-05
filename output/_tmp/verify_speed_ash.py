# -*- coding: utf-8 -*-
"""速度 / 防爆 全量核对：规格 · 注册表 · 对象实例。"""
import io
import os
import re
import sys

ROOT = r"D:/gameProject/FVM-Reborn-mod"
sys.path.insert(0, os.path.join(ROOT, "tools"))
import zhuore_spec as S  # noqa: E402

t = io.open(os.path.join(ROOT, "scripts/zhuore_enemy_init/zhuore_enemy_init.gml"),
            encoding="utf-8").read()
reg = {}
for m in re.finditer(r'register_enemy\("([^"]+)",\s*\{(.*?)\}\)', t, re.S):
    b = m.group(2)
    reg[m.group(1)] = (float(re.search(r"speed:\s*(-?\d+(?:\.\d+)?)", b).group(1)),
                       re.search(r"ash_proof:\s*(true|false)", b).group(1))


def create_info(key):
    p = os.path.join(ROOT, "objects", "obj_" + S.PREFIX + key, "Create_0.gml")
    x = io.open(p, encoding="utf-8-sig").read()
    ms = re.search(r"^[ \t]*move_speed[ \t]*=[ \t]*(-?\d+(?:\.\d+)?)", x, re.M)
    ash = re.search(r"^[ \t]*immune_to_ash[ \t]*=[ \t]*(true|false)", x, re.M)
    return (ms.group(1) if ms else "-"), (ash.group(1) if ash else "-")


print("%-14s %-8s %-8s %-10s %-9s %-8s" %
      ("对象", "表格换算", "注册speed", "Create移速", "注册防爆", "实例防爆"))
bad = 0
for m in S.MICE:
    key = m["key"]
    r = reg.get(S.PREFIX + key)
    ms, ash = create_info(key)
    ok = (ash == ("true" if m["ash_proof"] else "false")
          and (r is None or (abs(r[0] - m["speed"]) < 1e-9
                             and r[1] == ("true" if m["ash_proof"] else "false"))))
    if not ok:
        bad += 1
    print("%-14s %-8g %-8s %-10s %-9s %-8s %s" % (
        key, m["speed"],
        ("%g" % r[0]) if r else "召唤",
        ms,
        (r[1] if r else "-"),
        ash,
        "OK" if ok else "!! 不一致"))
print("\n不一致：%d" % bad)
