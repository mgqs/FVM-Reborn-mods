# -*- coding: utf-8 -*-
"""巫毒风洞对齐验证图：底图原铁笼 vs 风洞精灵「当前 / 上移 32」。

底图取自擦除前备份 output/_tmp/bak_wuduyanjiusuo_7，按关卡 bg_draw 的
(x,y,sx,sy) 映射回 1920×1080 游戏坐标；风洞精灵按 image_scale 1.8 与
origin 贴在格心（当前）与格心 -32（修复后）。
"""
import json
import os
import re

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LV = 7                      # 截图对应 wudu_7
OX, OY, CW, CH = 695, 228, 107, 116
R, C = 0, 4                 # 取样格子
PAD = 14
CROP = (1040, 150, 1330, 440)   # 游戏坐标裁切窗
ZOOM = 2.2


def font(sz, bold=False):
    for name in (("msyhbd.ttc" if bold else "msyh.ttc"), "simhei.ttf"):
        for root in (r"C:\Windows\Fonts", "/usr/share/fonts"):
            p = os.path.join(root, name)
            if os.path.exists(p):
                try:
                    return ImageFont.truetype(p, sz)
                except OSError:
                    pass
    return ImageFont.load_default()


def load_yy(p):
    s = open(p, encoding="utf-8-sig").read()
    s = re.sub(r",(\s*[}\]])", r"\1", s)
    return json.loads(s)


def level():
    p = os.path.join(ROOT, "datafiles", "level_data", "cross", "wudu_%d.json" % LV)
    return json.loads(open(p, encoding="utf-8").read().replace("\x00", ""))


def bg_backup():
    d = os.path.join(ROOT, "sprites", "spr_wuduyanjiusuo_%d" % LV)
    txt = open(os.path.join(d, "spr_wuduyanjiusuo_%d.yy" % LV), encoding="utf-8").read()
    fr = re.search(r'"\$GMSpriteFrame":"v1","%Name":"([0-9a-f\-]+)"', txt).group(1)
    return os.path.join(ROOT, "output", "_tmp", "bak_wuduyanjiusuo_%d" % LV, fr + ".png")


def wind_sprite():
    n = "spr_wind_tunnel"
    yy = load_yy(os.path.join(ROOT, "sprites", n, n + ".yy"))
    fr = yy["frames"][0]["name"]
    im = Image.open(os.path.join(ROOT, "sprites", n, fr + ".png")).convert("RGBA")
    return im, yy["sequence"]["xorigin"], yy["sequence"]["yorigin"], yy["width"], yy["height"]


def game_canvas():
    lv = level()
    g = lv["bg_draw"]
    bg = Image.open(bg_backup()).convert("RGB")
    bg = bg.resize((int(bg.width * g["sx"]), int(bg.height * g["sy"])), Image.LANCZOS)
    canvas = Image.new("RGB", (1920, 1080), (18, 16, 30))
    canvas.paste(bg, (int(round(g["x"])), int(round(g["y"]))))
    return canvas


def compose(base, sprite, ox, oy, gy, sx=1.8, sy=1.8):
    im = base.copy()
    sp = sprite.copy()
    sp = sp.resize((int(sp.width * sx), int(sp.height * sy)), Image.LANCZOS)
    px = int(round(OX + CW * (C + 0.5) - ox * sx))
    py = int(round(gy - oy * sy))
    im.paste(sp, (px, py), sp)
    return im


def mark(im, gy):
    d = ImageDraw.Draw(im)
    col = (255, 60, 60)
    d.line([(OX + CW * C, gy), (OX + CW * (C + 1), gy)], fill=col, width=2)
    return im


def main():
    base = game_canvas()
    sp, oxs, oys, _, _ = wind_sprite()
    cx_g, cy_g = OX + CW * (C + 0.5), OY + CH * (R + 0.5)

    panels = [
        ("底图原稿（铁笼仍在）", base, None),
        ("当前：精灵对齐格心", compose(base, sp, oxs, oys, cy_g), cy_g),
        ("修复后：再上移 32", compose(base, sp, oxs, oys, cy_g - 32), cy_g - 32),
    ]

    tiles = []
    for title, im, gy in panels:
        c = im.crop(CROP)
        c = c.resize((int(c.width * ZOOM), int(c.height * ZOOM)), Image.LANCZOS)
        d = ImageDraw.Draw(c)
        # 格心线（青色虚线）
        yy = int((cy_g - CROP[1]) * ZOOM)
        for x in range(0, c.width, 14):
            d.line([(x, yy), (x + 7, yy)], fill=(0, 220, 220), width=2)
        if gy is not None:
            y2 = int((gy - CROP[1]) * ZOOM)
            for x in range(0, c.width, 14):
                d.line([(x, y2), (x + 7, y2)], fill=(255, 70, 70), width=2)
        tiles.append((title, c))

    tw, th = tiles[0][1].size
    head = 92
    W = tw * 3 + PAD * 4
    H = head + th + 58
    out = Image.new("RGB", (W, H), (247, 249, 252))
    d = ImageDraw.Draw(out)
    d.text((PAD + 4, 16), "巫毒风洞对齐：底图原铁笼 vs 风洞精灵", font=font(26, True), fill=(28, 32, 44))
    d.text((PAD + 4, 52), "青线 = 格心　红线 = 精灵自身沿用的基准线（当前 = 格心；修复后 = 格心 -32）",
           font=font(14), fill=(110, 118, 134))
    for i, (title, t) in enumerate(tiles):
        x = PAD + i * (tw + PAD)
        out.paste(t, (x, head))
        d.text((x + 2, head + th + 10), title, font=font(15, True), fill=(28, 32, 44))
    p = os.path.join(ROOT, "output", "wudu_windtunnel_align.png")
    out.save(p)
    print("->", p, out.size)


if __name__ == "__main__":
    main()
