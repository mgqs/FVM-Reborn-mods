# -*- coding: utf-8 -*-
"""灼热地域（跨服·灼热地狱）8~15 星关卡 JSON 生成器

数据来源：
  · 怪物类型 —— 用户 2026-11-05 提供的《灼热地狱》总表
  · BOSS / 波次 / 血量 —— 用户表格（8 星炼狱之始 … 15 星炼狱之末）
  · 首通 / 重复奖励 —— 用户两张奖励表（写进 cross_server_reward，不在 JSON 里）
  · 出怪数量 —— 参考古堡前两关（castle-0 每批 5 只、castle-1 每批 6 只，2 波 × 10 批）

用法：
    python tools/zhuore_levels_build.py          # 生成 datafiles/level_data/cross/zhuore-*.json
    python tools/zhuore_levels_build.py --check   # 只校验已生成的文件
"""
import io
import json
import os
import random
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "datafiles", "level_data", "cross")

PREFIX = "zhuore_"
MAP_SPRITE = "spr_zhuorediyu"
# 底图 1114x600 × 1.8 = 2005x1080，与古堡底图同尺寸；
# (2,36) 是按底图格子实测反推的，能让 695/228/107/116 的网格压在原画格子上（误差 <2px）
BG_DRAW = {"x": 2, "y": 36, "sx": 1.8, "sy": 1.8}

TIME_LIMIT = 300
STARTING_FLAME = 3000
FIRST_WAVE_DELAY = 11
MIN_WAVE_TIME = 240
MAX_WAVE_TIME = 300

# ---------------------------------------------------------------------------
# 敌人表：id -> (中文名, 血量档)   档位按总表体力列分，用于控制出场节奏
# ---------------------------------------------------------------------------
ENEMY = {
    # 1 档：< 400
    "infected_normal_mouse":        ("平民僵尸鼠", 1),
    "kf_zr_mole":                   ("僵尸鼹鼠", 1),
    "kuafu_hopper":                 ("变异跳跳僵尸鼠", 1),
    # 2 档：500 ~ 1000
    "infected_kangaroo":            ("跳跳僵尸鼠", 2),
    "kf_zr_flower":                 ("捧花僵尸鼠", 2),
    "kf_zr_penguin":                ("企鹅僵尸鼠", 2),
    "infected_football_fan_mouse":  ("球迷僵尸鼠", 2),
    "infected_skateboard_mouse":    ("滑板僵尸鼠", 2),
    "kuafu_bat":                    ("蝙蝠僵尸鼠", 2),
    "kuafu_gift":                   ("多宝太郎僵尸鼠", 2),
    "kf_zr_dentist":                ("牙医僵尸鼠", 2),
    "kf_zr_ghost":                  ("神风幽灵鼠", 2),
    # 3 档：1100 ~ 3000
    "kf_zr_arson":                  ("纵火僵尸鼠", 3),
    "kuafu_rambo":                  ("兰博僵尸鼠", 3),
    "kf_zr_nonmain":                ("非主流僵尸鼠", 3),
    "kf_zr_magician":               ("魔术师僵尸鼠", 3),
    "infected_iron_pan_mouse":      ("铁锅僵尸鼠", 3),
    "kf_zr_can":                    ("罐头僵尸鼠", 3),
    "kuafu_landlady":               ("变异房东僵尸鼠", 3),
    "kuafu_flute":                  ("魔笛僵尸鼠", 3),
    "kf_zr_warrior":                ("武士僵尸鼠", 3),
    "kf_zr_garbage":                ("垃圾车僵尸鼠", 3),
    "infected_roller_skating_mouse": ("轮滑僵尸鼠", 3),
    "kuafu_pirate":                 ("加勒比僵尸鼠", 3),
    # 4 档：3500 ~ 10500
    "kuafu_soar":                   ("腾空僵尸鼠", 4),
    "kuafu_panda":                  ("变异熊猫僵尸鼠", 4),
    "kf_zr_sawblade":               ("锯刀狂僵尸鼠", 4),
    "kf_zr_naruto":                 ("火影忍者僵尸鼠", 4),
    "kuafu_wrestler":               ("摔跤手僵尸鼠", 4),
    "kuafu_jet":                    ("喷气僵尸鼠", 4),
    # 5 档：精英
    "kuafu_armour":                 ("特种装甲僵尸鼠", 5),
}

