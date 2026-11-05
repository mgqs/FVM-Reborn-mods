# -*- coding: utf-8 -*-
"""按给定 PNG 序列生成一个多帧精灵（.yy + layers + 资源注册）。

用法：在本文件底部 CONFIG 里配置，再 `python tools/make_multi_frame_sprite.py`
"""
import os
import re
import shutil
import uuid

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

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


def build(name, pngs, w, h, ox, oy, texture_group, force_parent_list=True):
    d = os.path.join(ROOT, 'sprites', name)
    if os.path.isdir(d):
        shutil.rmtree(d)
    os.makedirs(os.path.join(d, 'layers'), exist_ok=True)

    frames, keys = [], []
    # 注意：GMSprite 的 layers 是「整套图层」，所有帧共用同一份图层 GUID．
    # 每帧目录下放的是 layers/<frameGUID>/<layerGUID>.png，
    # 所以 lid 必须只生成一次；按帧生成会让 GameMaker 报「File missing for GMSprite」．
    lid = str(uuid.uuid4())
    layers = [LAYER_TMPL % dict(l=lid)]
    for i, src in enumerate(pngs):
        fid = str(uuid.uuid4())
        shutil.copyfile(src, os.path.join(d, fid + '.png'))
        ldir = os.path.join(d, 'layers', fid)
        os.makedirs(ldir, exist_ok=True)
        shutil.copyfile(src, os.path.join(ldir, lid + '.png'))
        frames.append(FRAME_TMPL % dict(f=fid))
        keys.append(KEY_TMPL % dict(f=fid, k=str(uuid.uuid4()), key=float(i), name=name))

    yy = YY_TMPL % dict(name=name, frames='\n'.join(frames), layers='\n'.join(layers),
                        keys='\n'.join(keys), w=w, h=h, w1=w - 1, h1=h - 1,
                        ox=ox, oy=oy, tg=texture_group, length=float(len(pngs)))
    with open(os.path.join(d, name + '.yy'), 'w', encoding='utf-8', newline='\n') as f:
        f.write(yy)
    print('精灵已生成:', d, len(pngs), '帧')

    # yyp
    yyp = os.path.join(ROOT, 'FVM_Reborn_makk.yyp')
    s = open(yyp, encoding='utf-8').read()
    entry = '    {"id":{"name":"%s","path":"sprites/%s/%s.yy",},},\n' % (name, name, name)
    if entry not in s:
        anchor = re.search(r'    \{"id":\{"name":"spr_', s)
        s = s[:anchor.start()] + entry + s[anchor.start():] if anchor else s
        open(yyp, 'w', encoding='utf-8', newline='\n').write(s)
        print('yyp 已注册')
    else:
        print('yyp 已有')

    # folders/精灵/mod.yy
    modf = os.path.join(ROOT, 'folders', '精灵', 'mod.yy')
    s = open(modf, encoding='utf-8').read()
    fentry = '    {"name":"%s","path":"sprites/%s/%s.yy",},\n' % (name, name, name)
    if fentry not in s:
        m = re.search(r'( *)"listViewItems":\[\n', s)
        if m:
            s = s[:m.end()] + fentry + s[m.end():]
            open(modf, 'w', encoding='utf-8', newline='\n').write(s)
            print('folder 已注册')
        else:
            print('!! mod.yy 没有 listViewItems')
    else:
        print('folder 已有')


if __name__ == '__main__':
    SRC = r"C:\Users\18203\Desktop\跨服\BOSS\精灵\变异皮特\sprites\DefineSprite_50_com.aurora.ui.maogoutd.resource.Intruder.kfcarbon.DragonMachineBossLowerBodyMouthIntruderMovie"
    pngs = [os.path.join(SRC, '%d.png' % i) for i in range(1, 7)]
    build('spr_kuafu_pete_claw_effect', pngs, 84, 69, 42, 68, 'enemy_volcanic')
