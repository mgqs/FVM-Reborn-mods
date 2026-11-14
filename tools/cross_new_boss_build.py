# -*- coding: utf-8 -*-
"""跨服新章节 BOSS 构建器：变异钢铁侠 / 变异绿巨人。

用法：
    python tools/cross_new_boss_build.py sprites
    python tools/cross_new_boss_build.py objects
    python tools/cross_new_boss_build.py register
    python tools/cross_new_boss_build.py            # 全部

要点：
  - 分段来自 SWF FrameLabel（见 cross_new_boss_spec.py 头注释），重采样对齐原版帧数
  - 锚点：body 用「bbox 归一化迁移」（新旧画布尺寸不同也能对准脚底），特效用中心/比例
  - 对象代码照抄本体 BOSS，只做需求差异补丁（钢铁侠技能3四枚导弹+首发可选、激光十字、
    绿巨人不可削弱+蓄力 4s），补丁全部带断言，源码变了会立刻报错
"""
import glob
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
import cross_new_boss_spec as S  # noqa: E402

SPR_DIR = os.path.join(ROOT, "sprites")
OBJ_DIR = os.path.join(ROOT, "objects")
SCR_DIR = os.path.join(ROOT, "scripts")
YYP = os.path.join(ROOT, "FVM_Reborn_makk.yyp")


# ---------------------------------------------------------------- 基础工具
def load_yy(p):
    return json.loads(re.sub(r",(\s*[}\]])", r"\1", io.open(p, encoding="utf-8-sig").read()))


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


def src_dir(pattern):
    hits = glob.glob(os.path.join(S.SRC_ROOT, pattern.replace("/", os.sep)))
    if len(hits) != 1:
        raise RuntimeError("源目录 glob 命中 %d 个: %s" % (len(hits), pattern))
    return hits[0]


def src_frames(pattern, expect=None):
    d = src_dir(pattern)
    files = [f for f in os.listdir(d) if f.lower().endswith(".png")]
    files.sort(key=lambda f: int(os.path.splitext(f)[0]))
    if expect is not None and len(files) != expect:
        raise RuntimeError("%s: 素材帧数 %d != 期望 %d" % (pattern, len(files), expect))
    return [os.path.join(d, f) for f in files]


def anchor_scaled(old_spr, old_idx, new_im):
    """bbox 归一化锚点迁移：原版 origin 在 bbox 内的相对位置 → 新图。"""
    om = sprite_meta(old_spr)
    obb = frame_image(old_spr, old_idx).split()[3].getbbox()
    ax = (om["ox"] - obb[0]) / float(obb[2] - obb[0])
    ay = (om["oy"] - obb[1]) / float(obb[3] - obb[1])
    nbb = new_im.split()[3].getbbox()
    if nbb is None:
        raise RuntimeError("参考帧全透明，锚点无法计算")
    return int(round(nbb[0] + ax * (nbb[2] - nbb[0]))), \
        int(round(nbb[1] + ay * (nbb[3] - nbb[1])))


def anchor_ratio(old_spr, new_im):
    """特效：原版 origin 占画布比例 → 新画布。"""
    om = sprite_meta(old_spr)
    return int(round(om["ox"] * new_im.width / float(om["w"]))), \
        int(round(om["oy"] * new_im.height / float(om["h"])))


# ---------------------------------------------------------------- 精灵 yy 模板（同 cross_new_mice_build）
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
    for i in images:
        if i.size != (w, h):
            raise RuntimeError("%s: 帧尺寸不一致 %s vs %s" % (name, i.size, (w, h)))
    d = os.path.join(SPR_DIR, name)
    if os.path.isdir(d):
        shutil.rmtree(d)
    os.makedirs(os.path.join(d, "layers"), exist_ok=True)

    lid = str(uuid.uuid4())
    frames, keys = [], []
    for i, im in enumerate(images):
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
        tg=S.TEX_GROUP, length=float(len(images)),
        pname=folder_key, ppath="%s/%s/boss/%s.yy" % (S.SPR_ROOT_FOLDER, S.CHAPTERS[boss_tag(name)]["folder_cn"], boss_key(name)),
    )
    io.open(os.path.join(d, name + ".yy"), "w", encoding="utf-8", newline="\n").write(yy)
    return w, h