# 《灼热地狱》总表「体力」列，只用于生成后校验难度曲线（不参与出怪逻辑）
ENEMY_HP = {
    "infected_normal_mouse": 360, "kf_zr_mole": 360, "kuafu_hopper": 370,
    "infected_kangaroo": 540, "kf_zr_flower": 600, "kf_zr_penguin": 600,
    "infected_football_fan_mouse": 720, "infected_skateboard_mouse": 720,
    "kuafu_bat": 880, "kuafu_gift": 900, "kf_zr_dentist": 960, "kf_zr_ghost": 1000,
    "kf_zr_arson": 1100, "kuafu_rambo": 1100, "kf_zr_nonmain": 1200,
    "kf_zr_magician": 1600, "infected_iron_pan_mouse": 1800, "kf_zr_can": 1800,
    "kuafu_flute": 1800, "kuafu_landlady": 2360, "kf_zr_warrior": 2100,
    "kf_zr_garbage": 2500, "infected_roller_skating_mouse": 3000, "kuafu_pirate": 3000,
    "kuafu_soar": 3500, "kuafu_panda": 3600, "kf_zr_sawblade": 3600,
    "kf_zr_naruto": 3600, "kuafu_wrestler": 8100, "kuafu_jet": 10500,
    "kuafu_armour": 43200,
}

# BOSS 对象 Create_0 里的 hp（倍数 = 目标血量 / 这个值）
BOSS_BASE = {
    "infected_fire_residue": 12000,   # 感染火渣
    "infected_arno":         18000,   # 变异阿诺
    "infected_mario_mouse":  20000,   # 变异洞君
    "kuafu_boss_baron":      30000,   # 变异针头男爵
    "kf_zrb_mary":           30000,   # 变异玛丽（blonde_mary 基座）
    "kf_zrb_shi":            30000,   # 变异屎者
    "kf_zrb_jack":           60000,   # 变异杰克
    "kf_zrb_vajra":          80000,   # 变异金刚
    "kf_zrb_cap":            90000,   # 变异美队
}

BOSS_CN = {
    "infected_fire_residue": "感染火渣",
    "infected_arno":         "变异阿诺",
    "infected_mario_mouse":  "变异洞君",
    "kuafu_boss_baron":      "变异针头男爵",
    "kf_zrb_mary":           "变异玛丽",
    "kf_zrb_shi":            "变异屎者",
    "kf_zrb_jack":           "变异杰克",
    "kf_zrb_vajra":          "变异金刚",
    "kf_zrb_cap":            "变异美队",
}

# ---------------------------------------------------------------------------
# 8 关配置：星级 / 章节名 / 每批数量 / 怪物池 / 两波 BOSS
#   每批数量参考古堡：castle-0 = 5、castle-1 = 6，之后每关 +1
#   这里怪物血量远高于古堡同批（43200 的装甲、10500 的喷气），所以加得慢一些
# ---------------------------------------------------------------------------
POOL_8 = ["infected_normal_mouse", "infected_football_fan_mouse",
          "infected_skateboard_mouse", "kuafu_hopper", "kf_zr_mole",
          "kf_zr_penguin", "kf_zr_flower", "infected_iron_pan_mouse"]

POOL_9 = POOL_8 + ["kf_zr_dentist", "kf_zr_arson", "kf_zr_nonmain",
                   "kuafu_gift", "kuafu_bat", "kf_zr_can",
                   "kuafu_landlady", "kf_zr_warrior"]

POOL_10 = POOL_9 + ["kf_zr_garbage", "infected_roller_skating_mouse",
                    "kf_zr_magician", "kuafu_panda", "kuafu_soar"]

POOL_11 = POOL_10 + ["kf_zr_sawblade", "kf_zr_naruto", "kuafu_rambo",
                     "kuafu_flute", "kuafu_pirate"]

POOL_12 = POOL_11 + ["kuafu_wrestler"]

POOL_14 = POOL_12 + ["kuafu_armour", "kuafu_jet"]

