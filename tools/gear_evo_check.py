#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""神器 / 宝石进化链静态自检（对应 GML 里的 mod_gear_evo_selfcheck()）。

为什么要有这个脚本：链表的唯一事实源是 scripts/mod_craft_evo_table/mod_craft_evo_table.gml，
改路线时如果写错 id（拼错、写成未注册的装备、同一条链里重复），游戏里只会表现成
「右侧列表里少一件」或「按钮永远置灰」，很难看出根因。这个脚本在编辑机上直接查表。

检查项：
  1. 链上每个 id 是否真的 register_weapon / register_gem 过；
  2. 同一目标是否被两条链指向（落账会互相覆盖凭证）；
  3. 链内是否有重复 id（自己进化自己）；
  4. 是否与金卡进化的凭证 id（evo_credit_<card_id>）撞车；
  5. 步数统计（神器 N 步 / 宝石 M 步），便于和文档对齐。

用法：
    python tools/gear_evo_check.py
退出码 0 = 全绿，1 = 有错。
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TABLE = ROOT / "scripts" / "mod_craft_evo_table" / "mod_craft_evo_table.gml"


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8-sig", errors="replace")


def parse_chains(text: str, key: str):
    """从 mod_gear_evo_defs() 里抠出 key: [ [...], [...] ] 的每条链。"""
    m = re.search(rf"\b{key}\s*:\s*\[", text)
    if not m:
        raise SystemExit(f"找不到 {key}: 段，脚本结构与 GML 不匹配")
    i = m.end() - 1
    depth = 0
    end = i
    for j in range(i, len(text)):
        if text[j] == "[":
            depth += 1
        elif text[j] == "]":
            depth -= 1
            if depth == 0:
                end = j
                break
    body = text[i + 1:end]
    chains = []
    for line in body.splitlines():
        # 整行注释（谱系里留位未实装的链就是这么写的）直接跳过
        if re.match(r"\s*//", line):
            continue
        line = re.sub(r"//.*$", "", line)
        ids = re.findall(r'"([^"]+)"', line)
        if ids:
            chains.append(ids)
    return chains


def collect_registered(pattern: str) -> set:
    names = set()
    for p in list(ROOT.glob("scripts/**/*.gml")) + list(ROOT.glob("objects/**/*.gml")):
        try:
            t = read(p)
        except OSError:
            continue
        names.update(re.findall(pattern, t))
    return names


def main() -> int:
    text = read(TABLE)
    weapons = parse_chains(text, "weapon")
    gems = parse_chains(text, "gem")

    reg_w = collect_registered(r'register_weapon\(\s*"([^"]+)"')
    reg_g = collect_registered(r'register_gem\(\s*"([^"]+)"')

    # 金卡进化的凭证：mod_evo_credit_id(id) = "evo_credit_" + id，目标都是卡 id
    card_ids = set(re.findall(r'evo_credit_" \+ string\(', text))  # 占位，真正的卡凭证集合下面用表里的 mod_evo 链取
    card_steps = re.findall(r'"([a-z0-9_]+)"\s*,\s*"([a-z0-9_]+)"\s*,\s*"([a-z0-9_]+)"', text)
    card_targets = {t for trip in card_steps for t in trip} - set(sum(weapons, [])) - set(sum(gems, []))

    errors = []
    steps = 0
    seen_to = {}

    for kind, chains, reg in (("weapon", weapons, reg_w), ("gem", gems, reg_g)):
        for ci, ch in enumerate(chains):
            tag = f"{kind}#{ci + 1} ({' -> '.join(ch)})"
            if len(ch) < 2:
                errors.append(f"{tag}: 链太短，至少要 2 个 id")
                continue
            for x in ch:
                if x not in reg:
                    errors.append(f"{tag}: 未注册的 {kind} `{x}`（register_{kind} 里找不到）")
            if len(set(ch)) != len(ch):
                errors.append(f"{tag}: 链内重复 id")
            for to in ch[1:]:
                if to in seen_to:
                    errors.append(f"{tag}: 目标 `{to}` 已被 {seen_to[to]} 占用（凭证会互相覆盖）")
                else:
                    seen_to[to] = tag
                if to in card_targets:
                    errors.append(f"{tag}: 目标 `{to}` 与金卡进化凭证同名，evo_credit_ 前缀撞车")
                steps += 1

    n_w = sum(len(c) - 1 for c in weapons)
    n_g = sum(len(c) - 1 for c in gems)
    print(f"神器链 {len(weapons)} 条 / {n_w} 步；宝石链 {len(gems)} 条 / {n_g} 步；合计 {steps} 步")
    print(f"已注册武器 {len(reg_w)} 件 / 宝石 {len(reg_g)} 颗")

    # ── 凭证售价：按**进化档位**（25 / 50 / 75），不是按登记顺序每张 +25 ──
    #    2026-11-16 用户纠正：三个档位最贵 75，别改回 25 * (序号)
    shop = ROOT / "scripts" / "gods_shop_init" / "gods_shop_init.gml"
    shop_txt = read(shop) if shop.exists() else ""
    if "25 * (_tier + 1)" not in text:
        errors.append("mod_craft_evo_table 里找不到档位售价 `25 * (_tier + 1)`（又被改回按序号 +25 了？）")
    if "gods_shop_register_gear_evo()" not in shop_txt:
        errors.append("gods_shop_init 没有调用 gods_shop_register_gear_evo()，凭证不会上架")
    if "mod_gear_evo_credit_price" not in shop_txt:
        errors.append("gods_shop_init 的售价没走 mod_gear_evo_credit_price()（会与登记表脱钩）")
    print(f"商店售价：按档位 25 / 50 / 75（{steps} 张凭证，最贵 75）")

    # ── 跨服商店：进化后的武器 / 宝石必须下架（打标 + 列表过滤两处都要在）──
    cross = ROOT / "scripts" / "cross_server_shop_init" / "cross_server_shop_init.gml"
    cross_txt = read(cross) if cross.exists() else ""
    if "cross_server_hidden" not in cross_txt:
        errors.append("cross_server_shop_init 没给进化后的装备打 cross_server_hidden（跨服会照卖成品）")
    csshop = ROOT / "objects" / "obj_cross_server_shop" / "Create_0.gml"
    if csshop.exists() and "cross_server_hidden" not in read(csshop):
        errors.append("obj_cross_server_shop/Create_0 没过滤 cross_server_hidden（打标了也不生效）")

    if errors:
        print("\nFAIL")
        for e in errors:
            print("  ✗", e)
        return 1
    print("\nOK  链上 id 全部已注册，无重复目标、无凭证撞车")
    return 0


if __name__ == "__main__":
    sys.exit(main())
