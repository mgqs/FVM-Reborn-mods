# -*- coding: utf-8 -*-
"""三方核对：规格表 / 对象 Create / 注册表，HP 与护盾是否一致。"""
import io
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.abspath(__file__)))), "tools"))
import zhuore_spec as S  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
INIT = os.path.join(ROOT, "scripts", "zhuore_enemy_init", "zhuore_enemy_init.gml")

text = io.open(INIT, encoding="utf-8").read()
reg = {}
for m in re.finditer(r'register_enemy\("([^"]+)",\s*\{(.*?)\}\)', text, re.S):
    body = m.group(2)
    reg[m.group(1)] = (int(re.search(r"hp:\s*(\d+)", body).group(1)),
                       int(re.search(r"shield:\s*(\d+)", body).group(1)))


def obj_hp(key):
    p = os.path.join(ROOT, "objects", "obj_" + S.PREFIX + key, "Create_0.gml")
    x = io.open(p, encoding="utf-8-sig").read()

    def g(name):
        mm = re.search(r"^%s\s*=\s*(\d+)" % name, x, re.M)
        return int(mm.group(1)) if mm else 0

    return g("hp"), g("maxhp"), g("shield_hp"), g("shield_max_hp")


print("%-14s %-10s %-6s %-6s %-8s %s" % ("对象", "表格名", "规格", "Create", "注册hp", "护盾 规格/实例/注册"))
bad = 0
for mm in S.MICE:
    key, hp, sh = mm["key"], mm["hp"], mm.get("shield") or 0
    oh, omh, osh, osmh = obj_hp(key)
    r = reg.get(S.PREFIX + key)
    ok = (oh == hp and omh == hp and osh == sh and osmh == sh
          and (r is None or (r[0] == hp and r[1] == sh)))
    if not ok:
        bad += 1
    print("%-14s %-10s %-6d %-6d %-8s %d/%d/%s %s"
          % (key, mm["cn"][:6], hp, oh, ("%d" % r[0]) if r else "召唤",
             sh, osh, ("%d" % r[1]) if r else "-", "OK" if ok else "!! 不一致"))
print("\n不一致对象：%d" % bad)
