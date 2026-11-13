# -*- coding: utf-8 -*-
"""情报岛查看任务 —— 演示图生成器（真实素材拼贴）

用法：python tools/mock_info_task.py
输出：docs/info_task_design/img/01_taskboard.png 02_red_dot.png 03_info_island.png 04_flow.png

坐标全部按源码复算（scale / origin 与游戏内一致）：
  obj_task_bg        @ (960,540)   scale 0.9   spr_task_bg 1608x1096 org(804,548)
  obj_player_menu_bg @ (1710,1079) scale 0.9
  obj_info_island_bg @ (1380,540)  scale 1.8   spr_info_island_bg_2 ; 底图 spr_info_island_bg_1 @ (530,540) x0.45
注意：GameMaker 显示尺寸取 .yy 的 width/height，很多 png 是它的 2~4 倍，put() 统一按 .yy 缩放。
构图：游戏画面先 1:1 画在 SCENE 上，再整体缩到画布上方，底部 150px 留给图例，互不遮挡。
"""
import os
import re
import glob
import math
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "docs", "info_task_design", "img")
os.makedirs(OUT, exist_ok=True)

W, H = 1920, 1080
SCENE = (1920, 1080)
SCENE_S = 0.845                 # 游戏画面整体缩放
SCENE_POS = (960, 470)          # 缩放后中心
LEGEND_TOP = 962
FONT_PATH = r"C:\Windows\Fonts\msyhbd.ttc"
ACCENT = (255, 214, 74)

# spr_task_state 帧序（取自 .yy 的 frames 数组，不能用文件名排序）：
# 0=1d09289a 新(橙)  1=64f7e694 进行中(蓝)  2=119609ff 完成(绿)  3=837c1ed2 已领取(紫)
STATE_FRAME = {"new": 0, "viewed": 1, "completed": 2, "claimed": 3}

_fonts, _meta_cache, _img_cache = {}, {}, {}


def F(sz):
    if sz not in _fonts:
        _fonts[sz] = ImageFont.truetype(FONT_PATH, sz)
    return _fonts[sz]


def meta(name):
    """返回 (draw_w, draw_h, ox, oy, frames)。

    关键：GameMaker 这里实际按 PNG 像素尺寸渲染，而 .yy 的 xorigin/yorigin 是 PNG 坐标。
    证据：spr_info_island_info_bg png 256x284 / yy 128x142，源码格距写 j*128*1.5 = 192 = png 宽；
          spr_package_slot_bg png 98x114 与源码列距 84/行距 96 吻合；spr_info_island_bg_1 png 1892x1948 的
          x0.45 = 851 = 面板宽度。所以 draw 尺寸一律取 PNG，origin 取 .yy。
    """
    if name in _meta_cache:
        return _meta_cache[name]
    d = os.path.join(ROOT, "sprites", name)
    t = open(os.path.join(d, name + ".yy"), encoding="utf-8", errors="replace").read()
    ox = int(re.search(r'"xorigin":\s*(-?\d+)', t).group(1))
    oy = int(re.search(r'"yorigin":\s*(-?\d+)', t).group(1))
    # 帧顺序必须读 .yy 的 frames 数组，不能按文件名排序（uuid 排序 = 随机顺序）
    blk = t[t.find('"frames"'):]
    order = re.findall(r'"%Name":"([0-9a-f\-]{36})"', blk)
    frames = [os.path.join(d, u + ".png") for u in order]
    frames = [f for f in frames if os.path.exists(f)]
    if not frames:
        frames = sorted(glob.glob(os.path.join(d, "*.png")), key=os.path.basename)
    pw, ph = Image.open(frames[0]).size
    r = (pw, ph, ox, oy, frames)
    _meta_cache[name] = r
    return r


def img(name, frame=0):
    key = (name, frame)
    if key not in _img_cache:
        _, _, _, _, frames = meta(name)
        _img_cache[key] = Image.open(frames[min(frame, len(frames) - 1)]).convert("RGBA")
    return _img_cache[key]


def put(c, name, frame=0, x=0.0, y=0.0, s=1.0, sy=None, alpha=1.0):
    yw, yh, yox, yoy, _ = meta(name)
    s = float(s)
    sy = s if sy is None else float(sy)
    im = img(name, frame)
    im = im.resize((max(1, int(round(yw * s))), max(1, int(round(yh * sy)))), Image.LANCZOS)
    if alpha < 1.0:
        im.putalpha(im.split()[3].point(lambda v: int(v * alpha)))
    c.alpha_composite(im, (int(round(x - yox * s)), int(round(y - yoy * sy))))


