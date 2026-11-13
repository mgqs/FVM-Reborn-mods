# -*- coding: utf-8 -*-
"""生成后羿四形态的「地火」多帧精灵（spr_houyi_god_ground_fire / _1 / _2 / _3）。

素材来源：C:\\Users\\18203\\Desktop\\皮特\\houyi\\sprites\\shape0..shape3\\2.png .. 18.png
  1.png / 19.png / 20.png 是全透明帧（alpha>=128 无像素），导入后循环播放会闪空，丢掉。

原点选「实心内容框的底部中心」：
  这样游戏里摆放时只要 x = 格中心、y = 内容底边即可，缩放系数 sx/sy 直接把内容框铺满一格。
"""
import os
import shutil
import uuid

ROOT = r"D:\gameProject\FVM-Reborn-mod"
SRC = r"C:\Users\18203\Desktop\皮特\houyi\sprites"
LAYER_GUID = "7fb5d22c-fdaf-4b48-b94c-9be62cdcfdc4"   # 与 spr_houyi_god_fire 同一套 layer
TEXTURE_GROUP = "effects"
PARENT = ("houyi_god", "folders/精灵/mod/Cards/Shooter/houyi_god.yy")

# name, 源目录, 画布 w/h, 原点 x/y(内容框底心), 内容框 left/top/right/bottom, 内容 w/h
SPECS = [
    ("spr_houyi_god_ground_fire",   "shape0", 124, 112, 55,  97, 15, 13,  95,  97,  81,  85),
    ("spr_houyi_god_ground_fire_1", "shape1", 124, 112, 55,  97, 15, 13,  95,  97,  81,  85),
    ("spr_houyi_god_ground_fire_2", "shape2", 147, 133, 67, 115, 17, 12, 116, 115, 100, 104),
    ("spr_houyi_god_ground_fire_3", "shape3", 153, 168, 78, 133, 20, 19, 135, 133, 116, 115),
]

FRAME_NUMS = list(range(2, 19))     # 2..18


def build_yy(name, w, h, ox, oy, bl, bt, br, bb, frames):
    tx, ty = PARENT
    fr_lines = "\n".join(
        '    {"$GMSpriteFrame":"v1","%%Name":"%s","name":"%s","resourceType":"GMSpriteFrame","resourceVersion":"2.0",}' % (g, g)
        for g in frames)
    key_lines = "\n".join(
        '            {"$Keyframe<SpriteFrameKeyframe>":"","Channels":{\n'
        '                "0":{"$SpriteFrameKeyframe":"","Id":{"name":"%s","path":"sprites/%s/%s.yy",},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",},\n'
        '              },"Disabled":false,"id":"%s","IsCreationKey":false,"Key":%d.0,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,}'
        % (g, name, name, str(uuid.uuid4()), i)
        for i, g in enumerate(frames))
    return """{
  "$GMSprite":"v2",
  "%%Name":"%(name)s",
  "bboxMode":0,
  "bbox_bottom":%(bb)d,
  "bbox_left":%(bl)d,
  "bbox_right":%(br)d,
  "bbox_top":%(bt)d,
  "collisionKind":1,
  "collisionTolerance":0,
  "DynamicTexturePage":false,
  "edgeFiltering":false,
  "For3D":false,
  "frames":[
%(fr)s,
  ],
  "gridX":0,
  "gridY":0,
  "height":%(h)d,
  "HTile":false,
  "layers":[
    {"$GMImageLayer":"","%%Name":"%(lg)s","blendMode":0,"displayName":"default","isLocked":false,"name":"%(lg)s","opacity":100.0,"resourceType":"GMImageLayer","resourceVersion":"2.0","visible":true,},
  ],
  "name":"%(name)s",
  "nineSlice":null,
  "origin":9,
  "parent":{
    "name":"%(tx)s",
    "path":"%(ty)s",
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
    "length":%(n)d.0,
    "lockOrigin":false,
    "moments":{
      "$KeyframeStore<MomentsEventKeyframe>":"",
      "Keyframes":[],
      "resourceType":"KeyframeStore<MomentsEventKeyframe>",
      "resourceVersion":"2.0",
    },
    "name":"%(name)s",
    "playback":1,
    "playbackSpeed":16.0,
    "playbackSpeedType":0,
    "resourceType":"GMSequence",
    "resourceVersion":"2.0",
    "showBackdrop":true,
    "showBackdropImage":false,
    "timeUnits":1,
    "tracks":[
      {"$GMSpriteFramesTrack":"","builtinName":0,"events":[],"inheritsTrackColour":true,"interpolation":1,"isCreationTrack":false,"keyframes":{"$KeyframeStore<SpriteFrameKeyframe>":"","Keyframes":[
%(keys)s,
          ],"resourceType":"KeyframeStore<SpriteFrameKeyframe>","resourceVersion":"2.0",},"modifiers":[],"name":"frames","resourceType":"GMSpriteFramesTrack","resourceVersion":"2.0","spriteId":null,"trackColour":0,"tracks":[],"traits":0,},
    ],
    "visibleRange":null,
    "volume":1.0,
    "xorigin":%(ox)d,
    "yorigin":%(oy)d,
  },
  "swatchColours":null,
  "swfPrecision":0.5,
  "textureGroupId":{
    "name":"%(tg)s",
    "path":"texturegroups/%(tg)s",
  },
  "type":0,
  "VTile":false,
  "width":%(w)d,
}""" % dict(name=name, h=h, w=w, ox=ox, oy=oy, bl=bl, bt=bt, br=br, bb=bb,
            lg=LAYER_GUID, tg=TEXTURE_GROUP, tx=tx, ty=ty,
            fr=fr_lines, keys=key_lines, n=len(frames))


