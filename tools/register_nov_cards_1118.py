# -*- coding: utf-8 -*-
"""登记「结界马 / 阴阳蛇」（2026-11-18 新卡）的对象与脚本到工程。

· 对象  obj_jiejiema                      → folders/物体/mod/Cards.yy
        obj_yinyangshe                    → folders/物体/mod/Cards.yy
        obj_yinyangshe_bullet             → folders/物体/mod/Bullet.yy
        obj_jiejiema_field / obj_yinyangshe_poison
                                          → folders/物体/mod/Effect.yy
· 脚本  jiejiema_field                    → folders/脚本/mod.yy

只增不删、按 name 去重，可重复执行。
自检：① 每个对象/脚本都要在 yyp resources 里；
      ② 代码里出现的每个 spr_* / obj_* 都必须能在 yyp 里找到（防手滑拼错名字）。
用法：python tools/register_nov_cards_1118.py
"""
import io
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
YPP = os.path.join(ROOT, "FVM_Reborn_makk.yyp")

OBJ_JOBS = [
    ("obj_jiejiema", "物体/mod/Cards"),
    ("obj_yinyangshe", "物体/mod/Cards"),
    ("obj_yinyangshe_bullet", "物体/mod/Bullet"),
    ("obj_jiejiema_field", "物体/mod/Effect"),
    ("obj_yinyangshe_poison", "物体/mod/Effect"),
]

SCRIPT_JOBS = [
    ("jiejiema_field", "脚本/mod"),
]

SRC_DIRS = [
    "objects/obj_jiejiema",
    "objects/obj_jiejiema_field",
    "objects/obj_yinyangshe",
    "objects/obj_yinyangshe_bullet",
    "objects/obj_yinyangshe_poison",
    "scripts/jiejiema_field",
]

# 长得像资源名、其实是普通变量的东西（obj_type 是 obj_card_parent 里的实例变量）
SKIP_NAMES = {"obj_type"}


def read(p):
    return io.open(p, encoding="utf-8").read()


def write(p, s):
    io.open(p, "w", encoding="utf-8", newline="\n").write(s)


def register_resource(yyp, name, kind):
    """kind: 'objects' / 'scripts'"""
    entry = '    {"id":{"name":"%s","path":"%s/%s/%s.yy",},},\n' % (name, kind, name, name)
    if entry in yyp:
        return yyp, False
    # 挂在同类型第一条之前，保持 IDE 里资源按类型分块的样子
    pat = r'    \{"id":\{"name":"(%s)_' % {"objects": "obj", "scripts": "scr"}[kind]
    m = re.search(pat, yyp)
    if not m:
        m = re.search(r'    \{"id":\{"name":"', yyp)
    return yyp[:m.start()] + entry + yyp[m.start():], True


def register_folder_entry(folder_path, name, kind):
    p = os.path.join(ROOT, "folders", *folder_path.split("/")) + ".yy"
    s = read(p)
    ent = '    {"name":"%s","path":"%s/%s/%s.yy",},\n' % (name, kind, name, name)
    if ent in s:
        return False
    m = re.search(r'"listItems":\[\n', s)
    if not m:
        raise SystemExit("!! %s 找不到 listItems 锚点" % p)
    s = s[:m.end()] + ent + s[m.end():]
    write(p, s)
    return True


def main():
    yyp = read(YPP)
    for name, folder in OBJ_JOBS:
        yyp, added = register_resource(yyp, name, "objects")
        fa = register_folder_entry(folder, name, "objects")
        print("对象 %-26s yyp=%s  folder(%s)=%s" % (name, added, folder, fa))
    for name, folder in SCRIPT_JOBS:
        yyp, added = register_resource(yyp, name, "scripts")
        fa = register_folder_entry(folder, name, "scripts")
        print("脚本 %-26s yyp=%s  folder(%s)=%s" % (name, added, folder, fa))
    write(YPP, yyp)

    # ── 自检 ────────────────────────────────────────────────────────────
    yyp = read(YPP)
    bad = []
    for d in SRC_DIRS:
        for fn in os.listdir(os.path.join(ROOT, d)):
            if not fn.endswith(".gml"):
                continue
            code = read(os.path.join(ROOT, d, fn))
            for ref in set(re.findall(r'\b(obj_[A-Za-z0-9_]+|spr_[A-Za-z0-9_]+)\b', code)):
                if ref in SKIP_NAMES:
                    continue
                if ('"%s"' % ref) in yyp or ('path":"objects/%s/' % ref) in yyp or \
                   ('path":"sprites/%s/' % ref) in yyp:
                    continue
                bad.append((d + "/" + fn, ref))
    if bad:
        print("\n!! 以下名字在代码里出现但 yyp 里没有：")
        for f, r in bad:
            print("   %-52s %s" % (f, r))
    else:
        print("\n自检通过：代码里引用的 obj_ / spr_ 全部已在 yyp 注册")
    for name, _ in OBJ_JOBS:
        if '"%s"' % name not in yyp:
            print("!! 对象未进 yyp:", name)
    for name, _ in SCRIPT_JOBS:
        if '"%s"' % name not in yyp:
            print("!! 脚本未进 yyp:", name)


if __name__ == "__main__":
    main()