def boss_tag(sprite_name):
    return "sh" if "_sh_" in sprite_name else "wd"


def boss_key(sprite_name):
    return "iron_man" if "iron_man" in sprite_name else "hulk"


def build_sprites():
    for boss in S.BOSSES:
        body_srcs = src_frames(boss["body_src"])
        if len(body_srcs) not in (426, 480):
            raise RuntimeError("%s: 主体帧数异常 %d" % (boss["cn"], len(body_srcs)))
        # 特效源帧（导弹两个特效共用 158 号精灵）
        eff_srcs = {}
        for suffix, old_spr, pat, segs, mode in boss["effects"]:
            if pat not in eff_srcs:
                eff_srcs[pat] = src_frames(pat)

        ref_new, ref_old_spr, ref_old_idx = boss["ref"]
        folder = "%s/%s/boss" % (S.SPR_ROOT_FOLDER, S.CHAPTERS[boss["tag"]]["folder_cn"])
        eff_modes = {e[0]: e[4] for e in boss["effects"]}
        # 身体精灵共用一张画布 → 统一锚点（原版同组精灵共用 origin，切换 sprite 才不跳）
        body_anchor = anchor_scaled(ref_old_spr, ref_old_idx,
                                    Image.open(body_srcs[ref_new]).convert("RGBA"))

        entries = [(sfx, old, total, segs, body_srcs) for sfx, old, total, segs in boss["sprites"]]
        entries += [(sfx, old, None, segs, eff_srcs[pat]) for sfx, old, pat, segs, mode in boss["effects"]]
        iron_srcs = src_frames(boss["iron_src"], 368) if "iron_src" in boss else None

        for sfx, old_spr, total, segs, srcs in entries:
            if segs and segs[0][0] == "@92":  # 装甲（激光）形态：92 号精灵整搬
                srcs = iron_srcs
            picks = []
            for seg in (segs or []):
                st, ln, out = seg
                if st == "@92":
                    picks += resample(srcs, out)
                else:
                    if st + ln > len(srcs):
                        raise RuntimeError("%s/%s: 段越界 %d+%d" % (boss["cn"], sfx, st, ln))
                    picks += resample(srcs[st:st + ln], out)
            if segs is None:
                picks = list(srcs)
            if total is not None and len(picks) != total:
                raise RuntimeError("%s/%s: 分段加总 %d != 原版 %d" % (boss["cn"], sfx, len(picks), total))
            images = [Image.open(p).convert("RGBA") for p in picks]
            # 空帧守卫：原版有内容、新帧全透明 → 分段取错
            om = sprite_meta(old_spr)
            lost = []
            for i in range(len(images)):
                if i < len(om["frames"]):
                    obb = frame_image(old_spr, i).split()[3].getbbox()
                    if obb and images[i].split()[3].getbbox() is None:
                        lost.append(i)
            if lost:
                raise RuntimeError("%s/%s: 第 %s 帧空白但原版有内容" % (boss["cn"], sfx, lost))

            name = "spr_%s%s_%s" % (boss["prefix"], boss["key"], sfx)
            if sfx in eff_modes:
                if eff_modes[sfx] == "center":
                    ox, oy = images[0].width // 2, images[0].height // 2
                else:
                    ox, oy = anchor_ratio(old_spr, images[0])
            elif sfx == "skill_2_iron":
                # 装甲形态画布与原版不同，用自己的首帧对齐
                ox, oy = anchor_scaled(old_spr, 0, images[0])
            else:
                ox, oy = body_anchor
            w, h = make_sprite(name, images, ox, oy, boss["key"], folder)
            print("[sprite] %-34s %3d帧 %dx%d origin(%d,%d)" % (name, len(images), w, h, ox, oy))