def build_sprite(name, src, w, h, ox, oy, bl, bt, br, bb):
    dst = os.path.join(ROOT, "sprites", name)
    if os.path.isdir(dst):
        shutil.rmtree(dst)
    os.makedirs(dst)
    frames = [str(uuid.uuid4()) for _ in FRAME_NUMS]
    for num, g in zip(FRAME_NUMS, frames):
        s = os.path.join(SRC, src, "%d.png" % num)
        shutil.copyfile(s, os.path.join(dst, g + ".png"))
        layer_dir = os.path.join(dst, "layers", g)
        os.makedirs(layer_dir)
        shutil.copyfile(s, os.path.join(layer_dir, LAYER_GUID + ".png"))
    text = build_yy(name, w, h, ox, oy, bl, bt, br, bb, frames)
    with open(os.path.join(dst, name + ".yy"), "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    return name, frames[0]


def register_yyp(entries):
    p = os.path.join(ROOT, "FVM_Reborn_makk.yyp")
    t = open(p, encoding="utf-8").read()
    block = "".join(
        '    {"id":{"name":"%s","path":"sprites/%s/%s.yy",},},\n' % (n, n, n)
        for n in entries if ('"name":"%s"' % n) not in t)
    if not block:
        print("yyp 已注册，跳过")
        return
    anchor = '    {"id":{"name":"spr_houyi_god_fire_1",'
    i = t.index(anchor)
    t = t[:i] + block + t[i:]
    open(p, "w", encoding="utf-8", newline="\n").write(t)
    print("yyp 已注册:", entries)


def register_folder(pairs):
    p = os.path.join(ROOT, "folders", "精灵", "mod", "Cards", "houyi_god.yy")
    t = open(p, encoding="utf-8").read()
    add = ""
    for name, first_frame in pairs:
        if ('"path":"sprites/%s/%s.yy"' % (name, name)) in t:
            continue
        add += '    {"name":"%s","path":"sprites/%s/%s.yy",},\n' % (first_frame, name, name)
    if not add:
        print("文件夹清单已包含，跳过")
        return
    # 现有最后一条没有尾逗号，先补一个，再插入我们的条目
    i = t.rindex("  ],")
    head = t[:i].rstrip()
    if not head.endswith(","):
        head += ","
    t = head + "\n" + add.rstrip(",\n") + "\n  ]," + t[i + len("  ],"):]
    open(p, "w", encoding="utf-8", newline="\n").write(t)
    print("文件夹清单已更新:", os.path.basename(p))


if __name__ == "__main__":
    pairs = [build_sprite(*s[:10]) for s in SPECS]
    register_yyp([n for n, _ in pairs])
    register_folder(pairs)
    for n, g in pairs:
        print(n, "首帧", g)
