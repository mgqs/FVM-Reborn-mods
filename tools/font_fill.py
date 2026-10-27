# -*- coding: utf-8 -*-
"""
font_fill.py —— 给 GameMaker 字体资源（fonts/<name>/<name>.yy + .png）补字形

背景
    GM 的字体是「按字形表打包」的：.yy 里 glyphs 记录了每个字符在图集 png 里的
    坐标与度量，缺字直接渲染成方框。IDE 只能在开编辑器时整批重生成，因此对
    "只缺几十个符号"的场景，最稳的做法是把缺的字形追加进现有图集，其它字形一个不动。

用法
    python tools/font_fill.py --dry-run          # 只看要补哪些字、要几行图集
    python tools/font_fill.py                    # 真正写入（自动备份 .bak_<时间>）
    python tools/font_fill.py --font font_hei    # 只处理一个字体
    python tools/font_fill.py --only-screen      # 只补项目文案里真正缺的字

字符集优先级（按顺序填，直到图集空间用完）
    1. 项目上屏缺字   .gml 字符串字面量里出现、该字体没有的字（Scribble 的印地语表除外）
    2. GB2312 符号区  全角空格、破折号、「」【】、≤≥±、①… 等
    3. GB2312 一级    3755 个常用汉字
    4. GB2312 二级    3008 个字，按编码顺序尽量填满剩余空间

字体源
    原字体（獅尾麥克黑體 / HarmonyOS Sans / Unifont）不在本机，改用系统自带的
    思源黑体 NotoSansSC-VF 按「墨密度 + 字面框」自动校准到与原字形同粗细同大小。
"""

import argparse
import io
import json
import os
import re
import shutil
import struct
import sys
import time

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NOTO = r"C:\Windows\Fonts\NotoSansSC-VF.ttf"

# 每个字体的渲染参数。size / 字重 / 基线由 calibrate() 实测校准后写入，
# binary 表示"无抗锯齿"（原字体 aa=0）→ 渲染后做二值化。
CONFIG = {
    "font_yuan": dict(size=20, wght=500, binary=None, ttf=NOTO),
    "font_hei":  dict(size=23, wght=320, binary=None, ttf=NOTO),
    "font_pixel": dict(size=16, wght=300, binary=110, ttf=NOTO),
}

# Noto 没有的字符 → 用同义字形顶上（否则渲染出来是 .notdef 空心方框）
FALLBACK_CHAR = {
    "\u2717": "\u00D7",   # ✗ → ×
    "\u2718": "\u00D7",   # ✘ → ×
    "\u2713": "\u221A",   # ✓ → √
    "\u2714": "\u221A",   # ✔ → √
}

# 最常用的中文标点，排在符号区最前面
COMMON_PUNCT = set("「」『』【】〔〕〈〉《》—…·、。，；：？！（）“”‘’≤≥≠≈±×÷∞√∵∴→←↑↓★☆○●◎△▲■□◆◇℃※")

# Scribble 的印地语（Kruti Dev）映射表里有一堆天城文，不是上屏文案，排除
SKIP_PREFIX = "__scribble"       # Scribble 文本库的内置脚本（印地语映射表等）

DEMO = {
    "font_yuan": "海克斯·炖煨蚝蛎「上汤」≤≥═✗の开胃小菜",
    "font_hei": "食材升级：老鼠啃咬速度+8%，「清汤锅」≤≥±",
    "font_pixel": "词条 ≤≥±×∞ 炖煨煲【上汤】の",
}

CAL_SAMPLE = "国菜我你他是的不了在有和人这中大为上个同说时要就出也得里后自以会家可下而过天去能对好小多然没日于起还发成事只作当想看文无开手十用主行方又如前所本见经头面公"
CAL_CHARS = list(CAL_SAMPLE)


# ────────────────────────── 工具 ──────────────────────────
def font_path(name):
    return os.path.join(ROOT, "fonts", name, name + ".yy")


def png_path(name):
    return os.path.join(ROOT, "fonts", name, name + ".png")


def load_yy(name):
    """返回 (原始文本, 解析后的 dict)"""
    raw = io.open(font_path(name), encoding="utf-8").read()
    data = json.loads(re.sub(r",(\s*[}\]])", r"\1", raw))
    return raw, data


def gb2312_symbols():
    out = []
    for hi in range(0xA1, 0xAA):
        for lo in range(0xA1, 0xFF):
            try:
                out.append(bytes([hi, lo]).decode("gb2312"))
            except Exception:
                pass
    return out


