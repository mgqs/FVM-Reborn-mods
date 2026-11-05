"""生成海克斯「食指的指令」标记图标精灵 spr_hex_mark

用法：python tools/make_hex_mark_sprite.py
源图：用户提供的蓝色五瓣花（128x123），复制到 sprites/spr_hex_mark/
同时写入 .yy、layers 目录，并把资源注册进 FVM_Reborn_makk.yyp 与 folders/精灵/mod.yy
"""
import os
import re
import shutil
import uuid

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC_PNG = r'C:\Users\18203\.workbuddy\clipboard-images\clipboard-2026-11-05T01-53-03-122Z-54c2e48a.png'
NAME = 'spr_hex_mark'
W, H = 128, 123


def main():
    d = os.path.join(ROOT, 'sprites', NAME)
    if os.path.isdir(d):
        shutil.rmtree(d)
    os.makedirs(os.path.join(d, 'layers'), exist_ok=True)

    frame_id = str(uuid.uuid4())
    layer_id = str(uuid.uuid4())
    key_id = str(uuid.uuid4())

    shutil.copyfile(SRC_PNG, os.path.join(d, frame_id + '.png'))
    layer_dir = os.path.join(d, 'layers', frame_id)
    os.makedirs(layer_dir, exist_ok=True)
    shutil.copyfile(SRC_PNG, os.path.join(layer_dir, layer_id + '.png'))

    yy = '''{
  "$GMSprite":"v2",
  "%%Name":"%(name)s",
  "bboxMode":0,
  "bbox_bottom":%(h)d,
  "bbox_left":0,
  "bbox_right":%(w1)d,
  "bbox_top":0,
  "collisionKind":0,
  "collisionTolerance":0,
  "DynamicTexturePage":false,
  "edgeFiltering":false,
  "For3D":false,
  "frames":[
    {"$GMSpriteFrame":"v1","%%Name":"%(frame)s","name":"%(frame)s","resourceType":"GMSpriteFrame","resourceVersion":"2.0",},
  ],
  "gridX":0,
  "gridY":0,
  "height":%(h)d,
  "HTile":false,
  "layers":[
    {"$GMImageLayer":"","%%Name":"%(layer)s","blendMode":0,"displayName":"default","isLocked":false,"name":"%(layer)s","opacity":100.0,"resourceType":"GMImageLayer","resourceVersion":"2.0","visible":true,},
  ],
  "name":"%(name)s",
  "nineSlice":null,
  "origin":4,
  "parent":{
    "name":"mod",
    "path":"folders/精灵/mod.yy",
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
            {"$Keyframe<SpriteFrameKeyframe>":"","Channels":{
                "0":{"$SpriteFrameKeyframe":"","Id":{"name":"%(frame)s","path":"sprites/%(name)s/%(name)s.yy",},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",},
              },"Disabled":false,"id":"%(key)s","IsCreationKey":false,"Key":0.0,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,},
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
    "name":"UI",
    "path":"texturegroups/UI",
  },
  "type":0,
  "VTile":false,
  "width":%(w)d,
}
''' % dict(name=NAME, frame=frame_id, layer=layer_id, key=key_id,
           w=W, h=H, w1=W - 1, ox=W // 2, oy=H // 2)
    with open(os.path.join(d, NAME + '.yy'), 'w', encoding='utf-8', newline='\n') as f:
        f.write(yy)

    # 注册进 yyp
    yyp = os.path.join(ROOT, 'FVM_Reborn_makk.yyp')
    s = open(yyp, encoding='utf-8').read()
    entry = '    {"id":{"name":"%s","path":"sprites/%s/%s.yy",},},\n' % (NAME, NAME, NAME)
    if entry not in s:
        anchor = re.search(r'    \{"id":\{"name":"spr_', s)
        if anchor:
            s = s[:anchor.start()] + entry + s[anchor.start():]
        else:
            m = re.search(r'  "resources":\[\n', s)
            s = s[:m.end()] + entry + s[m.end():]
        open(yyp, 'w', encoding='utf-8', newline='\n').write(s)
        print('yyp 已注册')
    else:
        print('yyp 已有')

    # 注册进 folders/精灵/mod.yy
    modf = os.path.join(ROOT, 'folders', '精灵', 'mod.yy')
    s = open(modf, encoding='utf-8').read()
    fentry = '    {"name":"%s","path":"sprites/%s/%s.yy",},\n' % (NAME, NAME, NAME)
    if fentry not in s:
        m = re.search(r'( *)"listViewItems":\[\n', s)
        if m:
            s = s[:m.end()] + fentry + s[m.end():]
            open(modf, 'w', encoding='utf-8', newline='\n').write(s)
            print('folder 已注册')
        else:
            print('!! mod.yy 没有 listItems')
    else:
        print('folder 已有')

    print('完成:', d)


if __name__ == '__main__':
    main()
