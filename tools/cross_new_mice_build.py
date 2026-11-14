# -*- coding: utf-8 -*-
"""跨服新章节小怪构建器：精灵 + 对象 + 注册脚本 + 资源登记。

用法：
    python tools/cross_new_mice_build.py sprites
    python tools/cross_new_mice_build.py objects
    python tools/cross_new_mice_build.py register
    python tools/cross_new_mice_build.py            # 全部

与 zhuore_build.py 的差异：
  - 素材是平坦目录（<帧号+1>.png），不依赖 DefineSprite 子目录
  - origin 按「每个精灵自己的参考帧」迁移（潜艇 land/water/enter 画布高度不同）
  - 章节前缀来自 spec，不再全局一个 PREFIX
"""
import io
import json
import os
import re
import shutil
import sys
import uuid

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import cross_new_mice_spec as S      # noqa: E402

SRC_ROOT = r"C:/Users/18203/Desktop/跨服"
SPR_DIR = os.path.join(ROOT, "sprites")
OBJ_DIR = os.path.join(ROOT, "objects")
SCR_DIR = os.path.join(ROOT, "scripts")
YYP = os.path.join(ROOT, "FVM_Reborn_makk.yyp")
TEX_GROUP = "enemy_volcanic"          # 跨服敌人统一，与 zhuore 一致

SPR_ROOT_FOLDER = "folders/精灵/Enemy/kuafu"
OBJ_ROOT_FOLDER = "folders/物体/Enemy/kuafu"


# ---------------------------------------------------------------- 基础工具
def load_yy(p):
    s = io.open(p, encoding="utf-8-sig").read()
    return json.loads(re.sub(r",(\s*[}\]])", r"\1", s))


def sprite_meta(name):
    d = load_yy(os.path.join(SPR_DIR, name, name + ".yy"))
    return dict(frames=[f["name"] + ".png" for f in d["frames"]],
                w=d["width"], h=d["height"],
                ox=d["sequence"]["xorigin"], oy=d["sequence"]["yorigin"])


def frame_image(sprite, idx):
    m = sprite_meta(sprite)
    return Image.open(os.path.join(SPR_DIR, sprite, m["frames"][idx])).convert("RGBA")


def resample(seq, n):
    if n <= 0:
        return []
    if len(seq) == n:
        return list(seq)
    if len(seq) == 1:
        return [seq[0]] * n
    if n == 1:
        return [seq[0]]
    return [seq[int(round(i * (len(seq) - 1) / (n - 1)))] for i in range(n)]


def src_frames(case):
    base = os.path.join(SRC_ROOT, case["src"].replace("/", os.sep))
    files = [f for f in os.listdir(base) if f.lower().endswith(".png")]
    files.sort(key=lambda f: int(os.path.splitext(f)[0]))
    if len(files) != case["total_src"]:
        raise RuntimeError("%s: 素材帧数 %d != 规格 %d" % (case["cn"], len(files), case["total_src"]))
    return [os.path.join(base, f) for f in files]


def sprite_name(case, suffix):
    # main / water 用主名（同 zhuore 的 penguin：spr_kf_zr_penguin / _land / _enter）
    if suffix in ("main", "water"):
        return "spr_" + case["prefix"] + case["key"]
    return "spr_%s%s_%s" % (case["prefix"], case["key"], suffix)


def compute_origin(ref, srcs):
    """参考帧：(素材帧号, 原版精灵, 原版帧号) → 新 origin。"""
    src_idx, old_spr, old_idx = ref
    om = sprite_meta(old_spr)
    obb = frame_image(old_spr, old_idx).split()[3].getbbox()
    dx = om["ox"] - (obb[0] + obb[2]) / 2.0
    dy = om["oy"] - obb[3]
    im = Image.open(srcs[src_idx]).convert("RGBA")
    sbb = im.split()[3].getbbox()
    return int(round((sbb[0] + sbb[2]) / 2.0 + dx)), int(round(sbb[3] + dy))