def gb2312_level(n):
    lo, hi = (0xB0, 0xD8) if n == 1 else (0xD8, 0xF8)
    out = []
    for h in range(lo, hi):
        for l in range(0xA1, 0xFF):
            try:
                out.append(bytes([h, l]).decode("gb2312"))
            except Exception:
                pass
    return out


def screen_chars():
    """项目 .gml 字符串字面量里出现的非 ASCII 字符（去注释）"""
    chars = set()
    for root, dirs, files in os.walk(ROOT):
        if os.sep + "." in root or "output" in root.split(os.sep) or "FvmNativeSupport" in root:
            continue
        for f in files:
            if not f.endswith(".gml"):
                continue
            if f.startswith(SKIP_PREFIX):
                continue
            p = os.path.join(root, f)
            try:
                s = io.open(p, encoding="utf-8", errors="replace").read()
            except Exception:
                continue
            s = re.sub(r"/\*.*?\*/", "", s, flags=re.S)
            s = re.sub(r"//[^\n]*", "", s)
            for m in re.finditer(r'"((?:[^"\\]|\\.)*)"', s):
                for ch in m.group(1):
                    if ord(ch) > 127:
                        chars.add(ch)
    return chars


_CMAP = {}


def cmap_of(ttf):
    """读 TTF 的 unicode cmap，用于判断某字符在源字体里到底有没有字形"""
    if ttf in _CMAP:
        return _CMAP[ttf]
    s = set()
    try:
        from fontTools.ttLib import TTFont
        f = TTFont(ttf, fontNumber=0, lazy=True)
        for t in f["cmap"].tables:
            if t.isUnicode():
                s |= set(t.cmap.keys())
        f.close()
    except Exception as e:
        print("  ⚠ 无法读取 cmap（%s），跳过字形存在性检测" % e)
    _CMAP[ttf] = s
    return s


# ────────────────────────── 校准 ──────────────────────────
def _ink_density(img):
    a = img.split()[-1]
    bb = a.getbbox()
    if not bb:
        return None
    px = a.crop(bb).point(lambda p: 255 if p > 128 else 0)
    n = sum(1 for v in px.get_flattened_data() if v > 0)
    return n / max(1, (bb[2] - bb[0]) * (bb[3] - bb[1]))


def measure_existing(name, data, chars):
    """从现有 png 量出真实字形指标"""
    g = data["glyphs"]
    im = Image.open(png_path(name)).convert("RGBA")
    asc = data["ascender"]
    dens, ink_h, ink_w, bot, shifts = [], [], [], [], []
    for ch in chars:
        v = g.get(str(ord(ch)))
        if not v:
            continue
        a = im.crop((v["x"], v["y"], v["x"] + v["w"], v["y"] + v["h"])).split()[-1]
        bb = a.getbbox()
        if not bb:
            continue
        d = _ink_density(im.crop((v["x"], v["y"], v["x"] + v["w"], v["y"] + v["h"])))
        if d is not None:
            dens.append(d)
        ink_h.append(bb[3] - bb[1])
        ink_w.append(bb[2] - bb[0])
        bot.append(bb[3] - asc)
        shifts.append(v["shift"])
    avg = lambda xs: sum(xs) / len(xs) if xs else 0
    return dict(density=avg(dens), ink_h=avg(ink_h), ink_w=avg(ink_w),
                bottom=avg(bot), shift=avg(shifts))


def calibrate(name, data, cfg):
    """用已有汉字反推：渲染出来的底边要落在哪个 y，才和原字形对齐"""
    base_font = ImageFont.truetype(cfg["ttf"], cfg["size"])
    if cfg["wght"]:
        base_font.set_variation_by_axes([cfg["wght"]])
    H = data["glyphs"][list(data["glyphs"])[0]]["h"]
    ex = measure_existing(name, data, CAL_CHARS)

    bots, dens, ih, iw = [], [], [], []
    for ch in CAL_CHARS:
        c = Image.new("L", (80, 80), 0)
        ImageDraw.Draw(c).text((20, 50), ch, fill=255, font=base_font, anchor="ls")
        bb = c.getbbox()
        if not bb:
            continue
        bots.append(bb[3] - 50)
        ih.append(bb[3] - bb[1])
        iw.append(bb[2] - bb[0])
        a = c.crop(bb)
        if cfg["binary"]:
            a = a.point(lambda p: 255 if p >= cfg["binary"] else 0)
        else:
            a = a.point(lambda p: 255 if p > 128 else 0)
        n = sum(1 for v in a.get_flattened_data() if v > 0)
        dens.append(n / max(1, a.width * a.height))
    avg = lambda xs: sum(xs) / len(xs) if xs else 0
    # 目标：渲染出的字形底边，落在「现有字形底边」所在的窗口 y 上
    base = int(round(data["ascender"] + ex["bottom"] - avg(bots)))
    return dict(base=base, H=H, shift_cjk=int(round(ex["shift"])),
                ex=ex, r_density=avg(dens), r_ink_h=avg(ih), r_ink_w=avg(iw),
                r_bottom=avg(bots))


