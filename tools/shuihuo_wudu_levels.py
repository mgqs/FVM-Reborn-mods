# -*- coding: utf-8 -*-
"""跨服·水火之间 / 巫毒研究所 —— 16 个关卡 JSON 生成器（2026-11-14，水路重设计版）

设计口径（全部照本体既有跨服章节的实测逻辑，参照 cross/castle-0..7.json）：
  1. 总敌数逐关爬升：100 / 120 / 140 / 160 / 180 / 200 / 220 / 250（与 castle、zhuore 完全一致）；
     2 波 × 10 subwave，每 subwave 均分，余数落最后几个 subwave（castle-7 即 13×10 + 12×10）。
  2. **每关独立敌种表，不累加**（castle 是 3/5/7/9/11/11/13/15 种；本生成器同量级）。
  3. 基础三鼠占绝大多数（castle-7 里普通/球迷/滑板合计 193/250 = 77%），新鼠只做少量点缀。
  4. **水路限制（本次核心）**：`global.enemy_map[? id].feature == "water"` 的鼠只能落在水行
     （obj_battle/Create_0.gml:317-386 按 feature 强行分派；无匹配行会报「没有适合water敌人的行」并挤到第 1 行）。
     因此：
       - 巫毒研究所全陆地 → 水鼠 0 只（生成时断言）；
       - 水火之间两套底图都有水行（_0 中段 3 行 / _1 上下 4 行）→ 水鼠占比 ~15%（castle 实测 12~19%），
         且按「鸭 → 纸船 → 热带鱼 → 青蛙王子 → 潜水 → 划艇 → 龙舟 → 拳皇潜艇 → 旗舰」逐关解锁。
  5. enemies 的 row 一律写 -1，交给引擎按 feature 自动选行（写死行号会踩水陆红线）。

幂等：重跑直接覆盖同路径文件；BOSS 表 / 地图 / 奖励 / 其它字段与上一版完全一致。
"""
import json
import os

OUT = os.path.join(os.path.dirname(__file__), '..', 'datafiles', 'level_data', 'cross')

CELL_L = {"object": [], "type": "normal", "plant": []}
CELL_R = {"object": ["lava"], "type": "normal", "plant": []}
CELL_W = {"object": [], "type": "water", "plant": []}


def sh_row(kind):
    # kind: 'stone' 上下石板行（左3石板+中3熔岩+右3石板） / 'water' 整行水
    if kind == 'water':
        return [dict(CELL_W) for _ in range(9)]
    row = []
    for c in range(9):
        row.append(dict(CELL_R) if 3 <= c <= 5 else dict(CELL_L))
    return row


SH_WATER_ROWS = {0: 3, 1: 3, 2: 3, 3: 3, 4: 4, 5: 4, 6: 4, 7: 4}   # _0 中段 3 行 / _1 上下 4 行


def shuihuo_map(lv):
    if lv < 4:      # _0：石板 / 水 / 石板
        rows = ['stone', 'stone', 'water', 'water', 'water', 'stone', 'stone']
    else:           # _1：水 / 石板 / 水
        rows = ['water', 'water', 'stone', 'stone', 'stone', 'water', 'water']
    return [sh_row(k) for k in rows]


def wudu_map(_lv):
    return [[dict(CELL_L) for _ in range(9)] for _ in range(7)]


REWARDS = [
    {"gold": 0, "items": []},
    {"gold": 0, "player_level": 2, "skill_level": 1, "items": [], "gem_unlock": [],
     "card_unlock": [], "weapon_unlock": []},
]

# ---------------------------------------------------------------- 编队口径
LEVEL_TOTALS = [100, 120, 140, 160, 180, 200, 220, 250]      # 与 castle / zhuore 一致

# 水火：水鼠逐关解锁（严格按强度；assault_mouse 突袭鼠 / butterfly_mouse 蝴蝶鼠 的
# register_enemy 里 feature 也是 "water"，别放进陆上序列）
SH_WATER_ORDER = ["infected_duck_mouse", "infected_paper_boat_mouse", "infected_tropical_fish_mouse",
                  "infected_frog_prince_mouse", "assault_mouse", "butterfly_mouse",
                  "infected_diver_mouse", "kf_sh_rowboat",
                  "kf_sh_dragon_boat", "kf_sh_kof_submarine", "kf_sh_flagship"]
SH_WATER_N = [1, 2, 3, 4, 5, 6, 8, 10]      # 每关启用的水鼠种数

# 水火：陆上鼠逐关解锁（基础三鼠单列）
SH_BASIC = ["infected_normal_mouse", "infected_football_fan_mouse", "infected_skateboard_mouse"]
SH_LAND_ORDER = ["infected_iron_pan_mouse", "repairman_mouse", "cucumber_normal_mouse",
                 "tangerine_skateboard_mouse", "infected_landlady_mouse",
                 "infected_roller_skating_mouse", "kf_zr_penguin",
                 "infected_giant_mouse", "lambo_mouse", "caribbean_mouse",
                 "infected_panda_mouse", "kuafu_wrestler", "special_armour_mouse"]
