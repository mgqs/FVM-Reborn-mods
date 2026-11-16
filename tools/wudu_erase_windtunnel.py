# -*- coding: utf-8 -*-
"""把巫毒研究所底图（spr_wuduyanjiusuo_0..7）上画进去的铁笼（风洞外观）P 掉。

背景
----
这 8 张底图的美术把铁笼（= 风洞外观）直接画进了地图；而 obj_wind_tunnel 还会在
同样格位生成风洞特效，叠成两层。此前的做法是把特效缩到 1.53 去贴铁笼；现在改成
把底图上的铁笼擦掉，让特效按原尺寸（1.8）绘制、居中于格心。

为什么能「无痕」
--------------
8 张底图是同一套美术（同为 night 时段、同一张网格底），同一格在别的关卡里往往
没有铁笼。39 个铁笼分布下来，只有 (row 0, col 8) 和 (row 6, col 8) 两格在全部 8 关
都有；其余 10 个格位总能找到一张「同位置干净」的底图 → 直接按像素拷贝，连光照
渐变都一致，看不出补丁。
对那两格兜底：从同图同列 ±2 行（棋盘同色、光照接近）平移一块过来。

几何
----
铁笼是同一张贴图重复粘贴，中心恒在「格心 + (3, -4.5)」底图像素处；外形含四角钉
约 100x108，统一按 110x120 的框处理（每边留 6~8px 余量吃掉投影与反锯齿）。
底图 bg_draw = x:2 y:36 sx:sy:1.8，格宽 59.44 / 格高 64.44 底图像素。

用法
----
  python tools/wudu_erase_windtunnel.py            # 干跑 -> output/wudu_erase_*.png
  python tools/wudu_erase_windtunnel.py --apply    # 写回精灵（顶层图 + layers 图层图）
幂等：已有备份时一律从备份读原图，重复执行结果不变。
"""
import json, os, re, sys, shutil
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OX, OY, CW, CH, COLS, ROWS = 695, 228, 107, 116, 9, 7

CAGE_DX, CAGE_DY = 3.0, -4.5      # 铁笼中心相对格心（底图像素）
CAGE_W, CAGE_H = 126, 136         # 统一擦除框（最大的那个笼子含角钉约 120x130）
N_IMG = 8
APPLY = "--apply" in sys.argv


def load_level(i):
    p = os.path.join(ROOT, "datafiles", "level_data", "cross", "wudu_%d.json" % i)
    return json.loads(open(p, encoding="utf-8").read().replace("\x00", ""))


def sprite_files(i):
    d = os.path.join(ROOT, "sprites", "spr_wuduyanjiusuo_%d" % i)
    txt = open(os.path.join(d, "spr_wuduyanjiusuo_%d.yy" % i), encoding="utf-8").read()
    frame = re.search(r'"\$GMSpriteFrame":"v1","%Name":"([0-9a-f\-]+)"', txt).group(1)
    layer = re.search(r'"layers":\[\s*\{"\$GMImageLayer":"","%Name":"([0-9a-f\-]+)"', txt).group(1)
    return os.path.join(d, frame + ".png"), os.path.join(d, "layers", frame, layer + ".png")


def is_metal(r, g, b):
    # 铁笼的白色金属框很亮，墙面石纹只有 120~145，用 150 卡掉
    return min(r, g, b) > 140 and max(r, g, b) - min(r, g, b) < 55


def is_mesh(r, g, b):
    return r < 72 and g < 72 and b < 72


def is_floor(r, g, b):
    """网格地面 = 蓝/紫系：B 明显高于 R 且明显高于 G（铁笼的灰白框 B-G 只有 29）"""
    return b > r + 25 and b > 90 and b - g > 45


def is_red(r, g, b):
    return r > 130 and g < 85 and b < 95 and r - g > 60 and r - b > 45


def cell_rect(r, c, bx, by, sx, sy):
    cx = (OX + CW * (c + 0.5) - bx) / sx + CAGE_DX
    cy = (OY + CH * (r + 0.5) - by) / sy + CAGE_DY
    return (int(round(cx - CAGE_W / 2)), int(round(cy - CAGE_H / 2)),
            int(round(cx + CAGE_W / 2)), int(round(cy + CAGE_H / 2)))


