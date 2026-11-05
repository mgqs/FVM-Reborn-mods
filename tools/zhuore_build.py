# -*- coding: utf-8 -*-
"""把「灼热地域」变异僵尸鼠导入项目：精灵 + 对象 + 资源注册。

用法：
    python tools/zhuore_build.py sprites   # 只生成精灵
    python tools/zhuore_build.py objects   # 只生成对象
    python tools/zhuore_build.py           # 全部
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
import swf_frame_labels as SWF      # noqa: E402
import zhuore_spec as S             # noqa: E402

SPR_DIR = os.path.join(ROOT, "sprites")
OBJ_DIR = os.path.join(ROOT, "objects")
YYP = os.path.join(ROOT, "FVM_Reborn_makk.yyp")
TEX_GROUP = "enemy_volcanic"

SPR_FOLDER_PARENT = "folders/精灵/Enemy/kuafu"
OBJ_FOLDER_PARENT = "folders/物体/Enemy/kuafu"


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


def alpha_bbox(im):
    return im.split()[3].getbbox()


def alpha_bbox_many(ims):
    """每帧是否有可见像素（alpha bbox 非空）。"""
    return [im.split()[3].getbbox() is not None for im in ims]


def resample(seq, n):
    """把帧列重采样到 n 帧（首尾保留）。"""
    if n <= 0:
        return []
    if len(seq) == n:
        return list(seq)
    if len(seq) == 1:
        return [seq[0]] * n
    if n == 1:
        return [seq[0]]
    return [seq[int(round(i * (len(seq) - 1) / (n - 1)))] for i in range(n)]


def src_frames(mouse):
    """取素材帧路径列表（按 1.png 2.png ... 排序）。"""
    base = os.path.join(S.SRC_ROOT, mouse.get("src_cn", mouse["cn"]), "sprites")
    subs = [d for d in os.listdir(base) if "DefineSprite_%d_" % mouse["sid"] in d]
    if not subs:
        raise RuntimeError("%s 找不到 sprite %d" % (mouse["cn"], mouse["sid"]))
    d = os.path.join(base, subs[0])
    files = [f for f in os.listdir(d) if f.lower().endswith(".png")]
    files.sort(key=lambda f: int(os.path.splitext(f)[0]))
    return [os.path.join(d, f) for f in files]


def swf_spans(mouse):
    """返回 (标签 -> (起, 止), sprite 总帧数)。"""
    p = os.path.join(S.SWF_ROOT, mouse["swf"])
    sprites = SWF.parse(open(p, "rb").read())
    info = sprites.get(mouse["sid"])
    if not info:
        raise RuntimeError("%s 里没有 sprite %d" % (mouse["swf"], mouse["sid"]))
    labels = sorted(info["labels"])
    spans = {}
    for i, (fr, lb) in enumerate(labels):
        end = labels[i + 1][0] if i + 1 < len(labels) else info["len"]
        spans[lb] = (fr, end)
    return spans, info["len"]


# ---------------------------------------------------------------- 精灵生成
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


def make_sprite(name, images, ox, oy, folder_key, folder=None):
    """images: PIL.Image 列表（可不同尺寸，统一到最大画布居中）。

    folder: 归属的 folders 路径（不含 `.yy`）。BOSS 用 boss 分组，
            小怪默认 zhuorediyu/xiaoguai。
    """
    folder = folder or "folders/精灵/Enemy/kuafu/zhuorediyu/xiaoguai"
    w = max(i.width for i in images)
    h = max(i.height for i in images)
    d = os.path.join(SPR_DIR, name)
    if os.path.isdir(d):
        shutil.rmtree(d)
    os.makedirs(os.path.join(d, "layers"), exist_ok=True)

    lid = str(uuid.uuid4())     # 所有帧共用同一个图层 GUID
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
        pname=folder_key,
        ppath="%s/%s.yy" % (folder, folder_key),
    )
    io.open(os.path.join(d, name + ".yy"), "w", encoding="utf-8", newline="\n").write(yy)
    return w, h


def sprite_name(key, suffix):
    base = "spr_" + S.PREFIX + key
    return base if suffix == "main" else "%s_%s" % (base, suffix)


def compute_origin(mouse, spans, srcs):
    """按参考帧把原版的 origin 偏移迁移到素材上。"""
    label, old_spr, old_idx = mouse["ref"]
    om = sprite_meta(old_spr)
    obb = alpha_bbox(frame_image(old_spr, old_idx))
    dx = om["ox"] - (obb[0] + obb[2]) / 2.0
    dy = om["oy"] - obb[3]

    st, _ = spans[label]
    im = Image.open(srcs[st]).convert("RGBA")
    sbb = alpha_bbox(im)
    ox = int(round((sbb[0] + sbb[2]) / 2.0 + dx))
    oy = int(round(sbb[3] + dy))
    return ox, oy


def build_sprites(only=None):
    report = []
    for mouse in S.MICE:
        if only and mouse["key"] != only:
            continue
        spans, total = swf_spans(mouse)
        srcs = src_frames(mouse)
        if len(srcs) != total:
            print("!! %s 素材帧数 %d != SWF 帧数 %d" % (mouse["cn"], len(srcs), total))
        ox, oy = compute_origin(mouse, spans, srcs)

        for suffix, old_spr, total_frames, segs in mouse["sprites"]:
            picks = []
            for seg in segs:
                label, n = seg[0], seg[1]
                if label is None:
                    # 显式区间段：(None, 目标帧数, (起, 止))——起止是 SWF 帧号（== srcs 下标）。
                    # 有些鼠的精灵并不是从 SWF 第 0 帧开始（例如小兵主精灵 = src[10:105]），
                    # 或者边界比 FrameLabel 早/晚一帧，靠标签表达不了，只能用绝对区间。
                    st, en = seg[2]
                else:
                    if label not in spans:
                        raise RuntimeError("%s: 标签 %s 不存在（可用: %s）"
                                           % (mouse["cn"], label, list(spans)))
                    st, en = spans[label]
                picks += resample(srcs[st:en], n)
            if len(picks) != total_frames:
                # 绝不在这里悄悄重采样：一旦分段加总不等于总帧数，
                # 全局重采样会把后续每一段整体挤歪，而且动画看起来「还能动」，很难发现。
                raise RuntimeError(
                    "%s/%s: 分段帧数加总 %d != 目标总帧数 %d"
                    % (mouse["cn"], suffix, len(picks), total_frames))
            images = [Image.open(p).convert("RGBA") for p in picks]

            # 空帧守卫：原版该帧有内容、新帧却全透明 → 说明取到了素材里的空帧
            # （捧花素材的「正常行走」整段就是空的），游戏里会表现为僵尸凭空隐形。
            on = alpha_bbox_many(images)
            oo = [alpha_bbox(frame_image(old_spr, i)) is not None
                  for i in range(total_frames)]
            lost = [i for i in range(total_frames) if oo[i] and not on[i]]
            if lost:
                raise RuntimeError("%s/%s: 第 %s 帧为空白但原版有内容（取到了素材空帧）"
                                   % (mouse["cn"], suffix, lost))

            name = sprite_name(mouse["key"], suffix)
            w, h = make_sprite(name, images, ox, oy, mouse["key"])
            report.append((name, len(images), w, h, ox, oy))
            print("[sprite] %-34s %3d帧 %dx%d origin(%d,%d)" % (name, len(images), w, h, ox, oy))
    return report


# ---------------------------------------------------------------- 对象生成
MOVE_SPEED_RE = re.compile(r"^(?P<pre>[ \t]*move_speed[ \t]*=[ \t]*)(?P<val>-?\d+(?:\.\d+)?)", re.M)


def patch_move_speed(txt, old_v, new_v, tag=""):
    """把 move_speed 里「数值等于 old_v」的第一处改成 new_v。
    按数值比较，避免 0.6 误伤 0.60 / 0.6 之类的写法差异。"""
    for m in MOVE_SPEED_RE.finditer(txt):
        if abs(float(m.group("val")) - old_v) < 1e-9:
            return txt[:m.start("val")] + ("%g" % new_v) + txt[m.end("val"):]
    raise RuntimeError("%s: 找不到 move_speed = %g 可改" % (tag, old_v))


def build_objects(only=None):
    for mouse in S.MICE:
        if only and mouse["key"] != only:
            continue
        old_obj = mouse["old"]
        new_obj = "obj_" + S.PREFIX + mouse["key"]
        src = os.path.join(OBJ_DIR, old_obj)
        dst = os.path.join(OBJ_DIR, new_obj)
        if not os.path.isdir(src):
            raise RuntimeError("原版对象不存在: " + old_obj)
        if os.path.isdir(dst):
            shutil.rmtree(dst)
        os.makedirs(dst)

        # 精灵名映射
        smap = {}
        for suffix, old_spr, _, _ in mouse["sprites"]:
            smap[old_spr] = sprite_name(mouse["key"], suffix)
        orep = dict(mouse.get("obj_replace", {}))
        orep[old_obj] = new_obj

        for fn in os.listdir(src):
            sp = os.path.join(src, fn)
            if fn.endswith(".yy"):
                txt = io.open(sp, encoding="utf-8-sig").read()
                txt = txt.replace('"name":"%s"' % old_obj, '"name":"%s"' % new_obj)
                txt = txt.replace('"%%Name":"%s"' % old_obj, '"%%Name":"%s"' % new_obj)
                # spriteId（多行，用正则整体替换）
                m = re.search(r'"spriteId":\{\s*"name":"([^"]*)",\s*"path":"[^"]*",\s*\}', txt)
                if m:
                    old_sp = m.group(1)
                    new_sp = smap.get(old_sp, old_sp)
                    txt = txt[:m.start()] + ('"spriteId":{\n    "name":"%s",\n'
                                             '    "path":"sprites/%s/%s.yy",\n  }'
                                             % (new_sp, new_sp, new_sp)) + txt[m.end():]
                # parent folder
                txt = re.sub(r'"parent":\{\s*"name":"[^"]*",\s*"path":"folders/[^"]*",\s*\},',
                             '"parent":{\n    "name":"%s",\n    "path":"folders/物体/Enemy/kuafu/zhuorediyu/xiaoguai/%s.yy",\n  },'
                             % (mouse["key"], mouse["key"]), txt, count=1)
                io.open(os.path.join(dst, new_obj + ".yy"), "w", encoding="utf-8", newline="\n").write(txt)
            elif fn.endswith(".gml"):
                txt = io.open(sp, encoding="utf-8-sig").read()
                for o in sorted(orep, key=len, reverse=True):
                    txt = re.sub(r"\b%s\b" % re.escape(o), orep[o], txt)
                for o in sorted(smap, key=len, reverse=True):
                    txt = re.sub(r"\b%s\b" % re.escape(o), smap[o], txt)
                # hp / maxhp
                txt = re.sub(r"^hp\s*=\s*[0-9]+", "hp = %d" % mouse["hp"], txt, flags=re.M)
                txt = re.sub(r"^maxhp\s*=\s*[0-9]+", "maxhp = %d" % mouse["hp"], txt, flags=re.M)
                # 护盾是「第二条血」，必须一起放大；漏了会造成注册表写 2000、
                # 实例却只有 80 盾，血条与实际完全对不上（捧花鼠就踩过这个坑）。
                sh = mouse.get("shield")
                if sh:
                    txt = re.sub(r"^shield_hp\s*=\s*[0-9]+", "shield_hp = %d" % sh, txt, flags=re.M)
                    txt = re.sub(r"^shield_max_hp\s*=\s*[0-9]+",
                                 "shield_max_hp = %d" % sh, txt, flags=re.M)
                # 移动速度 / 防爆：真正生效的是对象里的 move_speed 与 immune_to_ash，
                # register_enemy 的 speed / ash_proof 只是情报岛显示用的副本，两边必须一致。
                # 原版代码的 move_speed 大多取自《灼热地狱》总表（表格速度 × 0.03），但有几只
                # 被原作者取整写过（0.5 / 0.26 / 0.27 / -0.15），用 ms_patch 精确改到表格值。
                if fn == "Create_0.gml":
                    # 防爆：按表格「防爆」列。special_ash 只对 is_boss / infected_ 前缀生效，
                    # 跨服 id 不会命中，属于历史遗留，不影响这里的取值。
                    if "ash_proof" in mouse:
                        val = "true" if mouse["ash_proof"] else "false"
                        if re.search(r"^immune_to_ash\s*=\s*\w+", txt, re.M):
                            txt = re.sub(r"^immune_to_ash\s*=\s*\w+",
                                         "immune_to_ash = " + val, txt, flags=re.M)
                        else:
                            txt = txt.replace("event_inherited();",
                                              "event_inherited();\nimmune_to_ash = " + val, 1)
                for pfn, old_v, new_v in mouse.get("ms_patch", ()):
                    if pfn == fn:
                        txt = patch_move_speed(txt, old_v, new_v, mouse["cn"])
                # mouse_id
                txt = re.sub(r'mouse_id\s*=\s*"[^"]*"', 'mouse_id = "%s%s"' % (S.PREFIX, mouse["key"]), txt)
                # mouse_id
                txt = re.sub(r'mouse_id\s*=\s*"[^"]*"', 'mouse_id = "%s%s"' % (S.PREFIX, mouse["key"]), txt)
                io.open(os.path.join(dst, fn), "w", encoding="utf-8", newline="\n").write(txt)
            else:
                shutil.copy2(sp, os.path.join(dst, fn))
        print("[object] %-30s <- %s" % (new_obj, old_obj))


# ---------------------------------------------------------------- 注册
def ensure_folder(path, name, child_folders=(), items=()):
    """创建/更新 folders/xxx.yy（幂等）。"""
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
    """往 yyp 的 resources 和 Folders 里补条目（已存在则跳过）。"""
    txt = io.open(YYP, encoding="utf-8-sig").read()
    res_add, fold_add = [], []
    for kind, path in entries:
        if kind == "res":
            name = path.split("/")[1]
            line = '    {"id":{"name":"%s","path":"%s",},},\n' % (name, path)
            if '"path":"%s"' % path in txt:
                continue
            res_add.append(line)
        else:
            name = os.path.splitext(os.path.basename(path))[0]
            line = ('    {"$GMFolder":"","%%Name":"%s","folderPath":"%s","name":"%s",'
                    '"resourceType":"GMFolder","resourceVersion":"2.0",},\n') % (name, path, name)
            if '"folderPath":"%s"' % path in txt:
                continue
            fold_add.append(line)
    if res_add:
        m = re.search(r'"resources":\[\n', txt)
        txt = txt[:m.end()] + "".join(res_add) + txt[m.end():]
    if fold_add:
        m = re.search(r'"Folders":\[\n', txt)
        txt = txt[:m.end()] + "".join(fold_add) + txt[m.end():]
    io.open(YYP, "w", encoding="utf-8", newline="\n").write(txt)


def register(only=None):
    spr_folders, obj_folders = [], []
    entries = []

    for mouse in S.MICE:
        if only and mouse["key"] != only:
            continue
        key = mouse["key"]
        # 精灵 folder
        sp_items = []
        for suffix, old_spr, _, _ in mouse["sprites"]:
            name = sprite_name(key, suffix)
            p = "sprites/%s/%s.yy" % (name, name)
            sp_items.append((name, p))
            entries.append(("res", p))
        sp_path = "folders/精灵/Enemy/kuafu/zhuorediyu/xiaoguai/%s.yy" % key
        ensure_folder(sp_path, key, items=sp_items)
        spr_folders.append((key, sp_path))
        entries.append(("folder", sp_path))

        # 物体 folder
        obj_name = "obj_" + S.PREFIX + key
        ob_path = "objects/%s/%s.yy" % (obj_name, obj_name)
        entries.append(("res", ob_path))
        ob_folder = "folders/物体/Enemy/kuafu/zhuorediyu/xiaoguai/%s.yy" % key
        ensure_folder(ob_folder, key, items=[(obj_name, ob_path)])
        obj_folders.append((key, ob_folder))
        entries.append(("folder", ob_folder))

    # 两级父 folder
    spr_root = "folders/精灵/Enemy/kuafu/zhuorediyu.yy"
    ensure_folder(spr_root, "zhuorediyu",
                  child_folders=[("xiaoguai", "folders/精灵/Enemy/kuafu/zhuorediyu/xiaoguai.yy")])
    ensure_folder("folders/精灵/Enemy/kuafu/zhuorediyu/xiaoguai.yy", "xiaoguai",
                  child_folders=spr_folders)
    ensure_folder(OBJ_FOLDER_PARENT + "/zhuorediyu.yy", "zhuorediyu",
                  child_folders=[("xiaoguai", "folders/物体/Enemy/kuafu/zhuorediyu/xiaoguai.yy")])
    ensure_folder("folders/物体/Enemy/kuafu/zhuorediyu/xiaoguai.yy", "xiaoguai",
                  child_folders=obj_folders)

    # 上级 kuafu 挂 zhuorediyu
    ensure_folder("folders/精灵/Enemy/kuafu.yy", "kuafu", child_folders=[("zhuorediyu", spr_root)])
    ensure_folder("folders/物体/Enemy/kuafu.yy", "kuafu",
                  child_folders=[("zhuorediyu", OBJ_FOLDER_PARENT + "/zhuorediyu.yy")])

    for p in (spr_root, "folders/精灵/Enemy/kuafu/zhuorediyu/xiaoguai.yy",
              OBJ_FOLDER_PARENT + "/zhuorediyu.yy",
              "folders/物体/Enemy/kuafu/zhuorediyu/xiaoguai.yy"):
        entries.append(("folder", p))
    yyp_add(entries)
    print("[register] 资源与文件夹已登记")


def main():
    what = sys.argv[1] if len(sys.argv) > 1 else "all"
    only = sys.argv[2] if len(sys.argv) > 2 else None
    if what in ("sprites", "all"):
        build_sprites(only)
    if what in ("objects", "all"):
        build_objects(only)
    if what in ("register", "all"):
        register(only)


if __name__ == "__main__":
    main()
