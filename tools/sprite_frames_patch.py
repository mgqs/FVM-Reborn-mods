# -*- coding: utf-8 -*-
"""按给定的 PNG 序列重写一个精灵的帧集合（可增帧、可减帧）。

背景
----
GMSprite 的 `.yy` 里帧数据分三处，必须同步改，否则 IDE 打开报 File missing
或运行时帧数不对：
  1. `"frames":[ ... ]`          —— 每帧一条 {$GMSpriteFrame, %Name: <帧GUID>}
  2. `"sequence"."tracks"[0]["keyframes"]["Keyframes"]` —— 每帧一条 Keyframe，Key = 0..N-1
  3. `"sequence"."length"`       —— 必须等于帧数
另有磁盘结构（两处都要写，见 AGENTS.md / MEMORY）：
  `sprites/<名>/<帧GUID>.png`（顶层合成图，运行时读它）
  `sprites/<名>/layers/<帧GUID>/<图层GUID>.png`（图层源图）

用法
----
    python tools/sprite_frames_patch.py --check          # 只打印计划，不写盘
    python tools/sprite_frames_patch.py                  # 执行
    python tools/sprite_frames_patch.py --only arno_idle # 只做一项

画布尺寸、原点、所属文件夹、纹理组全部保持不变；只换帧内容与帧数。
新的帧 GUID 用 uuid4，原有帧 GUID 按序号复用，避免无谓 diff。
"""
import argparse
import io
import os
import re
import shutil
import sys
import uuid

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPRITES = os.path.join(ROOT, "sprites")
SWF = os.path.join(ROOT, "output", "_tmp")

# 阿诺（变异阿诺.swf → 精灵 98，导出 PNG 文件名 1 基）
ARNO = os.path.join(
    SWF, "swf_arno",
    "DefineSprite_98_com.aurora.ui.maogoutd.resource.Intruder.kfcarbon"
    ".TerminatorBossMouseStrengthenMoveIntruderMovie")
# 冰渣/火渣（WizardBoss*MouseMoveIntruderMovie）
BINGZHA = os.path.join(
    SWF, "swf_bingzha",
    "DefineSprite_84_com.aurora.ui.maogoutd.resource.Intruder.kfcarbon"
    ".WizardBossMouseMoveIntruderMovie")
HUOZHA = os.path.join(
    SWF, "swf_huozha",
    "DefineSprite_107_com.aurora.ui.maogoutd.resource.Intruder.kfcarbon"
    ".WizardBossFireMouseMoveIntruderMovie")
# 法老（AbyssBPharaohBossMoveIntruderMovie）
PHARAOH = os.path.join(
    SWF, "swf_pharaoh",
    "DefineSprite_247_com.aurora.ui.maogoutd.resource.Intruder.kfcarbon"
    ".AbyssBPharaohBossMoveIntruderMovie")
# 变异绿巨人（巫毒研究所，HulkBossMoveIntruderMovie）
HULK = os.path.join(
    SWF, "swf_hulk",
    "DefineSprite_190_com.aurora.ui.maogoutd.resource.Intruder.kfcarbon"
    ".newBoss.hulk.HulkBossMoveIntruderMovie")