SH_SPECIES_TOTAL = [4, 6, 8, 10, 12, 12, 14, 16]
SH_BASIC_SHARE = [1.00, 0.92, 0.88, 0.85, 0.82, 0.80, 0.78, 0.76]

# 巫毒：全陆地，水鼠 0；基础三鼠（普通 / 地鼠 / 球迷）
WD_BASIC = ["infected_normal_mouse", "kf_zr_mole", "infected_football_fan_mouse"]
WD_LAND_ORDER = ["kf_zr_flower", "kf_zr_arson", "kf_zr_can", "infected_iron_pan_mouse",
                 "infected_skateboard_mouse", "repairman_mouse", "cucumber_normal_mouse",
                 "apple_football_fan_mouse", "tangerine_skateboard_mouse", "taro_toho_mouse",
                 "kf_zr_nonmain", "infected_landlady_mouse", "infected_roller_skating_mouse",
                 "kf_zr_magician", "kuafu_flute", "ninja_mouse", "infected_giant_mouse",
                 "lambo_mouse", "caribbean_mouse", "kf_zr_ghost", "kf_zr_dentist",
                 "kf_zr_warrior", "kuafu_soar", "kf_wd_garbage", "infected_panda_mouse",
                 "kuafu_wrestler", "special_armour_mouse"]
WD_SPECIES_TOTAL = [3, 5, 7, 9, 11, 11, 13, 15]
WD_BASIC_SHARE = [1.00, 0.92, 0.88, 0.85, 0.82, 0.80, 0.78, 0.76]

WATER_QUOTA_RATIO = 0.15      # castle 实测水鼠占比 12~19%

SH_NAMES = ["水火相遇", "水火相融", "水火相拦", "水火相斥",
            "水火相位", "水火相争", "水火相噬", "水火相灭"]
WD_NAMES = ["五毒入口", "巫毒走道", "巫毒一室", "巫毒二室",
            "巫毒回廊", "巫毒暗道", "巫毒密室", "巫毒核心"]

# ---------------------------------------------------------------- BOSS 表
# (boss_id, 目标血量) —— hp_modify 生成时按 register_boss 基础血量反算
SH_BOSSES = [
    # 8星 水火相遇
    [(("infected_bingzha", 25000), ("infected_bingzha", 25000)),
     (("infected_fire_residue", 25000), ("infected_fire_residue", 25000))],
    # 9星 水火相融
    [(("infected_bingzha", 40000), ("infected_fire_residue", 40000)),
     (("infected_arno", 40000), ("honglonglong", 40000))],
    # 10星 水火相拦
    [(("infected_bingzha", 70000), ("infected_fire_residue", 70000)),
     (("kf_zrb_shi", 70000), ("needle_baron", 70000))],
    # 11星 水火相斥
    [(("honglonglong", 135000), ("kf_zrb_mary", 135000)),
     (("infected_fire_residue", 135000), ("infected_pharaoh", 135000))],
    # 12星 水火相位
    [(("kf_zrb_jack", 280000), ("infected_pharaoh", 280000)),
     (("kuafu_boss_xiaoming", 640000), ("kf_zrb_mary", 280000))],
    # 13星 水火相争
    [(("kuafu_boss_xiaoming", 420000), ("kuafu_boss_xiaoming", 420000)),
     (("kuafu_boss_xiaoming", 420000), ("kf_sh_iron_man", 420000))],
    # 14星 水火相噬
    [(("kf_sh_iron_man", 680000), ("kf_sh_iron_man", 680000)),
     (("kf_zrb_jack", 680000), ("kuafu_boss_xiaoming", 680000))],
    # 15星 水火相灭
    [(("kuafu_boss_xiaoming", 950000), ("kuafu_boss_xiaoming", 950000)),
     (("war_god", 900000), ("kf_sh_iron_man", 950000))],
]
WD_BOSSES = [
    # 8星 五毒入口
    [(("kuafu_boss_buzz", 35000), ("kuafu_boss_buzz", 35000)),
     (("infected_pharaoh", 35000), ("infected_pharaoh", 35000))],
    # 9星 巫毒走道
    [(("kf_zrb_shi", 50000), ("kf_zrb_shi", 50000)),
     (("kuafu_boss_baron", 50000), ("kuafu_boss_baron", 50000))],
    # 10星 巫毒一室
    [(("war_god", 120000), ("kuafu_boss_julie", 85000)),
     (("war_god", 120000), ("kuafu_boss_pete", 85000))],
    # 11星 巫毒二室
    [(("war_god", 232500), ("infected_arno", 155000)),
     (("war_god", 232500), ("infected_mario_mouse", 155000))],
    # 12星 巫毒回廊
    [(("kf_zrb_mary", 305000), ("kf_zrb_mary", 305000)),
     (("kuafu_boss_xiaoming", 305000), ("kuafu_boss_xiaoming", 305000))],
    # 13星 巫毒暗道
    [(("kuafu_boss_xiaoming", 470000), ("kuafu_boss_xiaoming", 470000)),
     (("kf_sh_iron_man", 470000), ("kf_sh_iron_man", 470000))],
    # 14星 巫毒密室
    [(("kf_zrb_cap", 780000), ("kf_sh_iron_man", 780000)),
     (("kf_wd_hulk", 780000), ("kuafu_boss_xiaoming", 780000))],
    # 15星 巫毒核心
    [(("kuafu_boss_julie", 1200000), ("kuafu_boss_pete", 1200000)),
     (("kf_wd_hulk", 1200000), ("kf_wd_hulk", 1200000))],
]

