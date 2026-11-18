# -*- coding: utf-8 -*-
"""跨服·水火之间 第二批僵尸鼠（潜艇 / 突袭 / 忍者首领 / 小喽啰 / 蜗牛 / 润滑黏液）交付核验图。

每只鼠一行：左侧写表格数值 + 精灵段布局（与 obj_enemy_parent 的 move*2 + attack*2 + death 对齐），
右侧按段取首帧缩略图。用法：python tools/kf_zombie_sheet.py
"""
import io
import json
import os
import re

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "output", "kf_sh_zombie_batch2.png")

ROWS = [
    dict(spr="spr_kf_sh_submarine", name="打击潜艇僵尸鼠", stat="体力 4500 · 速度 20→0.6 · 防爆 有",
         segs=[("正常行走", 0, 8), ("受伤行走", 8, 8), ("攻击", 16, 8), ("死亡爆炸", 24, 12)],
         note="水陆两栖；另 2 精灵：_land（同水上帧）/ _enter 16 帧（入水·出水）"),
    dict(spr="spr_kf_sh_assault", name="突袭僵尸鼠", stat="体力 720 · 速度 12→0.36 · 防爆 有",
         segs=[("正常行走", 0, 8), ("受伤行走", 8, 8), ("攻击", 16, 8), ("死亡下沉", 24, 8)],
         note="另 4 精灵：_helmet / _land / _land_helmet 各 32 帧、_appear 7 帧；头盔 280"),
    dict(spr="spr_kf_sh_ninja", name="忍者首领僵尸鼠", stat="体力 860 · 速度 40→1.2 / 8.57→0.257 · 防爆 有 · 冲撞 10",
         segs=[("正常行走", 0, 12), ("受伤行走", 12, 12), ("攻击", 24, 29), ("受伤攻击", 53, 29), ("死亡", 82, 12)],
         note="另 1 精灵：_summon 44 帧（出场 12 + 召唤 32）；召唤小喽啰 ×4 方向"),
    dict(spr="spr_kf_sh_minion", name="僵尸小喽啰鼠", stat="体力 100 · 速度 8.57→0.257 · 防爆 无",
         segs=[("正常行进", 0, 12), ("受伤行进", 12, 12), ("攻击", 24, 29), ("受伤攻击", 53, 29), ("死亡", 82, 13)],
         note="另 1 精灵：_summon 10 帧（出场）；由忍者首领召唤，出生即播出场"),
    dict(spr="spr_kf_sh_snail", name="蜗牛僵尸鼠", stat="体力 5400 · 速度 10→0.3 · 防爆 有",
         segs=[("正常前进", 0, 8), ("受伤前进", 8, 8), ("技能", 16, 8), ("受伤技能", 24, 8), ("爆炸", 32, 9)],
         note="碾压卡片 + 留下润滑黏液（特效 _snail_mucus 10 帧）"),
    dict(spr="spr_kf_sh_snail_mucus", name="蜗牛润滑黏液", stat="特效（非敌人）· 10 帧 = 出现 8 + 持续 2",
         segs=[("出现+持续", 0, 10)],
         note="Step 同步为 mod 10、锁帧 9、阈值 10*5；原版 6 帧"),
]


def load_yy(p):
    s = io.open(p, encoding="utf-8-sig").read()
    return json.loads(re.sub(r",(\s*[}\]])", r"\1", s))


def font(size):
    for f in (r"C:/Windows/Fonts/msyh.ttc", r"C:/Windows/Fonts/simhei.ttf"):
        if os.path.exists(f):
            return ImageFont.truetype(f, size)
    return ImageFont.load_default()


def main():
    pad, label_w, thumb_h = 14, 600, 96
    rows = []
    for r in ROWS:
        d = os.path.join(ROOT, "sprites", r["spr"])
        meta = load_yy(os.path.join(d, r["spr"] + ".yy"))
        frames = [f["name"] for f in meta["frames"]]
        tiles = []
        for label, st, n in r["segs"]:
            picks = [st] if n <= 1 else [st, st + n - 1]
            for i in picks:
                im = Image.open(os.path.join(d, frames[i] + ".png")).convert("RGBA")
                bb = im.getbbox()
                if bb:
                    im = im.crop(bb)
                sc = thumb_h / max(1, im.height)
                tiles.append((f"{label[:4]}·{i}",
                              im.resize((max(1, int(im.width * sc)), thumb_h), Image.LANCZOS)))
        rows.append((r, tiles))

    widths = [label_w + sum(t[1].width + 8 for t in tiles) + pad for _, tiles in rows]
    W = max(widths) + pad
    H = sum(thumb_h + 52 for _ in rows) + pad
    canvas = Image.new("RGB", (W, H), (247, 248, 251))
    d = ImageDraw.Draw(canvas)
    f_title, f_stat, f_note, f_tag = font(19), font(15), font(13), font(12)

    y = pad
    for r, tiles in rows:
        d.text((pad, y), r["name"], font=f_title, fill=(18, 20, 30))
        d.text((pad, y + 25), r["stat"], font=f_stat, fill=(36, 92, 160))
        d.text((pad, y + 47), r["note"], font=f_note, fill=(120, 126, 140))
        x = pad + label_w
        for tag, im in tiles:
            bg = Image.new("RGBA", im.size, (235, 238, 245, 255))
            bg.alpha_composite(im)
            canvas.paste(bg.convert("RGB"), (x, y + 6))
            d.text((x + 1, y + 6 + thumb_h + 2), tag, font=f_tag, fill=(110, 116, 130))
            x += im.width + 8
        d.line([(pad, y + thumb_h + 40), (W - pad, y + thumb_h + 40)], fill=(224, 227, 234))
        y += thumb_h + 52

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    canvas.save(OUT)
    print("saved", OUT, canvas.size)


if __name__ == "__main__":
    main()
