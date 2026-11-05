# -*- coding: utf-8 -*-
"""给 zhuore_spec.py 的每只鼠补 speed / ash_proof（以及两只的 move_speed）。"""
import io
import re

P = r"D:/gameProject/FVM-Reborn-mod/tools/zhuore_spec.py"

# key -> (表格速度原文, 换算后的 speed, 是否额外改对象 move_speed)
TABLE = {
    "penguin": ("20", 0.6, 0.6),
    "mole": ("30 / 4.62", 0.9, None),
    "garbage": ("17.14", 0.5142, None),
    "flower": ("12 / 30", 0.36, None),
    "warrior": ("40 / 8.57", 1.2, None),
    "warrior_minion": ("8.57", 0.2571, None),
    "naruto": ("40 / 8.57", 1.2, None),
    "naruto_minion": ("8.57", 0.2571, None),
    "dentist": ("30 / 4.62", 0.9, None),
    "ghost": ("20", 0.6, None),
    "arson": ("20", 0.6, None),
    "can": ("10", 0.3, None),
    "sawblade": ("30 / 4.62", 0.9, None),
    "nonmain": ("10", 0.3, 0.3),
    "magician": ("20", 0.6, None),
}

s = io.open(P, encoding="utf-8").read()
blocks = re.split(r"(?=    dict\(key=)", s)
out, n = [], 0
for b in blocks:
    m = re.match(r'    dict\(key="(\w+)"', b)
    if m and m.group(1) in TABLE:
        key = m.group(1)
        raw, spd, mv = TABLE[key]
        extra = "speed=%s, ash_proof=True, " % ("%g" % spd)
        if mv is not None:
            extra += 'move_speed=%s, ' % ("%g" % mv)
        # 插到 hp=xxx, 之后
        mm = re.search(r"hp=\d+,\s*", b)
        if not mm:
            raise SystemExit("找不到 hp: " + key)
        b = b[:mm.end()] + extra + b[mm.end():]
        n += 1
    out.append(b)
io.open(P, "w", encoding="utf-8", newline="\n").write("".join(out))
print("已补 %d 条" % n)