LEVELS = [
    dict(idx=0, star=8, title="炼狱之始", per=5, pool=POOL_8,
         waves=[("infected_fire_residue", 20000, "kf_zrb_mary", 20000),
                ("infected_arno", 20000, "kf_zrb_shi", 20000)]),
    dict(idx=1, star=9, title="炼狱之觉", per=6, pool=POOL_9,
         waves=[("kf_zrb_mary", 35000, "kf_zrb_shi", 35000),
                ("infected_mario_mouse", 35000, "kf_zrb_jack", 35000)]),
    dict(idx=2, star=10, title="炼狱之风", per=6, pool=POOL_10,
         waves=[("infected_fire_residue", 60000, "infected_fire_residue", 60000),
                ("kf_zrb_shi", 60000, "kf_zrb_shi", 60000)]),
    dict(idx=3, star=11, title="炼狱之扇", per=7, pool=POOL_11,
         waves=[("kf_zrb_jack", 125000, "kf_zrb_jack", 125000),
                ("kf_zrb_mary", 125000, "kf_zrb_mary", 125000)]),
    dict(idx=4, star=12, title="炼狱之轮", per=7, pool=POOL_12,
         waves=[("kf_zrb_shi", 259999, "kf_zrb_jack", 259999),
                ("kf_zrb_mary", 259999, "kf_zrb_vajra", 259999)]),
    dict(idx=5, star=13, title="炼狱之影", per=8, pool=POOL_12,
         waves=[("kf_zrb_shi", 400000, "kuafu_boss_baron", 400000),
                ("infected_fire_residue", 400000, "kf_zrb_cap", 400000)]),
    dict(idx=6, star=14, title="炼狱之锁", per=8, pool=POOL_14,
         waves=[("kf_zrb_cap", 640000, "kf_zrb_mary", 640000),
                ("kf_zrb_vajra", 640000, "kf_zrb_vajra", 640000)]),
    dict(idx=7, star=15, title="炼狱之末", per=9, pool=POOL_14,
         waves=[("kf_zrb_jack", 900000, "kf_zrb_mary", 900000),
                ("kf_zrb_vajra", 900000, "kf_zrb_cap", 900000)]),
]

# 每种怪在同一批里的数量上限（高级怪不许成群）
MAX_PER_KIND = {1: 99, 2: 99, 3: 5, 4: 4, 5: 1}

# 各星级的基础档位权重：决定这一关"主要由什么强度的怪组成"
TIER_WEIGHTS = {
    8:  {1: 40, 2: 40, 3: 8,  4: 0,  5: 0},
    9:  {1: 32, 2: 40, 3: 20, 4: 0,  5: 0},
    10: {1: 18, 2: 38, 3: 34, 4: 10, 5: 0},
    11: {1: 10, 2: 32, 3: 40, 4: 18, 5: 0},
    12: {1: 3,  2: 20, 3: 43, 4: 34, 5: 0},
    13: {1: 4,  2: 18, 3: 42, 4: 34, 5: 2},
    14: {1: 1,  2: 11, 3: 37, 4: 45, 5: 7},
    15: {1: 0,  2: 5,  3: 32, 4: 57, 5: 9},
}


def tier_of(eid):
    return ENEMY[eid][1]


def tier_counts(pool):
    c = {}
    for e in pool:
        c[tier_of(e)] = c.get(tier_of(e), 0) + 1
    return c


def batch_weight(eid, level_tier, counts, progress):
    """progress: 0（波首）~ 1（波尾），越高越放得开高级怪。

    档位权重先按「该档在池子里的种类数」均摊，否则同档里只有 1 种怪
    （比如 5 档只有特种装甲）会被同档其他怪彻底稀释掉，永远抽不到。
    """
    t = tier_of(eid)
    w = float(level_tier.get(t, 0))
    n = counts.get(t, 0)
    if w <= 0 or n == 0:
        return 0.0
    w /= n
    if t <= 2:
        w *= 1.35 - 0.55 * progress      # 低档越往后越少
    else:
        w *= 0.45 + 1.15 * progress      # 高档越往后越多
    if t == 5 and progress < 0.4:
        return 0.0                        # 精英怪只在中后段露面
    return w


def pick_kinds(rng, pool, k, weights):
    cand = [(e, weights[e]) for e in pool if weights.get(e, 0) > 0]
    picked = []
    for _ in range(k):
        rest = [(e, w) for e, w in cand if e not in picked]
        total = sum(w for _, w in rest)
        if total <= 0:
            break
        r = rng.uniform(0, total)
        acc = 0.0
        for e, w in rest:
            acc += w
            if acc >= r:
                picked.append(e)
                break
    return picked