# ---------------------------------------------------------------- 对象
def sub_or_fail(txt, old, new, tag, count=1):
    if old not in txt:
        raise RuntimeError("%s: 找不到待替换串: %r" % (tag, old[:80]))
    return txt.replace(old, new, count)


def clone_object(old_obj, new_obj, smap, folder_path, extra=None, drop_events=()):
    src = os.path.join(OBJ_DIR, old_obj)
    dst = os.path.join(OBJ_DIR, new_obj)
    if not os.path.isdir(src):
        raise RuntimeError("原版对象不存在: " + old_obj)
    if os.path.isdir(dst):
        shutil.rmtree(dst)
    os.makedirs(dst)
    for fn in os.listdir(src):
        sp = os.path.join(src, fn)
        if fn.endswith(".yy"):
            txt = io.open(sp, encoding="utf-8-sig").read()
            txt = txt.replace('"name":"%s"' % old_obj, '"name":"%s"' % new_obj)
            txt = txt.replace('"%%Name":"%s"' % old_obj, '"%%Name":"%s"' % new_obj)
            # 浏览器文件夹 → 新 boss 子文件夹
            txt = re.sub(r'"parent":\{\s*"name":"[^"]*",\s*"path":"folders/[^"]*",\s*\},',
                         '"parent":{\n    "name":"%s",\n    "path":"%s/%s.yy",\n  },'
                         % (os.path.basename(folder_path), folder_path, os.path.basename(folder_path)), txt, count=1)
            # spriteId → 新精灵
            m = re.search(r'"spriteId":\{\s*"name":"([^"]*)",\s*"path":"[^"]*",\s*\}', txt)
            if m:
                new_sp = smap.get(m.group(1), m.group(1))
                txt = txt[:m.start()] + ('"spriteId":{\n    "name":"%s",\n    "path":"sprites/%s/%s.yy",\n  }'
                                         % (new_sp, new_sp, new_sp)) + txt[m.end():]
            # 删除事件（绿巨人 Draw_64 伤害进度文字）
            for ev in drop_events:
                en, et = ev  # (eventNum, eventType)，如 Draw_64 = (64, 8)
                pat = r'\n    \{"\$GMEvent":"v1","%%Name":"","collisionObjectId":null,"eventNum":%d,"eventType":%d,[^\n]*\},' % (en, et)
                txt, n = re.subn(pat, "", txt)
                if n != 1:
                    raise RuntimeError("%s: 删除事件 %s 失败 (n=%d)" % (new_obj, ev, n))
            io.open(os.path.join(dst, new_obj + ".yy"), "w", encoding="utf-8", newline="\n").write(txt)
        elif fn.endswith(".gml"):
            if fn[:-4] in drop_names(drop_events):
                continue
            txt = io.open(sp, encoding="utf-8-sig").read()
            for o in sorted(smap, key=len, reverse=True):
                txt = re.sub(r"\b%s\b" % re.escape(o), smap[o], txt)
            if extra:
                txt = extra(fn, txt)
            io.open(os.path.join(dst, fn), "w", encoding="utf-8", newline="\n").write(txt)
        else:
            shutil.copy2(sp, os.path.join(dst, fn))
    print("[object] %-32s <- %s" % (new_obj, old_obj))


def drop_names(drop_events):
    table = {(0, 8): "Draw_0", (64, 8): "Draw_64", (0, 0): "Create_0",
             (0, 3): "Step_0", (0, 1): "Destroy_0", (0, 2): "Step_2"}
    return [table[(en, et)] for en, et in drop_events]