BOSS_BASE_HP = {
    "infected_bingzha": 12000, "infected_fire_residue": 12000,
    "infected_arno": 18000, "honglonglong": 20000,
    "kf_zrb_shi": 30000, "needle_baron": 30000, "kf_zrb_mary": 30000,
    "infected_pharaoh": 35000, "kf_zrb_jack": 60000,
    "kuafu_boss_xiaoming": 60000, "kf_sh_iron_man": 90000,
    "war_god": 250000, "kuafu_boss_buzz": 50000, "kuafu_boss_baron": 30000,
    "kuafu_boss_julie": 50000, "kuafu_boss_pete": 40000,
    "infected_mario_mouse": 20000, "kf_zrb_cap": 90000, "kf_wd_hulk": 120000,
}


# ---------------------------------------------------------------- 编队
def subwave_sizes(total):
    """2 波 × 10 subwave 均分，余数落在最后几个 subwave（castle-7 即 13×10 + 12×10）"""
    n = 20
    base = total // n
    rem = total % n
    sizes = [base] * n
    for i in range(rem):
        sizes[n - 1 - i] += 1
    return sizes


def weighted_split(total, species, weights):
    """按权重把 total 只怪分给 species，保证每种至少 1 只、合计精确等于 total"""
    if not species:
        return {}
    need = max(total, len(species))
    wsum = float(sum(weights))
    raw = [need * w / wsum for w in weights]
    cnt = [max(1, int(round(r))) for r in raw]
    # 修正总数
    while sum(cnt) > need:
        i = cnt.index(max(cnt))
        if cnt[i] <= 1:
            break
        cnt[i] -= 1
    while sum(cnt) < need:
        cnt[cnt.index(max(cnt))] += 1
    return dict(zip(species, cnt))


def build_roster(lv, basic, land_order, species_total_list, basic_share_list,
                 water_order=None, water_n_list=None, total=None):
    """返回 {enemy_id: count}，合计 = total"""
    total = LEVEL_TOTALS[lv] if total is None else total
    n_species = species_total_list[lv]
    water_n = water_n_list[lv] if water_n_list else 0
    water = (water_order or [])[:water_n]

    water_quota = int(round(total * WATER_QUOTA_RATIO)) if water else 0
    land_quota = total - water_quota

    land_newcomers = min(n_species - len(basic) - water_n, len(land_order))
    land_newcomers = max(land_newcomers, 0)
    extras = land_order[:land_newcomers]

    counts = {}
    # 基础三鼠按权重 45/30/25 分摊 basic_share 的份额
    basic_total = int(round(land_quota * basic_share_list[lv]))
    basic_total = max(basic_total, len(basic) * 5)
    counts.update(weighted_split(basic_total, basic, [0.45, 0.30, 0.25]))

    rest = land_quota - basic_total
    if extras and rest > 0:
        # 越早解锁的杂兵数量越多（castle: 铁锅 15 → 房东 2）
        weights = [1.0 / (i + 1) ** 0.85 for i in range(len(extras))]
        counts.update(weighted_split(rest, extras, weights))
    elif rest > 0:
        counts[basic[0]] += rest

    if water and water_quota > 0:
        ww = [1.0 / (i + 1) ** 0.7 for i in range(len(water))]
        counts.update(weighted_split(water_quota, water, ww))

    # 浮点取整兜底
    diff = total - sum(counts.values())
    if diff != 0:
        k = basic[0]
        counts[k] += diff
    return counts