def make_batch(rng, pool, per, level_tier, counts, progress):
    weights = {e: batch_weight(e, level_tier, counts, progress) for e in pool}
    # 每批 2~3 种（古堡也是 3 种混着来），太少会让整批变成同一个怪
    kinds = 3 if per >= 4 and sum(1 for w in weights.values() if w > 0) >= 3 else 2
    picked = pick_kinds(rng, pool, kinds, weights)
    if not picked:
        picked = [rng.choice(pool)]

    counts = {e: 1 for e in picked}
    left = per - len(picked)
    j = 0
    # 兜底用：池子里没有上限的杂兵，高级怪占满后往这里塞，避免死循环
    fillers = [e for e in pool if tier_of(e) <= 2]
    while left > 0:
        e = picked[j % len(picked)]
        j += 1
        if counts[e] < MAX_PER_KIND[tier_of(e)]:
            counts[e] += 1
            left -= 1
            continue
        # 当前这种已经到上限：换下一种；全满了就塞杂兵
        if all(counts[x] >= MAX_PER_KIND[tier_of(x)] for x in picked):
            f = rng.choice(fillers) if fillers else picked[0]
            counts[f] = counts.get(f, 0) + 1
            left -= 1
    return counts


def build_waves(cfg):
    rng = random.Random(20261105 + cfg["idx"] * 977)
    lw = TIER_WEIGHTS[cfg["star"]]
    counts = tier_counts(cfg["pool"])
    waves = []
    for wi, (b1, hp1, b2, hp2) in enumerate(cfg["waves"]):
        subwaves = []
        for i in range(10):
            # 第二波视为延续，进度整体后移
            progress = min(1.0, (i + wi * 3) / 10.0)
            picked_counts = make_batch(rng, cfg["pool"], cfg["per"], lw, counts, progress)
            lst = []
            for eid, n in picked_counts.items():
                for _ in range(n):
                    lst.append({"row": -1, "prosperity": 0, "type": eid})
            rng.shuffle(lst)
            subwaves.append({"subwave_index": 0, "enemy_list": lst})
        waves.append({
            "boss_wave": True,
            "wave_index": wi + 1,
            "boss": b1,
            "boss_1_hp_modify": round(hp1 / BOSS_BASE[b1], 6),
            "boss2": b2,
            "boss_2_hp_modify": round(hp2 / BOSS_BASE[b2], 6),
            "subwaves": subwaves,
        })
    return waves


# 底图 spr_zhuorediyu 上「有格子」的位置（按 bg_draw 反算格心，逐格取 32×32 采样检测，
# 检测率非 0 即 100%，无中间值）。"#" = 有地块可放置，"." = 岩浆空洞。
# 只是默认值：用户要自己排 map 时直接改 type/plant 即可。
MAP_LAYOUT = [
    "#..###..#",
    "#..##...#",
    "##....###",
    "###...###",
    "###....##",
    "#...##..#",
    "#..###..#",
]


def make_map():
    """默认地图：底图上有地块的地方 normal，空洞填 water（不可放置普通卡片）。"""
    out = []
    for line in MAP_LAYOUT:
        row = []
        for ch in line:
            row.append({"type": "normal" if ch == "#" else "water",
                        "plant": [], "object": []})
        out.append(row)
    return out


def build_level(cfg):
    return {
        "version": 1.2,
        "level_name": "%s%d" % (PREFIX, cfg["idx"]),
        "level_time_feature": "night",
        "map_sprite": MAP_SPRITE,
        "bg_draw": dict(BG_DRAW),
        "time_limit": TIME_LIMIT,
        "map_cols": 9,
        "map_rows": 7,
        "starting_flame": STARTING_FLAME,
        "first_wave_delay": FIRST_WAVE_DELAY,
        "total_waves": len(cfg["waves"]),
        "elite_wave": 1,
        "boss_wave": 1,
        "map": make_map(),
        "waves": build_waves(cfg),
        "rewards": [{"gold": 0, "items": []},
                    {"gold": 0, "player_level": 2, "skill_level": 1, "items": [],
                     "gem_unlock": [], "card_unlock": [], "weapon_unlock": []}],
        "hp_modify": 1,
        "min_wave_time": MIN_WAVE_TIME,
        "max_wave_time": MAX_WAVE_TIME,
    }


def registered_ids():
    """从 gml 里抓已经 register_enemy 过的 id，用来保证关卡不会引用不存在的敌人。"""
    ids = set()
    for fn in ("scripts/enemy_init/enemy_init.gml",
               "scripts/mod_enemy_init/mod_enemy_init.gml",
               "scripts/zhuore_enemy_init/zhuore_enemy_init.gml",
               "scripts/zhuore_boss_init/zhuore_boss_init.gml"):
        p = os.path.join(ROOT, fn)
        if not os.path.isfile(p):
            continue
        t = io.open(p, encoding="utf-8-sig").read()
        ids |= set(re.findall(r'register_enemy\(\s*"([^"]+)"', t))
    return ids