# ---------------------------------------------------------------- 精灵
YY_TMPL = """{
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
    "name":"%(pname)s",
    "path":"%(ppath)s",
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
"""

FRAME_TMPL = '    {"$GMSpriteFrame":"v1","%%Name":"%(f)s","name":"%(f)s","resourceType":"GMSpriteFrame","resourceVersion":"2.0",},'
LAYER_TMPL = '    {"$GMImageLayer":"","%%Name":"%(l)s","blendMode":0,"displayName":"default","isLocked":false,"name":"%(l)s","opacity":100.0,"resourceType":"GMImageLayer","resourceVersion":"2.0","visible":true,},'
KEY_TMPL = ('            {"$Keyframe<SpriteFrameKeyframe>":"","Channels":{\n'
            '                "0":{"$SpriteFrameKeyframe":"","Id":{"name":"%(f)s","path":"sprites/%(name)s/%(name)s.yy",},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",},\n'
            '              },"Disabled":false,"id":"%(k)s","IsCreationKey":false,"Key":%(key).1f,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,},')


def make_sprite(name, images, ox, oy, folder_key, folder):
    w = max(i.width for i in images)
    h = max(i.height for i in images)
    d = os.path.join(SPR_DIR, name)
    if os.path.isdir(d):
        shutil.rmtree(d)
    os.makedirs(os.path.join(d, "layers"), exist_ok=True)

    lid = str(uuid.uuid4())
    frames, keys = [], []
    for i, im in enumerate(images):
        if im.size != (w, h):
            canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
            canvas.paste(im, ((w - im.width) // 2, (h - im.height) // 2))
            im = canvas
        fid = str(uuid.uuid4())
        im.save(os.path.join(d, fid + ".png"))
        ldir = os.path.join(d, "layers", fid)
        os.makedirs(ldir, exist_ok=True)
        im.save(os.path.join(ldir, lid + ".png"))
        frames.append(FRAME_TMPL % dict(f=fid))
        keys.append(KEY_TMPL % dict(f=fid, k=str(uuid.uuid4()), key=float(i), name=name))

    yy = YY_TMPL % dict(
        name=name, frames="\n".join(frames), layers=LAYER_TMPL % dict(l=lid),
        keys="\n".join(keys), w=w, h=h, w1=w - 1, h1=h - 1,
        ox=max(0, min(w - 1, ox)), oy=max(0, min(h - 1, oy)),
        tg=TEX_GROUP, length=float(len(images)),
        pname=folder_key, ppath="%s/%s.yy" % (folder, folder_key),
    )
    io.open(os.path.join(d, name + ".yy"), "w", encoding="utf-8", newline="\n").write(yy)
    return w, h


def build_sprites(only=None):
    for case in S.CASES:
        if only and case["key"] != only:
            continue
        srcs = src_frames(case)
        folder = "%s/%s/xiaoguai" % (SPR_ROOT_FOLDER, S.INIT_SCRIPTS[case["prefix"][3:5]]["folder_cn"])
        for suffix, old_spr, total_frames, segs, ref in case["sprites"]:
            picks = []
            for label, st, en, n in segs:
                picks += resample(srcs[st:en], n)
            if len(picks) != total_frames:
                raise RuntimeError("%s/%s: 分段加总 %d != 目标 %d"
                                   % (case["cn"], suffix, len(picks), total_frames))
            images = [Image.open(p).convert("RGBA") for p in picks]
            # 空帧守卫：原版该帧有内容、新帧全透明 → 取错帧
            oo = [frame_image(old_spr, i).split()[3].getbbox() is not None
                  for i in range(total_frames)]
            lost = [i for i in range(total_frames)
                    if oo[i] and images[i].split()[3].getbbox() is None]
            if lost:
                raise RuntimeError("%s/%s: 第 %s 帧空白但原版有内容" % (case["cn"], suffix, lost))
            ox, oy = compute_origin(ref, srcs)
            name = sprite_name(case, suffix)
            w, h = make_sprite(name, images, ox, oy, case["key"], folder)
            print("[sprite] %-32s %3d帧 %dx%d origin(%d,%d)" % (name, len(images), w, h, ox, oy))


# ---------------------------------------------------------------- 对象
MOVE_SPEED_RE = re.compile(r"^(?P<pre>[ \t]*move_speed[ \t]*=[ \t]*)(?P<val>-?\d+(?:\.\d+)?)", re.M)


def patch_move_speed(txt, old_v, new_v, tag=""):
    for m in MOVE_SPEED_RE.finditer(txt):
        if abs(float(m.group("val")) - old_v) < 1e-9:
            return txt[:m.start("val")] + ("%g" % new_v) + txt[m.end("val"):]
    raise RuntimeError("%s: 找不到 move_speed = %g 可改" % (tag, old_v))


def build_objects(only=None):
    for case in S.CASES:
        if only and case["key"] != only:
            continue
        old_obj = case["old"]
        new_obj = "obj_" + case["prefix"] + case["key"]
        src = os.path.join(OBJ_DIR, old_obj)
        dst = os.path.join(OBJ_DIR, new_obj)
        if not os.path.isdir(src):
            raise RuntimeError("原版对象不存在: " + old_obj)
        if os.path.isdir(dst):
            shutil.rmtree(dst)
        os.makedirs(dst)

        smap = {}
        for suffix, old_spr, _, _, _ in case["sprites"]:
            smap[old_spr] = sprite_name(case, suffix)
        folder_cn = S.INIT_SCRIPTS[case["prefix"][3:5]]["folder_cn"]

        for fn in os.listdir(src):
            sp = os.path.join(src, fn)
            if fn.endswith(".yy"):
                txt = io.open(sp, encoding="utf-8-sig").read()
                txt = txt.replace('"name":"%s"' % old_obj, '"name":"%s"' % new_obj)
                txt = txt.replace('"%%Name":"%s"' % old_obj, '"%%Name":"%s"' % new_obj)
                m = re.search(r'"spriteId":\{\s*"name":"([^"]*)",\s*"path":"[^"]*",\s*\}', txt)
                if m:
                    # 原版龙舟/旗舰的 .yy 误指向 spr_rowboat_mouse（运行时被 Step 覆盖才没出事）；
                    # 新对象一律指向自己的 main 精灵
                    new_sp = smap.get(m.group(1), sprite_name(case, case["sprites"][0][0]))
                    txt = txt[:m.start()] + ('"spriteId":{\n    "name":"%s",\n'
                                             '    "path":"sprites/%s/%s.yy",\n  }'
                                             % (new_sp, new_sp, new_sp)) + txt[m.end():]
                txt = re.sub(r'"parent":\{\s*"name":"[^"]*",\s*"path":"folders/[^"]*",\s*\},',
                             '"parent":{\n    "name":"%s",\n    "path":"%s/%s/xiaoguai/%s.yy",\n  },'
                             % (case["key"], OBJ_ROOT_FOLDER, folder_cn, case["key"]), txt, count=1)
                io.open(os.path.join(dst, new_obj + ".yy"), "w", encoding="utf-8", newline="\n").write(txt)
            elif fn.endswith(".gml"):
                txt = io.open(sp, encoding="utf-8-sig").read()
                for o in sorted(smap, key=len, reverse=True):
                    txt = re.sub(r"\b%s\b" % re.escape(o), smap[o], txt)
                txt = re.sub(r"^hp\s*=\s*[0-9]+", "hp = %d" % case["hp"], txt, flags=re.M)
                txt = re.sub(r"^maxhp\s*=\s*[0-9]+", "maxhp = %d" % case["hp"], txt, flags=re.M)
                # 防爆：注册表只影响情报岛显示，真正生效的是对象里的 immune_to_ash
                if fn == "Create_0.gml":
                    if re.search(r"^immune_to_ash\s*=\s*\w+", txt, re.M):
                        txt = re.sub(r"^immune_to_ash\s*=\s*\w+", "immune_to_ash = true",
                                     txt, flags=re.M)
                    else:
                        txt = re.sub(r"^(event_inherited\(\);)",
                                     r"\1\nimmune_to_ash = true", txt, count=1, flags=re.M)
                    # 本体没写 mouse_id 的对象（潜艇）也要补，图鉴/情报岛按它索引
                    if not re.search(r'^mouse_id\s*=', txt, re.M):
                        txt = re.sub(r"^(event_inherited\(\);)",
                                     r'\1\nmouse_id = "%s%s"' % (case["prefix"], case["key"]),
                                     txt, count=1, flags=re.M)
                for pfn, old_v, new_v in case.get("ms_patch", ()):
                    if pfn == fn:
                        txt = patch_move_speed(txt, old_v, new_v, case["cn"])
                txt = re.sub(r'mouse_id\s*=\s*"[^"]*"',
                             'mouse_id = "%s%s"' % (case["prefix"], case["key"]), txt)
                io.open(os.path.join(dst, fn), "w", encoding="utf-8", newline="\n").write(txt)
            else:
                shutil.copy2(sp, os.path.join(dst, fn))
        print("[object] %-28s <- %s  hp=%d speed=%g" % (new_obj, old_obj, case["hp"], case["speed"]))


# ---------------------------------------------------------------- 注册脚本
INIT_TMPL = """/// %(title)s（跨服章节）小怪：僵尸鼠
/// 行为代码照抄本体同名鼠（%(_objs)s），只改精灵、hp、move_speed、防爆。
/// 数值口径：speed = 表格速度 × 0.03；两段速度（前进 / 后退）写在对象 Step 的 move_speed 赋值里。
function %(func)s()
{
%(body)s
}
"""

REG_TMPL = """    // %(cn)s：%(desc_short)s
    register_enemy("%(id)s", {
        name: "%(name)s",
        _obj: %(obj)s,
        hp: %(hp)d,
        shield: 0,
        description: "%(desc)s",
        speed: %(speed)g,
        atk: %(atk)d,
        cycle: %(cycle)d,
        range: %(range)d,
        ash_proof: true,
        spr: %(spr)s,
        feature: "%(feature)s",
    });
"""


def build_init_scripts():
    for tag, cfg in S.INIT_SCRIPTS.items():
        body = []
        objs = []
        for key in cfg["keys"]:
            case = next(c for c in S.CASES if c["key"] == key)
            reg = S.REG[key]
            eid = case["prefix"] + case["key"]
            objs.append(case["old"])
            main_suffix = case["sprites"][0][0]
            body.append(REG_TMPL % dict(
                cn=case["cn"], desc_short=reg["desc"].split("，")[-1],
                id=eid, name=reg["name"], obj="obj_" + eid,
                hp=case["hp"], speed=case["speed"], desc=reg["desc"],
                atk=reg["atk"], cycle=reg["cycle"], range=reg["range"],
                spr=sprite_name(case, main_suffix), feature=reg["feature"]))
        title = {"sh": "水火之间", "wd": "巫毒研究所"}[tag]
        txt = INIT_TMPL % dict(title=title, func=cfg["func"], _objs=" / ".join(objs),
                              body="\n".join(body).rstrip("\n"))
        d = os.path.join(SCR_DIR, cfg["file"])
        os.makedirs(d, exist_ok=True)
        io.open(os.path.join(d, cfg["file"] + ".gml"), "w", encoding="utf-8", newline="\n").write(txt)
        yy = ('{\n  "$GMScript":"v1",\n  "%%Name":"%s",\n  "isCompatibility":false,\n'
              '  "isDnD":false,\n  "name":"%s",\n  "parent":{\n    "name":"mod",\n'
              '    "path":"folders/脚本/mod.yy",\n  },\n  "resourceType":"GMScript",\n'
              '  "resourceVersion":"2.0",\n}\n') % (cfg["file"], cfg["file"])
        io.open(os.path.join(d, cfg["file"] + ".yy"), "w", encoding="utf-8", newline="\n").write(yy)
        print("[script] scripts/%s/%s.gml" % (cfg["file"], cfg["file"]))


def patch_mod_enemy_init():
    """在 mod_enemy_init 里挂上两个新章节的注册调用（幂等）。"""
    p = os.path.join(SCR_DIR, "mod_enemy_init", "mod_enemy_init.gml")
    s = io.open(p, encoding="utf-8-sig").read()
    anchor = "    zhuore_enemy_init();\n"
    add = ""
    for tag, cfg in S.INIT_SCRIPTS.items():
        call = "    %s();\n" % cfg["func"]
        if call not in s:
            add += call
    if add:
        s = s.replace(anchor, anchor + add, 1)
        io.open(p, "w", encoding="utf-8", newline="\n").write(s)
        print("[init] mod_enemy_init 已挂:", add.strip().replace("\n", " "))


# ---------------------------------------------------------------- 资源登记
def ensure_folder(path, name, child_folders=(), items=()):
    full = os.path.join(ROOT, path.replace("/", os.sep))
    os.makedirs(os.path.dirname(full), exist_ok=True)
    folders, listitems = [], []
    if os.path.exists(full):
        try:
            d = load_yy(full)
            folders = [(f["name"], f["path"]) for f in d.get("folders", [])]
            listitems = [(f["name"], f["path"]) for f in d.get("listItems", [])]
        except Exception:
            pass
    for c in child_folders:
        if c not in folders:
            folders.append(c)
    for it in items:
        if it not in listitems:
            listitems.append(it)
    txt = ('{\n  "$GMFolder":"",\n  "%%Name":"%s",\n  "folderPath":"%s",\n'
           '  "isDefaultView":false,\n  "listViewItems":[],\n  "name":"%s",\n'
           '  "resourceType":"GMFolder",\n  "resourceVersion":"2.0",\n'
           '  "viewLocked":false,\n  "visible":true,\n  "folders":[\n%s  ],\n'
           '  "listItems":[\n%s  ],\n}\n') % (
        name, path, name,
        "".join('    {"name":"%s","path":"%s",},\n' % f for f in folders),
        "".join('    {"name":"%s","path":"%s",},\n' % i for i in listitems))
    io.open(full, "w", encoding="utf-8", newline="\n").write(txt)


def yyp_add(entries):
    txt = io.open(YYP, encoding="utf-8-sig").read()
    res_add, fold_add = [], []
    for kind, path in entries:
        if kind == "res":
            name = path.split("/")[1]
            if '"path":"%s"' % path in txt:
                continue
            res_add.append('    {"id":{"name":"%s","path":"%s",},},\n' % (name, path))
        else:
            name = os.path.splitext(os.path.basename(path))[0]
            if '"folderPath":"%s"' % path in txt:
                continue
            fold_add.append('    {"$GMFolder":"","%%Name":"%s","folderPath":"%s","name":"%s",'
                            '"resourceType":"GMFolder","resourceVersion":"2.0",},\n'
                            % (name, path, name))
    if res_add:
        m = re.search(r'"resources":\[\n', txt)
        txt = txt[:m.end()] + "".join(res_add) + txt[m.end():]
    if fold_add:
        m = re.search(r'"Folders":\[\n', txt)
        txt = txt[:m.end()] + "".join(fold_add) + txt[m.end():]
    io.open(YYP, "w", encoding="utf-8", newline="\n").write(txt)
    print("[yyp] resources +%d, folders +%d" % (len(res_add), len(fold_add)))


def register(only=None):
    entries = []
    per_chapter = {tag: {"spr": [], "obj": []} for tag in S.INIT_SCRIPTS}
    for case in S.CASES:
        if only and case["key"] != only:
            continue
        tag = case["prefix"][3:5]
        folder_cn = S.INIT_SCRIPTS[tag]["folder_cn"]
        sp_items = []
        for suffix, _, _, _, _ in case["sprites"]:
            name = sprite_name(case, suffix)
            p = "sprites/%s/%s.yy" % (name, name)
            sp_items.append((name, p))
            entries.append(("res", p))
        sp_path = "%s/%s/xiaoguai/%s.yy" % (SPR_ROOT_FOLDER, folder_cn, case["key"])
        ensure_folder(sp_path, case["key"], items=sp_items)
        per_chapter[tag]["spr"].append((case["key"], sp_path))
        entries.append(("folder", sp_path))

        obj_name = "obj_" + case["prefix"] + case["key"]
        ob_path = "objects/%s/%s.yy" % (obj_name, obj_name)
        entries.append(("res", ob_path))
        ob_folder = "%s/%s/xiaoguai/%s.yy" % (OBJ_ROOT_FOLDER, folder_cn, case["key"])
        ensure_folder(ob_folder, case["key"], items=[(obj_name, ob_path)])
        per_chapter[tag]["obj"].append((case["key"], ob_folder))
        entries.append(("folder", ob_folder))

    # 章节 → xiaoguai → 单鼠 三级文件夹
    for tag, cfg in S.INIT_SCRIPTS.items():
        cn = cfg["folder_cn"]
        spr_root = "%s/%s.yy" % (SPR_ROOT_FOLDER, cn)
        obj_root = "%s/%s.yy" % (OBJ_ROOT_FOLDER, cn)
        ensure_folder("%s/%s/xiaoguai.yy" % (SPR_ROOT_FOLDER, cn), "xiaoguai",
                      child_folders=per_chapter[tag]["spr"])
        ensure_folder("%s/%s/xiaoguai.yy" % (OBJ_ROOT_FOLDER, cn), "xiaoguai",
                      child_folders=per_chapter[tag]["obj"])
        ensure_folder(spr_root, cn, child_folders=[("xiaoguai", "%s/%s/xiaoguai.yy" % (SPR_ROOT_FOLDER, cn))])
        ensure_folder(obj_root, cn, child_folders=[("xiaoguai", "%s/%s/xiaoguai.yy" % (OBJ_ROOT_FOLDER, cn))])
        entries.append(("folder", spr_root))
        entries.append(("folder", obj_root))
        entries.append(("folder", "%s/%s/xiaoguai.yy" % (SPR_ROOT_FOLDER, cn)))
        entries.append(("folder", "%s/%s/xiaoguai.yy" % (OBJ_ROOT_FOLDER, cn)))

    # kuafu 下挂两章
    ensure_folder(SPR_ROOT_FOLDER + ".yy", "kuafu",
                  child_folders=[(cfg["folder_cn"], "%s/%s.yy" % (SPR_ROOT_FOLDER, cfg["folder_cn"]))
                                 for cfg in S.INIT_SCRIPTS.values()])
    ensure_folder(OBJ_ROOT_FOLDER + ".yy", "kuafu",
                  child_folders=[(cfg["folder_cn"], "%s/%s.yy" % (OBJ_ROOT_FOLDER, cfg["folder_cn"]))
                                 for cfg in S.INIT_SCRIPTS.values()])
    entries.append(("folder", SPR_ROOT_FOLDER + ".yy"))
    entries.append(("folder", OBJ_ROOT_FOLDER + ".yy"))

    # 脚本资源
    script_items = []
    for cfg in S.INIT_SCRIPTS.values():
        p = "scripts/%s/%s.yy" % (cfg["file"], cfg["file"])
        entries.append(("res", p))
        script_items.append((cfg["file"], p))
    ensure_folder("folders/脚本/mod.yy", "mod", items=script_items)

    yyp_add(entries)
    print("[register] 完成")


def main():
    what = sys.argv[1] if len(sys.argv) > 1 else "all"
    only = sys.argv[2] if len(sys.argv) > 2 else None
    if what in ("sprites", "all"):
        build_sprites(only)
    if what in ("objects", "all"):
        build_objects(only)
    if what in ("register", "all"):
        build_init_scripts()
        patch_mod_enemy_init()
        register(only)


if __name__ == "__main__":
    main()