def box_stats(px, W, H, r, c, bx, by, sx, sy):
    """(金属+黑网占比, 红色占比)：判断该位置是否被铁笼/禁区装饰占住"""
    # 统计范围 = 擦除框（110x120）与「整个网格」的交集：
    #   · 必须覆盖框实际会搬的每一块，否则会把邻格里的红圈/其他笼一起搬过来；
    #   · 又要排除网格外的顶栏/侧墙装饰，那里的暗色会被误判成铁笼网面。
    gx0 = int(round((OX - bx) / sx))
    gx1 = int(round((OX + CW * COLS - bx) / sx))
    gy0 = int(round((OY - by) / sy))
    gy1 = int(round((OY + CH * ROWS - by) / sy))
    bx0, by0, bx1, by1 = cell_rect(r, c, bx, by, sx, sy)
    x0 = max(0, gx0, bx0)
    x1 = min(W, gx1, bx1)
    y0 = max(0, gy0, by0)
    y1 = min(H, gy1, by1)
    m = tot = floor = red = 0
    for y in range(max(0, y0), min(H, y1)):
        for x in range(max(0, x0), min(W, x1)):
            rr, gg, bb = px[x, y]
            tot += 1
            if is_floor(rr, gg, bb):
                floor += 1
            elif is_red(rr, gg, bb):
                red += 1
            elif is_metal(rr, gg, bb):
                m += 1
    return (m / max(1, tot), floor / max(1, tot), red / max(1, tot))