# ---- 钢铁侠主体补丁
def patch_iron_mouse(fn, txt):
    if fn == "Create_0.gml":
        txt = sub_or_fail(txt, "skill_group_list = [[0,1,1,2],[0,1]]",
                          "skill_group_list = [[0,1,1,2],[0,1,2]]", fn)  # 首轮技能池加入技能3
        txt = sub_or_fail(txt, 'mouse_id = "iron_man_mouse"', 'mouse_id = "kf_sh_iron_man"', fn)
    if fn == "Step_0.gml":
        # 技能3：每次 4 枚（原 3 枚）
        txt = sub_or_fail(txt, "while (array_length(selected_coords) < 3) {",
                          "while (array_length(selected_coords) < 4) {", fn)
        txt = sub_or_fail(txt, "for(var i = 0 ; i < 3 ; i++){",
                          "for(var i = 0 ; i < 4 ; i++){", fn)
        txt = sub_or_fail(txt, "if timer >= 23*5 && timer <= 38 * 5 && jump_times < 3{",
                          "if timer >= 23*5 && timer <= 38 * 5 && jump_times < 4{", fn)
        # 发射节奏 25 帧间隔(3枚) → 20 帧间隔(4枚，116/136/156/176)
        txt = sub_or_fail(txt, "if (timer-115) mod 25 == 21{",
                          "if (timer-115) mod 20 == 1{", fn)
        # 技能2/技能3 创建的伴随对象 → 本 BOSS 的克隆（否则会拉出旧版钢铁侠）
        txt = sub_or_fail(txt, "instance_create_depth(iron_man_pos.x,iron_man_pos.y+30,-800,obj_iron_man)",
                          "instance_create_depth(iron_man_pos.x,iron_man_pos.y+30,-800,obj_kf_sh_iron_man_laser)", fn)
        txt = sub_or_fail(txt, "instance_create_depth(x+35,y-420,-800,obj_iron_man_bullet)",
                          "instance_create_depth(x+35,y-420,-800,obj_kf_sh_iron_man_bullet)", fn)
    return txt


def patch_iron_laser(fn, txt):
    if fn == "Step_0.gml":
        # 技能2升级：单点摧毁 → 十字范围摧毁（中心 + 上下左右 1 格）
        txt = sub_or_fail(txt, "if grid_col == erase_grid.col && grid_row == erase_grid.row &&",
                          "if abs(grid_col - erase_grid.col) + abs(grid_row - erase_grid.row) <= 1 &&", fn)
    return txt


def patch_hulk(fn, txt):
    if fn == "Create_0.gml":
        txt = sub_or_fail(txt, "wait_time = 480", "wait_time = 240", fn)  # 蓄力 8s → 4s
        txt = sub_or_fail(txt, 'mouse_id = "hulk_mouse"', 'mouse_id = "kf_wd_hulk"', fn)
    if fn == "Step_0.gml":
        # 技能全部无法削弱：去掉蓄力期伤害统计与削弱判定
        txt = sub_or_fail(txt, """		if timer == 1{
			prev_hp = hp
			damage_take = 0
			show_notice("造成足够伤害以削弱该技能",wait_time)
			skill_dropped = false
		}
		else{
			damage_take = prev_hp - hp
		}
""", """		// 变异绿巨人：技能无法被削弱
		if timer == 1{
			skill_dropped = false
		}
""", fn)
        txt = sub_or_fail(txt, """		if timer >= wait_time{
			if damage_take >= 0.1 * maxhp{
				skill_dropped = true
			}
			timer = 0
""", """		if timer >= wait_time{
			timer = 0
""", fn)
        # 技能3 创建的摧毁特效 → 本 BOSS 的克隆
        txt = sub_or_fail(txt, "instance_create_depth(effect_pos.x,effect_pos.y,-800,obj_hulk_destroy_effect)",
                          "instance_create_depth(effect_pos.x,effect_pos.y,-800,obj_kf_wd_hulk_destroy_effect)", fn)
    return txt


# ---------------------------------------------------------------- 注册脚本
INIT_TMPL = """/// %(title)s（跨服章节）BOSS
/// 行为代码照抄本体同名 BOSS（%(old)s），技能参数按需求调整（见对象内注释）。
/// 注意：BOSS 的生成口是 obj_battle/Step_2 读取 global.enemy_map 的 `_obj`，
/// 所以必须 register_enemy；register_boss 只负责血条的图标与名字。
function %(func)s()
{
%(body)s
}
"""