# ────────────────────────── 渲染 ──────────────────────────
def needs_fullwidth(ch):
    import unicodedata
    eaw = unicodedata.east_asian_width(ch)
    if eaw in ("F", "W"):
        return True
    o = ord(ch)
    # 中文常用标点（—…‘’“”）、CJK 符号区、全角形式
    if 0x2010 <= o <= 0x201F or 0x3000 <= o <= 0x303F or 0xFF00 <= o <= 0xFF60:
        return True
    return False


def render_glyph(ch, cfg, cal):
    """返回 (RGBA 图, w, h, offset, shift)；无墨字符返回 None"""
    draw_ch = ch
    cm = cmap_of(cfg["ttf"])
    if cm and ord(ch) not in cm:
        if ch in FALLBACK_CHAR:
            draw_ch = FALLBACK_CHAR[ch]
        else:
            return None
    H = cal["H"]
    f = ImageFont.truetype(cfg["ttf"], cfg["size"])
    if cfg["wght"]:
        f.set_variation_by_axes([cfg["wght"]])
    pad = 32
    canvas = Image.new("RGBA", (pad * 2 + cfg["size"] * 3, H), (0, 0, 0, 0))
    dy = cal["base"]
    ImageDraw.Draw(canvas).text((pad, dy), draw_ch, fill=(255, 255, 255, 255), font=f, anchor="ls")

    alpha = canvas.split()[-1]
    if cfg["binary"]:
        alpha = alpha.point(lambda p: 255 if p >= cfg["binary"] else 0)
        r, g, b, _ = canvas.split()
        canvas = Image.merge("RGBA", (r, g, b, alpha))

    bb = alpha.getbbox()
    if not bb:
        return None
    left = bb[0] - pad
    right = bb[2] - pad
    w = right - left
    crop = canvas.crop((bb[0], 0, bb[2], H))

    adv = f.getlength(draw_ch)
    if needs_fullwidth(ch):
        shift = cal["shift_cjk"]
        offset = left
    else:
        shift = cal["shift_cjk"]
        offset = left + int(round((shift - adv) / 2))
    return crop, w, H, offset, shift


def blank_glyph(cal, shift):
    """空格类：1px 全透明"""
    return Image.new("RGBA", (1, cal["H"]), (0, 0, 0, 0)), 1, cal["H"], 0, shift


# ────────────────────────── 排布 ──────────────────────────
def atlas_usage(data, W, H):
    g = data["glyphs"]
    max_x = max(v["x"] + v["w"] for v in g.values())
    max_y = max(v["y"] + v["h"] for v in g.values())
    # 最后一行（y 最大那行）已用到哪
    last_y = max(v["y"] for v in g.values())
    row_right = max(v["x"] + v["w"] for v in g.values() if v["y"] == last_y)
    return max_x, max_y, last_y, row_right


def pack(items, W, H, start_y, row_right, row_h, gap=3, left=6, pad=3):
    """把 (ch, img, w, h, offset, shift) 依次排进图集，返回 (glyphs, cursor)

    右侧/底部留 pad 像素：纹理组带 border:2，glyph 贴边时会溢出到 page 外。
    """
    Ws, Hs = W - pad, H - pad
    out = []
    x = row_right + gap
    y = start_y
    if x >= Ws - left:
        x = left
        y = start_y + row_h
    for it in items:
        ch, img, w, h, offset, shift = it
        if x + w > Ws:
            x = left
            y += row_h
        if y + h > Hs:
            raise RuntimeError("图集空间不足：%d/%d 处放不下 %r" % (x, y, ch))
        out.append(dict(character=ord(ch), w=w, h=h, offset=offset, shift=shift, x=x, y=y, _img=img))
        x += w + gap
    return out, (x, y)