def main():
    os.makedirs(os.path.join(ROOT, "output"), exist_ok=True)

    # ---------- 1. 载入 8 张底图（apply 模式从备份读，保证幂等） ----------
    imgs, geo, holes = [], [], []
    for i in range(N_IMG):
        lv = load_level(i)
        bg = lv["bg_draw"]
        geo.append((bg["x"], bg["y"], bg["sx"], bg["sy"]))
        holes.append([(r, c) for r in range(ROWS) for c in range(COLS)
                      if "wind_tunnel" in (lv["map"][r][c].get("object") or [])])
        top_png, _ = sprite_files(i)
        bak = os.path.join(ROOT, "output", "_tmp", "bak_wuduyanjiusuo_%d" % i)
        bak_top = os.path.join(bak, os.path.basename(top_png))
        src_png = bak_top if (APPLY and os.path.exists(bak_top)) else top_png
        imgs.append(Image.open(src_png).convert("RGB"))

    # ---------- 2. 每张图每格：是否被铁笼 / 红线禁区占住 ----------
    occ = []
    for i in range(N_IMG):
        bx, by, sx, sy = geo[i]
        px = imgs[i].load()
        W, H = imgs[i].size
        occ.append({(r, c): box_stats(px, W, H, r, c, bx, by, sx, sy)
                    for r in range(ROWS) for c in range(COLS)})

    # ---------- 3. 逐图逐笼找源并拷贝 ----------
    for i in range(N_IMG):
        bx, by, sx, sy = geo[i]
        im = imgs[i].copy()
        op = im.load()
        base = imgs[i].load()
        W, H = im.size
        log = []
        for (r, c) in holes[i]:
            # 候选源按优先级排列；同一优先级里挑「金属像素最少」的那个
            # (优先级, 位移量, metal, floor, red, img, dx, dy, 说明)
            # 同位置拷贝没有任何像素错位（底图格距本身有 ±3px 抖动，平移两格会对不齐），
            # 所以同位置放宽阈值、平移收紧。
            cands = []
            for j in range(N_IMG):
                if j == i or (r, c) in holes[j]:
                    continue
                o = occ[j][(r, c)]
                cands.append((0, 0, o[0], o[1], o[2], imgs[j], 0, 0, "img%d" % j))
            for d in (2, -2, 4, -4, 6, -6):
                rr = r + d
                if 0 <= rr < ROWS and (rr, c) not in holes[i]:
                    o = occ[i][(rr, c)]
                    cands.append((1, abs(d), o[0], o[1], o[2], imgs[i], 0, int(round(d * CH / sy)), "self%+d行" % d))
            for j in range(N_IMG):
                if j == i:
                    continue
                for d in (2, -2, 4, -4):
                    rr = r + d
                    if 0 <= rr < ROWS and (rr, c) not in holes[j]:
                        o = occ[j][(rr, c)]
                        cands.append((2, abs(d), o[0], o[1], o[2], imgs[j], 0, int(round(d * CH / sy)), "img%d%+d行" % (j, d)))
            for d in (2, -2, 4, -4):
                cc = c + d
                if 0 <= cc < COLS and (r, cc) not in holes[i]:
                    o = occ[i][(r, cc)]
                    cands.append((3, abs(d), o[0], o[1], o[2], imgs[i], int(round(d * CW / sx)), 0, "self%+d列" % d))
            cands.sort(key=lambda t: (t[0], t[1], t[2]))
            src = None
            for (pri, _, metal, floor, red, sim_, dx_, dy_, how_) in cands:
                if pri == 0:
                    if metal < 0.002 and floor > 0.92 and red < 0.004:
                        src = (sim_, dx_, dy_, how_)
                        break
                else:
                    if metal < 0.004 and floor > 0.95 and red < 0.002:
                        src = (sim_, dx_, dy_, how_)
                        break
            if src is None:
                print("!! wudu_%d 格(%d,%d) 找不到干净源" % (i, r, c))
                continue
            sim, dx, dy, how = src
            spx = sim.load()
            x0, y0, x1, y1 = cell_rect(r, c, bx, by, sx, sy)
            for y in range(max(0, y0), min(H, y1)):
                for x in range(max(0, x0), min(W, x1)):
                    sx2, sy2 = x + dx, y + dy
                    if 0 <= sx2 < W and 0 <= sy2 < H:
                        op[x, y] = spx[sx2, sy2]

            # 边缘 5px 羽化，与周边真实像素融合
            for fade in range(5):
                a = (fade + 1) / 6.0
                for x in range(max(0, x0 + fade), min(W, x1 - fade)):
                    for yy in (y0 + fade, y1 - 1 - fade):
                        if 0 <= yy < H:
                            o, s = op[x, yy], base[x, yy]
                            op[x, yy] = tuple(int(round(o[k] * a + s[k] * (1 - a))) for k in range(3))
                for y in range(max(0, y0 + fade), min(H, y1 - fade)):
                    for xx in (x0 + fade, x1 - 1 - fade):
                        if 0 <= xx < W:
                            o, s = op[xx, y], base[xx, y]
                            op[xx, y] = tuple(int(round(o[k] * a + s[k] * (1 - a))) for k in range(3))
            # 残余清理：框周 30px 环带里若还有铁笼碎屑（个别关卡的笼子比统一框大），
            # 用邻域的干净地面像素迭代抹掉。只动几十个像素，不会影响整体。
            for _ in range(4):
                lay = im.load()
                residues = []
                rx0, ry0 = max(0, x0 - 30), max(0, y0 - 30)
                rx1, ry1 = min(W, x1 + 30), min(H, y1 + 30)
                for yy in range(ry0, ry1):
                    for xx in range(rx0, rx1):
                        if x0 <= xx < x1 and y0 <= yy < y1:
                            continue
                        prr, pgg, pbb = lay[xx, yy]
                        if is_metal(prr, pgg, pbb) or (prr < 55 and pgg < 55 and pbb < 70):
                            residues.append((xx, yy))
                if not residues:
                    break
                for (xx, yy) in residues:
                    acc = [0, 0, 0]; k = 0
                    for dy2 in range(-3, 4):
                        for dx2 in range(-3, 4):
                            nx, ny = xx + dx2, yy + dy2
                            if 0 <= nx < W and 0 <= ny < H:
                                prr, pgg, pbb = lay[nx, ny]
                                if is_floor(prr, pgg, pbb):
                                    acc[0] += prr; acc[1] += pgg; acc[2] += pbb; k += 1
                    if k >= 6:
                        lay[xx, yy] = (acc[0] // k, acc[1] // k, acc[2] // k)
            log.append("(%d,%d)←%s" % (r, c, how))

        png_out = os.path.join(ROOT, "output", "wudu_erase_%d.png" % i)
        im.save(png_out)
        print("wudu_%d  笼 %2d  %s" % (i, len(holes[i]), "  ".join(log)))

        if APPLY:
            top_png, lay_png = sprite_files(i)
            bak = os.path.join(ROOT, "output", "_tmp", "bak_wuduyanjiusuo_%d" % i)
            os.makedirs(bak, exist_ok=True)
            for f in (top_png, lay_png):
                b = os.path.join(bak, os.path.basename(f))
                if not os.path.exists(b):
                    shutil.copy2(f, b)
            im.save(top_png)
            im.save(lay_png)

    print("APPLY 完成（备份在 output/_tmp/bak_wuduyanjiusuo_*）" if APPLY
          else "DRY-RUN（未写回精灵）")


if __name__ == "__main__":
    main()
