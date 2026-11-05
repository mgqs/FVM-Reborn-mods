# -*- coding: utf-8 -*-
"""把注册表里的 speed / ash_proof 同步成规格表的值。"""
import io
import re
import sys

sys.path.insert(0, r"D:/gameProject/FVM-Reborn-mod/tools")
import zhuore_spec as S  # noqa: E402

P = r"D:/gameProject/FVM-Reborn-mod/scripts/zhuore_enemy_init/zhuore_enemy_init.gml"
spec = {S.PREFIX + m["key"]: m for m in S.MICE}

s = io.open(P, encoding="utf-8").read()
blocks = re.split(r"(?=    // )", s)
out, n = [], 0
for b in blocks:
    m = re.search(r'register_enemy\("([^"]+)"', b)
    if m and m.group(1) in spec:
        eid = m.group(1)
        ms = spec[eid]
        nb, c1 = re.subn(r"\n        speed: [0-9.]+,", "\n        speed: %g," % ms["speed"], b, count=1)
        nb, c2 = re.subn(r"\n        ash_proof: (?:true|false),",
                         "\n        ash_proof: %s," % ("true" if ms["ash_proof"] else "false"), nb, count=1)
        if c1 != 1 or c2 != 1:
            raise SystemExit("改失败: " + eid)
        b, n = nb, n + 1
    out.append(b)
io.open(P, "w", encoding="utf-8", newline="\n").write("".join(out))
print("已同步 %d 条" % n)
