# -*- coding: utf-8 -*-
"""生成石榴爆爆冰的两个新对象壳（.yy + yyp + folders 注册）。

  obj_shiliu_bullet   —— 石榴籽：爆炸后从空中砸向目标，落地帧结算碾压伤害
  obj_shiliu_ash_fx   —— 老鼠被石榴碾死时的碎冰特效（spr_shiliu_ash_effect 15 帧）

只负责「资源壳」，事件 .gml 由手写。已存在的条目不会重复注册。
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

JOBS = [
    ("obj_shiliu_bullet", "Bullet", "mod/Bullet", None, "spr_shiliu_bullet_0",
     [(0, 0), (3, 0)]),
    ("obj_shiliu_ash_fx", "Effect", "mod/Effect", None, "spr_shiliu_ash_effect",
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
        print("对象壳:", name)

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