# key -> (精灵名, 源目录, [(起始标签帧0基, 结束标签帧0基), ...], 说明)
# 分段依据 tools/swf_frame_labels.py 的 FrameLabel；导出 PNG 是 1 基，故 +1
PLAN = {
    "arno_idle": ("spr_infected_arno_idle", ARNO, [(0, 11)],
                  "进场循环 0..11（原 24 帧把射击段切了进来）"),
    "arno_s2_ready": ("spr_infected_arno_skill_2_ready", ARNO, [(52, 61), (62, 71)],
                      "冲刺预备 10 + 受伤冲刺预备 10（原 26 帧错位）"),
    "arno_s2": ("spr_infected_arno_skill_2", ARNO, [(72, 85), (86, 99)],
                "冲刺 14 + 受伤冲刺 14（原 22 帧只切到尾巴）"),
    "bingzha_f1_ready": ("spr_infected_bingzha_fire_skill_1_ready", HUOZHA,
                         [(38, 45), (46, 53)],
                         "念咒 8+8（原 32 帧：与 fire_skill_1 内容对调了）"),
    "bingzha_f1": ("spr_infected_bingzha_fire_skill_1", HUOZHA, [(54, 69), (70, 85)],
                   "释放 16+16（原 16 帧：与 fire_skill_1_ready 内容对调了）"),
    "pharaoh_s2": ("spr_infected_pharaoh_skill_2", PHARAOH,
                   [(110, 121), (122, 128), (129, 140), (141, 147)],
                   "召唤 12 + 释放 7 + 受伤召唤 12 + 受伤释放 7（原只有前 19 帧）"),
    "hulk_s1_ready": ("spr_kf_wd_hulk_skill_1_ready", HULK,
                      [(94, 104), (304, 314)],
                      "变滚球 11 + 受伤变滚球 11（原 16 帧取自跳跃段，不是滚动）"),
    "hulk_s1": ("spr_kf_wd_hulk_skill_1", HULK,
                [(105, 108), (315, 318)],
                "滚球 4 + 受伤滚球 4（原 14 帧取自跳跃段，不是滚动）"),
}

FRAME_ENTRY = ('    {{"$GMSpriteFrame":"v1","%Name":"{g}","name":"{g}",'
               '"resourceType":"GMSpriteFrame","resourceVersion":"2.0",}},')

KF_ENTRY = (
    '            {{"$Keyframe<SpriteFrameKeyframe>":"","Channels":{{\n'
    '                "0":{{"$SpriteFrameKeyframe":"","Id":{{"name":"{g}","path":'
    '"sprites/{name}/{name}.yy",}},"resourceType":"SpriteFrameKeyframe",'
    '"resourceVersion":"2.0",}},\n'
    '              }},"Disabled":false,"id":"{kf}","IsCreationKey":false,'
    '"Key":{key}.0,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>",'
    '"resourceVersion":"2.0","Stretch":false,}},')


def sprite_paths(name):
    d = os.path.join(SPRITES, name)
    return d, os.path.join(d, name + ".yy")


def read(p):
    return io.open(p, encoding="utf-8").read()


def write(p, s):
    io.open(p, "w", encoding="utf-8", newline="\n").write(s)


def canvas(name):
    t = read(sprite_paths(name)[1])
    w = int(re.search(r'\n  "width":\s*(\d+)', t).group(1))
    h = int(re.search(r'\n  "height":\s*(\d+)', t).group(1))
    return w, h


def layer_guid(t):
    m = re.search(r'"layers":\[\s*\{[^\}]*?"name":"([0-9a-f\-]{36})"', t, re.S)
    if not m:
        raise RuntimeError("未找到图层 GUID")
    return m.group(1)


def frame_guids(t):
    return re.findall(r'"\$GMSpriteFrame":"v1","%Name":"([0-9a-f\-]{36})"', t)


def span_of(t, open_idx):
    """从 open_idx（指向 '['）开始返回匹配的整段闭区间 [open_idx, close_idx]。"""
    depth = 0
    i = open_idx
    while i < len(t):
        c = t[i]
        if c == '"':                       # 跳过字符串
            i += 1
            while i < len(t) and t[i] != '"':
                i += 2 if t[i] == "\\" else 1
        elif c in "[{":
            depth += 1
        elif c in "]}":
            depth -= 1
            if depth == 0:
                return open_idx, i
        i += 1
    raise RuntimeError("括号未配平")


def frames_span(t):
    m = re.search(r'"frames":\s*\[', t)
    return span_of(t, m.end() - 1)


def keyframes_span(t):
    m = re.search(r'"\$KeyframeStore<SpriteFrameKeyframe>":"","Keyframes":\s*\[', t)
    return span_of(t, m.end() - 1)


