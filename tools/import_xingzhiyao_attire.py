# -*- coding: utf-8 -*-
"""星之耀 男女 A/B 四套时装 —— SWF → 14 帧 PNG → 工程精灵（2026-11-18）

来源：D:\\FVM开发\\game\\FVM开发\\res\\res1118\\星之耀男女AB\\0x14D17{110,120,210,220}.swf
目标形式：对齐 res/套装/女角色/打工兔妹（01.png..14.png + head.png，128x128 RGBA）

流程要点（踩过的坑，别改回去）：
  * SWF 是 14 帧的纸娃娃时间轴（标签：待机 / 射出），舞台 720x576、背景 #666666。
    位图是散件（DefineBitsLossless2），必须用 FFDec 导出「frame」才能得到合成帧；
    自己解析 DefineShape 的位图填充矩阵不可靠（16 位字段是小端，位读会错位）。
  * FFDec：java -jar ffdec.jar -export frame <out> <swf>  → 1.png..14.png
  * 角色在舞台上的位置固定：外框 131x131 @ (384,301)-(515,432)，
    沿用 spr_player_attire_10 的 origin(450,430) 口径裁 128 窗口。
  * 对齐口径取同系列 spr_player_attire_xingzhiyao_nan/nv：角色 bbox 中心 x=64、脚底 y=122。
  * 精灵本体 origin=7(64,128)、图标 origin=4(64,64)，纹理组 player，父文件夹 Player/attire。
"""
import os
import re
import subprocess
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SWF_DIR = r"D:\FVM开发\game\FVM开发\res\res1118\星之耀男女AB"
TMP = os.path.join(ROOT, "output", "_tmp", "xingzhiyao")
OUT = os.path.join(ROOT, "output", "xingzhiyao_attire")
FFDEC = os.path.join(TMP, "ffdec", "ffdec.jar")

BG = (102, 102, 102)      # SWF 舞台底色
BG_TOL = 8                # 与底色曼哈顿距离小于该值即视为底色（边缘只有零星 1px 过渡）
STAGE_W, STAGE_H = 720, 576

SETS = [
    # (swf 标签, 中文名, 时装 id, 精灵名)
    ("0x14D17110", "星之耀男A", "player_attire_xingzhiyao_nan_a", "spr_player_attire_xingzhiyao_nan_a"),
    ("0x14D17120", "星之耀男B", "player_attire_xingzhiyao_nan_b", "spr_player_attire_xingzhiyao_nan_b"),
    ("0x14D17210", "星之耀女A", "player_attire_xingzhiyao_nv_a", "spr_player_attire_xingzhiyao_nv_a"),
    ("0x14D17220", "星之耀女B", "player_attire_xingzhiyao_nv_b", "spr_player_attire_xingzhiyao_nv_b"),
]

# 与同系列一致的对齐口径
CHAR_CX = 64      # 角色 bbox 中心 x
FEET_Y = 122      # 角色脚底 y（星之耀男女原图就是 122）


def ensure_ffdec():
    """FFDec 只是导出工具，不入库；缺了就现下（23 MB，一次性）"""
    if os.path.isfile(FFDEC):
        return
    import urllib.request
    import zipfile
    url = ("https://github.com/jindrapetrik/jpexs-decompiler/releases/download/"
           "version26.5.0/ffdec_26.5.0.zip")
    os.makedirs(os.path.join(TMP, "ffdec"), exist_ok=True)
    zpath = os.path.join(TMP, "ffdec.zip")
    print("下载 FFDec …")
    urllib.request.urlretrieve(url, zpath)
    with zipfile.ZipFile(zpath) as z:
        z.extractall(os.path.join(TMP, "ffdec"))


def ffdec_export(tag):
    """导出 14 帧合成图（已存在则跳过）"""
    out = os.path.join(TMP, "out_" + tag)
    if os.path.isdir(out) and len([f for f in os.listdir(out) if f.endswith(".png")]) >= 14:
        return out
    ensure_ffdec()
    os.makedirs(out, exist_ok=True)
    swf = os.path.join(SWF_DIR, tag + ".swf")
    r = subprocess.run(["java", "-jar", FFDEC, "-export", "frame", out, swf],
                       capture_output=True, text=True)
    if r.returncode != 0:
        raise RuntimeError("FFDec 导出失败: %s\n%s" % (tag, r.stdout[-800:] + r.stderr[-800:]))
    print("FFDec 导出 %s → %s" % (tag, out))
    return out


