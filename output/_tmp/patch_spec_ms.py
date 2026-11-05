# -*- coding: utf-8 -*-
"""把规格表的 move_speed 换成可精确到「某一处赋值」的 ms_patch。"""
import io
import re

P = r"D:/gameProject/FVM-Reborn-mod/tools/zhuore_spec.py"

MS = {
    "penguin": [("Create_0.gml", 0.72, 0.6)],
    "garbage": [("Create_0.gml", 0.5, 0.5142)],
    "warrior": [("Create_0.gml", 0.26, 0.2571), ("Step_0.gml", 0.27, 0.2571)],
    "warrior_minion": [("Create_0.gml", 0.26, 0.2571)],
    "naruto": [("Create_0.gml", 0.26, 0.2571), ("Step_0.gml", 0.27, 0.2571)],
    "naruto_minion": [("Create_0.gml", 0.26, 0.2571)],
    "mole": [("Step_0.gml", -0.15, -0.1386)],
    "dentist": [("Step_0.gml", -0.15, -0.1386)],
    "sawblade": [("Step_0.gml", -0.15, -0.1386)],
    "nonmain": [("Create_0.gml", 0.6, 0.3)],
}

s = io.open(P, encoding="utf-8").read()
# 1. 去掉临时的 move_speed 字段
s = re.sub(r"move_speed=[0-9.]+, ", "", s)

# 2. 在 ash_proof=True, 后面插入 ms_patch
blocks = re.split(r"(?=    dict\(key=)", s)
out = []
for b in blocks:
    m = re.match(r'    dict\(key="(\w+)"', b)
    if m and m.group(1) in MS:
        items = ", ".join('("%s", %g, %g)' % (fn, o, n) for fn, o, n in MS[m.group(1)])
        b = b.replace("ash_proof=True, ",
                      "ash_proof=True,\n         ms_patch=[%s], " % items, 1)
    out.append(b)
io.open(P, "w", encoding="utf-8", newline="\n").write("".join(out))
print("ok")