def collect(name, src, ranges):
    w, h = canvas(name)
    if not os.path.isdir(src):
        raise RuntimeError("源目录不存在：%s（先跑 ffdec 导出）" % src)
    out = []
    for a, b in ranges:
        for lab in range(a, b + 1):
            p = os.path.join(src, "%d.png" % (lab + 1))
            if not os.path.exists(p):
                raise RuntimeError("缺源帧：%s" % p)
            im = Image.open(p)
            if im.size != (w, h):
                raise RuntimeError("%s 尺寸 %s != 画布 %s" % (p, im.size, (w, h)))
            out.append(p)
    return out


def plan_one(key, dry=True):
    name, src, ranges, why = PLAN[key]
    pngs = collect(name, src, ranges)
    d, yy = sprite_paths(name)
    t = read(yy)
    old = frame_guids(t)
    lay = layer_guid(t)
    guids = [old[i] if i < len(old) else str(uuid.uuid4()) for i in range(len(pngs))]

    # bbox：所有帧 alpha 并集
    left = top = 10 ** 6
    right = bottom = -1
    for p in pngs:
        bb = Image.open(p).convert("RGBA").getbbox()
        if not bb:
            continue
        left = min(left, bb[0]); top = min(top, bb[1])
        right = max(right, bb[2] - 1); bottom = max(bottom, bb[3] - 1)

    fs, fe = frames_span(t)
    ks, ke = keyframes_span(t)
    new_frames = '[\n' + "\n".join(FRAME_ENTRY.format(g=g) for g in guids) + '\n  ]'
    new_kfs = ('[\n' + "\n".join(
        KF_ENTRY.format(g=g, name=name, kf=str(uuid.uuid4()), key=i)
        for i, g in enumerate(guids)) + '\n          ]')

    out = t[:fs] + new_frames + t[fe + 1:]
    ks2, ke2 = keyframes_span(out)          # 帧块长度变了，重算 keyframe 位置
    out = out[:ks2] + new_kfs + out[ke2 + 1:]
    out = re.sub(r'("length":\s*)\d+\.0', lambda m: m.group(1) + "%d.0" % len(pngs), out, count=1)
    out = re.sub(r'("bbox_left":\s*)-?\d+', lambda m: m.group(1) + str(left), out, count=1)
    out = re.sub(r'("bbox_right":\s*)-?\d+', lambda m: m.group(1) + str(right), out, count=1)
    out = re.sub(r'("bbox_top":\s*)-?\d+', lambda m: m.group(1) + str(top), out, count=1)
    out = re.sub(r'("bbox_bottom":\s*)-?\d+', lambda m: m.group(1) + str(bottom), out, count=1)

    print("%-34s %3d → %3d 帧  %s" % (name, len(old), len(pngs), why))
    if dry:
        return
    # 先备份
    bak = os.path.join(ROOT, "output", "_tmp", "bak_patch_" + name)
    if not os.path.isdir(bak):
        shutil.copytree(d, bak)
    for i, (p, g) in enumerate(zip(pngs, guids)):
        fdir = os.path.join(d, "layers", g)
        os.makedirs(fdir, exist_ok=True)
        shutil.copyfile(p, os.path.join(fdir, lay + ".png"))
        shutil.copyfile(p, os.path.join(d, g + ".png"))
    keep = set(guids)
    for entry in os.listdir(os.path.join(d, "layers")):
        full = os.path.join(d, "layers", entry)
        if os.path.isdir(full) and entry not in keep:
            shutil.rmtree(full)
    for entry in os.listdir(d):
        if re.fullmatch(r"[0-9a-f\-]{36}\.png", entry) and entry[:-4] not in keep:
            os.remove(os.path.join(d, entry))
    write(yy, out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true", help="只打印计划")
    ap.add_argument("--only", default=None, help="只做指定项（PLAN 的 key）")
    args = ap.parse_args()
    keys = [args.only] if args.only else list(PLAN)
    for k in keys:
        if k not in PLAN:
            print("未知项：%s（可选 %s）" % (k, ", ".join(PLAN)))
            return 1
        plan_one(k, dry=args.check)
    return 0


if __name__ == "__main__":
    sys.exit(main())