def load_frames(out_dir):
    fps = []
    for i in range(1, 15):
        p = os.path.join(out_dir, "%d.png" % i)
        if not os.path.isfile(p):
            raise FileNotFoundError(p)
        fps.append(p)
    return fps


def key_bg(im):
    """把舞台底色抠成透明"""
    im = im.convert("RGBA")
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a and abs(r - BG[0]) + abs(g - BG[1]) + abs(b - BG[2]) <= BG_TOL:
                px[x, y] = (0, 0, 0, 0)
    return im


def char_bbox(ims):
    box = None
    for im in ims:
        b = im.split()[3].getbbox()
        if b:
            box = b if box is None else (min(box[0], b[0]), min(box[1], b[1]),
                                        max(box[2], b[2]), max(box[3], b[3]))
    return box


RING = 4  # SWF 里画了一圈 131x131 的点击外框线，抠色去不掉，按内缩 4px 抹掉


def trim_ring(im, box):
    """抹掉外框线：box 是外框矩形（含线），内缩 RING 之外的像素一律清空"""
    im = im.copy()
    px = im.load()
    inner = (box[0] + RING, box[1] + RING, box[2] - RING, box[3] - RING)
    for y in range(im.height):
        for x in range(im.width):
            if x < inner[0] or x >= inner[2] or y < inner[1] or y >= inner[3]:
                px[x, y] = (0, 0, 0, 0)
    return im


def crop_128(im, cx, top, feet):
    """把角色摆进 128 画布：bbox 中心 x=CHAR_CX、脚底 y=FEET_Y"""
    dx = int(round(CHAR_CX - cx))
    dy = int(round(FEET_Y - feet))
    canvas = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    canvas.paste(im, (dx, dy), im)
    return canvas


def make_icon(frame, bbox, head_h=72, head_w=96):
    """从头像区裁一块、按高度放大到 ~118 再横向裁到 128 —— 与游戏内其它图标一样的「大头」构图"""
    cx = (bbox[0] + bbox[2]) / 2.0
    top = bbox[1]
    box = (int(cx - head_w / 2), int(top - 3), int(cx + head_w / 2), int(top - 3 + head_h))
    head = frame.crop(box)
    scale = 118.0 / head.height
    head = head.resize((max(1, int(head.width * scale)), 118), Image.LANCZOS)
    canvas = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    x = (128 - head.width) // 2
    canvas.paste(head, (x, 128 - 3 - head.height), head)
    return canvas


def main():
    sys.path.insert(0, os.path.join(ROOT, "tools"))
    import make_multi_frame_sprite as mfs

    os.makedirs(OUT, exist_ok=True)
    report = []
    for tag, cn, attire_id, spr in SETS:
        frames = [key_bg(Image.open(p)) for p in load_frames(ffdec_export(tag))]
        stage_box = char_bbox(frames)          # 含外框线 = SWF 的 131x131 点击框
        frames = [trim_ring(im, stage_box) for im in frames]
        bbox = char_bbox(frames)               # 去掉外框后才是角色本体
        cx = (bbox[0] + bbox[2]) / 2.0
        top, feet = bbox[1], bbox[3]
        print("%s %s 外框=%s 角色 bbox=%s cx=%.1f 脚底=%d" % (tag, cn, stage_box, bbox, cx, feet))

        d = os.path.join(OUT, cn)
        os.makedirs(d, exist_ok=True)
        pngs = []
        for i, im in enumerate(frames, 1):
            c = crop_128(im, cx, top, feet)
            p = os.path.join(d, "%02d.png" % i)
            c.save(p)
            pngs.append(p)
        icon = make_icon(frames[0], bbox)
        icon.save(os.path.join(d, "head.png"))

        mfs.build(spr, pngs, 128, 128, 64, 128, "player", pdir="Player/attire", origin=7)
        mfs.build(spr + "_icon", [os.path.join(d, "head.png")], 128, 128, 64, 64,
                  "player", pdir="Player/attire", origin=4)
        report.append((cn, attire_id, spr, d))

    print("\n生成结果：")
    for cn, aid, spr, d in report:
        print("  %-8s %-38s %s" % (cn, aid, d))


if __name__ == "__main__":
    main()