def text(c, xy, s, sz=16, color=(0, 0, 0), anchor="lt", lh=None):
    d = ImageDraw.Draw(c)
    lh = lh or int(round(sz * 1.42))
    for i, line in enumerate(str(s).split("\n")):
        if line:
            d.text((xy[0], xy[1] + i * lh), line, font=F(sz), fill=color, anchor=anchor)


def rrect(c, boxr, fill, outline=None, radius=14, width=2):
    lay = Image.new("RGBA", c.size, (0, 0, 0, 0))
    ImageDraw.Draw(lay).rounded_rectangle(boxr, radius=radius, fill=fill,
                                          outline=outline, width=width)
    c.alpha_composite(lay)


def arrow(c, p0, p1, color=ACCENT + (255,), w=4, head=17):
    d = ImageDraw.Draw(c)
    d.line([p0, p1], fill=color, width=w)
    ang = math.atan2(p1[1] - p0[1], p1[0] - p0[0])
    for da in (0.42, -0.42):
        d.line([p1, (p1[0] - head * math.cos(ang - da), p1[1] - head * math.sin(ang - da))],
               fill=color, width=w)


def badge(c, x, y, n, r=15):
    lay = Image.new("RGBA", c.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(lay)
    d.ellipse((x - r - 3, y - r - 3, x + r + 3, y + r + 3), fill=(255, 255, 255, 242))
    d.ellipse((x - r, y - r, x + r, y + r), fill=ACCENT + (255,))
    d.text((x, y - 1), str(n), font=F(19), fill=(30, 24, 8), anchor="mm")
    c.alpha_composite(lay)


def red_dot(c, cx, cy, r=11):
    lay = Image.new("RGBA", c.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(lay)
    d.ellipse((cx - r - 3.5, cy - r - 3.5, cx + r + 3.5, cy + r + 3.5), fill=(255, 255, 255, 255))
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(228, 42, 34, 255))
    d.ellipse((cx - r * .62, cy - r * .74, cx - r * .08, cy - r * .2), fill=(255, 172, 162, 215))
    c.alpha_composite(lay)


def legend(c, items, title, sz=19):
    """底部图例：标题 + 两行编号说明"""
    d = ImageDraw.Draw(c)
    lay = Image.new("RGBA", c.size, (0, 0, 0, 0))
    ImageDraw.Draw(lay).rectangle((0, LEGEND_TOP - 18, W, H), fill=(11, 14, 24, 246))
    ImageDraw.Draw(lay).line([(0, LEGEND_TOP - 18), (W, LEGEND_TOP - 18)], fill=(56, 72, 100, 255), width=2)
    c.alpha_composite(lay)
    d.text((56, LEGEND_TOP + 14), title, font=F(23), fill=(255, 255, 255), anchor="lt")
    half = 2 if len(items) <= 3 else 2
    rows = [items[:half], items[half:]]
    ry = LEGEND_TOP + 58
    for row in rows:
        x = 60
        for n, s in row:
            d.ellipse((x, ry - 11, x + 22, ry + 11), fill=ACCENT + (255,))
            d.text((x + 11, ry - 1), str(n), font=F(14), fill=(30, 24, 8), anchor="mm")
            d.text((x + 32, ry), s, font=F(sz), fill=(226, 234, 246), anchor="lm")
            x += 32 + d.textlength(s, font=F(sz)) + 52
        ry += 42


def finish(scene, name, items, title):
    """把 1:1 的游戏画面缩放贴到画布上方，底部补图例。"""
    out = Image.new("RGBA", (W, H), (8, 10, 18, 255))
    sw, sh = int(SCENE[0] * SCENE_S), int(SCENE[1] * SCENE_S)
    out.alpha_composite(scene.resize((sw, sh), Image.LANCZOS),
                        (int(SCENE_POS[0] - sw / 2), int(SCENE_POS[1] - sh / 2)))
    legend(out, items, title)
    out.convert("RGB").save(os.path.join(OUT, name))
    print("ok", name)


def map_bg(c, dark=0.5):
    put(c, "spr_delicious_islands", 0, 960, 540, 1.0)
    c.alpha_composite(Image.new("RGBA", c.size, (0, 0, 0, int(255 * dark))))


# ══════════════════════════════════ 图 1：任务看板新增「卡片情报」页签
def fig_taskboard():
    c = Image.new("RGBA", SCENE, (0,0,0,0))
    map_bg(c, 0.58)
    put(c, "spr_task_bg", 0, 960, 540, 0.9)

    for label, ty, frame in [("主线任务", 250, 0), ("支线任务", 305, 0),
                             ("挑战任务", 360, 0), ("卡片情报", 415, 2)]:
        put(c, "spr_task_select_btn", frame, 560, ty, 1.8)
        text(c, (312, ty), label, 17, (255, 255, 255), "lm")

    rows = [("查看【泡椒春笋】的情报", "completed"),
            ("查看【金枪鱼海星】的情报", "completed"),
            ("查看【桥头米线】的情报", "completed"),
            ("查看【炎焱兔】的情报", "viewed"),
            ("查看【巫蛊蛇】的情报", "viewed"),
            ("查看【灯影花糕】的情报", "new"),
            ("查看【星星兔】的情报", "new")]
    for i, (t, st) in enumerate(rows):
        ly = 470 + 52 * i
        put(c, "spr_task_line_bg", 1 if i == 0 else 0, 560, ly, 1.8)
        text(c, (360, ly), t, 16, (255, 255, 255), "lm")
        put(c, "spr_task_state", STATE_FRAME[st], 785, ly, 1.8)
        put(c, "spr_task_split", 0, 560, ly + 14, 1.8)

    text(c, (1260, 190), "查看【泡椒春笋】的情报", 18, (0, 0, 0), "mm")
    text(c, (910, 232), "情报岛已经收录了这张卡，去把它翻出来看一眼。", 16, (0, 0, 0), "lt")
    text(c, (910, 505), "在情报岛查看「泡椒春笋」的情报（1/1）", 16, (0, 0, 0), "lt")
    put(c, "spr_coin", 0, 924, 735, 0.2)
    text(c, (944, 735), "金币（5000）", 16, (0, 0, 0), "lm")
    put(c, "spr_task_claim_btn", 1, 1260, 940, 1.8)
    put(c, "spr_closemenu_btn", 0, 1640, 90, 1.8)

    badge(c, 848, 402, 1)
    badge(c, 858, 522, 2)
    badge(c, 1246, 692, 3)
    badge(c, 1246, 908, 4)
    finish(c, "01_taskboard.png", [
        (1, "原 3 个页签之后新增「卡片情报」，只列卡片情报类任务"),
        (2, "行尾状态直接复用 spr_task_state：新 / 进行中 / 完成"),
        (3, "奖励固定 5000 金币，文案走源码既有「金币（N）」格式"),
        (4, "领取按钮沿用 spr_task_claim_btn，disabled 时换 _disabled 图"),
    ], "任务看板 · 新增第 4 个页签「卡片情报」")


# ══════════════════════════════════ 图 2：主界面双红点
def fig_menu_reddot():
    c = Image.new("RGBA", SCENE, (0,0,0,0))
    map_bg(c, 0.10)
    MX, MY = 1710, 1079
    put(c, "spr_player_menu_bg", 0, MX, MY, 0.9)
    put(c, "spr_player_menu_bg_ex", 0, MX - 2, MY - 0.8, 0.9)

    for name, bx, by, s in [("spr_info_btn", MX - 470, MY - 10, 0.4),
                            ("spr_task_btn", MX - 370, MY - 5, 0.9),
                            ("spr_craft_btn", MX - 290, MY - 5, 0.9),
                            ("spr_cookbook_btn", MX - 207, MY - 5, 0.9),
                            ("spr_shop_btn", MX - 127, MY - 5, 0.9),
                            ("spr_package_btn", MX - 45, MY - 5, 0.9),
                            ("spr_quit_btn", MX + 35, MY - 5, 0.9)]:
        put(c, name, 0, bx, by, s)

    # 任务按钮 yy 76x110 org(38,110) @0.9 → 68.4x99，顶边 y=975，右缘 x=1374
    tx, ty = MX - 370, MY - 5
    # 背包按钮 yy 78x108 org(38,108) @0.9 → 70.2x97.2，顶边 y=976.8
    px, py = MX - 45, MY - 5
    # 圆角图标右上沿：图标可见区 local 右上角约 (68,26)/(70,24)，红点压在边缘上
    red_dot(c, tx - 38 * 0.9 + 68 * 0.9, ty - 110 * 0.9 + 26 * 0.9, r=10)
    red_dot(c, px - 38 * 0.9 + 70 * 0.9, py - 108 * 0.9 + 24 * 0.9, r=10)

    badge(c, 1430, 936, 1)
    badge(c, 1806, 936, 2)
    arrow(c, (1430, 952), (1374, 984), ACCENT + (255,), 3)
    arrow(c, (1806, 952), (1700, 986), ACCENT + (255,), 3)
    finish(c, "02_red_dot.png", [
        (1, "任务栏红点：存在 state=new 的卡片情报任务"),
        (2, "背包红点：有已解锁、但还没在情报岛看过的卡"),
        (3, "两处同源 task_red_dot()，不新增存档字段，全部领完自动熄灭"),
        (4, "画在 obj_player_menu_bg/Draw_0，白描边+红圆 r=11，随按钮走"),
    ], "主界面 · 任务栏与背包双红点")


# ══════════════════════════════════ 图 3：情报岛点卡即完成
def fig_info_island():
    c = Image.new("RGBA", SCENE, (0,0,0,0))
    map_bg(c, 0.62)
    put(c, "spr_info_island_bg_1", 0, 530, 540, 0.45)
    put(c, "spr_info_island_bg_2", 0, 1380, 540, 1.8)
    for i in range(3):
        put(c, f"spr_info_island_select_btn_{i+1}", 1 if i == 0 else 0, 250 + 260 * i, 85, 1.8)

    cards = [("spr_chunsun_icon", "泡椒春笋"), ("spr_mixian", "桥头米线"),
             ("spr_yanyantu", "炎焱兔"), ("spr_wugushe", "巫蛊蛇"),
             ("spr_huagao", "灯影花糕"), ("spr_starrabbit", "星星兔"),
             ("spr_kuileima", "傀儡马"), ("spr_fushengcha", "浮生茶")]
    for idx, (sprn, cname) in enumerate(cards):
        j, i = idx % 4, idx // 4
        cx, cy = 226 + j * 192, 277 + 213 * i
        put(c, "spr_info_island_info_bg", 1 if idx == 0 else 0, cx, cy, 0.75)
        put(c, "spr_slot", 0, cx, cy - 3, 0.30)
        put(c, sprn, 0, cx, cy + 15, 0.8)
        text(c, (cx, cy + 87), cname, 14, (255, 255, 255), "mm")

    put(c, "spr_info_island_select_box", 0, 226, 277, 1.0, alpha=0.5)
    tp = (248, 350)
    lay = Image.new("RGBA", c.size, (0, 0, 0, 0))
    ImageDraw.Draw(lay).rectangle((tp[0] - 5, tp[1] - 5, tp[0] + 150, tp[1] + 30), fill=(0, 0, 0, 178))
    c.alpha_composite(lay)
    text(c, tp, "点击查看情报", 16, (255, 255, 255), "lt")

    put(c, "spr_chunsun_icon", 0, 1060, 330, 1.5)
    text(c, (1020, 190), "当前查看数值：星级：5，转职：0，技能：3", 16, (255, 255, 255), "lt")
    text(c, (1060, 350), "泡椒春笋", 19, (255, 255, 255), "mm")
    text(c, (1180, 250), "攻击力：500\n生命值：50\n能量消耗：210", 16, (255, 255, 255), "lt")
    text(c, (1380, 250), "攻击间隔：7.0 秒\n冷却时间：7.0 秒\n火苗产量：0", 16, (255, 255, 255), "lt")
    for k, (line, col) in enumerate([
            ("泡椒春笋：准备一段时间后长出穿刺老鼠的春笋，", (255, 255, 255)),
            ("攻击范围内陆、地鼠军", (255, 255, 255)),
            ("", (255, 255, 255)),
            ("准备时间", (255, 255, 255)),
            ("6.5", (255, 215, 107))]):
        text(c, (990, 440 + 30 * k), line, 16, col, "lt")

    t = "任务完成：查看【泡椒春笋】的情报 —— 5000 金币已可在任务看板领取"
    d = ImageDraw.Draw(c)
    tw = d.textlength(t, font=F(18))
    rrect(c, (960 - tw / 2 - 28, 964, 960 + tw / 2 + 28, 1014), (16, 22, 36, 242), None, 12)
    text(c, (960, 989), t, 18, (255, 222, 120), "mm")

    badge(c, 336, 398, 1)
    badge(c, 902, 989, 2)
    badge(c, 1490, 468, 3)
    finish(c, "03_info_island.png", [
        (1, "点中卡片即 Mouse_53 —— 全工程唯一的「看过」判定点"),
        (2, "命中瞬间置 state=completed 并弹提示，任务栏转成可领取红点"),
        (3, "右侧详情完全复用既有绘制：属性两列 + 金色数值正文"),
    ], "情报岛 · 点开卡片即完成任务")


# ══════════════════════════════════ 图 4：状态流转与改动面
def fig_flow():
    c = Image.new("RGBA", (W, H), (14, 18, 30, 255))
    lay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d0 = ImageDraw.Draw(lay)
    for gx in range(0, W, 48):
        d0.line([(gx, 0), (gx, H)], fill=(255, 255, 255, 9))
    for gy in range(0, H, 48):
        d0.line([(0, gy), (W, gy)], fill=(255, 255, 255, 9))
    c.alpha_composite(lay)

    d = ImageDraw.Draw(c)
    d.text((960, 84), "卡片情报任务 · 状态流转与改动面", font=F(40), fill=(255, 255, 255), anchor="mm")
    d.text((960, 138), "全部逻辑收口在 unlock_card() 与 Mouse_53 两点，不新增存档字段", font=F(20),
           fill=(150, 168, 196), anchor="mm")

    BW, BH = 306, 136
    nodes = [(310, 300, "unlock_card()", "卡解锁瞬间\n注册任务 + unlock_task", (86, 150, 240)),
             (770, 300, "state = new", "进列表\n任务栏 + 背包同时红点", (232, 120, 60)),
             (1230, 300, "state = completed", "情报岛点卡\nMouse_53 置完成", (60, 180, 110)),
             (1620, 560, "state = claimed", "点「领取奖励」\n金币 +5000", (150, 110, 210))]
    for x, y, title, sub, col in nodes:
        rrect(c, (x - BW / 2, y - BH / 2, x + BW / 2, y + BH / 2), col + (46,), col + (255,), 14, 3)
        text(c, (x, y - 34), title, 25, (255, 255, 255), "mm")
        text(c, (x, y + 24), sub, 18, (198, 212, 234), "mm")

    arrow(c, (310 + BW / 2 + 8, 300), (770 - BW / 2 - 8, 300), ACCENT + (255,), 4)
    arrow(c, (770 + BW / 2 + 8, 300), (1230 - BW / 2 - 8, 300), ACCENT + (255,), 4)
    arrow(c, (1230 + BW / 2 + 4, 320), (1560, 500), ACCENT + (255,), 4)
    text(c, (540, 262), "① 每张新卡发一次", 18, ACCENT, "mm")
    text(c, (1000, 262), "② 双红点亮起", 18, ACCENT, "mm")
    text(c, (1450, 400), "③ 领奖后熄灭", 18, ACCENT, "mm")

    rrect(c, (150, 540, 1010, 830), (22, 28, 44, 240), (70, 92, 130, 255), 14, 2)
    text(c, (186, 574), "task_red_dot() 判定口径", 24, (255, 255, 255), "lt")
    for k, line in enumerate([
            "扫 save_data.tasks 中 id 以 info_view_ 开头的条目：",
            "   state=new        → 任务栏红点 + 背包红点（还没看过）",
            "   state=completed  → 任务栏红点（5000 金币待领）",
            "   state=claimed    → 不计入",
            "背包红点另并入：已解锁但没生成过情报任务的卡",
            "O(n) 扫描，仅面板可见的帧计算，结果缓存一帧",
    ]):
        text(c, (186, 620 + 30 * k), line, 18,
             (255, 255, 255) if k == 0 else (206, 220, 240), "lt")

    rrect(c, (1040, 660, 1820, 900), (22, 28, 44, 240), (70, 92, 130, 255), 14, 2)
    text(c, (1076, 692), "改动面：6 个文件（核心 4 个），约 110 行", 23, (255, 255, 255), "lt")
    for k, line in enumerate([
            "scripts/task_edit/task_edit.gml     card_info_task_* 函数族",
            "scripts/edit_file/edit_file.gml     unlock_card() 内挂钩",
            "objects/obj_info_island_bg/Mouse_53.gml   置 completed",
            "objects/obj_player_menu_bg/Draw_0.gml    绘制双红点",
            "objects/obj_task_bg/Create_0.gml   第 4 页签 + 过滤",
            "objects/obj_game_init/Other_2.gml  启动恢复 / 补发",
    ]):
        text(c, (1076, 736 + 26 * k), "· " + line, 17, (206, 220, 240), "lt")

    text(c, (960, 1000), "旧存档兼容：首次进入时为所有「已解锁且未做过」的卡批量补发任务，state 直接给 new",
         19, (255, 214, 120), "mm")
    c.convert("RGB").save(os.path.join(OUT, "04_flow.png"))
    print("ok 04_flow.png")


if __name__ == "__main__":
    fig_taskboard()
    fig_menu_reddot()
    fig_info_island()
    fig_flow()