REG_TMPL = """    register_enemy("%(id)s", {
        name: "%(name)s",
        _obj: %(obj)s,
        hp: %(hp)d,
        shield: 0,
        description: "%(desc)s",
        speed: 0.3, atk: 10, cycle: 36, range: 90,
        ash_proof: true,
        spr: %(spr)s,
        feature: "land",
    });
    register_boss("%(id)s", {
        name: "%(name)s",
        hp: %(hp)d,
        icon: %(icon)s,
    });
"""


def build_init_scripts():
    for tag, cfg in S.CHAPTERS.items():
        boss = next(b for b in S.BOSSES if b["tag"] == tag)
        eid = boss["prefix"] + boss["key"]
        reg = S.REG[eid]
        body = REG_TMPL % dict(id=eid, name=reg["name"], obj="obj_" + eid,
                               hp=boss["hp"], desc=reg["desc"], spr=reg["spr"], icon=reg["icon"])
        txt = INIT_TMPL % dict(title=cfg["title"], old=boss["old_obj"],
                               func=cfg["init_func"], body=body.rstrip("\n"))
        d = os.path.join(SCR_DIR, cfg["init_file"])
        os.makedirs(d, exist_ok=True)
        io.open(os.path.join(d, cfg["init_file"] + ".gml"), "w", encoding="utf-8", newline="\n").write(txt)
        yy = ('{\n  "$GMScript":"v1",\n  "%%Name":"%s",\n  "isCompatibility":false,\n'
              '  "isDnD":false,\n  "name":"%s",\n  "parent":{\n    "name":"mod",\n'
              '    "path":"folders/脚本/mod.yy",\n  },\n  "resourceType":"GMScript",\n'
              '  "resourceVersion":"2.0",\n}\n') % (cfg["init_file"], cfg["init_file"])
        io.open(os.path.join(d, cfg["init_file"] + ".yy"), "w", encoding="utf-8", newline="\n").write(yy)
        print("[script] scripts/%s/%s.gml" % (cfg["init_file"], cfg["init_file"]))


def patch_mod_boss_init():
    p = os.path.join(SCR_DIR, "mod_boss_init", "mod_boss_init.gml")
    s = io.open(p, encoding="utf-8-sig").read()
    anchor = "    zhuore_boss_init();\n"
    add = ""
    for cfg in S.CHAPTERS.values():
        call = "    %s();\n" % cfg["init_func"]
        if call not in s:
            add += call
    if add:
        s = s.replace(anchor, anchor + add, 1)
        io.open(p, "w", encoding="utf-8", newline="\n").write(s)
        print("[init] mod_boss_init 已挂:", add.strip().replace("\n", " "))


# ---------------------------------------------------------------- 资源登记（同 mice 构建）
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