def build_waves(counts, bosses):
    total = sum(counts.values())
    sizes = subwave_sizes(total)

    # 轮转发牌：保证同一 subwave 里多种混编，不出现整段单一鼠
    seq = []
    remain = dict(counts)
    order = list(counts.keys())
    while sum(remain.values()) > 0:
        for k in order:
            if remain[k] > 0:
                seq.append(k)
                remain[k] -= 1

    waves, pos = [], 0
    for w in range(2):
        subwaves = []
        for s in range(10):
            n = sizes[w * 10 + s]
            picks = [{"row": -1, "prosperity": 0, "type": t} for t in seq[pos:pos + n]]
            pos += n
            subwaves.append({"subwave_index": 0, "enemy_list": picks})
        b1, b2 = bosses[w]
        m1 = round(b1[1] / BOSS_BASE_HP[b1[0]], 6)
        m2 = round(b2[1] / BOSS_BASE_HP[b2[0]], 6)
        waves.append({
            "boss_wave": True,
            "wave_index": w + 1,
            "boss": b1[0], "boss_1_hp_modify": m1,
            "boss2": b2[0], "boss_2_hp_modify": m2,
            "subwaves": subwaves,
        })
    return waves


def build_level(prefix, lv, counts, bosses, map_fn, sprite):
    d = {
        "version": 1.2,
        "level_name": "%s_%d" % (prefix, lv),
        "level_time_feature": "night",
        "map_sprite": sprite,
        "bg_draw": {"x": 2, "y": 36, "sx": 1.8, "sy": 1.8},
        "time_limit": 300,
        "map_cols": 9,
        "map_rows": 7,
        "starting_flame": 3000,
        "first_wave_delay": 11,
        "total_waves": 2,
        "elite_wave": 1,
        "boss_wave": 1,
        "map": map_fn(lv),
        "waves": build_waves(counts, bosses),
        "rewards": json.loads(json.dumps(REWARDS)),
        "hp_modify": 1,
        "min_wave_time": 240,
        "max_wave_time": 300,
    }
    path = os.path.join(OUT, "%s_%d.json" % (prefix, lv))
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(d, f, ensure_ascii=False, indent=4)
    return path


def selfcheck():
    """水路红线自检：水鼠只在水火、占比 10~20%、巫毒零水鼠、总敌数按表"""
    sh_ok = set(SH_BASIC) | set(SH_LAND_ORDER) | set(SH_WATER_ORDER)
    wd_ok = set(WD_BASIC) | set(WD_LAND_ORDER)
    n = 0
    for lv in range(8):
        sh = json.loads(open(os.path.join(OUT, "shuihuo_%d.json" % lv), encoding='utf-8').read())
        wd = json.loads(open(os.path.join(OUT, "wudu_%d.json" % lv), encoding='utf-8').read())
        for name, d, allowed, allow_water in (("shuihuo_%d" % lv, sh, sh_ok, True),
                                              ("wudu_%d" % lv, wd, wd_ok, False)):
            cnt = {}
            for w in d["waves"]:
                for sw in w["subwaves"]:
                    for e in sw["enemy_list"]:
                        cnt[e["type"]] = cnt.get(e["type"], 0) + 1
                        assert e["row"] == -1, "%s 出现写死行号" % name
                        assert e["type"] in allowed, "%s 出现清单外的鼠 %s" % (name, e["type"])
            total = sum(cnt.values())
            assert total == LEVEL_TOTALS[lv], "%s 总敌数 %d != %d" % (name, total, LEVEL_TOTALS[lv])
            water = sum(v for k, v in cnt.items() if k in SH_WATER_ORDER)
            if not allow_water:
                assert water == 0, "%s 无水行却放了水鼠 %d 只" % (name, water)
            else:
                ratio = water / float(total)
                assert 0.10 <= ratio <= 0.20, "%s 水鼠占比 %.1f%% 越界" % (name, ratio * 100)
            print("  %-11s 总%3d 敌种%2d 水鼠%2d(%2d%%)" %
                  (name, total, len(cnt), water, water * 100 // total))
            n += 1
    print("自检通过：%d 个关卡" % n)


def main():
    for lv in range(8):
        counts = build_roster(lv, SH_BASIC, SH_LAND_ORDER, SH_SPECIES_TOTAL, SH_BASIC_SHARE,
                              SH_WATER_ORDER, SH_WATER_N)
        p = build_level("shuihuo", lv, counts, SH_BOSSES[lv], shuihuo_map,
                        "spr_shuihuozhijian_%d" % (0 if lv < 4 else 1))
        print('written', os.path.relpath(p, os.path.join(os.path.dirname(__file__), '..')))
    for lv in range(8):
        counts = build_roster(lv, WD_BASIC, WD_LAND_ORDER, WD_SPECIES_TOTAL, WD_BASIC_SHARE)
        p = build_level("wudu", lv, counts, WD_BOSSES[lv], wudu_map,
                        "spr_wuduyanjiusuo_%d" % lv)
        print('written', os.path.relpath(p, os.path.join(os.path.dirname(__file__), '..')))
    selfcheck()


if __name__ == '__main__':
    main()