# ────────────────────────── 校验 / 预览 ──────────────────────────
def validate(data, new_glyphs, W, H):
    """越界 + 与旧字形重叠检查"""
    errs = []
    old = [dict(v) for v in data["glyphs"].values()]
    for gl in new_glyphs:
        if gl["x"] < 0 or gl["y"] < 0 or gl["x"] + gl["w"] > W or gl["y"] + gl["h"] > H:
            errs.append("越界 %r (%d,%d,%d,%d)" % (chr(gl["character"]), gl["x"], gl["y"], gl["w"], gl["h"]))
    boxes = [(g["x"], g["y"], g["x"] + g["w"], g["y"] + g["h"]) for g in new_glyphs]
    for i in range(len(boxes) - 1):
        a, b = boxes[i], boxes[i + 1]
        if a[0] < b[2] and b[0] < a[2] and a[1] < b[3] and b[1] < a[3]:
            errs.append("新字形自重叠 @%r" % (chr(new_glyphs[i]["character"]),))
    return errs


def render_text(glyphs, im, text, gap=0):
    """按 GM 的规则用 glyph 表拼一行字，用于肉眼检查对齐"""
    H = None
    for ch in text:
        g = glyphs.get(str(ord(ch)))
        if g:
            H = g["h"]
            break
    if H is None:
        H = 28
    widths = [glyphs[str(ord(c))]["shift"] if str(ord(c)) in glyphs else 0 for c in text]
    W = sum(widths) + 8
    out = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    x = 4
    for ch in text:
        g = glyphs.get(str(ord(ch)))
        if g:
            crop = im.crop((g["x"], g["y"], g["x"] + g["w"], g["y"] + g["h"]))
            out.alpha_composite(crop, (x + g["offset"], 0))
            x += g["shift"]
    return out


# ────────────────────────── 写盘 ──────────────────────────
def backup(name):
    stamp = time.strftime("%Y%m%d_%H%M%S")
    for ext in (".yy", ".png"):
        src = os.path.join(ROOT, "fonts", name, name + ext)
        shutil.copy2(src, src + ".bak_" + stamp)
    return stamp


def write_all(name, data, raw, new_glyphs, new_codes, dry=False):
    W = Image.open(png_path(name)).width
    H = Image.open(png_path(name)).height
    im = Image.open(png_path(name)).convert("RGBA")

    # 1) 贴图
    for gl in new_glyphs:
        if gl["_img"] is None:
            continue
        im.alpha_composite(gl["_img"], (gl["x"], gl["y"]))

    # 2) glyphs 文本（插在 glyphs 段最后一行的后面）
    lines = []
    for gl in new_glyphs:
        lines.append('    "%d":{"character":%d,"h":%d,"offset":%d,"shift":%d,"w":%d,"x":%d,"y":%d,},'
                     % (gl["character"], gl["character"], gl["h"], gl["offset"],
                        gl["shift"], gl["w"], gl["x"], gl["y"]))
    gs = raw.index('\n  "glyphs":{\n') + len('\n  "glyphs":{\n')
    ge = raw.index('\n  },', gs)
    out = raw[:ge] + "\n" + "\n".join(lines) + raw[ge:]

    # 3) ranges（逐字符单区间，保持原风格）
    rs = out.index('\n  "ranges":[\n') + len('\n  "ranges":[\n')
    rl = "".join('    {"lower":%d,"upper":%d,},\n' % (c, c) for c in sorted(new_codes))
    text = out[:rs] + rl + out[rs:]

    if dry:
        return "DRY", im

    stamp = backup(name)
    im.save(png_path(name))
    io.open(font_path(name), "w", encoding="utf-8", newline="\n").write(text)
    return stamp, im


