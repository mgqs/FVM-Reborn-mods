# -*- coding: utf-8 -*-
"""神器神装 / 宝石冷却提示 —— 精灵批量导入（2026-11-13）

按 AGENTS.md §1.4 三处注册：
  1. sprites/<name>/<name>.yy + layers/<frameGUID>/<layerGUID>.png
  2. FVM_Reborn_makk.yyp 的 resources
  3. folders/精灵/mod.yy 的 listViewItems

要点（踩过的坑，别改回去）：
  * GMSprite 的 layers 是「整套图层」，所有帧共用同一份图层 GUID；
    按帧生成 GUID 会让 GameMaker 报 File missing for GMSprite。
  * 时装本体 14 帧 128x128、origin=7（bottom_center, xo=64, yo=128）、纹理组 player；
    图标 1 帧 128x128、origin=4（middle_center, xo=yo=64）。
  * 变身立绘 origin=9（custom），位置靠 sequence 的 xorigin/yorigin 决定。

用法：
    python tools/import_shenzhuang_sprites.py            # 全量导入
    python tools/import_shenzhuang_sprites.py attire     # 只导入时装本体+图标
    python tools/import_shenzhuang_sprites.py bianshen   # 只导入变身立绘
    python tools/import_shenzhuang_sprites.py misc       # 只导入闪光/按钮
"""
import os
import re
import shutil
import sys
import uuid

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART = r"C:\Users\18203\Desktop\皮特\神器神装"
# 2026-11-13 用户补的两套男装（魔影迅疾男 / 天神之影男），此前只有变身立绘、缺 14 帧角色贴图
DL = r"C:\Users\18203\Desktop\Downloads"
BAK = os.path.join(ROOT, "output", "_tmp")

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
  "origin":%(origin)d,
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


def _backup(name):
    d = os.path.join(ROOT, "sprites", name)
    if not os.path.isdir(d):
        return
    dst = os.path.join(BAK, "bak_" + name)
    if os.path.isdir(dst):
        shutil.rmtree(dst)
    shutil.copytree(d, dst)
    print("  已备份 ->", dst)


def build(name, pngs, w, h, ox, oy, tg, origin, overwrite=False):
    d = os.path.join(ROOT, "sprites", name)
    if os.path.isdir(d):
        if not overwrite:
            print("!! 已存在，跳过:", name)
            return
        _backup(name)
        shutil.rmtree(d)
    os.makedirs(os.path.join(d, "layers"), exist_ok=True)

    frames, keys = [], []
    lid = str(uuid.uuid4())
    layers = [LAYER_TMPL % dict(l=lid)]
    for i, src in enumerate(pngs):
        fid = str(uuid.uuid4())
        shutil.copyfile(src, os.path.join(d, fid + ".png"))
        ldir = os.path.join(d, "layers", fid)
        os.makedirs(ldir, exist_ok=True)
        shutil.copyfile(src, os.path.join(ldir, lid + ".png"))
        frames.append(FRAME_TMPL % dict(f=fid))
        keys.append(KEY_TMPL % dict(f=fid, k=str(uuid.uuid4()), key=float(i), name=name))

    yy = YY_TMPL % dict(name=name, frames="\n".join(frames), layers="\n".join(layers),
                        keys="\n".join(keys), w=w, h=h, w1=w - 1, h1=h - 1,
                        ox=ox, oy=oy, tg=tg, length=float(len(pngs)), origin=origin)
    with open(os.path.join(d, name + ".yy"), "w", encoding="utf-8", newline="\n") as f:
        f.write(yy)
    print("  精灵已生成:", name, len(pngs), "帧", "%dx%d" % (w, h), "origin=%d" % origin)

    yyp = os.path.join(ROOT, "FVM_Reborn_makk.yyp")
    s = open(yyp, encoding="utf-8").read()
    entry = '    {"id":{"name":"%s","path":"sprites/%s/%s.yy",},},\n' % (name, name, name)
    if entry not in s:
        anchor = re.search(r'    \{"id":\{"name":"spr_', s)
        s = s[:anchor.start()] + entry + s[anchor.start():] if anchor else s
        open(yyp, "w", encoding="utf-8", newline="\n").write(s)
        print("  yyp 已注册")
    else:
        print("  yyp 已有")

    modf = os.path.join(ROOT, "folders", "精灵", "mod.yy")
    s = open(modf, encoding="utf-8").read()
    fentry = '    {"name":"%s","path":"sprites/%s/%s.yy",},\n' % (name, name, name)
    if fentry not in s:
        m = re.search(r'( *)"listViewItems":\[\n', s)
        if m:
            s = s[:m.end()] + fentry + s[m.end():]
            open(modf, "w", encoding="utf-8", newline="\n").write(s)
            print("  folder 已注册")
        else:
            print("!! mod.yy 没有 listViewItems")
    else:
        print("  folder 已有")


def numbered(folder):
    fs = [p for p in os.listdir(folder) if re.fullmatch(r"\d+\.png", p)]
    fs.sort(key=lambda p: int(p[:-4]))
    return [os.path.join(folder, p) for p in fs]


