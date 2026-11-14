# -*- coding: utf-8 -*-
"""变异皮特/朱莉 护盾精灵导入（幂等，可重复执行）。

素材：C:\\Users\\18203\\Desktop\\皮特\\sprites\\DefineSprite_130
      （11 帧 134x206 黄绿蜂巢屏障）
产出：spr_kuafu_boss_shield —— 皮特/朱莉共用，origin 取中心 (67,103)，
      纹理组 enemy_volcanic，挂 folders/精灵/Enemy/kuafu/mengyantiankong/boss/pete.yy

用法：python tools/pete_julie_shield.py
"""
import io
import json
import os
import re
import shutil
import uuid

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
YYP = os.path.join(ROOT, "FVM_Reborn_makk.yyp")

NAME = "spr_kuafu_boss_shield"
SRC = r"C:\Users\18203\Desktop\皮特\sprites\DefineSprite_130"
W, H = 134, 206
OX, OY = 67, 103          # 中心锚点
TG = "enemy_volcanic"
FOLDER = "folders/精灵/Enemy/kuafu/mengyantiankong/boss/pete.yy"
FOLDER_PATH_KEY = "folders/\u7cbe\u7075/Enemy/kuafu/mengyantiankong/boss/pete.yy"

YY_TMPL = '''{
  "$GMSprite":"v2",
  "%%Name":"%(name)s",
  "bboxMode":0,
  "bbox_bottom":%(h1)d,
  "bbox_left":0,
  "bbox_right":%(w1)d,
  "bbox_top":0,
  "collisionKind":0,
  "collisionTolerance":0,
  "DynamicTexturePage":false,
  "edgeFiltering":false,
  "For3D":false,
  "frames":[
%(frames)s
  ],
  "gridX":0,
  "gridY":0,
  "height":%(h)d,
  "HTile":false,
  "layers":[
%(layers)s
  ],
  "name":"%(name)s",
  "nineSlice":null,
  "origin":4,
  "parent":{
    "name":"pete",
    "path":"%(folder)s",
  },
  "preMultiplyAlpha":false,
  "resourceType":"GMSprite",
  "resourceVersion":"2.0",
  "sequence":{
    "$GMSequence":"v1",
    "%%Name":"%(name)s",
    "autoRecord":true,
    "backdropHeight":768,
    "backdropImageOpacity":0.5,
    "backdropImagePath":"",
    "backdropWidth":1366,
    "backdropXOffset":0.0,
    "backdropYOffset":0.0,
    "events":{
      "$KeyframeStore<MessageEventKeyframe>":"",
      "Keyframes":[],
      "resourceType":"KeyframeStore<MessageEventKeyframe>",
      "resourceVersion":"2.0",
    },
    "eventStubScript":null,
    "eventToFunction":{},
    "length":%(length).1f,
    "lockOrigin":false,
    "moments":{
      "$KeyframeStore<MomentsEventKeyframe>":"",
      "Keyframes":[],
      "resourceType":"KeyframeStore<MomentsEventKeyframe>",
      "resourceVersion":"2.0",
    },
    "name":"%(name)s",
    "playback":1,
    "playbackSpeed":30.0,
    "playbackSpeedType":0,
    "resourceType":"GMSequence",
    "resourceVersion":"2.0",
    "showBackdrop":true,
    "showBackdropImage":false,
    "timeUnits":1,
    "tracks":[
      {"$GMSpriteFramesTrack":"","builtinName":0,"events":[],"inheritsTrackColour":true,"interpolation":1,"isCreationTrack":false,"keyframes":{"$KeyframeStore<SpriteFrameKeyframe>":"","Keyframes":[
%(keys)s
          ],"resourceType":"KeyframeStore<SpriteFrameKeyframe>","resourceVersion":"2.0",},"modifiers":[],"name":"frames","resourceType":"GMSpriteFramesTrack","resourceVersion":"2.0","spriteId":null,"trackColour":0,"tracks":[],"traits":0,},
    ],
    "visibleRange":null,
    "volume":1.0,
    "xorigin":%(ox)d,
    "yorigin":%(oy)d,
  },
  "swatchColours":null,
  "swfPrecision":2.525,
  "textureGroupId":{
    "name":"%(tg)s",
    "path":"texturegroups/%(tg)s",
  },
  "type":0,
  "VTile":false,
  "width":%(w)d,
}
'''

FRAME_TMPL = '    {"$GMSpriteFrame":"v1","%%Name":"%(f)s","name":"%(f)s","resourceType":"GMSpriteFrame","resourceVersion":"2.0",},'
LAYER_TMPL = '    {"$GMImageLayer":"","%%Name":"%(l)s","blendMode":0,"displayName":"default","isLocked":false,"name":"%(l)s","opacity":100.0,"resourceType":"GMImageLayer","resourceVersion":"2.0","visible":true,},'
KEY_TMPL = ('            {"$Keyframe<SpriteFrameKeyframe>":"","Channels":{\n'
            '                "0":{"$SpriteFrameKeyframe":"","Id":{"name":"%(f)s","path":"sprites/%(name)s/%(name)s.yy",},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",},\n'
            '              },"Disabled":false,"id":"%(k)s","IsCreationKey":false,"Key":%(key).1f,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,},')