def check(files=None):
    ok = True
    reg = registered_ids()
    print("已注册敌人 id：%d 个" % len(reg))
    names = sorted(f for f in os.listdir(OUT_DIR) if f.startswith(PREFIX))
    if files:
        names = [n for n in names if n in files]
    prev_hp = -1
    for fn in names:
        p = os.path.join(OUT_DIR, fn)
        d = json.loads(io.open(p, encoding="utf-8-sig").read().rstrip("\x00"))
        cfg = [c for c in LEVELS if "%s%d.json" % (PREFIX, c["idx"]) == fn]
        cfg = cfg[0] if cfg else None
        dup = []
        hp_sum = 0
        for wi, w in enumerate(d["waves"]):
            for k in ("boss", "boss2"):
                if w[k] not in reg:
                    dup.append("%s 未注册" % w[k])
            if cfg:
                (b1, h1, b2, h2) = cfg["waves"][wi]
                got1 = BOSS_BASE[b1] * w["boss_1_hp_modify"]
                got2 = BOSS_BASE[b2] * w["boss_2_hp_modify"]
                if w["boss"] != b1 or w["boss2"] != b2:
                    dup.append("第%d波 BOSS 顺序不对" % (wi + 1))
                if abs(got1 - h1) > 1.5:
                    dup.append("%s 血量反算 %.0f != %d" % (b1, got1, h1))
                if abs(got2 - h2) > 1.5:
                    dup.append("%s 血量反算 %.0f != %d" % (b2, got2, h2))
            for si, sw in enumerate(w["subwaves"]):
                el = sw["enemy_list"]
                kinds = set(e["type"] for e in el)
                if cfg and len(el) != cfg["per"]:
                    dup.append("第%d波第%d批 %d 只 != %d" % (wi + 1, si + 1, len(el), cfg["per"]))
                if len(kinds) > 3:
                    dup.append("第%d波第%d批 混了 %d 种怪" % (wi + 1, si + 1, len(kinds)))
                elite = sum(1 for e in el if tier_of(e["type"]) == 5)
                if elite > 1:
                    dup.append("第%d波第%d批 精英怪 %d 只" % (wi + 1, si + 1, elite))
                for e in el:
                    if e["type"] not in reg:
                        dup.append("%s 未注册" % e["type"])
                    hp_sum += ENEMY_HP.get(e["type"], 0)
        if hp_sum < prev_hp:
            dup.append("小怪总血量 %.0f 比上一关 %.0f 低（难度倒挂）" % (hp_sum, prev_hp))
        prev_hp = hp_sum
        tot = sum(len(sw["enemy_list"]) for w in d["waves"] for sw in w["subwaves"])
        print("%-16s 波数=%d 批次=%d 敌人=%d 小怪血=%-8d %s" % (
            fn, len(d["waves"]),
            sum(len(w["subwaves"]) for w in d["waves"]), tot, hp_sum,
            "OK" if not dup else "问题: " + "; ".join(sorted(set(dup)))))
        ok = ok and not dup
    return ok


def main():
    args = sys.argv[1:]
    if "--check" in args:
        sys.exit(0 if check() else 1)

    reg = registered_ids()
    for cfg in LEVELS:
        for e in cfg["pool"]:
            if e not in ENEMY:
                raise RuntimeError("池里有未登记的怪: " + e)
            if e not in reg:
                raise RuntimeError("怪没有被 register_enemy: " + e)
        for (b1, _, b2, _) in cfg["waves"]:
            for b in (b1, b2):
                if b not in reg:
                    raise RuntimeError("BOSS 未注册: " + b)

    os.makedirs(OUT_DIR, exist_ok=True)
    for cfg in LEVELS:
        d = build_level(cfg)
        p = os.path.join(OUT_DIR, "%s%d.json" % (PREFIX, cfg["idx"]))
        txt = json.dumps(d, ensure_ascii=False, indent=4)
        io.open(p, "w", encoding="utf-8", newline="\n").write(txt)
        tot = sum(len(sw["enemy_list"]) for w in d["waves"] for sw in w["subwaves"])
        print("写出 %-28s %d星 %s  每批%d只 共%d只" % (
            os.path.basename(p), cfg["star"], cfg["title"], cfg["per"], tot))
    print()
    check()


if __name__ == "__main__":
    main()