def existing_frames(name):
    d = os.path.join(ROOT, "sprites", name, "layers")
    out = []
    for fd in os.listdir(d):
        p = os.path.join(d, fd)
        if not os.path.isdir(p):
            continue
        pngs = [f for f in os.listdir(p) if f.endswith(".png")]
        if pngs:
            out.append((fd, os.path.join(p, pngs[0])))
    return out


def copy_frames(name):
    """按 sequence 顺序（frames 列表里的 GUID 顺序即帧序）返回 copy 用的 png 列表。"""
    import json
    yyp = os.path.join(ROOT, "sprites", name, name + ".yy")
    t = open(yyp, encoding="utf-8").read()
    t = re.sub(r",(\s*[}\]])", r"\1", t)
    info = json.loads(t)
    out = []
    for fr in info["frames"]:
        fid = fr["name"]
        ld = os.path.join(ROOT, "sprites", name, "layers", fid)
        png = [f for f in os.listdir(ld) if f.endswith(".png")][0]
        out.append(os.path.join(ld, png))
    return out


# ─────────────────────────── 清单 ───────────────────────────
# 时装本体：14 帧 128x128，origin=7 bottom_center
ATTIRES = [
    ("spr_player_attire_moyingshengyi_nan", os.path.join(ART, "魔影圣衣男"), False),
    ("spr_player_attire_xingzhihuan_nan", os.path.join(ART, "星之焕男"), False),
    ("spr_player_attire_xingzhiyao_nan", os.path.join(ART, "星之耀男"), False),
    ("spr_player_attire_xingzhiyao_nv", os.path.join(ART, "星之耀女"), False),
    ("spr_player_attire_tianshenzhiyingbanbensan", os.path.join(ART, "天神之影女"), True),
    ("spr_player_attire_xingzhihuanbianshen3", os.path.join(ART, "星之焕女"), True),
    # 2026-11-13 下午补：原先只能用同族旧图占位，现用真实美术重建（覆盖旧占位）
    ("spr_player_attire_moyingxunji_nan", os.path.join(DL, "魔影迅疾男"), True),
    ("spr_player_attire_tianshenzhiying_nan", os.path.join(DL, "天神之影男"), True),
]

# 找不到美术资源的，先从现有同族套装复制一份独立精灵（后续换图不影响原套装）
# 2026-11-13：两条（魔影迅疾男 / 天神之影男）已拿到真实美术，移入上面的 ATTIRES，此处暂无条目
ATTIRES_COPY = []

# 变身立绘：(名字, 素材目录, 画布w, 画布h, xorigin, yorigin)
BIANSHEN = [
    ("spr_bianshen_moyingshengyi_nan", "魔影圣衣男变身", 1332, 325),
    ("spr_bianshen_moyingxunji_nan", "魔影迅疾男变身", 1332, 269),
    ("spr_bianshen_moyingxunji_nv", "魔影迅疾女变身", 1332, 416),
    ("spr_bianshen_tianshenzhiying_nan", "天神之影男变身", 1332, 239),
    ("spr_bianshen_xingzhiyao_nan", "星之耀男变身", 1811, 2044),
    ("spr_bianshen_xingzhihuan_nan", "星之焕男变身", 1811, 2044),
]


def do_attire():
    print("[时装本体 14 帧]")
    for name, src, ow in ATTIRES:
        pngs = numbered(src)
        assert len(pngs) == 14, (name, len(pngs))
        build(name, pngs, 128, 128, 64, 128, "player", 7, overwrite=ow)
        # 图标
        icon = os.path.join(ROOT, "sprites", name + "_icon")
        build(name + "_icon", [os.path.join(src, "head.png")], 128, 128, 64, 64,
              "player", 4, overwrite=os.path.isdir(icon))

    print("[时装本体 14 帧 · 复用现有同族美术]")
    for name, srcref in ATTIRES_COPY:
        pngs = copy_frames(srcref)
        assert len(pngs) == 14, (name, len(pngs))
        build(name, pngs, 128, 128, 64, 128, "player", 7)
        ipngs = copy_frames(srcref + "_icon")
        build(name + "_icon", ipngs, 128, 128, 64, 64, "player", 4)


def do_bianshen():
    print("[变身立绘]")
    for name, fold, w, h in BIANSHEN:
        pngs = numbered(os.path.join(ART, fold))
        build(name, pngs, w, h, -(1920 - w) // 2, -(1080 - h) // 2, "Default", 9)


def do_misc():
    print("[宝石冷却闪光] 12 帧 270x250，origin=4 居中")
    pngs = numbered(os.path.join(ART, "宝石冷却提示"))
    build("spr_gem_cooldown_flash", pngs, 270, 250, 135, 125, "Default", 4)


if __name__ == "__main__":
    what = sys.argv[1] if len(sys.argv) > 1 else "all"
    if what in ("all", "attire"):
        do_attire()
    if what in ("all", "bianshen"):
        do_bianshen()
    if what in ("all", "misc"):
        do_misc()
