# -*- coding: utf-8 -*-
"""导入桌面「跨服」下三张新地图的关卡底图精灵（单帧，参照 spr_zhuorediyu 先例）。

映射（关卡 index 0..7 对应星级门槛 8+index，见 cross_server_star_gate）：
  冰封遗迹   -> spr_bingfengyiji_0..7      (冰雪8星..15星, 1114x600)
  巫毒研究所 -> spr_wuduyanjiusuo_0..7     (巫毒8星..15星, 1108x597)
  水火之间   -> spr_shuihuozhijian_0/_1    (8~11星 -> 关卡 0..3, 12~15星 -> 关卡 4..7, 1108x597)

注册三处：sprites/<名>/<名>.yy；FVM_Reborn_makk.yyp resources + Folders(章节子文件夹)。
纹理组 maps（同 spr_mengyantiankong_*），origin 0（战斗底图按 (0,0) 绘制）。
可重复执行：已存在的精灵按现有 GUID 跳过。
"""
import os
import re
import shutil
import struct
import uuid

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = r"C:\Users\18203\Desktop\跨服"
CS_FOLDER = "folders/精灵/mod/Cross Server"

MAPS = [
    ("bingfengyiji",   "冰封遗迹",  [("spr_bingfengyiji_%d" % i, os.path.join(SRC, "冰封遗迹",   "冰雪%d星.png" % (i + 8)))  for i in range(8)]),
    ("wuduyanjiusuo",  "巫毒研究所", [("spr_wuduyanjiusuo_%d" % i, os.path.join(SRC, "巫毒研究所", "巫毒%d星.png" % (i + 8))) for i in range(8)]),
    ("shuihuozhijian", "水火之间",  [("spr_shuihuozhijian_0", os.path.join(SRC, "水火之间", "水火8~11星.png")),
                                   ("spr_shuihuozhijian_1", os.path.join(SRC, "水火之间", "水火12~15星.png"))]),
]

YY_TMPL = '''{
  "$GMSprite":"v2",
  "%%Name":"%(name)s",
  "bboxMode":0,
  "bbox_bottom":%(h1)d,
  "bbox_left":0,
  "bbox_right":%(w1)d,
  "bbox_top":0,
  "collisionKind":1,
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
  "origin":0,
  "parent":{
    "name":"%(folder)s",
    "path":"%(CS_FOLDER)s/%(folder)s.yy",
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
    "length":1.0,
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
    "xorigin":0,
    "yorigin":0,
  },
  "swatchColours":null,
  "swfPrecision":2.525,
  "textureGroupId":{
    "name":"maps",
    "path":"texturegroups/maps",
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
            '              },"Disabled":false,"id":"%(k)s","IsCreationKey":false,"Key":0.0,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,},')

FOLDER_TMPL = '''{
  "$GMFolder":"",
  "%%Name":"%(folder)s",
  "folderPath":"%(CS_FOLDER)s/%(folder)s.yy",
  "isDefaultView":false,
  "listViewItems":[],
  "name":"%(folder)s",
  "resourceType":"GMFolder",
  "resourceVersion":"2.0",
  "viewLocked":false,
  "visible":true,
  "folders":[
  ],
  "listItems":[
  ],
}
'''


def png_size(p):
    with open(p, 'rb') as f:
        d = f.read(33)
    if d[:8] != b'\x89PNG\r\n\x1a\n':
        raise RuntimeError('not png: ' + p)
    return struct.unpack('>II', d[16:24])


def build(name, png):
    w, h = png_size(png)
    d = os.path.join(ROOT, 'sprites', name)
    yy_path = os.path.join(d, name + '.yy')
    if os.path.isfile(yy_path):
        print('已有, 跳过:', name)
        return
    os.makedirs(os.path.join(d, 'layers'), exist_ok=True)
    fid, lid, kid = str(uuid.uuid4()), str(uuid.uuid4()), str(uuid.uuid4())
    shutil.copyfile(png, os.path.join(d, fid + '.png'))
    ldir = os.path.join(d, 'layers', fid)
    os.makedirs(ldir, exist_ok=True)
    shutil.copyfile(png, os.path.join(ldir, lid + '.png'))
    folder = re.match(r'spr_([a-z_]+?)_?\d*$', name).group(1)
    yy = YY_TMPL % dict(name=name, frames=FRAME_TMPL % dict(f=fid),
                        layers=LAYER_TMPL % dict(l=lid), keys=KEY_TMPL % dict(f=fid, k=kid, name=name),
                        w=w, h=h, w1=w - 1, h1=h - 1, folder=folder, CS_FOLDER=CS_FOLDER)
    with open(yy_path, 'w', encoding='utf-8', newline='\n') as f:
        f.write(yy)
    print('精灵已生成: %s (%dx%d)' % (name, w, h))


def main():
    # 1) 精灵
    for folder, _cn, items in MAPS:
        for name, png in items:
            if not os.path.isfile(png):
                raise RuntimeError('缺源图: ' + png)
            build(name, png)

    # 2) 章节子文件夹 .yy + yyp Folders 条目
    for folder, _cn, _items in MAPS:
        fpath = os.path.join(ROOT, CS_FOLDER.replace('/', os.sep), folder + '.yy')
        if not os.path.isfile(fpath):
            with open(fpath, 'w', encoding='utf-8', newline='\n') as f:
                f.write(FOLDER_TMPL % dict(folder=folder, CS_FOLDER=CS_FOLDER))
            print('文件夹已生成:', folder)

    yyp = os.path.join(ROOT, 'FVM_Reborn_makk.yyp')
    s = open(yyp, encoding='utf-8').read()
    changed = False
    # resources：插在第一个 spr_ 条目前（按 path 去重、只增不删）
    for folder, _cn, items in MAPS:
        for name, _png in items:
            entry = '    {"id":{"name":"%s","path":"sprites/%s/%s.yy",},},\n' % (name, name, name)
            if entry not in s:
                anchor = re.search(r'    \{"id":\{"name":"spr_', s)
                s = s[:anchor.start()] + entry + s[anchor.start():]
                changed = True
                print('yyp resources 已注册:', name)
    # Folders：插在 Cross Server 章节条目之后
    for folder, _cn, _items in MAPS:
        fentry = ('    {"$GMFolder":"","%%Name":"%(f)s","folderPath":"%(cs)s/%(f)s.yy",'
                  '"name":"%(f)s","resourceType":"GMFolder","resourceVersion":"2.0",},\n'
                  % dict(f=folder, cs=CS_FOLDER))
        if fentry not in s:
            anchor = re.search(r'    \{"\$GMFolder":"","%Name":"Cross Server"[^\n]*\n', s)
            s = s[:anchor.end()] + fentry + s[anchor.end():]
            changed = True
            print('yyp Folders 已注册:', folder)
    if changed:
        with open(yyp, 'w', encoding='utf-8', newline='\n') as f:
            f.write(s)
    print('完成')


if __name__ == '__main__':
    main()