def load_yy(p):
    s = io.open(p, encoding="utf-8-sig").read()
    return json.loads(re.sub(r",(\s*[}\]])", r"\1", s))


def build():
    pngs = [os.path.join(SRC, "%d.png" % i) for i in range(1, 12)]
    for p in pngs:
        assert os.path.isfile(p), "缺素材帧: " + p

    d = os.path.join(ROOT, "sprites", NAME)
    if os.path.isdir(d):
        shutil.rmtree(d)
    os.makedirs(os.path.join(d, "layers"), exist_ok=True)

    frames, keys = [], []
    # GMSprite 的 layers 是所有帧共用的一套：只生成一个图层 GUID，
    # 每帧目录 layers/<帧GUID>/<图层GUID>.png
    lid = str(uuid.uuid4())
    layers = [LAYER_TMPL % dict(l=lid)]
    for i, src in enumerate(pngs):
        fid = str(uuid.uuid4())
        shutil.copyfile(src, os.path.join(d, fid + ".png"))
        ldir = os.path.join(d, "layers", fid)
        os.makedirs(ldir, exist_ok=True)
        shutil.copyfile(src, os.path.join(ldir, lid + ".png"))
        frames.append(FRAME_TMPL % dict(f=fid))
        keys.append(KEY_TMPL % dict(f=fid, k=str(uuid.uuid4()), key=float(i), name=NAME))

    yy = YY_TMPL % dict(name=NAME, frames="\n".join(frames), layers="\n".join(layers),
                        keys="\n".join(keys), w=W, h=H, w1=W - 1, h1=H - 1,
                        ox=OX, oy=OY, tg=TG, length=11.0, folder=FOLDER_PATH_KEY)
    io.open(os.path.join(d, NAME + ".yy"), "w", encoding="utf-8", newline="\n").write(yy)
    print("精灵已生成:", d, "11 帧")

    # yyp resources（按 path 去重、只增不删）
    s = io.open(YYP, encoding="utf-8-sig").read()
    path_key = "sprites/%s/%s.yy" % (NAME, NAME)
    if '"path":"%s"' % path_key in s:
        print("yyp 已有")
    else:
        m = re.search(r'"resources":\[\n', s)
        assert m, "yyp 找不到 resources 段"
        entry = '    {"id":{"name":"%s","path":"%s",},},\n' % (NAME, path_key)
        s = s[:m.end()] + entry + s[m.end():]
        io.open(YYP, "w", encoding="utf-8", newline="\n").write(s)
        print("yyp 已注册")

    # folder listItems
    full = os.path.join(ROOT, FOLDER.replace("/", os.sep))
    dd = load_yy(full)
    items = [(f["name"], f["path"]) for f in dd.get("listItems", [])]
    if (NAME, path_key) not in items:
        items.append((NAME, path_key))
        txt = ('{\n  "$GMFolder":"",\n  "%%Name":"pete",\n  "folderPath":"%s",\n'
               '  "isDefaultView":false,\n  "listViewItems":[],\n  "name":"pete",\n'
               '  "resourceType":"GMFolder",\n  "resourceVersion":"2.0",\n'
               '  "viewLocked":false,\n  "visible":true,\n  "folders":[\n%s  ],\n'
               '  "listItems":[\n%s  ],\n}\n') % (
            FOLDER_PATH_KEY,
            "".join('    {"name":"%s","path":"%s",},\n' % f
                    for f in [(x["name"], x["path"]) for x in dd.get("folders", [])]),
            "".join('    {"name":"%s","path":"%s",},\n' % i for i in items))
        io.open(full, "w", encoding="utf-8", newline="\n").write(txt)
        print("folder 已注册:", FOLDER_PATH_KEY)
    else:
        print("folder 已有")

    # 顶层合成图与 layers 源图 md5 一致性抽查（B19）
    import hashlib
    frame_files = [f for f in os.listdir(d) if f.endswith(".png")]
    ok = True
    for fid in frame_files:
        a = hashlib.md5(open(os.path.join(d, fid), "rb").read()).hexdigest()
        b = hashlib.md5(open(os.path.join(d, "layers", fid[:-4], lid + ".png"), "rb").read()).hexdigest()
        if a != b:
            ok = False
            print("!! md5 不一致:", fid)
    print("md5 校验:", "通过" if ok else "失败", "(%d 帧)" % len(frame_files))


if __name__ == "__main__":
    build()