def register():
    entries = []
    for boss in S.BOSSES:
        tag = boss["tag"]
        cn = S.CHAPTERS[tag]["folder_cn"]
        # 精灵
        sp_items = []
        for sfx, *_ in boss["sprites"]:
            name = "spr_%s%s_%s" % (boss["prefix"], boss["key"], sfx)
            p = "sprites/%s/%s.yy" % (name, name)
            sp_items.append((name, p))
            entries.append(("res", p))
        for sfx, _, pat, _, _ in boss["effects"]:
            name = "spr_%s%s_%s" % (boss["prefix"], boss["key"], sfx)
            p = "sprites/%s/%s.yy" % (name, name)
            sp_items.append((name, p))
            entries.append(("res", p))
        sp_folder = "%s/%s/boss/%s.yy" % (S.SPR_ROOT_FOLDER, cn, boss["key"])
        ensure_folder(sp_folder, boss["key"], items=sp_items)
        entries.append(("folder", sp_folder))
        # 主体对象
        obj_name = "obj_" + boss["prefix"] + boss["key"]
        ob_path = "objects/%s/%s.yy" % (obj_name, obj_name)
        entries.append(("res", ob_path))
        # 随行对象
        comp_items = []
        for comp in S.COMPANIONS:
            if comp["boss"] != boss["key"]:
                continue
            cp = "objects/%s/%s.yy" % (comp["new"], comp["new"])
            entries.append(("res", cp))
            comp_items.append((comp["new"], cp))
        ob_folder = "%s/%s/boss/%s.yy" % (S.OBJ_ROOT_FOLDER, cn, boss["key"])
        ensure_folder(ob_folder, boss["key"], items=[(obj_name, ob_path)] + comp_items)
        entries.append(("folder", ob_folder))
        # 章节 boss 子文件夹挂到章节节点
        for root, node in ((S.SPR_ROOT_FOLDER, sp_folder), (S.OBJ_ROOT_FOLDER, ob_folder)):
            ensure_folder("%s/%s/boss.yy" % (root, cn), "boss", child_folders=[(boss["key"], node)])
            ensure_folder("%s/%s.yy" % (root, cn), cn,
                          child_folders=[("boss", "%s/%s/boss.yy" % (root, cn))])
            entries.append(("folder", "%s/%s/boss.yy" % (root, cn)))
            entries.append(("folder", "%s/%s.yy" % (root, cn)))

    # 注册脚本
    script_items = []
    for cfg in S.CHAPTERS.values():
        p = "scripts/%s/%s.yy" % (cfg["init_file"], cfg["init_file"])
        entries.append(("res", p))
        script_items.append((cfg["init_file"], p))
    ensure_folder("folders/脚本/mod.yy", "mod", items=script_items)

    yyp_add(entries)
    print("[register] 完成")


def build_objects():
    for boss in S.BOSSES:
        eid = boss["prefix"] + boss["key"]
        new_obj = "obj_" + eid
        smap = {}
        for sfx, old_spr, *_ in boss["sprites"]:
            smap[old_spr] = "spr_%s%s_%s" % (boss["prefix"], boss["key"], sfx)
        for sfx, old_spr, *_ in boss["effects"]:
            smap[old_spr] = "spr_%s%s_%s" % (boss["prefix"], boss["key"], sfx)
        folder = "%s/%s/boss/%s" % (S.OBJ_ROOT_FOLDER, S.CHAPTERS[boss["tag"]]["folder_cn"], boss["key"])
        drop = [(64, 8)] if boss["key"] == "hulk" else ()
        patcher = {"iron_man": patch_iron_mouse, "hulk": patch_hulk}[boss["key"]]
        clone_object(boss["old_obj"], new_obj, smap, folder, extra=patcher, drop_events=drop)
        # 随行对象
        for comp in S.COMPANIONS:
            if comp["boss"] != boss["key"]:
                continue
            extra = None
            if comp["new"] == "obj_kf_sh_iron_man_laser":
                base = patch_iron_laser
                old_id, new_id = comp["mouse_old"], comp["mouse_id"]
                def extra(fn, t, b=base, o=old_id, n=new_id):
                    if fn == "Create_0.gml":
                        t = sub_or_fail(t, 'mouse_id = "%s"' % o, 'mouse_id = "%s"' % n, fn)
                    return b(fn, t)
            elif comp.get("mouse_old"):
                old_id, new_id = comp["mouse_old"], comp["mouse_id"]
                def extra(fn, t, o=old_id, n=new_id):
                    if fn != "Create_0.gml":
                        return t
                    return sub_or_fail(t, 'mouse_id = "%s"' % o, 'mouse_id = "%s"' % n, fn)
            clone_object(comp["old"], comp["new"], comp["sprite_map"], folder, extra=extra)


def main():
    what = sys.argv[1] if len(sys.argv) > 1 else "all"
    if what in ("sprites", "all"):
        build_sprites()
    if what in ("objects", "all"):
        build_objects()
    if what in ("register", "all"):
        build_init_scripts()
        patch_mod_boss_init()
        register()


if __name__ == "__main__":
    main()