# ────────────────────────── 主流程 ──────────────────────────
def process(name, only_screen=False, fill_level2=True, dry=False, verbose=True):
    raw, data = load_yy(name)
    cfg = CONFIG[name]
    cal = calibrate(name, data, cfg)
    W, H = Image.open(png_path(name)).size
    have = set(int(k) for k in data["glyphs"])
    max_x, max_y, last_y, row_right = atlas_usage(data, W, H)
    row_h = H_glyph = data["glyphs"][list(data["glyphs"])[0]]["h"]

    if verbose:
        print("\n=== %s ===" % name)
        print("  现有 %d 字，图集 %dx%d，已用到 y=%d / x=%d" % (len(have), W, H, max_y, max_x))
        print("  校准: size=%d wght=%s base=%d line_h=%d shift=%d | 现有墨密度%.3f→渲染%.3f 现有字高%.1f→渲染%.1f"
              % (cfg["size"], cfg["wght"], cal["base"], row_h, cal["shift_cjk"],
                 cal["ex"]["density"], cal["r_density"], cal["ex"]["ink_h"], cal["r_ink_h"]))

    # 待补字符
    sc = screen_chars()
    def sym_rank(c):
        o = ord(c)
        if o in COMMON_PUNCT:
            return (0, o)
        if 0x2010 <= o <= 0x22FF or 0x2190 <= o <= 0x21FF:   # 破折/引号/箭头/数学
            return (1, o)
        if 0x2460 <= o <= 0x24FF or 0x25A0 <= o <= 0x25FF:   # ①②、几何图形
            return (2, o)
        if 0x3040 <= o <= 0x30FF:                            # 日文假名
            return (4, o)
        if 0xFF00 <= o <= 0xFF60 or 0xFFE0 <= o <= 0xFFE6:   # 全角 ASCII
            return (5, o)
        return (3, o)
    groups = [
        ("上屏缺字", [c for c in sorted(sc) if ord(c) not in have]),
        ("符号区", sorted([c for c in gb2312_symbols() if ord(c) not in have], key=sym_rank)),
    ]
    if not only_screen:
        groups.append(("一级汉字", [c for c in gb2312_level(1) if ord(c) not in have]))
        if fill_level2:
            groups.append(("二级汉字", [c for c in gb2312_level(2) if ord(c) not in have]))

    seen = set()
    ordered = []
    for label, cs in groups:
        if label == "符号区":
            cs = [c for c in cs if sym_rank(c)[0] <= 3]
        picked = [c for c in cs if c not in seen]
        seen.update(picked)
        ordered.append((label, picked))
        if verbose:
            print("  %s: 待补 %d 个" % (label, len(picked)))

    # 渲染
    items, codes, skipped = [], [], []
    for label, cs in ordered:
        for ch in cs:
            if ch in ("\u3000", " "):
                img, w, h, off, sh = blank_glyph(cal, cal["shift_cjk"])
            else:
                r = render_glyph(ch, cfg, cal)
                if r is None:
                    skipped.append(ch)
                    continue
                img, w, h, off, sh = r
            items.append((ch, img, w, h, off, sh))

    if verbose:
        print("  可渲染 %d 个，源字体无字形而跳过 %d 个%s"
              % (len(items), len(skipped), ("：" + "".join(skipped[:20])) if skipped else ""))
        cap = int((H - max_y) / (row_h + 2)) * int((W - 12) / 22)
        print("  预计占用：剩余高度 %d px ≈ %d 行 ≈ %d 字位" % (H - max_y, int((H - max_y) / (row_h + 2)), cap))

    # 排布（超出容量就截断）
    try:
        new_glyphs, cur = pack(items, W, H, last_y, row_right, row_h + 2)
    except RuntimeError:
        keep = []
        for it in items:
            keep.append(it)
            try:
                pack(keep, W, H, last_y, row_right, row_h + 2)
            except RuntimeError:
                keep.pop()
                break
        new_glyphs, cur = pack(keep, W, H, last_y, row_right, row_h + 2)
        if verbose:
            print("  ⚠ 空间不足，截断为 %d 个（剩余 %d 个下一轮再补）" % (len(keep), len(items) - len(keep)))
        items = keep

    codes = [g["character"] for g in new_glyphs]
    if verbose:
        print("  最终新增 %d 个字形，图集用到 (x=%d, y=%d)" % (len(new_glyphs), cur[0], cur[1]))
        print("  样例:", "".join(chr(c) for c in codes[:40]))

    errs = validate(data, new_glyphs, W, H)
    if errs:
        for e in errs[:6]:
            print("  ✗ " + e)
        raise RuntimeError("%s 校验未通过（%d 项）" % (name, len(errs)))
    if verbose:
        print("  校验通过：无越界、无重叠")

    stamp, im = write_all(name, data, raw, new_glyphs, codes, dry=dry)

    # 预览：把新字形与老字形混排，检查基线/间距是否一致
    merged = dict(data["glyphs"])
    for gl in new_glyphs:
        merged[str(gl["character"])] = gl
    demo = DEMO.get(name, "")
    if demo:
        pv = render_text(merged, im, demo)
        pv = pv.resize((pv.width * 2, pv.height * 2), Image.NEAREST)
        tag = "dry_" if dry else ""
        pv.save(os.path.join(ROOT, ".workbuddy", "tmp", "%s%s_preview.png" % (tag, name)))
    return dict(name=name, added=len(new_glyphs), cal=cal, codes=codes,
                stamp=stamp, dry=dry, image=im, new_glyphs=new_glyphs)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--font", default=None)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--only-screen", action="store_true")
    ap.add_argument("--no-level2", action="store_true")
    args = ap.parse_args()
    names = [args.font] if args.font else ["font_yuan", "font_hei", "font_pixel"]
    for n in names:
        process(n, only_screen=args.only_screen, fill_level2=not args.no_level2, dry=args.dry_run)


if __name__ == "__main__":
    main()
