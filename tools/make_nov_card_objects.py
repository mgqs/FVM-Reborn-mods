# -*- coding: utf-8 -*-
"""生成 11 月第二批新卡的对象骨架（.yy + yyp + folders 注册）。

只负责「资源壳」：对象 .yy、yyp resources 条目、folders 的 listItems。
事件 .gml 由 Write 单独写（本脚本不覆盖已存在的 .gml）。
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

OBJ_TMPL = '''{
  "$GMObject":"",
  "%%Name":"%(name)s",
  "eventList":[
%(events)s
  ],
  "managed":true,
  "name":"%(name)s",
  "overriddenProperties":[],
  "parent":{
    "name":"%(folder)s",
    "path":"folders/物体/%(folderpath)s.yy",
  },
  "parentObjectId":%(parent)s,
  "persistent":false,
  "physicsAngularDamping":0.1,
  "physicsDensity":0.5,
  "physicsFriction":0.2,
  "physicsGroup":0,
  "physicsKinematic":false,
  "physicsLinearDamping":0.1,
  "physicsObject":false,
  "physicsRestitution":0.1,
  "physicsSensor":false,
  "physicsShape":0,
  "physicsShapePoints":[],
  "physicsStartAwake":true,
  "properties":[],
  "resourceType":"GMObject",
  "resourceVersion":"2.0",
  "solid":false,
  "spriteId":%(sprite)s,
  "spriteMaskId":null,
  "visible":true,
}
'''

EVENT_TMPL = ('    {"$GMEvent":"v1","%%Name":"","collisionObjectId":null,"eventNum":%(num)d,'
              '"eventType":%(type)d,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},')

# (eventType, eventNum) -> 文件名
EV_NAME = {
    (0, 0): "Create_0",
    (1, 0): "Destroy_0",
    (3, 0): "Step_0",
    (8, 0): "Draw_0",
    (12, 0): "CleanUp_0",
}
for _n in range(0, 16):
    EV_NAME[(7, 10 + _n)] = "Other_%d" % (10 + _n)

# name, folder(显示名), folderpath, parentObjectId 或 None, sprite 或 None, [(eventType,eventNum)]
JOBS = [
    ("obj_galaxy_horse", "Cards", "mod/Cards", "obj_card_parent", "spr_galaxy_horse",
     [(0, 0), (3, 0), (7, 11)]),
    ("obj_galaxy_horse_bullet", "Bullet", "mod/Bullet", "obj_bullet_parent", None,
     [(0, 0), (3, 0)]),
    ("obj_yuansushe", "Cards", "mod/Cards", "obj_card_parent", "spr_yuansushe",
     [(0, 0), (3, 0), (7, 11)]),
    ("obj_yuansushe_bullet", "Bullet", "mod/Bullet", "obj_bullet_parent", None,
     [(0, 0), (3, 0)]),
    ("obj_yuansushe_fx", "Effect", "mod/Effect", None, None,
     [(0, 0), (3, 0)]),
    ("obj_xinggui_god", "Cards", "mod/Cards", "obj_card_parent", "spr_xinggui_god",
     [(0, 0), (1, 0), (3, 0), (7, 10)]),
    ("obj_xinggui_god_effect", "Effect", "mod/Effect", None, None,
     [(0, 0), (3, 0)]),
]


def parent_block(name):
    if name is None:
        return "null"
    return ('{\n    "name":"%s",\n    "path":"objects/%s/%s.yy",\n  }' % (name, name, name))


def sprite_block(name):
    if name is None:
        return "null"
    return ('{\n    "name":"%s",\n    "path":"sprites/%s/%s.yy",\n  }' % (name, name, name))


def main():
    yyp_path = os.path.join(ROOT, "FVM_Reborn_makk.yyp")
    yyp = open(yyp_path, encoding="utf-8").read()
    folder_cache = {}

    for name, fname, fpath, parent, sprite, events in JOBS:
        d = os.path.join(ROOT, "objects", name)
        os.makedirs(d, exist_ok=True)
        ev = "\n".join(EVENT_TMPL % dict(num=n, type=t) for t, n in events)
        yy = OBJ_TMPL % dict(name=name, events=ev, folder=fname, folderpath=fpath,
                             parent=parent_block(parent), sprite=sprite_block(sprite))
        with open(os.path.join(d, name + ".yy"), "w", encoding="utf-8", newline="\n") as f:
            f.write(yy)
        print("对象壳:", name, "事件", [EV_NAME[(t, n)] for t, n in events])

        entry = '    {"id":{"name":"%s","path":"objects/%s/%s.yy",},},\n' % (name, name, name)
        if entry in yyp:
            print("  yyp 已有")
        else:
            anchor = re.search(r'    \{"id":\{"name":"obj_', yyp)
            if anchor:
                yyp = yyp[:anchor.start()] + entry + yyp[anchor.start():]
                print("  yyp 已注册")
            else:
                print("  !! yyp 找不到 obj_ 锚点")

        # folders
        fp = os.path.join(ROOT, "folders", "物体", fpath + ".yy")
        if fp not in folder_cache:
            folder_cache[fp] = open(fp, encoding="utf-8").read()
        s = folder_cache[fp]
        fe = '    {"name":"%s","path":"objects/%s/%s.yy",},\n' % (name, name, name)
        if fe in s:
            print("  folder 已有")
        else:
            m = re.search(r' *"listItems":\[\n', s)
            if m:
                s = s[:m.end()] + fe + s[m.end():]
                folder_cache[fp] = s
                print("  folder 已注册")
            else:
                print("  !! 没有 listItems:", fp)

    with open(yyp_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(yyp)
    for fp, s in folder_cache.items():
        with open(fp, "w", encoding="utf-8", newline="\n") as f:
            f.write(s)
    print("yyp / folders 已写回")


if __name__ == "__main__":
    main()
